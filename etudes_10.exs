defmodule Stats do

  def minimum(values) do
    try do 
      [h, t] = values
      minimum(t, h)
    rescue
      e -> e
    end
  end

  defp minimum([], min), do: min
  defp minimum([h|t], min) when h < min, do: minimum(t, h)
  defp minimum([_h|t], min), do: minimum(t, min)




  def maximum([h|t]), do: maximum(t, h)
  defp maximum([], max), do: max
  defp maximum([h|t], max) when h > max, do: maximum(t, h)
  defp maximum([_h|t], max), do: maximum(t, max)

  def range(list) do 
    {minimum(list), maximum(list)}
  end
end

IO.puts "#{inspect Stats.minimum([])}"
IO.puts "#{inspect Stats.minimum({1})}"
IO.puts "#{inspect Stats.minimum(:atom)}"
