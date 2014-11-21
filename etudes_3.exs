defmodule Geom do
	@moduledoc """
	Geometry related functions for elixir etude

	## Examples
      iex> Math.area(1, 2)
      3
	"""

	@doc """
	Returns area as width * height, defaults to 1 for width and height if not given as parameter 
	"""
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

	@doc """
	Test default values
	"""
	def default_values(a \\ 1, b, c, d \\ 4) do
		IO.puts "a: #{a} b: #{b} c: #{c} d: #{d}"
	end

end

IO.puts Geom.area(3,4)
IO.puts Geom.area(12, 7)
IO.puts Geom.area(7)
IO.puts Geom.area()

IO.puts Geom.area(:rectangle, 3, 4)
IO.puts Geom.area(:triangle, 3, 5)
IO.puts Geom.area(:ellipse, 2, 4)

IO.puts Geom.area(:rectangle, -3, 4)
IO.puts Geom.area(:triangle, 3, -4)
IO.puts Geom.area(:ellipse, -3, -4)

IO.puts Geom.area({:rectangle, 7, 3})
IO.puts Geom.area({:triangle, 7, 3})
IO.puts Geom.area({:pentagon, 7, 3})

Geom.default_values(100, 200)
Geom.default_values(100, 200, 300)
Geom.default_values(100, 200, 300, 400)

