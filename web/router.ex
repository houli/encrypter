defmodule Encrypter.Router do
  use Encrypter.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Encrypter do
    pipe_through :browser # Use the default browser stack

    get "/", SessionController, :new
    post "/login", SessionController, :create
    get "/logout", SessionController, :delete
    get "/pages", PageController, :index
    get "/registration", RegistrationController, :new
    post "/registration", RegistrationController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", Encrypter do
  #   pipe_through :api
  # end
end
