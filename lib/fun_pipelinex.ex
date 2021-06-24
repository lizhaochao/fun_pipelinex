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
    fn f, a, guard, exec_f, block ->
      quote do
        def unquote(f)(unquote_splicing(a)) when unquote(guard) do
          with(
            curr_m <- __MODULE__,
            args <- unquote(H.make_args(a)),
            {in_filters, out_filters} <- H.get_filters(@filters, unquote(pipelines), curr_m)
          ) do
            H.debug_log(title: :before_run_filters, args: args, in_filters: in_filters, out_filters: out_filters)

            args
            |> Executor.run_by_args(in_filters, curr_m, unquote(f))
            |> Executor.run_by_resp(out_filters)
          end
        end

        def unquote(exec_f)(unquote_splicing(a)) when unquote(guard) do
          unquote(block)
        end
      end
    end
    |> H.generate_funs(block)
  end
end
