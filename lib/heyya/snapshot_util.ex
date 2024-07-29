defmodule Heyya.SnapshotUtil do
  @moduledoc """
  `Heyya.SnapshotUtil` module provides helper methods that make it easier to write snapshot tests.
  """

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
  Should the snapshot be overridden? if it doesn't match.

  # Returns

  True if the snapshot should be overridden, denoted by the environment variable `HEYYA_OVERRIDE`. The value can be `true`, `1`, `yes`, or `YES`.
  False if the snapshot should not be overridden
  """
  @spec override? :: boolean
  def override? do
    "HEYYA_OVERRIDE" |> System.get_env() |> overriding_value?()
  end

  defp overriding_value?("true"), do: true
  defp overriding_value?("TRUE"), do: true
  defp overriding_value?("1"), do: true
  defp overriding_value?("YES"), do: true
  defp overriding_value?("yes"), do: true
  defp overriding_value?(_), do: false

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
  def filename(%Macro.Env{function: {function_name, _}} = _env, extra \\ nil) do
    base =
      function_name
      |> Atom.to_string()
      |> then(fn atom_name ->
        if extra == nil do
          atom_name
        else
          atom_name <> "_" <> extra
        end
      end)
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
  def get_snapshot(full_path) do
    case File.read(full_path) do
      {:ok, value} -> value
      {:error, _} -> ""
    end
  rescue
    _ -> ""
  end

  @spec overwrite!(String.t(), String.t(), binary) :: :ok
  def overwrite!(base_dir, file_name, content) do
    File.mkdir_p!(base_dir)

    :ok =
      base_dir
      |> Path.join(file_name)
      |> File.write(content)

    # Print out some visual indication that
    # we wrote a new file and skipped the test
    IO.write("S")
  end
end
