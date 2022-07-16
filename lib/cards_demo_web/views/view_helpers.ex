defmodule CardsDemoWeb.ViewHelpers do
  @moduledoc """
  Defines commonly used functions by more than one LiveView view.
  """

  @doc "Returns a universal pseudo random string based on the socket id."
  @spec update_print( map()) :: String.t()
  def update_print( assigns) do
    RandomUtils.unique_random( assigns.socket.id)
  end
end
