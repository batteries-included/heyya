defmodule ExampleWeb.Router do
  use ExampleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ExampleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExampleWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/numbers", Live.NumberList
    live "/counter", Live.Counter
  end

  # Notice that we add the dev scope
  # in the test and dev environment only.
  #
  # Tests need it for Heyya.LiveComponentCase
  if Enum.member?([:dev, :test], Mix.env()) do
    scope "/dev" do
      pipe_through :browser
      live "/heyya/host", Heyya.LiveComponentHost
    end
  end
end
