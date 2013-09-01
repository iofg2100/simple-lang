require 'pp'
require './parser.rb'
require './ast.rb'
require './transform.rb'

def parse(str)
  parsed = Parser.new.parse(str)
  pp parsed
  transformed = Transform.new.apply(parsed)
  pp transformed
  transformed.eval

rescue Parslet::ParseFailed => failure
  puts failure.cause.ascii_tree
end

str = <<EOS
a = 1 - 2 * 3
b = a * (1.5 + 6.2)
x0 = 5
x_1 = -6 + x0
EOS

str2 = "
a > 1
a > 1
a == 2
3 + (3 + 2) * f(2, 3) + f(1)
"

parse str
