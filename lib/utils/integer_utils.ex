defmodule IntegerUtils do
  @moduledoc "Integer related utilities"

  defguard is_non_neg_integer( term) when is_integer( term) and term >= 0

  @doc """
  Returns integer if integer or string convertible to integer.
  Raises ArgumentError otherwise.
  """
  @spec int!( term()) :: integer()
  def int!( num) when is_integer( num), do: num
  def int!( str) when is_bitstring( str) do
    String.to_integer( str)
  end

  @doc """
  Returns integer if integer or string convertible to integer.
  Returns nil otherwise.
  """
  def int( num) when is_integer( num), do: num
  def int( str) when is_bitstring( str) do
    case Integer.parse( str) do
      { int, _rem} -> int
      _ -> nil
    end
  end
  def int( _), do: nil


  @doc "Integer to the power of"
  @spec pow( integer(), non_neg_integer()) :: integer()
  def  pow( n, k) when is_integer( n) and is_non_neg_integer( k), do: pow( n, k, 1)
  defp pow( _, 0, acc), do: acc
  defp pow( n, k, acc), do: pow( n, k - 1, n * acc)

end
