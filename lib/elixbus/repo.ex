defmodule Elixbus.Repo do
  use Ecto.Repo,
    otp_app: :elixbus,
    adapter: Ecto.Adapters.Postgres
end
