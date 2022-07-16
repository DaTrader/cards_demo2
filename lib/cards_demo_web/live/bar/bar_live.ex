defmodule CardsDemoWeb.Bar.BarLive do
  @moduledoc "Bar aspect"
  use CardsDemoWeb, :live_view

  @me __MODULE__
  @image_list [
    "https://image.shutterstock.com/shutterstock/photos/1908685945/display_1500/stock-photo-close-up-of-a-part-of-a-microprocessor-in-soft-focus-under-high-magnification-details-of-a-1908685945.jpg",
    "https://image.shutterstock.com/shutterstock/photos/1698227716/display_1500/stock-photo-golden-coins-with-bitcoin-symbol-on-a-mainboard-1698227716.jpg",
    "https://image.shutterstock.com/shutterstock/photos/1931369411/display_1500/stock-photo-fuerteventura-spain-january-a-super-electric-rimac-c-car-from-a-croatian-d-illustration-1931369411.jpg"
  ]
  @images @image_list |> Stream.with_index() |> Map.new( fn { k, v} -> { v, k} end)


  #######
  # Mount
  #

  @impl true
  def mount( params, session, socket) do
    account_ref = lv_account_ref( socket) || session[ "_csrf_token"]
    params = lv_params( socket) || params

    if connected?( socket) do
      CardsDemoWeb.Switchboard.SwitchLive.subscribe( account_ref)
    end

    socket =
      socket
      |> assign_account_ref( account_ref)
      |> assign_params( params)
      |> assign_image( @images[ image_index( params[ "image"])])

    { :ok, socket}
  end


  ######################################
  # Handling switch's broadcast messages
  #

  @impl true
  def handle_info( %Phoenix.Socket.Broadcast{} = msg, socket) do
    params = lv_params!( socket)
    params = Map.put( params, "image", "#{ image_index( params[ "image"]) + 1}")

    socket = CardsDemoWeb.Switchboard.SwitchLive.redirect_aspect( socket, %{
      event: msg.event,
      msg: msg.payload,
      module: @me,
      params: params
    })

    { :noreply, socket}
  end

  def handle_info( _, socket), do: socket


  @spec image_index( String.t() | nil) :: non_neg_integer()
  defp image_index( nil), do: 0
  defp image_index( index_str) do
    with { image_index, _} <- Integer.parse( index_str) do
      rem( image_index, map_size( @images))
    else
      _ -> 0
    end
  end


  ###############
  # State assigns
  #

  defp lv_account_ref( socket), do: socket.assigns[ :account_ref]

  defp lv_params( socket), do: socket.assigns[ :params]
  defp lv_params!( socket), do: socket.assigns.params

  defp assign_account_ref( socket, account_ref),
       do: assign( socket, :account_ref, account_ref)

  defp assign_params( socket, params),
       do: assign( socket, :params, params)

  defp assign_image( socket, image_url),
       do: assign( socket, :image, image_url)
end
