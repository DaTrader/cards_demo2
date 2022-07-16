defmodule MapUtils do
  @moduledoc "Provides utility functions for maps."

  @doc """
  Deep-merges the right map into the left map.
  """
  @spec deep_merge( map(), map()) :: map()
  def deep_merge( left, right) do
    Map.merge( left, right, &deep_resolve/3)
  end

  defp deep_resolve( _key, left = %{}, right = %{}) do
    deep_merge( left, right)
  end

  defp deep_resolve( _key, _left, right) do
    right
  end


  @doc """
  Passes each key, value pair to the provided function and stores the resulting new key value pair in a new map.
  Skips when function returns nil or false.
  """
  @spec take( map(), ( { any(), any()} -> { any(), any()})) :: map()
  def take( map, fun) when is_map( map) and is_function( fun) do
    for kv <- map,
        new_kv = fun.( kv), # skips if untruthy e.g. nil
        into: %{},
        do: new_kv
  end


  @doc """
  Merges map2 into map1 by replacing values in map1 for each key in map2.
  Raises KeyError if a key from map2 does not already exist in map1.
  """
  @spec merge!( map(), map()) :: map()
  def merge!( map1, map2) do
    for { k, v} <- map2, reduce: map1 do
      acc -> Map.replace!( acc, k, v)
    end
  end

  @doc "Puts a value in the map unless it is nil in which case returns the map unchanged."
  @spec put_unless_nil( map(), any(), any()) :: map()
  def put_unless_nil( map, _, nil), do: map

  def put_unless_nil( map, key, value) do
    Map.put( map, key, value)
  end


  @doc "Puts a value in the map unless the key already exists in which case raises an ArgumentError."
  @spec put_new!( map(), any(), any()) :: map()
  def put_new!( map, key, _) when is_map_key( map, key) do
    raise ArgumentError, "Key #{ key} is already present in the map!"
  end

  def put_new!( map, key, value) do
    Map.put( map, key, value)
  end


  @doc "Checks if two maps have the same keys."
  @spec same_keys?( map(), map()) :: boolean()
  def same_keys?( map1, map2) do
    map_size( map1) == map_size( map2) and Enum.all?( map1, fn { k, _} -> Map.has_key?( map2, k) end)
  end
end
