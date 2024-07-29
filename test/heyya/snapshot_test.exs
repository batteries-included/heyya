defmodule HeyyaTest.SnapshotTest do
  use Heyya.SnapshotCase

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

  component_snapshot_test "Form with rest" do
    assigns = %{}

    ~H"""
    <form phx-change="change" phx-submit="submit" phx-target="1" />
    """
  end

  component_snapshot_test "Text only" do
    assigns = %{}

    ~H"""
    Tes3ting
    """
  end

  component_snapshot_test "Header with rest again" do
    assigns = %{}

    ~H"""
    <Header.simple phx-change="change" phx-submit="submit" phx-target="1">
      Testing Again. Ordering matters.
    </Header.simple>
    """
  end
end
