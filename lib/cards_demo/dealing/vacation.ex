defmodule CardsDemo.Dealing.Vacation do
  @moduledoc false
  alias CardsDemo.Dealing.Vacation

  @typep uuid() :: UUIDUtils.uuid()
  @type t() :: %__MODULE__{
                 id: uuid(),
                 summary: String.t()
               }
  defstruct id: nil,
            summary: nil

  def new( id, summary) do
    %Vacation{
      id: id,
      summary: summary
    }
  end

  def key( vacation) do
    { :vacation, vacation.id}
  end
end

alias CardsDemo.Dealing.{ Enjoyable, Vacation}

defimpl Enjoyable, for: Vacation do
  def key( enjoyable), do: Vacation.key( enjoyable)
end
