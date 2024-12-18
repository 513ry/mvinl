# frozen-string-literal: true

=begin lexer.rb
Copyright (c) 2024, Daniel Sierpiński All rights reserved.

See Copyright Notice in mvnil.rb
=end

require 'strscan'

module MVinl
  class LexerError < StandardError; end
  class UnexpectedTokenError < LexerError; end

  class Lexer
    attr_reader :eos

    ID_REGEX = /[a-zA-Z_][a-zA-Z0-9_]*/
    TOKENS = {
      KEYWORD: Regexp.union(Context::RESERVED),
      OPEN_PAREN: /\(/,
      CLOSE_PAREN: /\)/,
      NEW_LINE: /(?:[ \t]*(?:\r?\n)[ \t]*)+/,
      WHITESPACE: /[ \t]/,
      KEYWORD_ARG: /(#{ID_REGEX}):/,
      ID: ID_REGEX,
      GROUP: /@(#{ID_REGEX})/,
      CONSTANT: /!([A-Z][A-Z0-9_]*)/,
      VARIABLE: /!(#{ID_REGEX})/,
      FLOAT: /[+-]?\d+\.\d+/,
      NUMBER: /[+-]?\d+/,
      MULTILINE_STRING: /"((?:\\.|[^"\\])*)"\s*\\\s*/,
      STRING: /["']((?:\\.|[^"\\])*)["']/,
      SYMBOL: /:(#{ID_REGEX})/,
      COMMENT: /#/,
      OPER: %r{[+\-*/%]},
      END_TAG: /\./
    }.freeze

    def initialize(context, input = '')
      @context = context
      @ss = StringScanner.new(input)
      @args_n = 0
      @in_group = false
      @eos = false
    end

    def feed(input)
      @ss = StringScanner.new(input)
    end

    def next_token
      return process_eos if @ss.eos?

      # Check if variable name been used
      MVinl::Context::CONSTANTS.each_key do |const_name|
        return [:CONSTANT_CALL, const_name] if @ss.scan(/\A#{Regexp.escape const_name.to_s}\b/)
      end
      @context.variables.each_key do |var_name|
        return [:VARIABLE_CALL, var_name] if @ss.scan(/\A#{Regexp.escape var_name.to_s}\b/)
      end

      TOKENS.each do |type, regex|
        if @ss.scan regex
          @last_type = type
          break
        end
      end
      case @last_type
      when :NEW_LINE
        @context.state[:lines] += 1
        return next_token if continuation_line?

        [:END_TAG, "\n"]
      when :WHITESPACE
        # Whitespace (' ' and '\t') does nothing in mvnl 0.1. I handle them
        # though as indentation plays a role in 0.2 to predict position of elements
        next_token
      when :COMMENT
        skip_to_next_line
        next_token
      when :OPEN_PAREN then [:OPEN_PAREN, '(']
      when :CLOSE_PAREN
        unless @context.state[:depth].positive?
          raise UnexpectedTokenError, 'CLOSE_PARAM found with no matching OPEN_PARAM'
        end

        [:CLOSE_PAREN, ')']
      when :OPER
        unless @context.state[:depth].positive?
          raise UnexpectedTokenError, 'OPER found with no matching OPEN_PARAM'
        end

        [:OPER, @ss.matched]
      when :KEYWORD
        return [:DEF, @ss.matched] if @ss.matched == 'def'

        [:KEYWORD, @ss.matched]
      when :KEYWORD_ARG
        if !@context.state[:in_prop]
          raise UnexpectedTokenError, 'Looking for identifier but found KEYWORD_ARG'
        elsif @context.state[:in_keyword_arg]
          raise UnexpectedTokenError, 'Looking for a keyword argument value but found KEYWORD_ARG'
        end

        [:KEYWORD_ARG, @ss[1]]
      when :GROUP
        # Group gets canceled whenever encountered another group id or a matching end tag
        if @context.state[:in_keyword_arg]
          raise UnexpectedTokenError, 'Looking for a keyword argument value but found GROUP'
        end

        @in_group = true
        [:GROUP, @ss[1]]
      when :CONSTANT then [:CONSTANT, @ss[1]]
      when :VARIABLE then [:VARIABLE, @ss[1]]
      when :ID then [:ID, @ss.matched]
      when :NUMBER, :FLOAT, :STRING, :SYMBOL, :MULTILINE_STRING
        # Values can't be used outside an property or a lambda
        if !@context.state[:in_prop] && !@context.state[:depth].positive? && !@context.state[:in_var]
          raise UnexpectedTokenError, "Looking for ID or OPEN_PAREN but found #{@last_type}"
        elsif !@context.state[:in_keyword_arg] && @context.state[:keyword_arg_depth].positive? &&
              !@context.state[:depth].positive? && !@context.state[:in_var]
          raise UnexpectedTokenError, "Looking for END_TAG or KEYWORD_ARG but found #{@last_type}"
        end

        [@last_type, @ss[1] || @ss.matched]
      when :END_TAG then [:END_TAG, '.']
      else
        raise UnexpectedTokenError, "Unexpected character: '#{@ss.getch}'"
      end
    rescue LexerError => e
      warn "Syntax error at #{@ss.charpos - @ss.matched_size}: #{e}"
    end

    def tokenize
      tokens = []
      while (token = next_token)
        warn "Tokenize: #{token}"
        tokens << token
      end
      tokens
    end

    private

    def continuation_line?
      return true unless @in_group

      # Auto end properties
      lookahead = @ss.check(/\A(?:#{TOKENS[:GROUP]}|#{TOKENS[:ID]}$|#{TOKENS[:END_TAG]}|#{TOKENS[:NEW_LINE]})/)
      warn "Continue? in_prop?: #{@context.state[:in_prop].inspect}, lookahead: #{lookahead.inspect}"
      @context.state[:in_prop] ? !lookahead : true
    end

    # Move the cursor to the next new line tag
    def skip_to_next_line
      @ss.scan_until(/\n/) || @ss.terminate
    end

    def process_eos
      return if @eos

      @eos = true
      [false, '$']
    end
  end
end
