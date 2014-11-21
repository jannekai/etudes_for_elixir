defmodule Stats do

	def minimum([h|t]), do: minimum(t, h)
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

data = [4, 1, 7, -17, 8, 2, 5]

IO.puts Stats.minimum(data)
IO.puts Stats.maximum(data)
IO.puts "#{inspect Stats.range(data)}"

