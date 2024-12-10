# frozen-string-literal: true

=begin parser.rb
Copyright (c) 2024, Daniel Sierpiński All rights reserved.

See Copyright Notice in mvnil.rb
=end

require 'mvinl.tab'

# Generated parser class
class MVinl::Parser < MVinl::Program
  def initialize(lexer, context, debug: false)
    @lexer = lexer
    @context = context
    @yydebug = debug
    @tokens = []
    @done = false
    super()
  end

  def parse
    do_parse
  end

  def feed(input)
    @lexer.feed input
  end

  def next_token
    if @tokens.empty?
      @lexer.next_token
    else
      @tokens.shift
    end
  end

  def enqueue_token(token)
    @tokens << token
  end

  def finalize!
    @done = true
  end

  def parsing_done?
    @done && @tokens.empty?
  end
end
