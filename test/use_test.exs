defmodule UseTest do
  use ExUnit.Case

  use FunPipelinex

  pipeline :biz_in do
    filter(ArgsChecker)
    filter(HMacChecker)
    filter(:has_approve_permission)
  end

  pipe_through in: [:biz_in, :approve_permission], out: :biz_out do
    def approve(user, id, operation, reason) do
      {user, id, operation, reason}
    end
  end

  test "ok" do
    assert {1, 2, 3, 4} == approve(1, 2, 3, 4)
  end
end
