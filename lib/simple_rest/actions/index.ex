defmodule RiakcCommon.SimpleRest.Actions.Index do
  alias RiakcCommon.SimpleRest.Utils.{API, Endpoint, Params}

  defmacro __using__(opts) do
    {scope, opts} = Keyword.pop(opts, :scope)
    {resource, _opts} = Keyword.pop(opts, :resource)

    code = cond do
      is_tuple(scope) or is_nil(scope) ->
        path = quote do: Endpoint.build(unquote(scope), nil, unquote(resource))

        quote do
          def index(context) do
            url = context.target <> unquote(path)
            API.get(url,context.handler,context.headers,context.opts)
          end
          def index(opts,context) do
            query_string = URI.encode_query(Params.normalize(opts))
            url = context.target <> unquote(path) <> "?" <> query_string
            API.get(url,context.handler,context.headers,context.opts)
          end
          defdelegate list(context), to: __MODULE__, as: :index
          defdelegate list(opts,context), to: __MODULE__, as: :index
        end
      is_binary(scope) ->
        path = quote do: Endpoint.build(unquote(scope), scope_id, unquote(resource))

        quote do
          def index(scope_id,context) do
            url = context.target <> unquote(path)
            API.get(url,context.handler,context.headers,context.opts)
          end
          def index(scope_id, opts) do
            query_string = URI.encode_query(Params.normalize(opts))
            url = context.target <> unquote(path) <> "?" <> query_string
            API.get(url,context.handler,context.headers,context.opts)
          end
          defdelegate list(scope_id,context), to: __MODULE__, as: :index
          defdelegate list(scope_id, opts,context), to: __MODULE__, as: :index
        end
    end

    quote do
      unquote(code)
    end
  end
end
