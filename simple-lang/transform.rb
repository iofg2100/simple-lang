require 'parslet'
require 'simple-lang/ast'

module SimpleLang

  class Transform < Parslet::Transform

    # values

    rule(:number => simple(:x)) { NumberLiteral.new(x.to_f) }
    rule(:identifier => simple(:name)) { Variable.new(name.to_s) }

    rule(:funcall => { :identifier => simple(:identifier), :parameters => sequence(:parameters) }) do
      FunCall.new(identifier.to_s, parameters)
    end

    rule(:funcall => { :identifier => simple(:identifier), :parameters => simple(:parameter) }) do
      FunCall.new(identifier.to_s, [parameter])
    end

    rule(:value => simple(:item)) { item }

    # unary expressions

    rule(:unary_expression => simple(:value) ) do
      value
    end

    rule(:unary_expression => { :op => simple(:op), :value => simple(:value) }) do
      UnaryOperation.new(op.to_s, value)
    end

    # binary expressions

    LeftItem = Struct.new(:left)
    RightItem = Struct.new(:op, :right)

    rule(:left => simple(:x)) { LeftItem.new(x) }
    rule(:op => simple(:op), :right => simple(:right)) { RightItem.new(op, right) }

    rule(:binary_expression => sequence(:seq)) do
      left = seq[0].left
      seq[1..-1].each do |item|
        left = BinaryOperation.new(left, item.op.to_s, item.right)
      end
      left
    end

    rule(:binary_expression => simple(:expression)) do
      expression
    end

    # procedures

    rule(:procedure => simple(:expression)) do
      Procedure.new([expression])
    end

    rule(:procedure => sequence(:expressions)) do
      Procedure.new(expressions)
    end

  end

end
