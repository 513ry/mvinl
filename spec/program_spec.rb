# frozen-string-literal: true

require_relative 'spec_helper'
require 'mvinl'

describe MVinl, '#eval' do
  context 'no input' do
    it 'returns an empty hash' do
      result = MVinl.eval('')
      expect(result).to eq({})
    end
  end

  context 'groups' do
    it 'retruns a single group' do
      result = MVinl.eval('@x')
      expect(result).to eq({ x: {} })
    end
    it 'returns two groups' do
      result = MVinl.eval('@x @y')
      expect(result).to eq({ x: {}, y: {} })
    end
  end

  context 'properties' do
    it 'return a single property' do
      result = MVinl.eval('@x a')
      expect(result).to eq({ x: { a: [[], {}] } })
    end
    it 'returns two properties' do
      result = MVinl.eval('@x a b')
      expect(result).to eq({ x: { a: [[], {}], b: [[], {}] } })
    end
  end

  context 'variables' do
    it 'stores a single variable' do
      MVinl.eval('!n 0')
      expect(MVinl.context.variables[:n]).to be_truthy
    end
    it 'stores two variables' do
      MVinl.eval('!n 3 !m 6')
      expect(MVinl.context.variables[:n] && MVinl.context.variables[:m]).to be_truthy
    end
    it 'stores a single variable with it\'s value' do
      MVinl.eval('!n 5')
      expect(MVinl.context.variables[:n]).to eq 5
    end
    it 'evaluates a single variable' do
      result = MVinl.eval('!n 5 x n')
      expect(result).to eq({ x: [[5], {}] })
    end
  end

  context 'functions' do
    it 'stores function definition with \'+\' OPER and no arguments' do
      MVinl.eval('def (f (+ 1))')
      expect(MVinl.context.functions).to eq({ f: { args: [], body: [:+, 1] } })
    end
    it 'stores function definition with \'-\' OPER and no arguments' do
      MVinl.eval('def (f (- 1))')
      expect(MVinl.context.functions).to eq({ f: { args: [], body: [:-, 1] } })
    end
    it 'stores function definition with \'*\' OPER and no arguments' do
      MVinl.eval('def (f (* 1))')
      expect(MVinl.context.functions).to eq({ f: { args: [], body: [:*, 1] } })
    end
    it 'stores function definition with \'/\' OPER and no arguments' do
      MVinl.eval('def (f (/ 1))')
      expect(MVinl.context.functions).to eq({ f: { args: [], body: [:/, 1] } })
    end
    it 'stores function definition with \'%\' OPER and no arguments' do
      MVinl.eval('def (f (% 1))')
      expect(MVinl.context.functions).to eq({ f: { args: [], body: [:%, 1] } })
    end
    it 'stores function definition with a single argument' do
      MVinl.eval('def (f a (+ a a))')
      expect(MVinl.context.functions).to eq({ f: { args: %I[a], body: %I[+ a a] } })
    end
    it 'stores function definition with two arguments' do
      MVinl.eval('def (f a b (+ a b))')
      expect(MVinl.context.functions).to eq({ f: { args: %I[a b], body: %I[+ a b] } })
    end
    it 'evaluates anonimous function' do
      result = MVinl.eval('x (+ 2 2)')
      expect(result).to eq({ x: [[4], {}] })
    end
    it 'evaluates function' do
      result = MVinl.eval('def (foo (+ 5)) x (foo)')
      expect(result).to eq({ x: [[5], {}] })
    end
    it 'evaluates function calling another function' do
      result = MVinl.eval('def (foo (+ 5)) def (bar (foo)) x (bar)')
      expect(result).to eq({ x: [[5], {}] })
    end
    it 'evaluates function inside a variable' do
      MVinl.eval('def (foo (+ 7)) !n (foo)')
      expect(MVinl.context.variables[:n]).to eq 7
    end
  end
end

describe MVinl, '#eval_from_file' do
  context 'stack example' do
    it 'evaluates a basic example' do
      MVinl.reset
      result = MVinl.eval_from_file('spec/stack.mvnl')
      expect(result).to eq({ menu: { Menu: [[], { New_Game: :state_next, Exit: :abord }] },
                             game: { Mouse: [[], {}], Board: [[3, 3], {}],
                                     Button: [['󰮱  Hello Vinl!'], {
                                       line_height: 25, padding: 8
                                     }] } })
    end
    it 'evaluates an example with variables' do
      MVinl.reset
      result = MVinl.eval_from_file('spec/vars.mvnl')
      expect(result).to eq({ x: [[5], { fun: 10 }] })
    end
    it 'function respects variable change' do
      MVinl.reset
      result = MVinl.eval_from_file('spec/complex_vars.mvnl')
      expect(result).to eq({ x: [[20], {}] })
    end
  end
end
