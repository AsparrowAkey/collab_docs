defmodule CollabDocsWeb.PageController do
  use CollabDocsWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: "/documents")
  end
end
