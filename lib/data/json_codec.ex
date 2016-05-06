defmodule RiakcCommon.Data.JsonCodec do
  defmacro __using__(_) do
    quote  do

      defimpl Poison.Encoder, for: __MODULE__ do
        def encode(struct,options) do
          map = 
            if Map.has_key?(struct,:__struct__) do
              :maps.remove(:__struct__, struct)
            else
              struct
            end
          Poison.Encoder.Map.encode(map,options)
        end
      end

      defimpl Poison.Decoder, for: __MODULE__ do

        unquote(__json_module__(__CALLER__.module))

        defp atom_key(key) do
          if is_atom(key) do
            key
          else
            try do
              String.to_existing_atom(key)
            rescue
              _any -> nil
            end
          end
        end

        defp type(key) do
          atom = atom_key(key)
          type = json_module().__json_schema__(:type,atom)
          cond do
            nil == type ->
              nil
            is_atom(type) ->
              type.__struct__
            is_list(type) ->
              [embed] = type
              [embed.__struct__]
            true ->
              nil
          end
        end

        defp do_transform(map,key,value) do
          type = type(key)
          if nil != type do
            decoded = Poison.Decode.decode(value,as: type)
            Map.put(map,key,decoded)
          else
            map
          end
        end
        
        def decode(map,options) do
          Map.keys(map)
          |> Enum.reduce(map,fn(key,map) ->
            case Map.get(map, key) do
              value when is_map(value) or is_list(value) ->
                do_transform(map,key,value)
              value ->
                map
            end
          end)
        end

      end

    end
  end

  defp __json_module__(module) do
    quote do
      def json_module(), do: unquote(module)
    end
  end


end