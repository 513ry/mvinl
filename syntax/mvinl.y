/*
 * Copyright (c) 2024, Daniel Sierpiński All rights reserved.
 *
 * Minimal Vinl grammar definition.
 *
 * See Copyright Notice in mvnil.rb
 */

class MVinl::Program
options no_result_var
rule
  program
    : /* empty */                                    { Hash.new }
    | program group                                  { val[0].merge(val[1]) }
    | program properties                             { val[0].merge(val[1]) }
    | program variable_def                           { val[0] }
    | program function_def                           { val[0] }
    | program EOS                                    { val[0] }
    ;
  variable_def
    : var_def_name super_value                       { define_variable(val[0], val[1]) }
    ;
  var_def_name
    : VARIABLE                                       { @context.state[:in_var] = true; val[0].to_sym }
    ;
  group
    : GROUP properties                               { {val[0].to_sym => create_group(val[1])} }
    ;
  properties
    : /* empty */                                    { Hash.new }
    | properties property                            { val[0].merge(val[1]) }
    | properties property END_TAG                    { val[0].merge(val[1]) }
    ;
  property
    : prop_id                                        { create_property(val[0]) }
    | prop_id positional_args                        { create_property(val[0], val[1]) }
    | prop_id positional_args keyword_args           { create_property(val[0], val[1], val[2]) }
    ;
  prop_id
    : identifier                                     { @context.state[:in_prop] = true; val[0] }
    ;
  positional_args
    : /* empty */                                    { Array.new }
    | positional_args super_value                    { val[0] << val[1] }
    ;
  keyword_args
    : /* empty */                                    { Hash.new }
    | keyword_args keyword_arg
      {
	@context.state[:keyword_arg_depth] = 0
	val[0].merge(val[1])
      }
    ;
  keyword_arg
    : keyword_arg_id super_value
      {
	@context.state[:in_keyword_arg] = false
	@context.state[:keyword_arg_depth] += 1
	{val[0].to_sym => val[1]}
      }
    ;
  keyword_arg_id
    : KEYWORD_ARG                                    { @context.state[:in_keyword_arg] = true; val[0] }
    ;
  super_value
    : value                                          { val[0] }
    | lambda                                         { val[0] }
    | VARIABLE_CALL                                  { val[0] }
    ;
  value
    : NUMBER                                         { val[0].to_i }
    | FLOAT                                          { val[0].to_f }
    | string                                         { val[0] }
    | SYMBOL                                         { val[0].to_sym }
    ;
  string
    : STRING                                         { val[0] }
    | MULTILINE_STRING string                        { "#{val[0]} #{val[1]}" }
    ;
  function_def
    : DEF open_paren identifier args polish_notation_def close_paren
      {
	  define_function(val[2], val[3], val[4])
      }
    ;
  polish_notation_def
    : open_paren identifier args close_paren         { [val[1], *val[2]] }
    | open_paren operator args close_paren           { [val[1], *val[2]] }
    ;
  lambda
    : open_paren identifier params close_paren       { evaluate_pn(val[1], val[2]) }
    | open_paren operator params close_paren         { evaluate_pn(val[1], val[2]) }
    ;
  open_paren
    : OPEN_PAREN                                     { @context.state[:depth] += 1 }
    ;
  close_paren
    : CLOSE_PAREN                                    { @context.state[:depth] -= 1 }
    ;
  args
    : /* empty */                                    { Array.new }
    | args identifier                                { val[0] << val[1] }
    | args value                                     { val[0] << val[1] }
    | args polish_notation_def                       { val[0] << val[1] }
    ;
  params
    : /* empty */                                    { Array.new }
    | params super_value                             { val[0] << val[1] }
    | params identifier                              { val[0] << val[1] }
    | params polish_notation                         { val[0] << val[1] }
    ;
  operator
    : OPER                                           { val[0].to_sym }
    ;
  identifier
    : ID                                             { val[0].to_sym }
    ;
end

---- inner
  class MVinl::ParserError < StandardError; end

  private

  def create_property(id, positional_args = [], keyword_args = {})
    @context.state[:in_prop] = false
    {id => [positional_args, keyword_args]}
  end

  def create_group(properties)
    properties ||  Hash.new
  end


  def define_variable(name, value)
    @context.state[:in_var] = false
    @context.variables[name] = value
    value
  end

  def define_function(name, args, body)
  @context.functions[name.to_sym] = {args: args, body: body}
    nil
  end

  def evaluate_pn(operator, operands, context = {})
    operands.map! do |op|
      if op.is_a?(Array)
        evaluate_pn(op[0], op[1..], context) # Nested PN expression
      elsif context.key?(op)
        context[op] # Function identifier
      else
	op # Literal value (e.g., NUMBER or STRING)
      end
    end

    if @context.functions.key?(operator)
      function = @context.functions[operator]
      raise MVinl::ParserError, "Argument mismatch for #{operator}" if operands.size != function[:args].size

      # Map arguments to operands
      new_context = function[:args].zip(operands).to_h
      # Replace symbols in body with context values
      function = replace_symbols(function[:body], new_context)
      # Recursive evaluation
      evaluate_pn(function[0], function[1..], new_context)
    else
      begin
        operands.reduce(operator)
      rescue NoMethodError
        raise MVinl::ParserError, "Unknown operator: #{operator}"
      end
    end
  end

  def replace_symbols(array, replacements)
    array.map do |element|
      if element.is_a?(Array)
        replace_symbols(element, replacements)
      elsif element.is_a?(Symbol) && replacements.key?(element)
        replacements[element]
      else
        element
      end
    end
  end
