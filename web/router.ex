defmodule Encrypter.Router do
  use Encrypter.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Encrypter.Plug.CurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Encrypter do
    pipe_through :browser # Use the default browser stack

    get "/", FolderController, :index
    get "/folders/new", FolderController, :new
    post "/folders", FolderController, :create
    get "/folders/:id", FolderController, :show
    delete "/folders/:id", FolderController, :delete
    get "/folders/:id/edit", FolderController, :edit
    post "/folders/:id/edit", FolderController, :add_user

    get "/folders/:id/upload", FileController, :new
    post "/folders/:id/upload", FileController, :create

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    get "/logout", SessionController, :delete

    get "/registration", RegistrationController, :new
    post "/registration", RegistrationController, :create
  end
end
