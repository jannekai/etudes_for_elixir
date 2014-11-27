
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

defmodule Dates do

  def julian(date) do
    [year, month, day] = date_parts(date)
    {month_days, _} = Enum.split([31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31], month-1)
    days = List.foldl(month_days, 0, &(&1+&2)) + day
    if month > 2 && is_leap_year(year) do
      days = days + 1
    end
    days
  end

  defp date_parts(date) do
    for s <- String.split(date, "-"), do: String.to_integer(s)
  end

  defp is_leap_year(year) do
      (rem(year,4) == 0 and rem(year,100) != 0) or (rem(year, 400) == 0)
  end

end

defmodule Cards do

  def make_deck do
    suits = ["Clubs", "Diamonds", "Hearts", "Spades"]
    ranks = ["A", "K", "Q", "J", "10", "9", "8", "7", "6", "5", "4", "3", "2"]
    for rank <- ranks, suite <- suits, do: {rank, suite}
  end

  def shuffle(deck) do
    :random.seed(:erlang.now())
    shuffle(deck, [])
  end

  defp shuffle([], acc), do: acc
  defp shuffle(deck, acc) do
    {leading, [h, t]} = Enum.split(deck, :random.uniform(deck, Enum.count(deck)) - 1)
    shuffle(leading ++ t, [h | acc])
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

IO.puts Dates.julian("2013-12-31")
IO.puts Dates.julian("2012-12-31")
IO.puts Dates.julian("2012-02-05")
IO.puts Dates.julian("2013-02-05")
IO.puts Dates.julian("1900-03-01")
IO.puts Dates.julian("2000-03-01")
IO.puts Dates.julian("2013-01-01")
IO.puts ""

IO.puts "#{inspect Cards.make_deck}"