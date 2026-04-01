defmodule CollabDocsWeb.DocumentLive do
  use CollabDocsWeb, :live_view

  alias CollabDocs.Documents


  @impl true
  def handle_event("edit", %{"content" => content}, socket) do

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

    {:noreply, assign(socket, :last_saved_at, System.system_time(:second))}
  end

  @impl true
  def handle_event("typing_start", _params, socket) do
    CollabDocsWeb.Presence.update(
      self(),
      socket.assigns.topic,
      socket.assigns.user_id,
      fn meta -> Map.put(meta, :typing, true) end
    )
    {:noreply, socket}
  end

  @impl true
  def handle_event("typing_stop", _params, socket) do
    CollabDocsWeb.Presence.update(
      self(),
      socket.assigns.topic,
      socket.assigns.user_id,
      fn meta -> Map.put(meta, :typing, false) end
    )
    {:noreply, socket}
  end

  # Document content updates
  @impl true
  def handle_info({:document_updated, content}, socket) do

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

  # Triggers a re-render every second for the last saved indicator
  @impl true
  def handle_info(:tick, socket) do
    {:noreply, socket}
  end

  defp format_last_saved(nil), do: "Not saved yet"
  defp format_last_saved(saved_at) do
    diff = System.system_time(:second) - saved_at
    cond do
      diff < 5   -> "Saved just now"
      diff < 60  -> "Last saved #{diff} seconds ago"
      true       -> "Last saved #{div(diff, 60)} minutes ago"
    end
  end

  # Initializes the state and real time connections of a view
  @impl true
  @colors ["#E57373", "#64B5F6", "#81C784", "#FFD54F", "#BA68C8", "#4DB6AC", "#FF8A65"]
  def mount(%{"id" => id}, _session, socket) do
    document = Documents.get_document!(id)
    topic = "document:#{id}"
    user_id = "user_#{:rand.uniform(1000)}"
    color = Enum.random(@colors)

    presences =
    if connected?(socket) do
      Phoenix.PubSub.subscribe(CollabDocs.PubSub, topic)

      {:ok, _} =
      CollabDocsWeb.Presence.track(
        self(),
        topic,
        user_id,
        %{
          online_at: System.system_time(:second),
          color: color
        }
      )

      :timer.send_interval(1000, self(), :tick)

      CollabDocsWeb.Presence.list(topic)
      else
      %{}
    end

   {:ok,
   socket
   |> assign(:document, document)
   |> assign(:topic, topic)
   |> assign(:user_id, user_id)
   |> assign(:color, color)
   |> assign(:presences, presences)
   |> assign(:last_saved_at, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1><%= @document.title %></h1>

      <div style="display: flex; gap: 8px; margin-bottom: 8px;">
      <%= for {_user_id, %{metas: [meta | _]}} <- @presences do %>
          <span style={"
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background-color: #{meta.color};
            display: inline-block;
          "}></span>
        <% end %>
      </div>

      <div style="min-height: 24px; margin-bottom: 8px;">
        <%= for {user_id, %{metas: [meta | _]}} <- @presences,
            user_id != @user_id,
            meta[:typing] == true do %>
          <span style={"color: #{meta.color}; font-size: 14px;"}>
            Someone is typing...
          </span>
        <% end %>
      </div>

      <p style="font-size: 13px; color: gray;">
        <%= format_last_saved(@last_saved_at) %>
      </p>

      <p>Users online: <%= map_size(@presences) %></p>

      <form phx-change="edit">
        <textarea
          id={"document-content-#{@document.id}"}
          name="content"
          phx-debounce="300"
          phx-focus="typing_start"
          phx-blur="typing_stop"
          rows="10"
          cols="80"
        ><%= @document.content %></textarea>
      </form>
    </div>
    """
  end
end
