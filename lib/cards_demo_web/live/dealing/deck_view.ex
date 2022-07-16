defmodule CardsDemoWeb.Dealing.DeckView do
  @moduledoc """
  Defines helper functions used by DeckView template and its LiveComponents and effectively renders the
  DeckView template.
  """
  use CardsDemoWeb, :view


  @doc "Returns dom_id (elem_id) codified into 36 base Integer string (to occupy less space)"
  @spec elem_id( EMap.Id.t()) :: String.t()
  def elem_id( id) do
    Integer.to_string( id, 36)
  end


  ###################
  # DeckView template
  #

  require PhoenixLiveViewExt.MultiRender
  @multi_render_fun :prerender
  @before_compile PhoenixLiveViewExt.MultiRender
  import PhoenixLiveViewExt.Listilled.Helpers, only: [ phx_update: 1]

  def prerender( assigns) do
    prerender( "deck_view.html", assigns)
  end
end
