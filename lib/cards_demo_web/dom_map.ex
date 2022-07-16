defmodule CardsDemoWeb.DomMap do
  @moduledoc """
  Maps domain ids to enumerated dom_ids to hide the original complexity of the domain ids and/or to mitigate their
  incompatibility with DOM id restrictions (the permitted character subset).
  """

  @typep id() :: any()
  @type dom_id() :: non_neg_integer()
  @type t() :: %__MODULE__{
                 auto_id: non_neg_integer(),
                 dom_ids: %{ id() => dom_id()}
               }
  defstruct auto_id: 0,
            dom_ids: %{}


  alias CardsDemoWeb.DomMap

  @doc "Returns new dom_layout structure"
  @spec new() :: t()
  def new() do
    %DomMap{}
  end

  @doc "Returns a DOM layout element id mapped to the provided id."
  @spec dom_id( t(), id()) :: dom_id()
  def dom_id( dom_map, id) do
    dom_map.dom_ids[ id]
  end

  @doc "Maps new dom_ids to the provided ids. Skips duplicates if any."
  @spec map_ids( t(), Enumerable.t( id())) :: t()
  def map_ids( dom_map, ids) do
    for id <- ids,
        !DomMap.dom_id( dom_map, id),
        reduce: dom_map
      do
      dom_map ->
        dom_id = dom_map.auto_id + 1

        %DomMap{
          dom_map |
          auto_id: dom_id,
          dom_ids: Map.put( dom_map.dom_ids, id, dom_id)
        }
    end
  end

  @doc "Keeps only the dom element ids mapped to the provided ids."
  @spec keep( t(), [ id()]) :: t()
  def keep( dom_map, ids) do
    update_in( dom_map.dom_ids, &Map.take( &1, ids))
  end
end
