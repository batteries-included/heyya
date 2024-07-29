defmodule Heyya.SnapshotUtilTest do
  use ExUnit.Case

  alias Heyya.SnapshotUtil

  test "Heyya.Snapshots.compare_html/2 doesnt care about httml attr order" do
    a = "<h1 attrone=\"a\" attrtwo=\"b\">HI</h1>"
    b = "<h1 attrtwo=\"b\" attrone=\"a\">HI</h1>"

    assert SnapshotUtil.compare_html(a, b)
  end

  test "Heyya.SnapshotUtil.compare_html doesnt care about inner spacing" do
    a = "<h1 class=\"test\">HI</h1>"
    b = "<h1    class=\"test\">HI</h1>"

    assert SnapshotUtil.compare_html(a, b)
  end
end
