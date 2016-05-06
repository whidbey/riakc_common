defmodule Riakc.Data.JsonSchema do


  @base ~w(integer boolean string map array any)a

  defmacro __using__(_) do
    quote do
      import Riakc.Data.JsonSchema , only: [json_schema: 1]
      Module.register_attribute(__MODULE__, :riakc_json_fields, accumulate: true)
    end
  end

  defmacro json_schema([do: block]) do
    quote do

      Module.register_attribute(__MODULE__, :struct_fields, accumulate: true)
      
      try do
        import Riakc.Data.JsonSchema
        unquote(block)
      after
        :ok
      end
      fields = @riakc_json_fields |> Enum.reverse
      Module.eval_quoted __ENV__, [
        Riakc.Data.JsonSchema.__defstruct__(@struct_fields),
        Riakc.Data.JsonSchema.__types__(fields)]
    end
  end

  defmacro field(name, type \\ :string, opts \\ []) do
    quote do
      Riakc.Data.JsonSchema.__field__(__MODULE__, unquote(name), unquote(type), unquote(opts))
    end
  end

  def __field__(mod, name, type, opts) do

    type_checked = check_type!(name, type)

    default = default_for_type(type, opts)
    put_struct_field(mod, name, default)
    if true != type_checked do
      Module.put_attribute(mod, :riakc_json_fields, {name, type})
    end

  end

  def __defstruct__(struct_fields) do
    quote do
      defstruct unquote(Macro.escape(struct_fields))
    end
  end

  def __types__(fields) do
    quoted =
      Enum.map(fields, fn {name, type} ->
        quote do
          def __json_schema__(:type, unquote(name)) do
            unquote(Macro.escape(type))
          end
        end
      end)

    types = Macro.escape(fields)

    quote do
      def __json_schema__(:types), do: unquote(types)
      unquote(quoted)
      def __json_schema__(:type, _), do: nil
    end
  end

  defp primitive?(base) when base in @base, do: true
  defp primitive?(_), do: false

  defp raise_type_error(name, type) do
    raise ArgumentError, "invalid or unknown type #{inspect type} for field #{inspect name}"
  end
  defp ensure_compiled(name,type) do
    if Code.ensure_compiled?(type) do
      type
    else
      raise_type_error(name, type)
    end
  end

  defp check_type!(name, type) do
    IO.puts "check_type!"
    cond do           
      primitive?(type) ->
        IO.puts "check_type! primitive"
        true
      is_list(type) ->
        IO.puts "check_type! list"
        [embed] = type
        ensure_compiled(name,embed)
      is_atom(type) ->
        IO.puts "check_type! atom"
        ensure_compiled(name,type)
      true ->
        raise ArgumentError, "invalid type #{inspect type} for field #{inspect name}"
    end
  end


  defp default_for_type(_, opts) do
    Keyword.get(opts, :default)
  end

  defp put_struct_field(mod, name, assoc) do
    fields = Module.get_attribute(mod, :struct_fields)
  
    if List.keyfind(fields, name, 0) do
      raise ArgumentError, "field #{inspect name} is already set on json_schema"
    end
    Module.put_attribute(mod, :struct_fields, {name, assoc})
  end




end