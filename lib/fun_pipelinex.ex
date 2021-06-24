defmodule FunPipelinex do
  @moduledoc """
  fun_pipelinex is a package which filter function's args and return value by your custom Filters.
  """

  alias FunPipelinex.{Executor, Parser}
  alias FunPipelinex.Helper, as: H

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :filters, accumulate: true)
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
    in_pipelines = H.get_pipelines(pipelines, :in)
    out_pipelines = H.get_pipelines(pipelines, :out)

    block
    |> Parser.parse_fun()
    |> Enum.map(fn fun ->
      %{f: f, a: a, guard: guard, block: block} = fun
      exec_f = H.make_exec_fun_name(f)

      quote do
        def unquote(f)(unquote_splicing(a)) when unquote(guard) do
          with(
            filters <- @filters,
            curr_m <- __MODULE__,
            args <- unquote(H.make_args(a)),
            in_filters <- H.get_filters(filters, unquote(in_pipelines)) |> H.fmt_filters(curr_m),
            out_filters <- H.get_filters(filters, unquote(out_pipelines)) |> H.fmt_filters(curr_m)
          ) do
            args
            |> Executor.run_by_args(in_filters, curr_m, unquote(f))
            |> Executor.run_by_resp(out_filters)
          end
        end

        def unquote(exec_f)(unquote_splicing(a)) when unquote(guard) do
          unquote(block)
        end
      end
    end)
  end
end
