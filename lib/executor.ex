defmodule FunPipelinex.Executor do
  @moduledoc false

  alias FunPipelinex.Helper

  def run_by_args(args, filters, curr_m, f) do
    with(
      {:ok, args} <- run(filters, args),
      exec_f <- Helper.make_exec_fun_name(f),
      a <- Keyword.values(args)
    ) do
      apply(curr_m, exec_f, a)
    else
      err -> err
    end
  end

  def run_by_resp(resp, filters) do
    run(filters, resp)
    |> case do
      {:ok, resp} -> resp
      err -> err
    end
  end

  ###
  def run(filters, term), do: do_run(filters, {:ok, term})

  def do_run([], result), do: result

  def do_run([{m, f} | rest], {:ok, term}) do
    apply(m, f, [term])
    |> case do
      {:ok, _args} = result -> do_run(rest, result)
      err -> do_run([], err)
    end
  end
end
