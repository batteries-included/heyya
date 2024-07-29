defmodule ExampleWeb.NumbersLiveTest do
  use Heyya.LiveCase
  use ExampleWeb.ConnCase

  describe "/numbers is a place of meaningless numbers" do
    test "Can remove numbers", %{conn: conn} do
      conn
      |> start(~p"/numbers")
      |> assert_html("32")
      |> click("#btn-32")
      |> refute_html("32")
    end
  end

  test "/numbers buttons render well", %{conn: conn} do
    conn
    |> start(~p"/numbers")
    |> assert_matches_snapshot(selector: "#btn-32", name: "Button 32")
    |> click("#btn-32")
    |> assert_matches_snapshot(selector: "#btn-33", name: "Button 33")
    |> click("#btn-33")
  end

  test "/numbers renders the live_view", %{conn: conn} do
    conn
    |> start(~p"/numbers")
    |> assert_matches_snapshot(name: "full_view", selector: "main")
  end

  test "/numbers renders the live_view with default name", %{conn: conn} do
    conn
    |> start(~p"/numbers")
    |> assert_matches_snapshot()
  end

  describe "/numbers" do
    test "/numbers renders the live_view matches the same snapshot", %{conn: conn} do
      # It's possible to use the same snapshot name multiple
      # times that will ensure that the snapshot is the same in the same test.
      #
      # Snapshot names are unique/scoped per test.
      conn
      |> start(~p"/numbers")
      |> assert_matches_snapshot(name: "base")

      conn
      |> start(~p"/numbers")
      |> assert_matches_snapshot(name: "base")
    end
  end
end
