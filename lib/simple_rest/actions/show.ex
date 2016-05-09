defmodule RiakcCommon.SimpleRest.Actions.Show do
  alias RiakcCommon.SimpleRest.Utils.{API, Endpoint}

  defmacro __using__(opts) do
    {scope, opts} = Keyword.pop(opts, :scope)
    {resource, opts} = Keyword.pop(opts, :resource)
    {singular, _opts} = Keyword.pop(opts, :singular)

    has_scope_id = cond do
      is_binary(scope) -> true
      is_tuple(scope) or is_nil(scope) -> false
    end

    code = cond do
      singular && !has_scope_id ->
        quote do
          def show(context) do
            url = context.target <> 
              Endpoint.build(unquote(scope), nil, unquote(resource))
            API.get(url,context.handler,context.headers,context.opts)
          end
          
          def show_operation() do
            fn(context) ->
              show(context)
            end
          end

        end
      singular && has_scope_id ->
        quote do
          def show(scope_id,context) do
            url = context.target <>
              Endpoint.build(unquote(scope), scope_id, unquote(resource))
            API.get(url,context.handler,context.headers,context.opts)
          end

          def show_operation(scope_id) do
            fn(context) ->
              show(scope_id,context)
            end
          end

        end
      !has_scope_id ->
        quote do
          def show(id,context) do
            url = context.target <>
              Endpoint.build(unquote(scope), nil, unquote(resource), id)
            API.get(url,context.handler,context.headers,context.opts)
          end
          defdelegate fetch(id,context), to: __MODULE__, as: :show

          def show_operation(id) do
            fn(context) ->
              show(id,context)
            end
          end
          defdelegate fetch_operation(id), to: __MODULE__, as: :show_operation
        end
       has_scope_id ->
        quote do
          def show(scope_id, id,context) do
            url = context.target <> 
              Endpoint.build(unquote(scope), scope_id, unquote(resource), id)
            API.get(url,context.handler,context.headers,context.opts)
          end
          defdelegate fetch(scope_id, id,context), to: __MODULE__, as: :show


          def show_operation(scope_id,id) do
            fn(context) ->
              show(scope_id,id,context)
            end
          end
          defdelegate fetch_operation(id), to: __MODULE__, as: :show_operation
        end

    end

    quote do
      unquote(code)
    end
  end
end
