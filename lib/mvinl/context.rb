# frozen-string-literal: true

module MVinl
  # Lexer and parser shared context
  class Context
    attr_accessor :variables, :functions, :state

    def initialize
      reset
    end

    def reset
      @variables = {}
      @functions = {}
      @state = {
        in_prop: false,
        in_var: false,
        in_keyword_arg: false,
        keyword_arg_depth: 0,
        depth: 0
      }
    end
  end
end
