defmodule RiakcCommon.SimpleRest.Actions.Create do
  alias RiakcCommon.SimpleRest.Utils.{API, Endpoint}

  defmacro __using__(opts) do
    {scope, opts} = Keyword.pop(opts, :scope)
    {resource, opts} = Keyword.pop(opts, :resource)
    {method,_opts} = Keyword.pop(opts, :create_method)

    code = cond do
      is_tuple(scope) or is_nil(scope) ->
        quote do
          defp create_operation(params,context) do
            url = context.target <> 
              Endpoint.build(unquote(scope), nil, unquote(resource))
            case unquote(method) do
              :put ->
                API.put(url,params,context.handler,context.headers,context.opts)
              :post ->  
                API.post(url,params,context.handler,context.headers,context.opts)
              _ -> 
                API.post(url,params,context.handler,context.headers,context.opts)
            end
          end

          def create(params) do
            action = fn(context)->
                create_operation(params,context)
              end
            {:create,action}
          end

        end
      is_binary(scope) ->
        quote do
          defp create_operation(scope_id, params, context) do
            url = context.target <> 
              Endpoint.build(unquote(scope), scope_id, unquote(resource))
            case unquote(method) do
              :put ->
                API.put(url,params,context.handler,context.headers,context.opts)
              :post ->
                API.post(url,params,context.handler,context.headers,context.opts)
              _ -> 
                API.post(url,params,context.handler,context.headers,context.opts)
            end
          end

          def create(scope_id,params) do
            action = fn(context)->
                create_operation(scope_id,params,context)
              end
            {:create,action}
          end

        end
    end

    quote do
      unquote(code)
    end
  end
end
