
defmodule Cards do

  def make_deck do
    suits = ["Clubs", "Diamonds", "Hearts", "Spades"]
    ranks = [14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2]
    for rank <- ranks, suite <- suits, do: {rank, suite}
  end

  def shuffle(deck) do
    :random.seed(:erlang.now())
    shuffle(deck, [])
  end

  defp shuffle([], acc), do: acc
  defp shuffle(deck, acc) do
    {leading, [h | t]} = Enum.split(deck, :random.uniform(Enum.count(deck)) - 1)
    shuffle(leading ++ t, [h | acc])
  end

end

defmodule Player do

  require Logger

  def start_link() do
    {:ok, spawn_link(fn -> handle([]) end)}
  end

  defp handle(cards) do
    receive do
      {:start, sender, newcards} -> (
        Logger.debug("#{inspect newcards}")
        send sender, { :ok }
        handle(newcards)
      )
      {:stop} -> Logger.debug "#{inspect self()} stopping"
    end
  end
end

defmodule Game do

  require Cards
  require Player
  require Logger

  def start() do
    deck = Cards.make_deck |> Cards.shuffle    
    {:ok, p1} = Player.start_link
    {:ok, p2} = Player.start_link
    
    Logger.debug "#{inspect p1} #{inspect p2}"

    state = %{:p1 => p1, :p2 => p2, :deck => deck}
    
    game_loop(:deal, state)    
  end

  def game_loop(:deal, state) do
    {p1_cards, p2_cards} = Enum.split(state[:deck], 26)
    send state[:p1], {:start, self, p1_cards}
    send state[:p2], {:start, self, p2_cards}
    game_loop(:wait_deal, state, 0)
  end

  def game_loop(:wait_deal, _state, 2) do
    Logger.debug "Dealt cards"
  end

  def game_loop(:wait_deal, state, clients_initialized) do
    receive do
      {:ok} -> game_loop(:wait_deal, state, clients_initialized + 1)
      after 1000 -> Logger.error "Timeout in wait_deal, exiting"
    end
  end

end

Game.start()
