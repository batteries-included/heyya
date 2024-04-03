# Heyya

`Heyya` is a utility to help with testing your [Phoenix](https://www.phoenixframework.org/) components and live view.

## Getting Started

Getting Started

To use Heyya in your Phoenix project, add it to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:heyya, "~> 0.8.0"}
  ]
end
```

Then, run `mix deps.get` to install Heyya and its dependencies. Use some case templates provided that make testing easier and more automated.

## Examples

In order to show how the different tests can be
implemented we have an example Phoenix project in the example
project.

Changes of note are:

- Added two example live views that show simple pages.
- Added the Heyya dependency
- Added the `/dev/heyya/host` route for dev and test environments
- Added snapshot component tests that show variants get expected classes and aggregate components combine as expected.
- Added live view tests that show Heyya's full page live view testing utilities. Open a page and surf around.
- Added a live_component tests that shows stateful component testing with dynamic content without full page data load.

### Example Snapshot Usage

```
use Heyya.SnapshotCase

component_snapshot_test "Super Simple H1 Test" do
  assigns = %{}

  ~H"""
  <h1>Testing</h1>
  """
end
```

To run the snapshot tests, run `mix test` as usual. This will compare the snapshots to the current rendered output of the components and fail the tests if the snapshots do not match.

If you need to update the snapshots for any reason, you can run `HEYYA_OVERRIDE=true mix test` to reset the snapshot values to the current rendered output of the components.

Credit:

The initial snapshot code used [Snapshy](https://hex.pm/packages/snapshy). We have since moved on to inspect the html rather than using snapshy. Thank you to them for the initial implementation.

### Example Live View Test

```
use Heyya.LiveCase
use MyPhoenixWeb.ConnCase

test "widget list with new button", %{conn: conn} do
  start(conn, ~p|/widgets|)
  |> assert_html("Widgets List")
  |> click("a", "New Widgets")
  |> follow(~p|/widgets/new|)
end
```

### Example Live Component Test
In order to test a live view component we need a full
endpoint. Attach the component host into the Router for test
environments (attaching for debug is nice sometimes too).

That can be done like this:
```
if Enum.member?([:dev, :test], Mix.env()) do
  scope "/dev" do
    pipe_through :browser

    live "/heyya/host", Heyya.LiveComponentHost
  end
end
```

From then on `/dev/heyya/host` will host dynamic content with no layout other than a single wrapper div.


```
  use Heyya.LiveComponentCase
  use ExampleWeb.ConnCase
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <.live_component module={ExampleWeb.LiveCounterComponent} id="example" />
    """
  end

  test "Test Counter", %{conn: conn} do
    conn
    |> start()
    |> click("button.increment")
    |> assert_html("Counter: 1")
  end
```

## Contributing

We welcome contributions to Heyya! Please see the CONTRIBUTING.md file for guidelines on how to contribute.

## License

Heyya is released under the MIT License.
