defmodule CardsDemoWeb.Switchboard.SwitchLive do
  @moduledoc "Toggles between the two inner_content LiveView instances."
  use CardsDemoWeb, :live_view


  ##################
  # Mount and render
  #

  @impl true
  def mount( _params, session, socket) do
    socket =
      socket
      |> assign_account_ref( session[ "_csrf_token"])
      |> assign_aspect( "")

    { :ok, socket}
  end

  @impl true
  def handle_event( event, _payload, socket) do
    if event in [ "show_foo", "show_bar"] do
      broadcast_event( lv_account_ref!( socket), event)
    end

    { :noreply, socket}
  end

  @impl true
  @spec handle_info( term(), Socket.t()) :: { :noreply, Socket.t()}
  def handle_info( { :redirected, aspect}, socket) do
    { :noreply, assign_aspect( socket, String.trim( aspect, "show_"))}
  end

  def handle_info( _, socket), do: socket



  #################
  # EndPoint Pubsub
  #

  @doc """
  Subscribes the calling process to switchboard events.
  Makes sure the calling process is subscribed only once per topic.
  """
  @spec subscribe( String.t()) :: :ok | { :error, term()}
  def subscribe( topic) do
    topic = "aspect_#{ topic}"
    CardsDemoWeb.Endpoint.unsubscribe( topic)
    CardsDemoWeb.Endpoint.subscribe( topic)
  end

  @spec broadcast_event( String.t(), atom(), map()) :: :ok | { :error, term()}
  defp broadcast_event( topic, event, msg \\ %{}) do
    topic = "aspect_#{ topic}"
    CardsDemoWeb.Endpoint.broadcast( topic, event, Map.put( msg, :sender, self()))
  end


  #############
  # Redirection
  #

  @type renders_inner() :: ( map() -> Rendered.t())
  @type renders() :: ( map(), renders_inner() -> Rendered.t())


  @doc """
  Redirects if target_live module found and not the same as the one supplied in payload.
  Intended for invocation by aspect LiveView processes
  """
  @spec redirect_aspect( Socket.t(), map()) :: Socket.t()
  def redirect_aspect( socket, payload) do
    case get_target_module( payload.event, payload.module) do
      nil ->
        socket

      # Note: LiveView Issue #1520
      # LiveView JS fails to update the SwitchLive rendering if message sent to it straight away.
      # Comment the send() call below and uncomment the delayed one and it works.
      target_live_module ->
#        Process.send_after( payload.msg.sender, { :redirected, payload.event}, 1000, [])
        send( payload.msg.sender, { :redirected, payload.event})
        push_redirect( socket, to: Routes.live_path( socket, target_live_module, payload.params))
    end
  end

  # Gets the event target LiveView module unless same as the provided one
  @spec get_target_module( String.t(), module()) :: module()
  defp get_target_module( "show_foo", CardsDemoWeb.Foo.FooLive), do: nil
  defp get_target_module( "show_bar", CardsDemoWeb.Bar.BarLive), do: nil
  defp get_target_module( "show_foo", _), do: CardsDemoWeb.Foo.FooLive
  defp get_target_module( "show_bar", _), do: CardsDemoWeb.Bar.BarLive


  ################
  # Assigned state
  #

  defp lv_account_ref!( socket) do
    socket.assigns.account_ref
  end

  defp assign_account_ref( socket, account_ref),
       do: assign( socket, :account_ref, account_ref)

  defp assign_aspect( socket, aspect),
       do: assign( socket, :aspect, aspect)
end
