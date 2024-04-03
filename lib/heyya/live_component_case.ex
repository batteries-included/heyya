defmodule Heyya.LiveComponentCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  import Phoenix.LiveViewTest

  alias Heyya.LiveTestSession

  using options do
    quote do
      import Heyya.LiveCase, except: [start: 1, start: 2]
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
