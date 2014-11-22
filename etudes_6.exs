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

defmodule Dates do
	def date_parts(date) do
		for s <- String.split(date, "-"), do: String.to_integer(s)
	end

	def julian(date) do
		[year, month, day] = date_parts(date)
		days_per_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

		days = day + days_to_month(month, days_per_month, 0)
		if is_leap_year(year) do
			days + 1
		else
			days
		end
	end

	def days_to_month(1, _days_per_month, days) do
		days
	end
	
	def days_to_month(month, [h | tail], days) do
		days_to_month(month-1, tail, days + h)
	end

	defp is_leap_year(year) do
	    (rem(year,4) == 0 and rem(year,100) != 0) or (rem(year, 400) == 0)
	end

end

defmodule Teeth do
	require Stats
	require Enum

	def alert(depths) do
		alert(1, depths, [])
	end

	defp alert(_tooth, [], alerts) do 
		Enum.reverse(alerts)
	end

	defp alert(tooth, [h | t], alerts) do
		if Stats.maximum(h) > 3 do
			alert(tooth + 1, t, [tooth | alerts])
		else 
			alert(tooth + 1, t, alerts)
		end		
	end

	def pocket_depths do
	  [
		[0], 			[2,2,1,2,2,1], 	[3,1,2,3,2,3],	[3,1,3,2,1,2],	
		[3,2,3,2,2,1],	[2,3,1,2,1,1],	[3,1,3,2,3,2],	[3,3,2,1,3,1],	
		[4,3,3,2,3,3],	[3,1,1,3,2,2],	[4,3,4,3,2,3],	[2,3,1,3,2,2],
	  	[1,2,1,1,3,2],	[1,2,2,3,2,3],	[1,3,2,1,3,3], 	[0],
	  	[3,2,3,1,1,2],	[2,2,1,1,3,2],	[2,1,1,1,1,2], 	[3,3,2,1,1,3],	
	  	[3,1,3,2,3,2],	[3,3,1,2,3,3], 	[1,2,2,3,3,3],	[2,2,3,2,3,3],	
	  	[2,2,2,4,3,4], 	[3,4,3,3,3,4],	[1,1,2,3,1,2],	[2,2,3,2,1,3],
	  	[3,4,2,4,4,3],	[3,3,2,1,2,3],	[2,2,2,2,3,3], 	[3,2,3,2,3,2]
	  ]
	end
end

defmodule NonFP do
	def generate_pockets(teeth, good_tooth_probability) do
		:random.seed(:erlang.now())
		generate_pockets(teeth, [], good_tooth_probability)
	end

	defp generate_pockets([], result, _good_tooth_probability) do
		Enum.reverse(result)
	end

	defp generate_pockets([?F|t], result, good_tooth_probability) do
		generate_pockets(t, [[0] | result], good_tooth_probability)
	end

	defp generate_pockets([_h|t], result, good_tooth_probability) do
		if :random.uniform < good_tooth_probability do
			base_depth = 2
		else
			base_depth = 3
		end
		generate_pockets(t, [generate_tooth([], 6, base_depth) | result], good_tooth_probability)
	end

	defp generate_tooth(result, 0, _base_depth), do: result
	defp generate_tooth(result, count, base_depth) do
		depth = base_depth + :random.uniform(3) - 2
	 	generate_tooth([depth | result], count - 1, base_depth)
	end

end

data = [4, 1, 7, -17, 8, 2, 5]

IO.puts Stats.minimum(data)
IO.puts Stats.maximum(data)
IO.puts "#{inspect Stats.range(data)}"
IO.puts ""

IO.puts Dates.julian("2013-12-31")
IO.puts Dates.julian("2012-12-31")
IO.puts Dates.julian("2012-02-05")
IO.puts Dates.julian("2013-02-05")
IO.puts Dates.julian("1900-03-01")
IO.puts Dates.julian("2000-03-01")
IO.puts Dates.julian("2013-01-01")
IO.puts ""

# IO.puts "#{inspect Teeth.alert(Teeth.pocket_depths())}"

IO.puts ""
IO.puts "#{inspect NonFP.generate_pockets('FFFF', 0.3)}"
IO.puts "#{inspect NonFP.generate_pockets('TTTTFFTTTTFFFTTTTF', 0.3)}"

