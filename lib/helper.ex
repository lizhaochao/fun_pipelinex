defmodule FunPipelinex.Helper do
  @moduledoc false

  def make_m_name([_ | _] = term),
    do: [Elixir] |> Kernel.++(term) |> Enum.join(".") |> String.to_atom()
end
