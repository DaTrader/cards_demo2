defmodule EMap do
  @moduledoc """
  Provides functions for managing a structure of mapped entities while maintaining their indices (keys).
  """

  defmodule Id do
    @moduledoc """
    Provides support for Entity ID data type.
    """

    @type t() :: non_neg_integer()

    @compile { :inline, parse!: 1}
    @compile { :inline, decode: 1}
    @compile { :inline, decode_list: 1}

    @doc "'Parses' id from a string"
    @spec parse!( String.t()) :: t()
    def parse!( id) do
      IntegerUtils.int!( id)
    end

    @doc " 'Decodes' id that is either an integer already (if value) or a string if key."
    @spec decode( iodata()) :: t()
    def decode( id) do
      IntegerUtils.int!( id)
    end

    @doc """
    'Decodes' a list of id's. As those are plain integers for the time being, simply returns what it receives,
    for the Jason library is doing its job properly already.
    The implementation is encapsulated here in case we change EMap.id type to something else in the future
    """
    @spec decode_list( iodata()) :: [ t()]
    def decode_list( id_list) when is_list( id_list) do
      id_list
    end
  end


  import ListUtils, only: [ list_add: 3]
  import IntegerUtils, only: [ int!: 1]

  @typep index() :: non_neg_integer()
  @typep list_name() :: atom()
  @typep entity() :: map() | struct()
  @typep encoded_entity() :: iodata()
  @typep entity_decoder() :: ( encoded_entity() -> struct())
  @typep id() :: Id.t()
  @type t() :: %__MODULE__{
                 :__entities__ => %{ id() => entity()},
                 :__auto_id__ => id()
               }
  defstruct __entities__: %{},
            __auto_id__: 0

  defguard is_id( term) when is_integer( term)  # internal ids


  @compile { :inline, entities: 1, entity: 2}

  @doc "Convenience function that substitutes the cumbersome emap.__entities__ refrence."
  @spec entities( t()) :: %{ id() => entity()}
  def entities( emap) do
    emap.__entities__
  end


  @doc """
  Convenience function to substitute cumbersome emap.__entities__[ id] references.
  Intended for importing.
  """
  @spec entity( t(), id()) :: any()
  def entity( emap, id) do
    emap.__entities__[ id]
  end


  # JSON-decodes the encoded EMap specialization.
  # The function provided must provide implementation for all entity types stored in the entities map
  # and for the EMap specialization itself.
  @spec decode( encoded_entity(), entity_decoder()) :: t()
  def decode( emap, entity_decoder) do
    %{
      "fields" => %{
        "__entities__" => entities,
        "__auto_id__" => auto_id
      }
    } = emap

    %{
      entity_decoder.( emap) |
      __entities__: Map.new( entities, fn { id, entity} -> { int!( id), entity_decoder.( entity)} end),
      __auto_id__: int!( auto_id)
    }
  end

  # Lists entity's id at a specified index position in the entity map or as last in the list if index omitted.
  @spec list_entity( t(), list_name(), index() | :last, id()) :: t()
  def list_entity( emap, list_name, index, id) when is_id( id) do
    %{ ^list_name => list} = emap

    %{ emap | list_name => list_add( list, index, id)}
  end


  # Unlists the ids of entities without changes to the entity mapping.
  @spec unlist_entities( t(), list_name(), list( id())) :: t()

  def unlist_entities( emap, _, []), do: emap

  def unlist_entities( emap, list_name, [ _ | _] = ids) do
    %{ ^list_name => list} = emap

    %{ emap | list_name => Enum.reject( list, & &1 in ids)}
  end


  # Updates entity list with a modified list returned by the updater function.
  @spec update_list( t(), list_name(), ( list( id()) -> list( id()))) :: t()
  def update_list( emap, list_name, updater) when is_function( updater) do
    %{ ^list_name => list} = emap

    %{ emap | list_name => updater.( list)}
  end


  # Updates entity in the entity map.
  # Any error returned by the updater function must conform to the { :error, any()} standard.
  # Returns error if entity found or if returned by the updater.
  @spec update_entity( t(), id(), ( %{} -> %{})) :: t() | { :error, :not_found | any()}
  def update_entity( emap, id, updater) when is_id( id) do
    with %{} = entity <- entity( emap, id),
         %{} = entity <- updater.( entity)
      do
      %{ emap | __entities__: %{ emap.__entities__ | id => entity}}
    else
      nil -> { :error, :not_found}

      { :error, _} = error -> error
    end
  end


  # Drops all entities mapped to the supplied ids and unlists them if a key to their path in the root is provided.
  # Note: Any data integrity implications should be dealt with by the caller (parent/root list, children, ..)
  @spec drop_entities( t(), list_name() | nil, list( id())) :: t()
  def drop_entities( emap, list_name \\ nil, ids)

  def drop_entities( emap, nil, ids) when is_list( ids) do
    %{ emap | __entities__: Map.drop( emap.__entities__, ids)}
  end

  def drop_entities( emap, list_name, ids) when is_list( ids) do
    emap
    |> drop_entities( ids)
    |> unlist_entities( list_name, ids)
  end


  # Adds an entity to the entity map and associates it with a new id.
  # If a key to their path in the root is provided, lists it there as well.
  # Returns a tuple with the entity map and a new id the added entity has been mapped to.
  @spec add_entity( t(), list_name() | nil, entity()) :: { t(), id()}
  def add_entity( emap, list_name \\ nil, entity)

  def add_entity( emap, nil, entity) do
    id = new_id( emap)

    emap =
      %{
        emap |
        __auto_id__: id,
        __entities__: Map.put( emap.__entities__, id, entity)
      }

    { emap, id}
  end

  def add_entity( emap, list_name, entity) do
    { emap, id} = add_entity( emap, entity)
    { list_entity( emap, list_name, :last, id), id}
  end


  # Returns a new auto_id for the entity map.
  @spec new_id( t()) :: id()
  defp new_id( %{ __auto_id__: id}) do
    id + 1
  end
end
