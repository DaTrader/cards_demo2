defprotocol CardsDemo.Dealing.Enjoyable do
  @moduledoc false

  @typep uuid() :: UUIDUtils.uuid()
  @type class() :: atom()
  @type entry_key() :: { class(), uuid()}
  @type t() :: term()

  @doc "Returns the Enjoyable entry's key"
  @spec key( t()) :: entry_key()
  def key( enjoyable)
end
