import Config

# Database Configuration
config :collab_docs, CollabDocs.Repo,
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  hostname: "localhost",
  database: "collab_docs_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# In development, we turn off caching, turn on debugging,
# and reload code automatically.
#
# Watchers can run external tools, like bundling JavaScript
# or CSS files.
config :collab_docs, CollabDocsWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "CWsbTpT5GJZxaKsb2bpUAvbTTE7szjO9MxXPkEp0dRFhChXLe5+RHp8q5iK381Y9",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:collab_docs, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:collab_docs, ~w(--watch)]}
  ]

# ## SSL Support
#
# To use HTTPS in development, create a self-signed cert:
#     mix phx.gen.cert
# For details: mix help phx.gen.cert
#
# Replace `http:` with `https:` in config, or use both
# to run HTTP and HTTPS on different ports.

# Reload browser tabs when matching files change.
config :collab_docs, CollabDocsWeb.Endpoint,
  live_reload: [
    web_console_logger: true,
    patterns: [
      # Static files but not user uploads
      ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$"E,
      # Gettext translations
      ~r"priv/gettext/.*\.po$"E,
      # Router, Controllers, LiveViews and LiveComponents
      ~r"lib/collab_docs_web/router\.ex$"E,
      ~r"lib/collab_docs_web/(controllers|live|components)/.*\.(ex|heex)$"E
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :collab_docs, dev_routes: true

# No metadata or timestamps in dev logs
config :logger, :default_formatter, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Include debug annotations and locations in rendered markup.
  # Changing this configuration will require mix clean and a full recompile.
  debug_heex_annotations: true,
  debug_attributes: true,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false
