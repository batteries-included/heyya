# Heyya

`Heyya` is a utility to help with testing your [Phoenix](https://www.phoenixframework.org/) components and live view. Under the hood it uses [Snapshy](https://hex.pm/packages/snapshy)

## Getting Started

Getting Started

To use Heyya in your Phoenix project, add it to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:heyya, "~> 0.2.0"}
  ]
end
```

Then, run `mix deps.get` to install Heyya and its dependencies.

## Example Snapshot Usage

```
use Heyya.SnapshotTest

component_snapshot_test "Super Simple H1 Test" do
  assigns = %{}

  ~H"""
  <h1>Testing</h1>
  """
end
```

To run the snapshot tests, run `mix test` as usual. This will compare the snapshots to the current rendered output of the components and fail the tests if the snapshots do not match.

If you need to update the snapshots for any reason, you can run `SNAPSHY_OVERRIDE=true mix test` to reset the snapshot values to the current rendered output of the components.

## Example Live View Test

```
use Heyya.LiveTest
use MyPhoenixWeb.ConnCase
test "widget list with new button", %{conn: conn} do
  start(conn, ~p|/widgets|)
  |> assert_html("Widgets List")
  |> click("a", "New Widgets")
  |> follow(~p|/widgets/new|)
end
```

## Contributing

We welcome contributions to Heyya! Please see the CONTRIBUTING.md file for guidelines on how to contribute.

## License

Heyya is released under the MIT License.
