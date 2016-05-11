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
          Module.put_attribute(mod, :riakc_operation_fields, {:request,operation, type})
        end
    end)
  end

  def __response__(mod, type, operations) do
    Enum.each(operations,fn(operation) -> 
        if operation == :all do
          Module.put_attribute(mod, :riakc_crud_response, type)
        else
          Module.put_attribute(mod, :riakc_operation_fields, {:response,operation, type})
        end
    end)
  end

  def __types__(fields,request,response) do
    {request,response} = 
      Enum.split_while(fields,fn({direction,_op,_type})->
        direction == :request 
      end)

    quoted_request =
      Enum.map(request, fn {_direction,operation, type} ->
        quote do
          def __request__(unquote(operation)) do
            unquote(Macro.escape(type))
          end
        end
      end)

    quoted_response =
      Enum.map(response, fn {_direction,operation, type} ->
        quote do
          def __response__(unquote(operation)) do
            unquote(Macro.escape(type))
          end
        end
      end)


    quote do
      unquote(quoted_request)
      def  __request__(_), do: unquote(request)
      unquote(quoted_response)
      def  __response__(_), do: unquote(response)
    end
  end


end
