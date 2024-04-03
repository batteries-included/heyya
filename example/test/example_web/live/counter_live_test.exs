defmodule ExampleWeb.CounterLiveTest do
  use Heyya.LiveCase
  use ExampleWeb.ConnCase

  # Sometimes you want to test the behavior
  # of a LiveView including all live components
  #
  # For example if you have url params or want to show that the pages are accessible
  describe "CounterLive" do
    test "increments the counter", %{conn: conn} do
      conn
      |> start(~p"/counter")
      |> assert_html("0")
      |> click("button.increment")
      |> assert_html("1")
    end

    test "Get the counter value from url", %{conn: conn} do
      conn
      |> start(~p"/counter?counter=5")
      |> assert_html("5")
    end
  end
end
