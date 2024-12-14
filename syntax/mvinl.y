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
    | program constant_def                           { val[0] }
    | program variable_def                           { val[0] }
    | program function_def                           { val[0] }
    | program EOS                                    { val[0] }
    ;
  variable_def
    : var_def_name super_value
      {
	@context.define_variable(val[0], val[1]) ||
	  raise(MVinl::ParserError, "Trying to define a reserved word '#{val[0]}' as a variable")
      }
    ;
  var_def_name
    : VARIABLE                                       { @context.state[:in_var] = true; val[0].to_sym }
    ;
  constant_def
    : const_def_name super_value
      {
	if (res = @context.define_constant(val[0], val[1])) == nil
	  raise(MVinl::ParserError, "Trying to define a reserved word '#{val[0]}' as a constant")
	elsif (res == false)
	  raise(MVinl::ParserError, "Can't overwrite a constant #{val[0]}")
	else
          res
        end
      }
    ;
  const_def_name
    : CONSTANT                                       { @context.state[:in_var] = true; val[0].to_sym }
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
    | CONSTANT_CALL                                  { MVinl::Context::CONSTANTS[val[0]] }
    | VARIABLE_CALL                                  { @context.variables[val[0]] }
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
	@context.define_function(val[2], val[3], val[4])
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
    | args CONSTANT_CALL                             { val[0] << { con: val[1] } }
    | args VARIABLE_CALL                             { val[0] << { var: val[1] } }
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

  def evaluate_const(const_name)
    MVinl::Context::CONSTANTS[const_name]
  end

  def evaluate_var(var_name)
    @context.variables[var_name]
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
      # Evaluate variables
      function.map! do |e|
        if e.is_a? Hash
	  e[:var] ? evaluate_var(e[:var]) : evaluate_const(e[:con])
	else
	  e
	end
      end
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
