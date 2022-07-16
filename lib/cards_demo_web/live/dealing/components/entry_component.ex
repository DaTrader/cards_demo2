defmodule CardsDemoWeb.Dealing.EntryComponent do
  @moduledoc false
  use Phoenix.LiveComponent


  ####################
  # Listilled behavior
  #

  alias PhoenixLiveViewExt.Listilled
  alias CardsDemo.Dealing.{ Vacation, Game, Food, Enjoyable}
  alias CardsDemoWeb.DomMap
  import CardsDemoWeb.Dealing.DeckView, only: [ elem_id: 1]
  @behaviour Listilled
  @data_sources [ :card]
  @typep assigns() :: map()
  @typep card_entry() :: Vacation.t() | Game.t() | Food.t()


  # Prepares the entry dom_id list.
  @impl true
  def prepare_list( %{ card: card} = state) do
    { card.keys, state}
  end

  def prepare_list( state) do
    { [], state}
  end


  # Checks if any of the state value changed
  @impl true
  def state_changed?( old_state, new_state) do
    Enum.any?( @data_sources, &new_state[ &1] != old_state[ &1])
  end


  # Constructs new card assigns from the provided Deck state.
  @impl true
  def construct_assigns( state, entry_key) do
    %{
      id: component_id( entry_key, state),
    }
    |> Map.merge( to_assigns( state.card.entries[ entry_key]))
  end


  # Returns entry_key as component_id (dom_id)
  # e.g. vacation-123, game-1423, ..
  @impl true
  def component_id( entry_key, state) do
    elem_id( DomMap.dom_id( state.dom_map, entry_key))
  end


  # Transforms a particular Card entry struct into assigns
  @spec to_assigns( card_entry()) :: assigns()
  defp to_assigns( %Vacation{} = vacation) do
    { class, _} = Enjoyable.key( vacation)

    %{
      class: class,
      summary: vacation.summary
    }
  end

  defp to_assigns( %Game{} = game) do
    { class, _} = Enjoyable.key( game)

    %{
      class: class,
      summary: game.summary
    }
  end

  defp to_assigns( %Food{} = food) do
    { class, _} = Enjoyable.key( food)

    %{
      class: class,
      summary: food.summary
    }
  end


  ##########
  # Template
  #

  require PhoenixLiveViewExt.MultiRender
  @before_compile PhoenixLiveViewExt.MultiRender
  import PhoenixLiveViewExt.Listilled.Helpers, only: [ updated_sort: 1]

  @impl true
  def render( %{ updated: :delete} = assigns) do
    ~L"""
    <div id={"dln-#{@id}"} data-delete="true"></div>
    """
  end

  def render( assigns) do
    render( "entry_component_t.html", assigns)
  end


  # Renders entry_component_t template content contingent on the content class
  @spec render_content( map()) :: Rendered.t()
  def render_content( %{ class: :vacation} = assigns) do
    render( "entry_component_vacation.html", assigns)
  end

  def render_content( %{ class: :game} = assigns) do
    render( "entry_component_game.html", assigns)
  end

  def render_content( %{ class: :food} = assigns) do
    render( "entry_component_food.html", assigns)
  end
end
