# frozen-string-literal: true

=begin engine.rb
Copyright (c) 2024, Daniel Sierpiński All rights reserved.

See Copyright Notice in mvnil.rb
=end

require_relative '../../syntax/mvinl.tab'

class MVinl::Parser < MVinl::Program
  def initialize(lexer, debug: false)
    @yydebug = debug
    @lexer = lexer
    @tokens = []
    @done = false
    super()
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

  def parse
    do_parse
  end
end
