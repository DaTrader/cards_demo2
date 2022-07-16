defmodule RandomUtils do
  @moduledoc false

  @doc """
  Returns a hash of a string made up of the provided string and a stringified make_ref (a unique for each node).
  """
  @spec unique_random( Socket.t()) :: String.t()
  def unique_random( socket_id) when is_bitstring( socket_id) do
    make_ref()
    |> :erlang.ref_to_list()
    |> List.to_string()
    |> then( &"#{ socket_id}.#{ &1}")
    |> then( &:crypto.hash( :md5, &1))
    |> Base.encode64( padding: false)
  end
end
