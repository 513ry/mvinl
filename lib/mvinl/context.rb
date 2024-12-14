# frozen-string-literal: true

require 'pry'

module MVinl
  # Lexer and parser shared context
  class Context
    attr_accessor :variables, :functions, :state

    RESERVED = %I[def]
    CONSTANTS = {}

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
        lines: 0,
        depth: 0
      }
    end

    def define_function(name, args, body)
      @functions[name] = { args: args, body: body }
    end

    def define_constant(name, value)
      if RESERVED.include? name
        nil
      elsif CONSTANTS[name]
        false
      else
        @state[:in_var] = false
        CONSTANTS[name] = value
      end
    end

    def define_variable(name, value)
      if RESERVED.include? name
        nil
      else
        @state[:in_var] = false
        @variables[name] = value
      end
    end
  end
end
