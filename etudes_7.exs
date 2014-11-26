
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

defprotocol Valid do
  @doc "Returns true if data is considered valid"
  def valid?(data)
end

defmodule Geography do

  defimpl Valid, for: City do 
    def valid?(city) do
      cond do
        city.population < 0 -> false
        city.latitude < -90.0 -> false
        city.latitude > 90.0 -> false
        city.longitude < -180.0 -> false
        city.longitude > 180.0 -> false
        true -> true
      end
    end
  end

  defimpl Inspect, for: City do 
    import Inspect.Algebra

    def inspect(city, _opts) do
      lat = if city.latitude < 0 do
        concat(to_string(Float.round(abs(city.latitude * 1.0), 2)), "°S")
      else
        concat(to_string(Float.round(city.latitude * 1.0, 2)), "°N")
      end

      lon = if city.longitude < 0 do
        concat(to_string(Float.round(abs(city.longitude * 1.0), 2)), "°W")
      else
        concat(to_string(Float.round(city.longitude * 1.0, 2)), "°E")
      end      
      concat [city.name, " (", Integer.to_string(city.population), ") ", lat, " ", lon]
    end
  end

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
    city = %City{
      name: name, 
      population: String.to_integer(population), 
      latitude: String.to_float(latitude), 
      longitude: String.to_float(longitude)
    }
    [%{current | cities: [city | current.cities]} | countries]
  end

  def total_population(countries, language) do
    total_population(countries, language, 0)
  end

  defp total_population([], _language, sum), do: sum

  defp total_population([country | tail], language, sum) do
    cond do
      country.language == language -> total_population(tail, language, total_city_population(country.cities, sum))
      true -> total_population(tail, language, sum)
    end   
  end

  defp total_city_population([], sum), do: sum
  defp total_city_population([city | tail], sum) do
    total_city_population(tail, city.population + sum)
  end

end

defmodule Run do 
  def run do
    IO.puts "#{inspect College.make_room_list("test.csv")}"
    data = Geography.make_geo_list("geography.csv")
    IO.puts "#{inspect data}"
    IO.puts "German speakers #{inspect Geography.total_population(data, "German")}"
    IO.puts "Spanish speakers #{inspect Geography.total_population(data, "Spanish")}"
    IO.puts "Korean speakers #{inspect Geography.total_population(data, "Korean")}"

    city = %City{name: "Hamburg", population: 1739117, latitude: 53.57532, longitude: 10.01534}
    IO.puts "#{inspect city}"
    IO.puts Valid.valid?(city)
    city = %City{name: "Nowhere", population: -1000, latitude: 37.1234, longitude: -12.457}
    IO.puts "#{inspect city}"
    IO.puts Valid.valid?(city)
    city = %City{name: "Impossible", population: 1000, latitude: 135.0, longitude: 175}
    IO.puts "#{inspect city}"
    IO.puts Valid.valid?(city)
  end
end


Run.run
