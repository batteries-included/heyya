defmodule Heyya.LiveTestSession do
  @moduledoc """
  This module is a struct to hold the state of a session of live view testing.

  It wraps up Plug connection, the current view, and the latest rendered html
  """

  @enforce_keys [:conn]
  defstruct conn: nil, html: nil, view: nil

  @type t() :: %__MODULE__{conn: Plug.Conn.t(), html: any() | nil, view: any() | nil}
end
