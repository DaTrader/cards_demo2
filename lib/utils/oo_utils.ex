defmodule OOUtils do
  @moduledoc false

  defmacro defextends( ancestors, { :%{}, _, _} = defaults, fields) when is_list( ancestors) do
    quote do
      for struct <- unquote( ancestors),
          map = Map.from_struct( struct),
          reduce: %{}
        do
        acc -> Map.merge( acc, map)
      end
      |> MapUtils.merge!( unquote( defaults))
      |> Map.merge( Map.new( unquote( fields)), fn k, _, _ -> raise( ArgumentError, "Duplicate field #{ k}!") end)
      |> Map.to_list()
      |> defstruct()
    end
  end

  defmacro defextends( ancestors, { :%{}, _, _} = defaults) when is_list( ancestors) do
    quote do
      defextends( unquote( ancestors), unquote( defaults), [])
    end
  end

  defmacro defextends( ancestors, fields) when is_list( ancestors) do
    quote do
      defextends( unquote( ancestors), %{}, unquote( fields))
    end
  end

  defmacro defextends( parent, { :%{}, _, _} = defaults, fields) do
    quote do
      defextends( [ unquote( parent)], unquote( defaults), unquote( fields))
    end
  end

  defmacro defextends( parent, { :%{}, _, _} = defaults) do
    quote do
      defextends( [ unquote( parent)], unquote( defaults), [])
    end
  end

  defmacro defextends( parent, fields) do
    quote do
      defextends( [ unquote( parent)], %{}, unquote( fields))
    end
  end

  defmacro defextends( ancestors) when is_list( ancestors) do
    quote do
      defextends( unquote( ancestors), %{}, [])
    end
  end

  defmacro defextends( parent) do
    quote do
      defextends( [ unquote( parent)], %{}, [])
    end
  end
end
