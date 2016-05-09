defmodule RiakcCommon.SimpleRest.Actions.Delete do
  alias RiakcCommon.SimpleRest.Utils.{API, Endpoint}

  defmacro __using__(opts) do
    {scope, opts} = Keyword.pop(opts, :scope)
    {resource, _opts} = Keyword.pop(opts, :resource)

    code = cond do
      is_tuple(scope) or is_nil(scope) ->
        quote do
          def delete(id,context) do
            url = context.target <> 
              Endpoint.build(unquote(scope), nil, unquote(resource), id)
            API.delete(url,context.handler,context.headers,context.opts)
          end
          defdelegate destroy(id,context), to: __MODULE__, as: :delete

          def delete_operation(id) do
            fn(context) ->
              delete(id,context)
            end
          end
          defdelegate destroy_operation(id), to: __MODULE__, as: :delete_operation

        end
      is_binary(scope) ->
        quote do
          def delete(scope_id, id,context) do
            url = context.target <> 
              Endpoint.build(unquote(scope), scope_id, unquote(resource), id)
            API.delete(url,context.handler,context.headers,context.opts)
          end
          defdelegate destroy(scope_id, id,context), to: __MODULE__, as: :delete
          
          def delete_operation(scope_id,id) do
            fn(context) ->
              delete(scope_id,id,context)
            end
          end
          defdelegate destroy_operation(scope_id,id), to: __MODULE__, as: :delete_operation

        end

    end

    quote do
      unquote(code)
    end
  end
end
