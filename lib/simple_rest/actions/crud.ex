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
      unquote(compile(actions, opts))
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
end
