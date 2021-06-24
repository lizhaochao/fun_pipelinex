defmodule FunPipelinex.Helper do
  @moduledoc false

  alias FunPipelinex.Helper, as: Self

  @exec_fun_name_suffix "_exec__macro"

  def make_exec_fun_name(f), do: String.to_atom("#{f}#{@exec_fun_name_suffix}")

  def make_m_name([_ | _] = term),
    do: [Elixir] |> Kernel.++(term) |> Enum.join(".") |> String.to_atom()

  ###
  def get_pipelines([_ | _] = pipelines, key), do: pipelines && Keyword.get(pipelines, key, nil)
  def get_pipelines(_other_pipelines, _key), do: []

  ###
  def get_filters(filters, [_ | _] = pipelines) when is_list(filters) do
    pipelines
    |> Enum.map(fn pipeline ->
      Enum.filter(filters, fn {key, _filter} -> key == pipeline end)
    end)
    |> List.flatten()
    |> Keyword.values()
  end

  def get_filters(filters, pipeline) when is_list(filters) and is_atom(pipeline),
    do: get_filters(filters, [pipeline])

  def get_filters(_filters, _curr_m), do: []

  def fmt_filters(filters, curr_m) when is_list(filters) and is_atom(curr_m) do
    Enum.map(filters, fn module_or_fun ->
      module_or_fun
      |> to_string()
      |> case do
        "Elixir." <> _rest -> {module_or_fun, :call}
        _fun_name -> {curr_m, module_or_fun}
      end
    end)
  end

  def fmt_filters(_filters, _curr_m), do: []

  ###
  def make_args(a_expr) do
    quote do
      keys = unquote(Self.get_arg_names(a_expr))
      values = [unquote_splicing(a_expr)]
      Self.make_args(keys, values, [])
    end
  end

  def make_args(keys, values, args), do: do_make_args(keys, values, args)
  defp do_make_args([] = _keys, [] = _values, args), do: Enum.reverse(args)
  defp do_make_args([_ | _] = _keys, [] = _values, args), do: args
  defp do_make_args([] = _keys, [_ | _] = _values, args), do: args

  defp do_make_args([key | key_rest], [value | value_rest], args) do
    new_args = Keyword.put(args, key, value)
    do_make_args(key_rest, value_rest, new_args)
  end

  def get_arg_names(args), do: do_get_arg_names(args, [])
  defp do_get_arg_names([], names), do: Enum.reverse(names)
  defp do_get_arg_names([{arg, _, _} | rest], names), do: do_get_arg_names(rest, [arg | names])
  defp do_get_arg_names([_other_expr | rest], names), do: do_get_arg_names(rest, names)
end
