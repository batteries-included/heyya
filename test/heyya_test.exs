defmodule HeyyaTest do
  use Heyya

  component_snapshot_test "Header test" do
    assigns = %{}

    ~H"""
    <Header.simple>Testing</Header.simple>
    """
  end
end
