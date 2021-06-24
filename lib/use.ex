defmodule FunPipelinex.Helper do
  @moduledoc false

  ###
  def parse_filters({:__block__, _, filter_expr}), do: do_parse_filters(filter_expr, [])
  def parse_filters(filter_expr), do: do_parse_filters([filter_expr], [])

  def do_parse_filters([], filters), do: Enum.dedup(filters)

  def do_parse_filters([{:filter, _, [{:__aliases__, _, term}]} | rest], filters),
    do: do_parse_filters(rest, [make_m_name(term) | filters])

  def do_parse_filters([{:filter, _, [f_name]} | rest], filters) when is_atom(f_name),
    do: do_parse_filters(rest, [f_name | filters])

  def make_m_name([_ | _] = term),
    do: [Elixir] |> Kernel.++(term) |> Enum.join(".") |> String.to_atom()
end
