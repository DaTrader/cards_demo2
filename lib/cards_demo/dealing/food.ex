defmodule CardsDemo.Dealing.Food do
  @moduledoc false
  alias CardsDemo.Dealing.Food

  @typep uuid() :: UUIDUtils.uuid()
  @type t() :: %__MODULE__{
                 id: uuid(),
                 summary: String.t()
               }
  defstruct id: nil,
            summary: nil

  def new( id, summary) do
    %Food{
      id: id,
      summary: summary
    }
  end

  def key( food) do
    { :food, food.id}
  end
end

alias CardsDemo.Dealing.{ Enjoyable, Food}

defimpl Enjoyable, for: Food do
  def key( enjoyable), do: Food.key( enjoyable)
end
