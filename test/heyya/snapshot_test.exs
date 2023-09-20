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

  describe "The inner workings" do
    test "Heyya.SnapshotTest.compare_html/2 doesnt care about httml attr order" do
      a = "<h1 attrone=\"a\" attrtwo=\"b\">HI</h1>"
      b = "<h1 attrtwo=\"b\" attrone=\"a\">HI</h1>"

      assert Heyya.SnapshotTest.compare_html(a, b)
    end
  end
end
