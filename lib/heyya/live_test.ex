defmodule Heyya.LiveTest do
  @moduledoc """

  `Heyya.LiveTest` module provides helper methods that make it easier to write a
  more linear live view test. It takes care of the fact that there's
  connection state, view state, and last html state.

  These ideas origionally came from: https://www.reddit.com/r/elixir/comments/ydyt2m/better_liveview_tests/

  This implementation doesn't hide follow (in large part because
  of the ergonomics of follow_redirect being a macro)

  ## Example

  ```
  defmodule MyPhoenixWeb.ListLiveTest do
    use Heyya.LiveTest
    use MyPhoenixWeb.ConnCase

    test "widget list with new button", %{conn: conn} do
      start(conn, ~p|/widgets|)
      |> assert_html("Widgets List")
      |> click("a", "New Widgets")
      |> follow(~p|/widgets/new|)
    end
  end
  ```
  """

  import ExUnit.Assertions

  alias Heyya.LiveTestSession
  alias Phoenix.LiveViewTest

  defmacro __using__(_opts) do
    quote do
      # import things, but only import what we absolutely need from LiveViewTest
      import Heyya.LiveTest
      import Phoenix.LiveViewTest, only: [live: 1, live: 2, follow_redirect: 3]

      # require the modules that we use the macros in
      require Heyya.LiveTest
      require Phoenix.LiveViewTest
    end
  end

  @doc """
  Macro that creates code to start a new LiveTestSession. This takes in a plug
  connection (Usually from your ConnTest)
  """
  defmacro start(conn, path) do
    quote bind_quoted: [conn: conn, path: path] do
      assert {:ok, view, html} = live(conn, path),
             "Should be a be able to start a new live session with path #{path}"

      %Heyya.LiveTestSession{conn: conn, html: html, view: view}
    end
  end

  @doc """
  Macro that creates code to follow a redirect. This takes
  in a LiveTestSession and will assert that a redirect exists.
  """
  defmacro follow(before, to \\ nil) do
    quote bind_quoted: [before: before, to: to] do
      # The value coming in will likely be a piped in LiveTestSession how,
      # But we want to always return a new LiveTestSession so wrap the follow in a lambda
      # called via then()
      then(before, fn %Heyya.LiveTestSession{html: html, conn: conn} = test_session ->
        assert {:ok, new_view, new_html} = follow_redirect(html, conn, to), "Should follow any redirects that exist"

        %Heyya.LiveTestSession{test_session | html: new_html, view: new_view}
      end)
    end
  end

  @doc """
  This method will use LiveViewTest.render_async to ensure that all
  outstanding async operations are completed.  By default this
  will wait the ExUnit default timeout.
  """
  def await_async(
        %LiveTestSession{view: view} = test_session,
        timeout \\ Application.fetch_env!(:ex_unit, :assert_receive_timeout)
      ) do
    %LiveTestSession{test_session | html: LiveViewTest.render_async(view, timeout)}
  end

  @spec focus(Heyya.LiveTestSession.t(), binary()) :: Heyya.LiveTestSession.t()
  def focus(%LiveTestSession{view: view} = test_session, selector) do
    assert_element(test_session, selector)

    new_html =
      view
      |> LiveViewTest.element(selector)
      |> LiveViewTest.render_focus()

    %LiveTestSession{test_session | html: new_html}
  end

  @doc """
  This method clicks on an element that's selected via selector then renders
  the result. Finally returning a new LiveTestSession with updated rendered html

  This will also assert that there is an element that's specified by the selector

  This doesn't follow navigations or redirect.

  returns: `%Heyya.LiveTestSession{}`
  """
  @spec click(Heyya.LiveTestSession.t(), String.t(), String.t() | nil) ::
          Heyya.LiveTestSession.t()
  def click(%LiveTestSession{view: view} = test_session, selector, text \\ nil) do
    assert_element(test_session, selector, text)

    new_html =
      view
      |> LiveViewTest.element(selector, text)
      |> LiveViewTest.render_click()

    %LiveTestSession{test_session | html: new_html}
  end

  @doc """
  Sets the form specified by the selector to a new value.

  This doesn't submit the form

  returns: `%Heyya.LiveTestSession{}`
  """
  @spec form(Heyya.LiveTestSession.t(), String.t(), any) :: Heyya.LiveTestSession.t()
  def form(%LiveTestSession{view: view} = test_session, selector, opts) do
    new_html =
      view
      |> LiveViewTest.form(selector, opts)
      |> LiveViewTest.render_change()

    %LiveTestSession{test_session | html: new_html}
  end

  @doc """
  Submits the form and renders the result of submitting.

  This doesn't follow any redirects.

  returns: `%Heyya.LiveTestSession{}`
  """
  @spec submit_form(Heyya.LiveTestSession.t(), String.t(), any) :: Heyya.LiveTestSession.t()
  def submit_form(%LiveTestSession{view: view} = test_session, selector, opts) do
    new_html =
      view
      |> LiveViewTest.form(selector, opts)
      |> LiveViewTest.render_submit()

    %LiveTestSession{test_session | html: new_html}
  end

  ###
  #
  # Assertions
  #
  ###

  @doc """
  Asserts that the html in the LiveTestSession matches the
  provided expected html.

  Returns the LiveTestSession.
  """
  @spec assert_html(Heyya.LiveTestSession.t(), String.t() | Regex.t()) ::
          Heyya.LiveTestSession.t()
  def assert_html(%LiveTestSession{html: html} = test_session, expected_html) do
    assert html =~ expected_html,
           "Expected the current live session's state html to contain expected html"

    test_session
  end

  @doc """
  Refute that the html in the LiveTestSession matches the provided html string.

  Returns the LiveTestSession.
  """
  @spec refute_html(Heyya.LiveTestSession.t(), String.t() | Regex.t()) ::
          Heyya.LiveTestSession.t()
  def refute_html(%LiveTestSession{html: html} = test_session, unexpected_html) do
    refute html =~ unexpected_html,
           "The current live veiew session should contain the rejected html"

    test_session
  end

  @spec assert_element(Heyya.LiveTestSession.t(), String.t(), String.t() | nil) ::
          Heyya.LiveTestSession.t()
  def assert_element(%LiveTestSession{view: view} = test_session, selector, text \\ nil) do
    assert LiveViewTest.has_element?(view, selector, text)
    test_session
  end

  @spec refute_element(Heyya.LiveTestSession.t(), String.t(), String.t() | nil) ::
          Heyya.LiveTestSession.t()
  def refute_element(%LiveTestSession{view: view} = test_session, selector, text \\ nil) do
    refute LiveViewTest.has_element?(view, selector, text)
    test_session
  end

  @spec assert_page_title(Heyya.LiveTestSession.t(), String.t() | Regex.t()) ::
          Heyya.LiveTestSession.t()
  def assert_page_title(%LiveTestSession{view: view} = test_session, expected) do
    assert LiveViewTest.page_title(view) =~ expected, "The page title should match"
    test_session
  end

  @spec refute_page_title(Heyya.LiveTestSession.t(), String.t() | Regex.t()) ::
          Heyya.LiveTestSession.t()
  def refute_page_title(%LiveTestSession{view: view} = test_session, unexpected) do
    refute LiveViewTest.page_title(view) =~ unexpected, "The page title should not match"
    test_session
  end
end
