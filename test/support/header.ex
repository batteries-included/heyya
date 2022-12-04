defmodule Header do
  use Phoenix.Component

  attr :class, :any, default: "text-3xl font-bold tracking-tight text-gray-900"
  slot :inner_block, required: true

  def simple(assigns) do
    ~H"""
    <h1 class={@class}><%= render_slot(@inner_block) %></h1>
    """
  end
end
