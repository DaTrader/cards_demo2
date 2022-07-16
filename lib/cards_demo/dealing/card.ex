defmodule CardsDemo.Dealing.Card do
  @moduledoc false

  alias CardsDemo.Dealing.{ Card, Enjoyable}

  @typep criterion() :: String.t() | [ String.t()] | criteria()
  @typep criteria() :: Keyword.t( criterion())
  @typep entry_key() :: Enjoyable.entry_key()
  @type t() :: %__MODULE__{
                 entries: %{ entry_key() => Enjoyable.t()},
                 keys: [ entry_key()],
                 criteria: criteria()
               }
  defstruct entries: %{},
            keys: [],
            criteria: []

  @spec new( criteria()) :: t()
  def new( criteria \\ []) when is_list( criteria) do
    %Card{
      criteria: criteria
    }
  end

  @doc """
  Updates the Card entry list anew from the provided resource (a Stream).
  Raises if any of the keys is listed twice.
  """
  @spec update( t(), Enumerable.t()) :: t()
  def update( card, resource) do
    for entry <- resource, reduce: Card.new( card.criteria) do
      card ->
        key = Enjoyable.key( entry)
        %Card{
          entries: MapUtils.put_new!( card.entries, key, entry),
          keys: ListUtils.list_add( card.keys, key)
        }
    end
  end
end
