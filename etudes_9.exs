defmodule Deck do

  def new do
    suits = ["Clubs", "Diamonds", "Hearts", "Spades"]
    ranks = [14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2]
    for rank <- ranks, suite <- suits, do: {rank, suite}
  end

  def shuffle(deck) do
    :random.seed(:erlang.now())
    shuffle(deck, [])
  end

  defp shuffle([], acc) do
    acc
  end

  defp shuffle(deck, acc) do
    {leading, [h | t]} = Enum.split(deck, :random.uniform(Enum.count(deck)) - 1)
    shuffle(leading ++ t, [h | acc])
  end

end

defmodule Player do

  require Logger

  def start_link(cards) do
    Logger.debug("Starting player process #{inspect self()} with #{inspect cards}")
    {:ok, spawn_link(fn -> handle_msg(cards) end)}
  end

  defp handle_msg(cards) do
    receive do
      {:battle, dealer} -> handle_msg(handle_battle(cards, dealer))
      {:war, dealer} -> handle_msg(handle_war(cards, dealer))
      {:cards, received_cards} -> handle_msg([cards | received_cards])
      {:stop} -> 
        Logger.debug "#{inspect self()} #{inspect cards} stopping"
    end
  end

  defp handle_battle(cards, dealer) do
    Logger.debug("Received :battle request from #{inspect dealer} #{inspect cards}")
  end

  defp handle_war(cards, dealer) do 
    Logger.debug("Received :war request from #{inspect dealer} #{inspect cards}")
  end

end

defmodule Game do

  require Deck
  require Player
  require Logger

  def run() do
    {p1_cards, p2_cards} = Deck.new |> Deck.shuffle |> Enum.split 26
    {:ok, p1} = Player.start_link(p1_cards)
    {:ok, p2} = Player.start_link(p2_cards)
        
    state = %{:players => [p1, p2], :board => [], :responses => 0}

    Logger.debug "Begin game #{inspect state}"

    game_loop(:begin, state)
  end

  defp game_loop(:begin, state) do
    type = round_type(state)
    for pid <- state[:players] do
      Logger.debug("Sending #{inspect type} to #{inspect pid}")
      send(pid, {round_type(state), self()})
    end
    state = %{state | :responses => 0}
    Logger.debug "Begin round #{inspect state}"
    game_loop(:wait, state)    
  end

  defp game_loop(:wait, %{responses: 2} = state) do
    Logger.debug "Received cards from all players #{inspect state}"
  end

  defp game_loop(:wait, state) do
    receive do
      {:ok} -> game_loop(:wait_players, %{state | :responses => state[:responses] + 1})
      after 1000 -> Logger.error "Timeout in wait_deal, exiting #{inspect state})"
    end
  end

  defp round_type(%{board: []} = _state), do: :battle
  defp round_type(%{} = _state), do: :war

end

Game.run()
