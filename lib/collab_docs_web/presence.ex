defmodule CollabDocsWeb.Presence do
  use Phoenix.Presence,
    otp_app: :collab_docs,
    pubsub_server: CollabDocs.PubSub
end
