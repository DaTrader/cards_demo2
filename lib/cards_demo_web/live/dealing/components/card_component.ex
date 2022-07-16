defmodule CardsDemoWeb.Dealing.CardComponent do
  @moduledoc false

  #########################
  # LiveComponent behaviour
  #

  use Phoenix.LiveComponent
  alias PhoenixLiveViewExt.{ Listiller, Listilled}
  alias CardsDemoWeb.DomMap

  @impl true
  def mount( socket) do
    { :ok, socket, temporary_assigns: [ entries: []]}
  end

  # Adds the list of entry assigns for entries as temporary assigns.
  @impl true
  def update( new_assigns, socket) do
    list_data = Listiller.apply( CardsDemoWeb.Dealing.EntryComponent, socket.assigns, new_assigns)

    socket =
      socket
      |> assign( new_assigns)
      |> Listilled.Helpers.assign_list( list_data)

    { :ok, socket}
  end


  ####################
  # Listilled behavior
  #

  alias PhoenixLiveViewExt.Listilled
  import CardsDemoWeb.Dealing.DeckView, only: [ elem_id: 1]
  import EMap, only: [ entity: 2]
  @behaviour Listilled
  @data_sources [ :deck]


  # Prepares the card dom_id list.
  @impl true
  def prepare_list( state) do
    with %{ deck: deck} <- state do
      { deck.cards, state}
    else
      _ -> { [], state}
    end
  end

  # Returns card_id as component_id (dom_id)
  @impl true
  def component_id( card_id, _) do
    elem_id( card_id)
  end

  # Checks if any of the state value changed
  @impl true
  def state_changed?( old_state, new_state) do
    Enum.any?( @data_sources, &new_state[ &1] != old_state[ &1])
  end

  # Constructs new Card assigns from the provided Deck state.
  @impl true
  def construct_assigns( state, card_id) do
    card = entity( state.deck, card_id)

    %{
      id: component_id( card_id, state),
      card: card,
      dom_map: DomMap.keep( state.dom_map, card.keys)
    }
  end


  ##########
  # Template
  #

  require PhoenixLiveViewExt.MultiRender
  @before_compile PhoenixLiveViewExt.MultiRender
  import PhoenixLiveViewExt.Listilled.Helpers

  @impl true
  def render( %{ updated: :delete} = assigns) do
    ~L"""
    <div id={"dln-card-#{@id}"} data-delete="true"></div>
    """
  end

  def render( assigns) do
    render( "card_component_t.html", assigns)
  end
end
