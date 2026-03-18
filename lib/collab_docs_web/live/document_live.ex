defmodule CollabDocsWeb.DocumentLive do
  use CollabDocsWeb, :live_view

  alias CollabDocs.Documents
  alias CollabDocs.Documents.Document

  @impl true
def handle_event("edit", %{"value" => content}, socket) do
  document = socket.assigns.document

  # Update the database
  {:ok, updated} =
    Documents.update_document(document, %{
      content: content
    })

  # Broadcast to others
  Phoenix.PubSub.broadcast(
    CollabDocs.PubSub,
    "document:#{document.id}",
    {:document_updated, updated.content}
  )

  # Update your own view
  {:noreply, assign(socket, document: updated)}
end

  # Handle updates from other users
  @impl true
  def handle_info({:document_updated, content}, socket) do
    updated = %{socket.assigns.document | content: content}
    {:noreply, assign(socket, document: updated)}
end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    document = Documents.get_document!(id)
    topic = "document:#{id}"

    if connected?(socket) do
    Phoenix.PubSub.subscribe(CollabDocs.PubSub, topic)
  end

    {:ok,
    socket
    |> assign(:document, document)
    |> assign(:topic, topic)}

  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1><%= @document.title %></h1>

      <textarea
        phx-change="edit"
        phx-debounce="300"
        rows="10"
        cols="80"
      ><%= @document.content %></textarea>
    </div>
    """
  end
end
