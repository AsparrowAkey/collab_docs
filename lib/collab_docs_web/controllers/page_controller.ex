defmodule CollabDocsWeb.PageController do
  use CollabDocsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
