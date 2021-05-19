defmodule Components.Repo do
  use Ecto.Repo,
    otp_app: :components,
    adapter: Ecto.Adapters.Postgres
end
