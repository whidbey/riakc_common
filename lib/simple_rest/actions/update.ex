defmodule RiakcCommon.SimpleRest.Actions.Update do
  alias RiakcCommon.SimpleRest.Utils.{API, Endpoint}

  defmacro __using__(opts) do
    {scope, opts} = Keyword.pop(opts, :scope)
    {resource, opts} = Keyword.pop(opts, :resource)
    {method,_opts} = Keyword.pop(opts, :update_method)

    code = cond do
      is_tuple(scope) or is_nil(scope) ->
        quote do
          defp update_operation(params,context) do 
            update_operation(params.id, Map.delete(params, :id),context)
          end
          defp update_operation(id, params,context) do
            url = context.target <> 
              Endpoint.build(unquote(scope), nil, unquote(resource), id)
            case unquote(method) do
              :put ->
                 API.put(url, params,context.handler,context.headers,context.opts)
              :patch -> 
                 API.patch(url, params,context.handler,context.headers,context.opts)
              _ ->
                 API.post(url, params,context.handler,context.headers,context.opts)
            end
          end

          def update(params) do
            update(params.id,Map.delete(params,:id))
          end
          def update(id,params) do
            action = fn(context) ->
                update_operation(id,params,context)
              end
            {:update,action}
          end

        end
      is_binary(scope) ->
        quote do
          defp update_operation(scope_id, params,context) do 
            update_operation(scope_id, params.id, Map.delete(params, :id),context)
          end
          defp update_operation(scope_id, id, params,context) do
            url = context.target <> 
              Endpoint.build(unquote(scope), scope_id, unquote(resource), id)
            case unquote(method) do
              :put ->
                 API.put(url, params,context.handler,context.headers,context.opts)
              :patch -> 
                 API.patch(url, params,context.handler,context.headers,context.opts)
              _ ->
                 API.post(url, params,context.handler,context.headers,context.opts)
            end
          end

          def update(scope_id,params) do
            update(scope_id,params.id,Map.delete(params,:id))
          end
          def update(scope_id,id,params) do
            action = fn(context) ->
                update(scope_id,id,params,context)
              end
            {:update,action}
          end

        end

    end

    quote do
      unquote(code)
    end
  end
end
