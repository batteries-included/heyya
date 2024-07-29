defmodule Heyya.SnapshotCase do
  @moduledoc """
  `Heyya.SnapshotCase` allows for fast snapshot
  testing of Phoenix components. Snapshot testing
  components is a fast and easy way to ensure that
  they work and produce what they expected to
  produce without having to hand write
  assertions.

  ## Complex Tests Made Easy

  Suppose you have a component button with a color
  and and icon. You want to test that the correct
  css class is applied to the whole dom tree. Instead
  assert that the dom tree is functionally equivalent
  to the expected output.

  ```elixir
  component_snapshot_test "Eiffel 65" do
    assigns = %{}

    ~H|<.button phx-click="click" class="bg-blue-500">Click me</.button>|
  end
  ```

  ## Change Tests Faster

  Any changes to that would require changes to the
  test are easily updated by running the tests and
  updating the snapshots. This happens by setting the
  environment variable `HEYYA_OVERRIDE` to `true` or `1`.

  ```
  HEYYA_OVERRIDE=true mix test
  ```
  """

  use ExUnit.CaseTemplate

  @doc """
  Wire up the module to prepare for snapshot testing.
  """
  using _ do
    quote do
      use ExUnit.Case

      import Heyya.SnapshotCase, only: [component_snapshot_test: 2, component_snapshot_test: 3]
      import Phoenix.Component
      import Phoenix.LiveViewTest
    end
  end

  @doc """
  A named component snapshot test
  """
  defmacro component_snapshot_test(name, do: expr) do
    quote do
      test unquote(name) do
        Heyya.SnapshotCase.inner_test(unquote(expr))
      end
    end
  end

  @doc """
  A named component snapshot test, where context is passed through.
  """
  defmacro component_snapshot_test(name, context, do: expr) do
    quote do
      test unquote(name), unquote(context) do
        Heyya.SnapshotCase.inner_test(unquote(expr))
      end
    end
  end

  defmacro inner_test(expr) do
    base_dir = Heyya.SnapshotUtil.directory(__CALLER__)
    fname = Heyya.SnapshotUtil.filename(__CALLER__)

    quote bind_quoted: [base_dir: base_dir, fname: fname, expr: expr] do
      # The component rendered to html
      rendered = rendered_to_string(expr)

      # Where the snapshot should be located
      snapshot = Heyya.SnapshotUtil.get_snapshot(Path.join(base_dir, fname))

      case {Heyya.SnapshotUtil.compare_html(snapshot, rendered), Heyya.SnapshotUtil.override?()} do
        {true, _} ->
          # If they match (might not be string identical)
          # then return ok
          :ok

        {false, true} ->
          # Where this should be located

          # If we didn't match but we're allowed to overwrite, then do that now
          Heyya.SnapshotUtil.overwrite!(base_dir, fname, rendered)

          # If we overwrite everything then return ok
          :ok

        {false, false} ->
          raise ExUnit.AssertionError,
            left: snapshot,
            right: rendered,
            message: "Received value does not match stored snapshot.",
            expr: "Snapshot == Received"
      end
    end
  end
end
