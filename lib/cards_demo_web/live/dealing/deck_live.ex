defmodule CardsDemoWeb.Dealing.DeckLive do
  @moduledoc "Running independently of other LiveViews in the App."
  use CardsDemoWeb, :live_view

  ###############################
  # Mount, render and termination
  #

  @impl true
  def mount( _params, _session, socket) do
    fake_event();
    { :ok, initialize( socket), temporary_assigns: [ cards: []]}
  end

  @impl true
  def render( assigns) do
    # Note: skipping the static rendering here is a workaround to circumvent the LiveView Issue #1479 i.e.
    #       the diffing between the first and the second mount/render which the JS hooks never get notified of
    if connected?( assigns.socket) do
      CardsDemoWeb.Dealing.DeckView.prerender( assigns)
    else
      ~L""
    end
  end


  ####################
  # Presentation logic
  #

  alias CardsDemo.Dealing
  alias CardsDemo.Dealing.{ Deck, Card}
  alias CardsDemoWeb.DomMap
  alias PhoenixLiveViewExt.{ Listiller, Listilled}
  import EMap, only: [ entity: 2]

  # Initializes the LiveView state
  @spec initialize( Socket.t()) :: Socket.t()
  defp initialize( socket) do
    socket
    |> load_deck()
    |> build_cards( %{})
  end


  @impl true
  def handle_info( :fake_change, socket) do
    deck = lv_deck!( socket)

    deck =
      EMap.update_entity( deck, List.first( deck.cards), fn card ->
        %Card{
          card |
          keys: ListUtils.list_move( card.keys, 0, length( card.keys) - 1)
        }
      end)

    socket =
      socket
      |> assign_deck( deck)
      |> build_dom_map()
      |> build_cards( socket.assigns)

    fake_event()

    { :noreply, socket}
  end

  defp fake_event() do
    Process.send_after( self(), :fake_change, 3000)
  end


  # Distills and assigns cards that result inserted, deleted or updated in the socket relative to their old state.
  @spec build_cards( Socket.t(), map()) :: Socket.t()
  defp build_cards( socket, old_assigns) do
    list_data = Listiller.apply( CardsDemoWeb.Dealing.CardComponent, old_assigns, socket.assigns)

    Listilled.Helpers.assign_list( socket, list_data)
  end


  # Loads and assigns a dealing deck data structure
  @spec load_deck( Socket.t()) :: Socket.t()
  defp load_deck( socket) do
    socket
    |> assign_deck( prototype_deck( socket))
    |> build_dom_map()
  end

  # Builds a dom map of Card entry ids and assigns it to the socket
  # Requires deck be already assigned to the socket.
  @spec build_dom_map( Socket.t()) :: Socket.t()
  defp build_dom_map( socket) do
    deck = lv_deck!( socket)

    # Concatenate all card keys into a single list - mounts top down
#    entry_keys =
#      for card_id <- deck.cards,
#          card = entity( deck, card_id),
#          reduce: []
#        do
#        entry_keys -> entry_keys ++ card.keys
#      end

    # Put all card keys into a single MapSet - mounts elements in a non-orderly fashion.
    # Works only with the workaround in render/1, otherwise results in untreated diffing-incurred
    # order of element mounting.
    entry_keys =
      for card_id <- deck.cards,
          card = entity( deck, card_id),
          reduce: MapSet.new()
        do
        entry_keys -> MapSet.union( entry_keys, MapSet.new( card.keys))
      end

    assign_dom_map( socket, DomMap.map_ids( lv_dom_map( socket) || DomMap.new(), entry_keys))
  end


  # Prototypes a Deck
  @spec prototype_deck( Socket.t()) :: Deck.t()
  defp prototype_deck( socket) do
    Deck.new()
    |> Deck.add_card(
         [ destination: "Bora Bora"]
         |> Card.new()
         |> fetch_card( socket)
       )
    |> elem( 0)
    |> Deck.add_card(
         [ destination: "Aspen"]
         |> Card.new()
         |> fetch_card( socket)
       )
    |> elem( 0)
    |> Deck.add_card(
         [ destination: "Dubrovnik"]
         |> Card.new()
         |> fetch_card( socket)
       )
    |> elem( 0)
    |> Deck.add_card(
         [ genre: "RPG"]
         |> Card.new()
         |> fetch_card( socket)
       )
    |> elem( 0)
  end

  defp fetch_card( card, socket) do
    Dealing.fetch( card, socket_id: socket.id)
  end



  ################################
  # LiveView State getters/setters
  #

  defp lv_deck!( socket) do
    socket.assigns.deck
  end

  defp assign_deck( socket, deck) do
    assign( socket, :deck, deck)
  end

  defp lv_dom_map( socket) do
    socket.assigns[ :dom_map]
  end

  defp assign_dom_map( socket, dom_map) do
    assign( socket, :dom_map, dom_map)
  end
end
