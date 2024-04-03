defmodule Heyya.LiveComponentCase do
  @moduledoc """
    A test case template that provides helpers
    for testing live components. It relies on LiveComponentHost
    being mounted.

    It allows for testing dyanmic content such as
    live components with a simplified stack.

    ## Usage

    ```elixir
    # component_test.exs
    use Heyya.LiveComponentCase
    use ExampleWeb.ConnCase

    # By default LiveComponentCase will look for a render function in the module
    def render(assigns) do
      ~H|<.live_component module={ExampleWeb.LiveCounterComponent} id="example" />|
    end

    test "Test Counter", %{conn: conn} do
      conn
      |> start()
      |> click("button.increment")
      |> assert_html("Counter: 1")
    end
    ```


    ## Options

    - `:view_module` - The module that will render the live component
    - `:view_method` - The method that will render the live component
    - `:base_path` - The path to the live component host. Defaults to "/dev/heyya/host"

    ## `Heyya.LiveComponentHost`

    The `Heyya.LiveComponentHost` is a live view that renders only a single live
    component with no other layout or content. It is used to test live components in
    isolation of so don't mount it in scope with complex Plugs.

    ```elixir
    if Enum.member?([:dev, :test], Mix.env()) do
      scope "/dev" do
        pipe_through :browser
        live "/heyya/host", Heyya.LiveComponentHost
      end
    end
    ```
  """
  use ExUnit.CaseTemplate

  import Phoenix.LiveViewTest

  alias Heyya.LiveTestSession

  using options do
    quote do
      # We provide the path and provide `start` so remove those
      # `follow_redirect` is about moving off the page. While that's
      # possible these tests are explicitly about less than page
      # level testing
      import Heyya.LiveCase, except: [start: 1, start: 2, follow_redirect: 3]
      import Heyya.LiveComponentCase
      import Phoenix.LiveViewTest

      # Where's the component that will render our live component for testing
      @view_module unquote(Keyword.get(options, :view_module, nil) || __CALLER__.module)
      @view_method unquote(Keyword.get(options, :view_method, :render))

      # Assuming the live_view host is mounted at /dev/live_component/host
      # if not you can pass the base_path option to the use macro
      @base_path unquote(Keyword.get(options, :base_path, "/dev/heyya/host"))
    end
  end

  defmacro start(conn) do
    quote bind_quoted: [conn: conn] do
      path = "#{@base_path}?module=#{Atom.to_string(@view_module)}&method=#{Atom.to_string(@view_method)}"

      assert {:ok, view, html} = live(conn, path),
             "Should be a be able to start a new live session with path #{path}"

      %LiveTestSession{conn: conn, html: html, view: view}
    end
  end
end
