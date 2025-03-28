# frozen-string-literal: true

=begin mvinl.rb
Copyright (c) 2018, 2024, Daniel Sierpiński All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
=end

require 'mvinl/context'
require 'mvinl/parser'
require 'mvinl/lexer'

# Library entry point
module MVinl
  @context = Context.new
  @parser = Parser.new(Lexer.new(@context, ''), @context)

  def self.eval(input)
    @parser.feed input
    @parser.parse
  end

  def self.eval_from_file(path)
    self.eval File.read(path)
  end

  def self.context
    @context
  end

  def self.reset
    @context.reset
  end
end
