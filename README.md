# Heyya

`Heyya` is a utility to help with snapshot testing your
[Phoenix](https://www.phoenixframework.org/) components. Under the hood it
uses [Snapshy](https://hex.pm/packages/snapshy)

## Example Usage

```
use Heyya

component_snapshot_test "Super Simple H1 Test" do
  assigns = %{}

  ~H"""
  <h1>Testing</h1>
  """
end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `heyya` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:heyya, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/heyya>.
