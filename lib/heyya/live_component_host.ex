defmodule Heyya.LiveComponentHost do
  @moduledoc """
  This live view takes in a Module name and a
  method name then dynamically renders it. Params
  (other than module anme and method name) are
  passed along to the function as assigns.

  Content is wrapped in a div with
  id "heyya-inner-content" so that we know what
  outter chrome can be ignored.
  """

  use Phoenix.LiveView,
    layout: {Heyya.LiveComponentHost, :empty_layout}

  def empty_layout(assigns) do
    ~H"""
    <div id="heyya-inner-content">
      {@inner_content}
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event(_, _, socket) do
    # We need a better handle events so that tests can assert
    # on emitted from the live component
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    params = Map.new(params, fn {k, v} -> {String.to_existing_atom(k), v} end)

    {:ok,
     socket
     |> assign_module(params)
     |> assign_method(params)
     |> assign_params(params)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    {apply(@module, @method, [@params])}
    """
  end

  defp assign_module(socket, params) do
    case Map.get(params, :module) do
      nil ->
        socket

      module_name ->
        assign(socket, :module, String.to_existing_atom(module_name))
    end
  end

  defp assign_method(socket, params) do
    case Map.get(params, :method) do
      nil ->
        socket

      method ->
        assign(socket, :method, String.to_existing_atom(method))
    end
  end

  defp assign_params(socket, params) do
    assign(socket, :params, Map.drop(params, [:module, :method]))
  end
end
