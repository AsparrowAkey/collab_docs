defmodule CollabDocsWeb.DocumentLive do
  use CollabDocsWeb, :live_view

  alias CollabDocs.Documents


  @impl true
def handle_event("edit", %{"content" => content}, socket) do
  IO.inspect(content, label: ">>> TYPING")
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

  {:noreply, socket}
  end

  # Document content updates
  @impl true
  def handle_info({:document_updated, content}, socket) do
    IO.inspect(content, label: ">>> RECEIVED UPDATE")
    updated = %{socket.assigns.document | content: content}
    {:noreply, assign(socket, document: updated)}
  end

  # Handle updates from other users
  @impl true
  def handle_info(
      %Phoenix.Socket.Broadcast{event: "presence_diff"},
      socket) do
  presences = CollabDocsWeb.Presence.list(socket.assigns.topic)
  {:noreply, assign(socket, presences: presences)}
  end

  # Catch all for message errors
  @impl true
  def handle_info(msg, socket) do
    IO.inspect(msg, label: "Unhandled message")
    {:noreply, socket}
  end

  # Initializes the state and real time connections of a view
  @impl true
  def mount(%{"id" => id}, _session, socket) do
    document = Documents.get_document!(id)
    topic = "document:#{id}"
    user_id = "user_#{:rand.uniform(1000)}"

    presences =
    if connected?(socket) do
      Phoenix.PubSub.subscribe(CollabDocs.PubSub, topic)

    {:ok, _} =
      CollabDocsWeb.Presence.track(
        self(),
        topic,
        user_id,
        %{online_at: System.system_time(:second)}
      )

    CollabDocsWeb.Presence.list(topic)
    else
      %{}
  end

   {:ok,
   socket
   |> assign(:document, document)
   |> assign(:topic, topic)
   |> assign(:user_id, user_id)
   |> assign(:presences, presences)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1><%= @document.title %></h1>

      <p>Users online: <%= map_size(@presences) %></p>
    <form phx-change="edit">
      <textarea
        id={"document-content-#{@document.id}"}
        name="content"
        phx-debounce="300"
        rows="10"
        cols="80"
      ><%= @document.content %></textarea>
    </form>
    </div>
    """
  end
end
