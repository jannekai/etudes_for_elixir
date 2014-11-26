
defmodule Calculus do

  def derivative(fun, x) do 
    delta = 1.0e-10
    (fun.(x + delta) - fun.(x)) / delta
  end

end


f1 = fn(x) -> x * x end
IO.puts f1.(7)
IO.puts Calculus.derivative(f1, 3)
IO.puts Calculus.derivative(fn(x) -> 3 * x * x + 2 * x + 1 end, 5)
IO.puts Calculus.derivative(&:math.sin/1, 0)

