defmodule CardsDemo.Dealing.Deck do
  @moduledoc false

  import OOUtils
  alias CardsDemo.Dealing.{ Deck, Card}

  @type card_id() :: EMap.Id.t()
  @type t() :: %__MODULE__{
                 cards: [ card_id()],
               }
  defextends EMap,
             cards: []


  def new() do
    %Deck{}
  end

  @spec add_card( t(), Card.t()) :: { t(), card_id()}
  def add_card( deck, %Card{} = card) do
    EMap.add_entity( deck, :cards, card)
  end
end
