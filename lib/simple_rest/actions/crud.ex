defmodule RiakcCommon.SimpleRest.Actions.CRUD do
  import String, only: [capitalize: 1, to_atom: 1]

  @actions [:index, :show, :create, :update, :delete]
  @action_implementations Enum.map(@actions, fn action ->
    {action, to_atom "Elixir.RiakcCommon.SimpleRest.Actions.#{action |> to_string |> capitalize}"}
  end)

  defmacro __using__(opts) do
    actions = Keyword.get(opts, :only, @actions)
    actions = actions -- Keyword.get(opts, :except, [])
    resource = Keyword.fetch!(opts, :resource)
    opts = Keyword.drop(opts, [:only, :except])

    quote do
      require RiakcCommon.SimpleRest.Utils.Endpoint
      require RiakcCommon.SimpleRest.Utils.ApiContext
      import RiakcCommon.SimpleRest.Actions.CRUD , only: [request: 1, response: 1]
      unquote(compile(actions, opts))

      import RiakcCommon.SimpleRest.Actions.CRUD, only: [crud_schema: 1]
      Module.register_attribute(__MODULE__, :riakc_crud_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :riakc_crud_request, accumulate: false)
      Module.register_attribute(__MODULE__, :riakc_crud_response, accumulate: false)
    end

  end

  defp compile(actions, opts) do
    compile(actions, opts, [])
  end

  for action <- @actions do
    defp compile([unquote(action) = action | rest], opts, acc) do
      compile(rest, opts, [quote do
        use unquote(@action_implementations[action]), unquote(opts)
      end | acc])
    end
  end

  defp compile([], _, acc) do
    acc
  end

  defmacro crud_schema([do: block]) do
    quote do
      
      try do
        import RiakcCommon.SimpleRest.Actions.CRUD
        unquote(block)
      after
        :ok
      end
      fields = @riakc_crud_fields |> Enum.reverse
      request = @riakc_crud_request
      response = @riakc_crud_response
      Module.eval_quoted __ENV__, [
        RiakcCommon.SimpleRest.Actions.CRUD.__types__(fields,request,response)
      ]
    end
  end

  defmacro request(type \\ nil , operations \\ [:all]) do
    quote do
      RiakcCommon.SimpleRest.Actions.CRUD.__request__(__MODULE__, unquote(type), unquote(operations))
    end
  end

  defmacro response(type \\ nil , operations \\ [:all]) do
    quote do
      RiakcCommon.SimpleRest.Actions.CRUD.__response__(__MODULE__,unquote(type), unquote(operations))
    end
  end

  def __request__(mod, type, operations) do
    Enum.each(operations,fn(operation) -> 
        if operation == :all do
          Module.put_attribute(mod, :riakc_crud_request, type)
        else
          put_struct_field(mode,:request,operation, type)
        end
    end)
  end

  def __response__(mod, type, operations) do
    Enum.each(operations,fn(operation) -> 
        if operation == :all do
          Module.put_attribute(mod, :riakc_crud_response, type)
        else
          put_struct_field(mode,:response,operation, type)
        end
    end)
  end

  def __types__(fields,request,response) do
    {requests,responses} = 
      Enum.split_while(fields,fn({direction,_op,_type})->
        direction == :request 
      end)

    quoted_requests =
      Enum.map(requests, fn {_direction,operation, type} ->
        quote do
          def __request__(unquote(operation)) do
            unquote(Macro.escape(type))
          end
        end
      end)

    quoted_responses =
      Enum.map(responses, fn {_direction,operation, type} ->
        quote do
          def __response__(unquote(operation)) do
            unquote(Macro.escape(type))
          end
        end
      end)


    quote do
      unquote(quoted_requests)
      def  __request__(_), do: unquote(request)
      unquote(quoted_responses)
      def  __response__(_), do: unquote(response)
    end
  end


  defp put_struct_field(mod, direction, operation,type) do
    fields = Module.get_attribute(mod, :riakc_crud_fields)
    defined = Enum.any?(fields, fn({d,o,_t}) ->
      (direction == d) and (operation == o)
    end)
    if defined do
      raise ArgumentError, "field #{inspect name} is already set on crud_schema"
    end
    Module.put_attribute(mod, :riakc_crud_fields, {direction, operation,type})
  end
end
