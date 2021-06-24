### implement filters
defmodule ArgsChecker do
  def call(args) do
    new_args = Keyword.put(args, :user, :sysadmin)
    {:ok, new_args}
  end
end

defmodule HMacChecker do
  def call(args) do
    new_args =
      args
      |> Enum.slice(0, 3)
      |> Kernel.++(reason: :agree_buy_toy)

    {:ok, new_args}
  end
end

### Test
defmodule UseTest do
  use ExUnit.Case

  use FunPipelinex

  pipeline :biz_in do
    filter(ArgsChecker)
    filter(HMacChecker)
  end

  pipeline :approve_permission do
    filter(:has_approve_permission)
  end

  pipeline :biz_out do
    filter(:fmt_resp)
  end

  pipe_through in: [:biz_in, :approve_permission], out: :biz_out do
    def approve(user, id, operation, reason) do
      {user, id, operation, reason}
    end
  end

  pipe_through [] do
    def agree(result) do
      {result}
    end
  end

  ###
  test "in and out pipelines are ok" do
    assert {:sysadmin, 2, 3, :agree_buy_toy, :resp} == approve(1, 2, 3, 4)
  end

  test "no pipeline" do
    assert {:yes} == agree(:yes)
  end

  ### implement filters
  def has_approve_permission(args) do
    user = Keyword.get(args, :user)

    if user == :sysadmin do
      {:ok, args}
    else
      {:error, :no_permission}
    end
  end

  def fmt_resp(resp) do
    new_resp = resp |> Tuple.to_list() |> Kernel.++([:resp]) |> List.to_tuple()
    {:ok, new_resp}
  end
end
