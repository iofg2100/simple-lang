require 'parslet'
require 'simple-lang/ast'

module SimpleLang

  class Transform < Parslet::Transform

    # values

    rule(:number => simple(:x)) { NumberAST.new(x.to_f) }
    rule(:identifier => simple(:name)) { VariableAST.new(name.to_s) }

    rule(:function_call => { :identifier => simple(:identifier), :function_call_parameters => sequence(:parameters) }) do
      FunctionCallAST.new(identifier.to_s, parameters)
    end

    rule(:value => simple(:item)) { item }

    # unary expressions

    rule(:unary_expression => simple(:value) ) do
      value
    end

    rule(:unary_expression => { :op => simple(:op), :value => simple(:value) }) do
      UnaryOperationAST.new(op.to_s, value)
    end

    # binary expressions

    LeftItem = Struct.new(:left)
    RightItem = Struct.new(:op, :right)

    rule(:left => simple(:x)) { LeftItem.new(x) }
    rule(:op => simple(:op), :right => simple(:right)) { RightItem.new(op, right) }

    rule(:binary_expression => sequence(:seq)) do
      left = seq[0].left
      seq[1..-1].each do |item|
        left = BinaryOperationAST.new(left, item.op.to_s, item.right)
      end
      left
    end

    rule(:binary_expression => simple(:expression)) do
      expression
    end

    # procedures

    rule(:procedure => sequence(:expressions)) do
      ProcedureAST.new(expressions)
    end

    # controls
  
    rule(:when_statement => {:parameter => simple(:parameter), :content => simple(:procedure)}) do
      Struct.new(:parameter, :procedure).new(parameter, procedure)
    end

    rule(:else_statement => {:content => simple(:procedure)}) do
      procedure
    end

    rule(:case_when_expression => {
        :case_statement => {:parameter => simple(:case_parameter)},
        :whens => sequence(:when_statements),
        :elses => sequence(:else_statements)
      }) do
      CaseWhenExpressionAST.new(case_parameter, when_statements, else_statements[0])
    end
    
    rule(:function_literal => { :function_literal_parameters => sequence(:params), :content => simple(:procedure) }) do
      FunctionLiteralAST.new(params.map {|item| item.name}, procedure)
    end

  end

end
