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
end
