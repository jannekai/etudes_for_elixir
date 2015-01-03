
defmodule WeatherSupervisor do
end

defmodule Weather do
  use GenServer

  require Logger

  def start_link(opts \\ []) do
    Logger.debug "Starting GenServer process #{__MODULE__}"
    GenServer.start_link(__MODULE__, [], [{:name, __MODULE__}])
  end

  def init([]) do
    :inets.start()
    {:ok, []}
  end

  def handle_call(station, _from, state) do
    url = "http://w1.weather.gov/xml/current_obs/#{station}.xml"
    {result, {{_, code, code_message}, _options, content}} = :httpc.request(String.to_char_list(url))

    case code do
      200 -> 
        response = parse_result(List.to_string(content))
      _ -> 
        response = {:error, "#{inspect code} #{inspect code_message}"}
    end    
    {:reply, response, state}
  end

  defp parse_result(content) do
    location = get_element("location", content)
    observation_time = get_element("observation_time_rfc822", content)
    weather = get_element("weather", content)
    temperature = get_element("temperature_string", content)

    {:ok, [location: location, observation_time: observation_time, weather: weather, temperature: temperature]}
  end

  defp get_element(element_name, xml) do
    {:ok, pattern} = Regex.compile("<#{element_name}>([^<]+)</#{element_name}>")
    case Regex.run(pattern, xml) do
      [_all, match] -> {element_name, match}
      nil -> {element_name, nil}
    end
  end

end

link = Weather.start_link()
IO.puts "#{inspect link}"
IO.puts "#{inspect GenServer.call(Weather, "KSJC")}"
IO.puts "#{inspect GenServer.call(Weather, "ABCD")}"
