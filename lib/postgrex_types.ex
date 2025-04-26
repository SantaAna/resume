Postgrex.Types.define(
  Resume.PostgrexTypes,
  Pgvector.extensions() ++ Ecto.Adapters.Postgres.extensions()
)
