defmodule CollabDocsWeb.DocumentsLive do
  use CollabDocsWeb, :live_view

  alias CollabDocs.Documents

  @impl true
  def mount(_params, _session, socket) do
    documents = Documents.list_documents()
    {:ok, assign(socket, :documents, documents)}
  end

  @impl true
  def handle_event("create_document", _params, socket) do
    {:ok, document} = Documents.create_document(%{
      title: "Untitled Document",
      content: ""
    })

    {:noreply, push_navigate(socket, to: "/documents/#{document.id}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Documents</h1>

      <button phx-click="create_document">
        + New Document
      </button>

      <ul>
        <%= for document <- @documents do %>
          <li>
            <a href={"/documents/#{document.id}"}>
              <%= document.title %>
            </a>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
