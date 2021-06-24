# fun_pipelinex  [![Hex Version](https://img.shields.io/hexpm/v/fun_pipelinex.svg)](https://hex.pm/packages/fun_pipelinex) [![docs](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/fun_pipelinex/)
fun_pipelinex is a package which filter function's args and return value by your custom Filters.
## Installation
Add fun_pipelinex to your list of dependencies in `mix.exs`:
```elixir
def deps do
  [{:fun_pipelinex, "~> 1.0.0"}]
end
```
Maybe you need to execute `export HEX_MIRROR="https://repo.hex.pm"` first.
Then run `mix deps.get`.
## Chain of Responsibility Pattern Implementation
## Usage
```elixir
defmodule API do
  use FunPipelinex
  
  # Define pipelines
  # Filters are ordered.
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
  # composite pipelines are allowed, pipelines are ordered too.
  pipe_through in: [:biz_in, :approve_permission], out: :biz_out do
    def approve(user, id, operation, reason) do
      {user, id, operation, reason}
    end
  end

  # implements filters in current module.
  def has_approve_permission(args) do
    user = Keyword.get(args, :user)
    if user == :sysadmin do
      # if success, must be {:ok, something} format.
      {:ok, args}
    else
      # if not match {:ok, something} format, it will stop and return.
      {:error, :no_permission}
    end
  end

  def fmt_resp(resp) do
    {:ok, resp}
  end
end

# Implements filters in independent module.
defmodule ArgsChecker do
  # NOTICE: function name & arity must be the following example.
  def call(args) do
    # if you change args, it doesn't matter, passing it to next filter.
    {:ok, args}
  end
end

defmodule HMacChecker do
  def call(args) do
    {:ok, args}
  end
end
```
## Contributing
Contributions to fun_pipelinex are very welcome!

Bug reports, documentation, spelling corrections... all of those (and probably more) are much appreciated contributions!
