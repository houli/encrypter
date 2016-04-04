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
    get "/folder/new", FolderController, :new
    post "/folder", FolderController, :create
    get "/folder/:id", FolderController, :show
    delete "/folder/:id", FolderController, :delete
    get "/folder/:id/edit", FolderController, :edit
    post "/folder/:id/edit", FolderController, :add_user
    get "/folder/:id/upload", FolderController, :new_file
    post "/folder/:id/upload", FolderController, :upload_file

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    get "/logout", SessionController, :delete

    get "/registration", RegistrationController, :new
    post "/registration", RegistrationController, :create
  end
end
