defmodule Geom do
	def area({shape, a, b}) do 
		area(shape, a, b)
	end

	def area(width \\ 1, height \\ 1) when width >= 0 and height >= 0 do
		width * height
	end

	def area(:rectangle, width, height) when width >= 0 and height >= 0 do 
		width * height
	end

	def area(:triangle, base, height) when base >= 0 and height >= 0 do 
		base * height / 2
	end

	def area(:ellipse, major_radius, minor_radius) when major_radius >= 0 and minor_radius >= 0 do 
		:math.pi * major_radius * minor_radius
	end

	def area(_, _, _) do 
		0
	end
end

defmodule AskArea do

	require Geom
	require String

	def area() do
		try do
			shape = get_shape()
			{a, b} = case shape do
				:rectangle -> get_dimensions("Give rectangle width >", "Give rectangle height >")
				:triangle -> get_dimensions("Give triangle base width >", "Give triangle height >")
				:ellipse -> get_dimensions("Give ellipse major radius >", "Give ellipse minor radius >")
			end
			calculate(shape, a, b)
		catch
			{:error, msg} -> IO.puts msg
		end			
	end

	def get_shape() do
		input = IO.gets "R)ectangle, T)riangle, or E)llipse: "
		char = String.upcase(String.first(String.strip(input)))
		case char  do
			"R" -> {:rectangle, nil}
			"T" -> {:triangle, nil}
			"E" -> {:ellipse, nil}
			"B" -> throw :error
			_ -> throw {:error, "Unknown shape type given, #{char}"}
		end
	end

	def get_number(prompt) do
		input = IO.gets "Enter #{prompt} >"
		String.to_integer(String.strip(input))
	end

	def get_dimensions(prompt1, prompt2) do
		{get_number(prompt1), get_number(prompt2)}
	end

	def calculate(shape, a, b) do	
		cond do
			shape == :unknown -> IO.puts "Invalid shape given #{shape}"
			a < 0 or b < 0 -> IO.puts "Value of #{a} and #{b} must be greater or equal to zero"
			true -> IO.puts "Area of #{shape} with #{a} and #{b} is #{Geom.area(shape, a, b)}"
		end
	end
end

defmodule Dates do
	def date_parts(date) do
		for s <- String.split(date, "-"), do: String.to_integer(s)
	end
end

# AskArea.area()

IO.puts "#{inspect Dates.date_parts("2013-06-15")}"
