defmodule ExampleWeb.Live.NumberList do
  @moduledoc false
  use ExampleWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, numbers: Enum.to_list(0..69))}
  end

  @impl Phoenix.LiveView
  def handle_event("remove", %{"number" => to_remove}, %{assigns: %{numbers: numbers}} = socket) do
    # Params that come in are strings since everything is passed along the http/websocket
    {int_number, _} = Integer.parse(to_remove, 10)
    # Reject the number from the list
    {:noreply, assign(socket, numbers: Enum.reject(numbers, fn n -> n == int_number end))}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-4 gap-8">
      <div>
        <%= for number <- @numbers do %>
          <.button phx-click="remove" phx-value-number={number} id={"btn-#{number}"}>
            <%= number %>
          </.button>
        <% end %>
      </div>
    </div>
    """
  end
end
