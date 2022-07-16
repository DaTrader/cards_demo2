defmodule CardsDemo.Dealing.Game do
  @moduledoc false
  alias CardsDemo.Dealing.Game

  @typep uuid() :: UUIDUtils.uuid()
  @type t() :: %__MODULE__{
                 id: uuid(),
                 summary: String.t()
               }
  defstruct id: nil,
            summary: nil

  def new( id, summary) do
    %Game{
      id: id,
      summary: summary
    }
  end

  def key( game) do
    { :game, game.id}
  end
end

alias CardsDemo.Dealing.{ Enjoyable, Game}

defimpl Enjoyable, for: Game do
  def key( enjoyable), do: Game.key( enjoyable)
end
