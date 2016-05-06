defmodule RiakcCommon.SimpleRest.Actions.Create do
  alias RiakcCommon.SimpleRest.Utils.{API, Endpoint}

  defmacro __using__(opts) do
    {scope, opts} = Keyword.pop(opts, :scope)
    {resource, _opts} = Keyword.pop(opts, :resource)

    code = cond do
      is_tuple(scope) or is_nil(scope) ->
        quote do
          def create(params,context) do
            url = context.target <> 
              Endpoint.build(unquote(scope), nil, unquote(resource))
            API.post(url,params,context.handler,context.headers,context.opts)
          end
        end
      is_binary(scope) ->
        quote do
          def create(scope_id, params, context) do
            url = context.target <> 
              Endpoint.build(unquote(scope), scope_id, unquote(resource))
            API.post(url,params,context.handler,context.headers,context.opts)
          end
        end
    end

    quote do
      unquote(code)
    end
  end
end
