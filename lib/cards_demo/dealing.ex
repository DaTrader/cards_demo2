defmodule CardsDemo.Dealing do
  @moduledoc false

  alias CardsDemo.Dealing.{ Card, Vacation, Game}

  def fetch( card, opts) do
    creates_entry =
      cond do
        Keyword.has_key?( card.criteria, :destination) ->
          &Vacation.new( new_uuid( opts), "Vacation #{ &1}")

        Keyword.has_key?( card.criteria, :players) ->
          &Vacation.new( new_uuid( opts), "Game #{ &1}")

        Keyword.has_key?( card.criteria, :genre) ->
          &Game.new( new_uuid( opts), "Food #{ &1}")

        true ->
          nil
      end

    creates_entry && Card.update( card, resource( card.criteria, creates_entry)) || card
  end

  # Generates a sample resource for use by Card.update/2
  @spec resource( Card.criteria(), ( non_neg_integer() -> term())) :: Enumerable.t()
  defp resource( _card_criteria, creates_entry) do
    Stream.resource(
      fn -> 0 end,
      fn
        i when i in 0 .. 9 ->
          { [ creates_entry.( i)], i + 1}

        i ->
          { :halt, i}
      end,
      fn i -> i end
    )
  end

  defp new_uuid( opts) when is_list( opts) do
    RandomUtils.unique_random( Keyword.get( opts, :socket_id))
  end
end
