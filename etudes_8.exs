
defmodule Calculus do

  require List

  def derivative(fun, x) do 
    delta = 1.0e-10
    (fun.(x + delta) - fun.(x)) / delta
  end

  def older_males(list) do
    for {name, "M", age} <- list, age > 40, do: {name, age}
  end

  def male_or_older(list) do
    for {name, gender, age} <- list, age > 40 or gender == "M", do: {name, gender, age}
  end

  def mean(values) do
    List.foldl(values, 0, &(&1+&2)) / Enum.count(values)
  end

  def std_deviation(values) do
    sum = List.foldl(values, 0, &(&1+&2))
    sum_squares = List.foldl(values, 0, &(&1 * &1 + &2))
    count = Enum.count(values)
    :math.sqrt(((sum_squares * Enum.count(values)) - (sum * sum)) / (count * (count - 1)))
  end
end


f1 = fn(x) -> x * x end
IO.puts f1.(7)
IO.puts Calculus.derivative(f1, 3)
IO.puts Calculus.derivative(fn(x) -> 3 * x * x + 2 * x + 1 end, 5)
IO.puts Calculus.derivative(&:math.sin/1, 0)

data = [
  {"Federico", "M", 22}, 
  {"Kim", "F", 45}, 
  {"Hansa", "F", 30}, 
  {"Tran", "M", 47}, 
  {"Cathy", "F", 32}, 
  {"Elias", "M", 50}
]
IO.puts "Data #{inspect data}"
IO.puts "Older males: #{inspect Calculus.older_males(data)}"
IO.puts "Male or older: #{inspect Calculus.male_or_older(data)}"

data = [7, 2, 9]
IO.puts "#{inspect data} mean: #{inspect Calculus.mean(data)} stddev: #{inspect Calculus.std_deviation(data)}"
