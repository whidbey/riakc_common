defmodule RiakcCommon.SimpleRest.Actions.Delete do
  alias RiakcCommon.SimpleRest.Utils.{API, Endpoint}

  defmacro __using__(opts) do
    {scope, opts} = Keyword.pop(opts, :scope)
    {resource, _opts} = Keyword.pop(opts, :resource)

    code = cond do
      is_tuple(scope) or is_nil(scope) ->
        quote do
          defp delete_operation(id,context) do
            url = context.target <> 
              Endpoint.build(unquote(scope), nil, unquote(resource), id)
            API.delete(url,context.handler,context.headers,context.opts)
          end

          def delete(id) do
            action = fn(context) ->
                delete_operation(id,context)
              end
            {:delete,action}
          end
          defdelegate destroy(id), to: __MODULE__, as: :delete

        end
      is_binary(scope) ->
        quote do
          defp delete_operation(scope_id, id,context) do
            url = context.target <> 
              Endpoint.build(unquote(scope), scope_id, unquote(resource), id)
            API.delete(url,context.handler,context.headers,context.opts)
          end
          
          def delete(scope_id,id) do
            action = fn(context) ->
                delete_operation(scope_id,id,context)
              end
            {:delete,action}
          end
          defdelegate destroy(scope_id,id), to: __MODULE__, as: :delete
          
        end

    end

    quote do
      unquote(code)
    end
  end
end
