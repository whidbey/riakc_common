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
          defp show_operation(context) do
            url = context.target <> 
              Endpoint.build(unquote(scope), nil, unquote(resource))
            API.get(url,context.handler,context.headers,context.opts)
          end
          
          def show() do
            action = fn(context) ->
                show_operation(context)
              end
            {:show,action}
          end

        end
      singular && has_scope_id ->
        quote do
          defp show_operation(scope_id,context) do
            url = context.target <>
              Endpoint.build(unquote(scope), scope_id, unquote(resource))
            API.get(url,context.handler,context.headers,context.opts)
          end

          def show(scope_id) do
            action = fn(context) ->
                show(scope_id,context)
              end
            {:show,action}
          end

        end
      !has_scope_id ->
        quote do
          defp show_operation(id,context) do
            url = context.target <>
              Endpoint.build(unquote(scope), nil, unquote(resource), id)
            API.get(url,context.handler,context.headers,context.opts)
          end

          def show(id) do
            action = fn(context) ->
                show_operation(id,context)
              end
            {:show,action}
          end
          defdelegate fetch(id), to: __MODULE__, as: :show

        end
       has_scope_id ->
        quote do
          defp show_operation(scope_id, id,context) do
            url = context.target <> 
              Endpoint.build(unquote(scope), scope_id, unquote(resource), id)
            API.get(url,context.handler,context.headers,context.opts)
          end

          def show_operation(scope_id,id) do
            action = fn(context) ->
                show_operation(scope_id,id,context)
              end
            {:show,action}
          end
          defdelegate fetch(scope_id,id), to: __MODULE__, as: :show
        end

    end

    quote do
      unquote(code)
    end
  end
end
