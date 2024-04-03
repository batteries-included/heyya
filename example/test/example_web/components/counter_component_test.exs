defmodule ExampleWeb.LiveCounterComponentTest do
  use Heyya.LiveComponentCase

  # The testing live_view is mounted in the endpoint
  # and we need test connection access to our endpoint
  use ExampleWeb.ConnCase

  # We need to create a component render method
  use Phoenix.Component

  # In order to test a live component, we need to render it in a live view.
  # This is done by defining a function that renders the bare minimum
  def render(assigns) do
    ~H"""
    <.live_component module={ExampleWeb.LiveCounterComponent} id="example" />
    """
  end

  describe "Heyya.ExampleLiveCounterComponent" do
    test "Test Counter", %{conn: conn} do
      conn
      |> start()
      |> assert_html("Counter: 0")
      |> click("button.increment")
      |> assert_html("Counter: 1")
      |> click("button.increment")
      |> refute_html("Counter: 1")
    end

    test "Test Reset", %{conn: conn} do
      conn
      |> start()
      |> click("button.increment")
      |> assert_html("Counter: 1")
      |> click("button.reset")
      |> assert_html("Counter: 0")
    end
  end
end
