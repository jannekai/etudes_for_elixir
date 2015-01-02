
defmodule CallRecord do
  defstruct [
    number: nil, 
    start_date: "1900-01-01", 
    start_time: "00:00:00", 
    end_date: "1900-01-01", 
    end_time: "00:00:00"
  ]
end

defmodule PhoneETS do

  require Logger

  def setup(file_name) do
    {:ok, device} = File.open(file_name, [:read, :utf8])
    :ets.new(:calls, [:bag, :protected, :named_table])
    read_and_store_entries(device, IO.read(device, :line))
  end  

  defp read_and_store_entries(_device, :eof), do: {}
  defp read_and_store_entries(device, line) do
    [number, start_date, start_time, end_date, end_time] = line |> String.strip() |> String.split(",")
    record = %CallRecord{number: number, start_date: start_date, start_time: start_time, end_date: end_date, end_time: end_time}
    :ets.insert(:calls, {number, record})
    read_and_store_entries(device, IO.read(device, :line))
  end

  def summary() do
    result = summary(:ets.tab2list(:calls), %{})
    Logger.debug "#{inspect result}"
  end

  defp summary([], result), do: result
  defp summary([{key, entry} | t], result) do    
    result = Dict.put_new(result, key, 0)
    begin = :calendar.datetime_to_gregorian_seconds(string_to_datetime(entry.start_date, entry.start_time))
    finish = :calendar.datetime_to_gregorian_seconds(string_to_datetime(entry.end_date, entry.end_time))
    duration = div(finish - begin + 59, 60)
    result = Dict.put(result, key, result[key] + duration)
    Logger.debug "#{inspect key} #{inspect entry} #{inspect begin} #{inspect finish} #{inspect duration}"
    summary(t, result)
  end

  defp string_to_datetime(date, time) do
    [year, month, day] = for s <- String.split(date, "-"), do: String.to_integer(s)
    [hour, minute, second] = for s <- String.split(time, ":"), do: String.to_integer(s)
    {{year, month, day}, {hour, minute, second}}
  end

end

PhoneETS.setup("etudes_11.csv")
PhoneETS.summary()
