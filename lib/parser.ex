defmodule FunPipelinex.Parser do
  @moduledoc false

  alias FunPipelinex.{Error, Helper}

  @allowed_fun_types [:def]
  @not_support_types [:@, :defmodule, :use, :require, :import, :alias]

  ###
  def parse_fun({:__block__, _, [_ | _] = block}), do: parse_fun(block, [])
  def parse_fun(block), do: parse_fun([block], [])

  def parse_fun([], funs), do: Enum.reverse(funs)

  def parse_fun([expr | rest], funs) do
    fun = do_parse_fun(expr, %{})
    parse_fun(rest, [fun | funs])
  end

  defp do_parse_fun({type, _, fun}, parts) when type in @allowed_fun_types do
    do_parse_fun(fun, parts)
  end

  defp do_parse_fun([{:when, _, fa_guard}, [{:do, block}]], parts) do
    fa_guard
    |> do_parse_fun(parts)
    |> Map.put(:block, block)
  end

  defp do_parse_fun([fa, [{:do, block}]], parts) do
    fa
    |> do_parse_fun(parts)
    |> Map.put(:block, block)
    |> Map.put(:guard, true)
  end

  defp do_parse_fun([fa, guard], parts) do
    fa
    |> do_parse_fun(parts)
    |> Map.put(:guard, guard)
  end

  defp do_parse_fun({f, _, [{_, _, _} | _] = a}, parts) when f not in @not_support_types do
    parts
    |> Map.put(:f, f)
    |> Map.put(:a, a)
  end

  defp do_parse_fun({f, _, _}, parts) when f not in @not_support_types do
    parts
    |> Map.put(:f, f)
    |> Map.put(:a, [])
  end

  defp do_parse_fun({type, _, [_ | _]}, _parts), do: raise(Error, "not support #{type}")
  defp do_parse_fun(_other_expr, _parts), do: raise(Error, "unknown function")

  ###
  def parse_filters({:__block__, _, filter_expr}), do: do_parse_filters(filter_expr, [])
  def parse_filters(filter_expr), do: do_parse_filters([filter_expr], [])

  def do_parse_filters([], filters), do: Enum.dedup(filters)

  def do_parse_filters([{:filter, _, [{:__aliases__, _, term}]} | rest], filters),
    do: do_parse_filters(rest, [Helper.make_m_name(term) | filters])

  def do_parse_filters([{:filter, _, [f_name]} | rest], filters) when is_atom(f_name),
    do: do_parse_filters(rest, [f_name | filters])
end
