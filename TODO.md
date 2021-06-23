## Usage

```elixir
defmodule API do
  use FunPipelinex
  
  # define pipeline
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

  # use pipe_through to wrap function
  pipe_through in: [:biz_in, :approve_permission], out: :biz_out do
    def approve(user, id, operation, reason) do
      ...
    end
  end

  # implement filters
  def has_approve_permission(args) do
    user = Keyword.get(args, :user)
    user == :sysadmin
  end

  def fmt_resp(resp) do
    {:ok, resp}
  end
end

# implement filters
defmodule ArgsChecker do
  def call(args) do
    ...
  end
end

defmodule HMacChecker do
  def call(args) do
    ...
  end
end
```