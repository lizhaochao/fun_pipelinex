defmodule FunPipelinex do
  @moduledoc """
  fun_pipelinex is a package which filter function's args and return value by your custom Filters.
  """

  alias FunPipelinex.Parser

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :filters, accumulate: true)

      require Logger
      import unquote(__MODULE__), only: [pipeline: 2, pipe_through: 2]
    end
  end

  defmacro pipeline(name, do: block) do
    block
    |> Parser.parse_filters()
    |> Enum.map(fn filter ->
      quote do
        @filters {unquote(name), unquote(filter)}
      end
    end)
  end

  defmacro pipe_through(pipelines, do: block) do
    in_pipelines = Keyword.get(pipelines, :in, nil)
    out_pipelines = Keyword.get(pipelines, :out, nil)
    funs = Parser.parse_fun(block)

    Enum.map(funs, fn fun ->
      %{f: f, a: a, guard: guard, block: block} = fun

      quote do
        def unquote(f)(unquote_splicing(a)) when unquote(guard) do
          unquote(block)
        end
      end
    end)
  end
end
