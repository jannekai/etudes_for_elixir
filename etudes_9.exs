defmodule Deck do

  def make do
    suits = ["Clubs", "Diamonds", "Hearts", "Spades"]
    ranks = [14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2]
    for rank <- ranks, suite <- suits, do: {rank, suite}
  end

  def make_test do 
    suits = ["Clubs", "Diamonds"]
    ranks = [5, 4, 3, 2]
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

defmodule PlayerState do
  defstruct id: nil, cards: []
end


defmodule Player do

  require Logger
  require PlayerState

  def start_link(id, cards) do
    state = %PlayerState{id: id, cards: cards}
    Logger.debug("Starting player process #{inspect state}")
    {:ok, spawn_link(fn -> handle_msg(state) end)}
  end

  defp handle_msg(%PlayerState{} = state) do
    receive do
      {:draw, sender, count} -> handle_msg(handle_draw(state, sender, count))
      {:cards, cards} -> handle_msg(handle_cards(state, cards))
      {:stop} -> 
        Logger.debug "#{inspect state} stopping"
    end
  end

  defp handle_draw(%PlayerState{} = state, sender, count) do
    Logger.debug("Received draw request #{inspect state} #{inspect count}")
    {drawn, rest} = Enum.split(state.cards, count)
    send(sender, {:ok, state.id, drawn})
    %{state | cards: rest}
  end

  defp handle_cards(%PlayerState{} = state, cards) do 
    Logger.debug("Received new cards #{inspect cards} #{inspect state}")
    %{state | cards: state.cards ++ cards}
  end

end

defmodule GameState do
  defstruct players: [], board: [], p1: nil, p2: nil
end

defmodule Game do

  require Deck
  require Player
  require Logger
  require GameState

  def run() do
    deck = Deck.make_test |> Deck.shuffle
    {p1_cards, p2_cards} = Enum.split(deck, trunc(Enum.count(deck) / 2))
    {:ok, p1} = Player.start_link(:p1, p1_cards)
    {:ok, p2} = Player.start_link(:p2, p2_cards)

    state = %GameState{players: [p1, p2], p1: p1, p2: p2}

    Logger.debug "Begin game #{inspect state}"

    begin_round(state, 1)
  end

  defp begin_round(%GameState{} = state, num_cards) do
    Logger.debug "Requesting cards #{inspect state} #{num_cards}"
    for pid <- state.players, do: send(pid, {:draw, self(), num_cards})
    wait_cards(state, [], [], 0)
  end

  defp wait_cards(%GameState{} = state, [p1_card|_] = p1_cards, [p2_card|_] = p2_cards, 2) do
    Logger.debug "Received cards from all players #{inspect state} #{inspect p1_card} #{inspect p1_cards} #{inspect p2_card} #{inspect p2_cards}"    

    cond do
      elem(p1_card, 0) > elem(p2_card, 0) ->
        send(state.p1, {:cards, state.board ++ p1_cards ++ p2_cards})
        state = %{state | board: []}
        begin_round(state, 1)
      elem(p2_card, 0) > elem(p1_card, 0) ->
        send(state.p2, {:cards, state.board ++ p1_cards ++ p2_cards})
        state = %{state | board: []}
        begin_round(state, 1)
      true ->         
        begin_round(state, 3)
    end    
  end

  defp wait_cards(%GameState{} = state, p1_cards, p2_cards, responses) do
    receive do
      {:ok, id, []} -> finish_game(state, id)
      {:ok, :p1, cards} -> wait_cards(state, cards, p2_cards, responses + 1)
      {:ok, :p2, cards} -> wait_cards(state, p1_cards, cards, responses + 1)
      after 1000 ->  Logger.error "Timeout in wait_deal, exiting #{inspect state})"
    end
  end

  defp finish_game(state, loser) do
    Logger.debug "Finished game, loser was: #{loser} #{inspect state}"
  end

end

Game.run()
