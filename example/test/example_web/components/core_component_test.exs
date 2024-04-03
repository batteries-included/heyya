defmodule ExampleWeb.CoreComponentTest do
  use Heyya.SnapshotCase

  import ExampleWeb.CoreComponents

  describe "button/1" do
    component_snapshot_test "renders the bare min" do
      assigns = %{}

      ~H"""
      <.button>Click me</.button>
      """
    end

    # Show a test with phx-click and classes
    component_snapshot_test "renders with phx-click and classes" do
      assigns = %{}

      ~H"""
      <.button phx-click="click" class="bg-blue-500 text-white">Click me</.button>
      """
    end
  end

  describe "table" do
    component_snapshot_test "renders a small table" do
      assigns = %{rows: Enum.map(1..3, fn i -> %{id: i, name: "Some Name: #{i}"} end)}

      ~H"""
      <.table rows={@rows} id="example_table">
        <:col :let={row} label="ID"><%= row.id %></:col>
        <:col :let={row} label="Name"><%= row.name %></:col>
      </.table>
      """
    end
  end

  describe "back/1" do
    component_snapshot_test "Standard example" do
      assigns = %{}

      ~H"""
      <.back navigate="/">Back to home</.back>
      """
    end
  end
end
