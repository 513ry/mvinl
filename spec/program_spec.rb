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

  context 'functions' do
    it 'Stores function definition with \'+\' OPER and no arguments' do
      MVinl.eval('def (f (+ 1))')
      expect(MVinl::Parser::FUNCTIONS).to eq({ f: { args: [], body: [:+, 1] } })
    end

    it 'Stores function definition with \'-\' OPER and no arguments' do
      MVinl.eval('def (f (- 1))')
      expect(MVinl::Parser::FUNCTIONS).to eq({ f: { args: [], body: [:-, 1] } })
    end

    it 'Stores function definition with \'*\' OPER and no arguments' do
      MVinl.eval('def (f (* 1))')
      expect(MVinl::Parser::FUNCTIONS).to eq({ f: { args: [], body: [:*, 1] } })
    end

    it 'Stores function definition with \'/\' OPER and no arguments' do
      MVinl.eval('def (f (/ 1))')
      expect(MVinl::Parser::FUNCTIONS).to eq({ f: { args: [], body: [:/, 1] } })
    end

    it 'Stores function definition with \'%\' OPER and no arguments' do
      MVinl.eval('def (f (% 1))')
      expect(MVinl::Parser::FUNCTIONS).to eq({ f: { args: [], body: [:%, 1] } })
    end

    it 'Stores function definition with a single argument' do
      MVinl.eval('def (f a (+ a a))')
      expect(MVinl::Parser::FUNCTIONS).to eq({ f: { args: %I[a], body: %I[+ a a] } })
    end

    it 'Stores function definition with two arguments' do
      MVinl.eval('def (f a b (+ a b))')
      expect(MVinl::Parser::FUNCTIONS).to eq({ f: { args: %I[a b], body: %I[+ a b] } })
    end

    it 'Evaluate anonimous function' do
      result = MVinl.eval('@x x (+ 2 2)')
      expect(result).to eq({ x: { x: [[4], {}] } })
    end

    it 'Evaluate function' do
      result = MVinl.eval('def (foo (+ 5)) @x x (foo)')
      expect(result).to eq({ x: { x: [[5], {}] } })
    end

    it 'Evaluate function calling another function' do
      result = MVinl.eval('def (foo (+ 5)) def (bar (foo)) @x x (bar)')
      expect(result).to eq({ x: { x: [[5], {}] } })
    end
  end
end
