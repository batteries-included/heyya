defmodule ExampleWeb.Live.Counter do
  @moduledoc false
  use ExampleWeb, :live_view

  @impl Phoenix.LiveView
  def mount(params, _, socket) do
    # Get the starting number from the params, default to 0
    # this simulates a query parameter like /counter?starting_number=5
    {starting_number, _} = params |> Map.get("starting_number", "0") |> Integer.parse(10)
    {:ok, assign(socket, counter: starting_number)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <h2>Super Counter Page</h2>
    <div class="flex flex-column gap-2">
      <.live_component module={ExampleWeb.LiveCounterComponent} counter={@counter} id="main_counter" />
    </div>
    """
  end
end
