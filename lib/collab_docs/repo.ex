defmodule CollabDocs.Repo do
  use Ecto.Repo,
    otp_app: :collab_docs,
    adapter: Ecto.Adapters.Postgres
end
