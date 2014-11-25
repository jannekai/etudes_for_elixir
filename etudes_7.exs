
defmodule College do
	require String
	
	def make_room_list(file) do
		{:ok, device} = File.open(file, [:read, :utf8])
		dict = parse_lines(device, IO.read(device, :line), HashDict.new)
		File.close(file)
		dict
	end

	defp parse_lines(_device, :eof, dict), do: dict

	defp parse_lines(device, line, dict) do
		line = String.strip(line)
		[_id, name, room] = String.split(line, ",")
		dict = Dict.put_new(dict, room, [])
		dict = Dict.put(dict, room, [name | Dict.get(dict, room)])
		parse_lines(device, IO.read(device, :line), dict)
	end
end

defmodule Country do
	defstruct name: "", language: "", cities: []
end

defmodule City do
	defstruct name: "", population: 0, latitude: 0.0, longitude: 0.0
end

defmodule Geography do
	def make_geo_list(file) do
		{:ok, device} = File.open(file, [:read, :utf8])
		parse_lines(device, IO.read(device, :line), [])
	end

	defp parse_lines(_device, :eof, countries), do: Enum.reverse(countries)

	defp parse_lines(device, line, countries) do 
		parts = String.strip(line)
		parts = String.split(parts, ",")
		countries = parse_parts(parts, countries)
		parse_lines(device, IO.read(device, :line), countries)
	end

	defp parse_parts([name, language], countries) do
		[%Country{name: name, language: language} | countries]
	end

	defp parse_parts([name, population, latitude, longitude], [current | countries]) do 
		city = %City{name: name, population: population, latitude: latitude, longitude: longitude}
		[%{current | cities: [city | current.cities]} | countries]
	end
end

IO.puts "#{inspect College.make_room_list("test.csv")}"
IO.puts "#{inspect Geography.make_geo_list("geography.csv")}"

