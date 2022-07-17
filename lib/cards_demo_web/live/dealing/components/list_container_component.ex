defmodule CardsDemoWeb.Dealing.ListContainerComponent do
  @moduledoc false
  use Phoenix.LiveComponent

  @default_container_hook "ListillContainerHook"
  @default_tail_hook "ListillTailHook"

  @impl true
  def mount( socket) do
    socket =
      socket
      |> assign_new( :container_hook, fn -> @default_container_hook end)
      |> assign_new( :tail_hook, fn -> @default_tail_hook end)

    { :ok, socket}
  end

  # Returns a universal pseudo random string based on the socket id.
  @spec update_print( map()) :: String.t()
  defp update_print( assigns) do
    RandomUtils.unique_random( assigns.socket.id)
  end
end
