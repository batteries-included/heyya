defmodule Heyya.SnapshotCase do
  @moduledoc """
  `Heyya.SnapshotCase` allows for fast snapshot
  testing of Phoenix components. Snapshot testing
  components is a fast and easy way to ensure that
  they work and produce what they expected to
  produce without having to hand write
  assertions.
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
    quote do
      rendered = rendered_to_string(unquote(expr))
      snapshot = Heyya.SnapshotCase.get_snapshot(unquote(Macro.escape(__CALLER__)))

      case {Heyya.SnapshotCase.compare_html(snapshot, rendered), Heyya.SnapshotCase.override?()} do
        {true, _} ->
          # If they match (might not be string identical)
          # then return ok
          :ok

        {false, true} ->
          # If we didn't match but we're allowed to overwrite, then do that now
          Heyya.SnapshotCase.override!(unquote(Macro.escape(__CALLER__)), rendered)

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

  @spec compare_html(binary, binary) :: boolean
  def compare_html(snapshot_value, rendered_value) do
    # Parse the HTML with Floki
    #
    # Since we know that all the values
    r = Floki.parse_fragment!(rendered_value)
    s = Floki.parse_fragment!(snapshot_value)

    # For every node in the fragments compare them
    deep_compare(s, r)
  end

  @spec override? :: boolean
  def override? do
    "HEYYA_OVERRIDE" |> System.get_env() |> overriding_value?()
  end

  @spec override!(Macro.Env.t(), binary) :: :ok
  def override!(%Macro.Env{} = env, content) do
    base_dir = directory(env)
    fname = filename(env)

    File.mkdir_p!(base_dir)
    base_dir |> Path.join(fname) |> File.write!(content)

    # Print out some visual indication that
    # we wrote a new file and skipped the test
    IO.write("S")
  end

  defp overriding_value?("true"), do: true
  defp overriding_value?("TRUE"), do: true
  defp overriding_value?("1"), do: true
  defp overriding_value?("YES"), do: true
  defp overriding_value?("yes"), do: true
  defp overriding_value?(_), do: false

  defp deep_compare(expected, test_value) when is_list(expected) and is_list(test_value) do
    # Deep compare is given a list of nodes. Those lists should be the same
    # however OTP 26 decided that it wanted to make maps not have stable
    # map order for small keys. That is what phoenix uses for @rest and attrs
    #
    # So we have dive into the nodes making sure they are scemantically the same.
    length(expected) == length(test_value) and
      expected
      |> Enum.zip(test_value)
      |> Enum.all?(fn {expected, test} -> deep_compare(expected, test) end)
  end

  # Compares two node tuples from the parsed HTML.
  # The node tuples contain the node name, attributes, and content.
  #
  # This checks that the node names match, the attributes match
  # with no regard for order, and recursively compares the content.
  #
  # ## Returns
  #
  # True if the nodes match, false otherwise.
  defp deep_compare({expected_node, expected_attrs, expected_content}, {test_node, test_attrs, test_content}) do
    expected_node == test_node && compare_attrs(expected_attrs, test_attrs) &&
      deep_compare(expected_content, test_content)
  end

  ###
  # Compares two content values when they are binaries.
  #
  # This trims whitespace from both binaries before comparing.
  #
  # ## Returns
  #
  # True if the trimmed content matches, false otherwise.
  # """
  defp deep_compare(expected_content, test_content) when is_binary(expected_content) and is_binary(test_content) do
    String.trim(expected_content) == String.trim(test_content)
  end

  defp deep_compare(expected_content, test_content) do
    expected_content == test_content
  end

  defp compare_attrs(expected, test) do
    sorted_expected = Enum.sort_by(expected, fn {attr_name, _value} -> attr_name end)
    sorted_test = Enum.sort_by(test, fn {attr_name, _value} -> attr_name end)
    sorted_expected == sorted_test
  end

  @doc """
  Gets the directory to store snapshot files for the test.


  ## Parameters

  - env: The macro environment which contains metadata about the test file.

  ## Returns

  The directory path as a binary where snapshots should be stored.
  """
  @spec directory(Macro.Env.t()) :: String.t()
  def directory(%Macro.Env{file: file} = _env) do
    path_parts = Path.split(file)

    # This is kind of silly and unsafe, but I don't have a better way
    #
    # We are trying to get the base test directory of this project.
    # However there can be directories named test in
    # the path or there can be files named test
    #
    # So we assume the last directory that is named test is the correct one to do.
    # This will produce un-expected results if there is a structure like this:
    #
    # mylib
    # lib
    # test
    #   test
    #     my_other_snap_test_file.exs
    #   my_snapshot_test.exs
    #
    # The __snapshot__ directory for `my_other_snap_test_file` will be wrong
    base_dir =
      path_parts
      |> Enum.reverse()
      |> Enum.drop_while(&(&1 != "test"))
      |> Enum.reverse()
      |> Path.join()
      |> Path.join("__snapshots__")

    # We know where the base directory for this project is, but we need
    # to know the directory for this test file.
    # For that we need the parts of the path that aren't in the basedir
    inner_dir_parts = path_parts |> Enum.drop_while(&(&1 != "test")) |> Enum.drop(1)
    # We want to group multiple tests into a directory
    # named after the file the test are in.
    filename_part = inner_dir_parts |> List.last() |> String.replace(".exs", "")

    # Drop the filename
    kept_inner_dir = Enum.drop(inner_dir_parts, -1)

    suffix =
      Path.join(kept_inner_dir ++ [filename_part])

    # Join everything back together
    Path.join(base_dir, suffix)
  end

  @spec filename(Macro.Env.t()) :: String.t()
  def filename(%Macro.Env{function: {function_name, _}} = _env) do
    base =
      function_name
      |> Atom.to_string()
      # Collapse multiple spaces together
      |> String.replace(~r/\s+/, "_")
      # Function names can have slashes
      |> String.replace(~r/\/+/, "__")
      # Just to make sure
      |> Macro.underscore()

    base <> ".heyya_snap"
  end

  @doc """
  Gets the stored snapshot for the given macro environment.

  This looks up the snapshot file path and name based on the environment,
  reads the file contents, and returns the snapshot.

  If there is no snapshot file yet, returns an empty binary.

  ## Parameters

  - env: The macro environment which contains metadata about the test module and function.

  ## Returns

  The stored snapshot as a binary, or empty binary if no snapshot exists.
  """
  @spec get_snapshot(Macro.Env.t()) :: binary
  def get_snapshot(%Macro.Env{} = env) do
    dir = directory(env)
    fname = filename(env)

    full_path = Path.join(dir, fname)

    try do
      case File.read(full_path) do
        {:ok, value} -> value
        {:error, _} -> ""
      end
    rescue
      _ -> ""
    end
  end
end
