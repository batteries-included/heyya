defmodule Header do
  @moduledoc """
  Example component to use in testing Heyya.
  """
  use Phoenix.Component

  attr :class, :any, default: "text-3xl font-bold tracking-tight text-gray-900"
  attr :rest, :global

  slot :inner_block, required: true

  def simple(assigns) do
    ~H"""
    <h1 class={@class} {@rest}>{render_slot(@inner_block)}</h1>
    """
  end
end
