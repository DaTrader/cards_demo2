defmodule ListUtils do
  @moduledoc "List related utilities"
  import IntegerUtils, only: [ is_non_neg_integer: 1]

  @doc "Adds element to list at the specified index or last if index is omitted."
  @spec list_add( [ any()], integer() | :last, any()) :: [ any()]
  def list_add( list, index \\ :last, elem)

  def list_add( [], _, elem) do
    [ elem]
  end

  def list_add( list, :last, elem) when is_list( list) do
    [ elem | Enum.reverse( list)] |> Enum.reverse()
  end

  def list_add( list, 0, elem) when is_list( list) do
    [ elem | list]
  end

  def list_add( list, index, elem) when is_list( list) do
    List.insert_at( list, index, elem)
  end


  @doc "Moves element from one position in the list to another."
  @spec list_move( [ any()], dst_x :: non_neg_integer(), src_x :: non_neg_integer()) :: [ any()]
  def list_move( list, dst, src) when is_list( list) and is_non_neg_integer( dst) and is_non_neg_integer( src) do
    src != dst &&
      case List.pop_at( list, src) do
        { nil, _} -> list
        { e, rest} -> List.insert_at( rest, dst, e)
      end
    || list
  end


  @doc "Returns the second element in the list or nil if there isn't any."
  @spec second( list()) :: any() | nil
  def second( []), do: nil
  def second( [ _only_one]), do: nil
  def second( [ _ | [ second | _]]), do: second


  @doc "Returns the second to last element in the list or nil if there isn't any."
  @spec penultimate( list()) :: any() | nil
  def penultimate( list) do
    list
    |> Enum.reverse()
    |> second()
  end
end
