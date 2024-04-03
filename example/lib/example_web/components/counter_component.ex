defmodule ExampleWeb.LiveCounterComponent do
  @moduledoc false
  use ExampleWeb, :live_component

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    value = Map.get(assigns, :counter, 0) || 0
    {:ok, assign(socket, :counter, value)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("increment", _, %{assigns: %{counter: counter}} = socket) do
    {:noreply, assign(socket, :counter, counter + 1)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("reset", _, socket) do
    {:noreply, assign(socket, :counter, 0)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="flex flex-column gap-2">
      <button class="increment" phx-click="increment" phx-target={@myself}>Increment</button>
      <button class="reset" phx-click="reset" phx-target={@myself}>Reset</button>
      <span>Counter: <%= @counter %></span>
    </div>
    """
  end
end
