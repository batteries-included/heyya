defmodule HeyyaTest.SnapshotTest do
  use Heyya.SnapshotTest

  component_snapshot_test "Header test" do
    assigns = %{}

    ~H"""
    <Header.simple>Testing</Header.simple>
    """
  end

  component_snapshot_test "Header test with class" do
    assigns = %{custom_class: "my-class"}

    ~H"""
    <Header.simple class={@custom_class}>Testing with static</Header.simple>
    """
  end
end
