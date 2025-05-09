defmodule Resume.Util do
  @moduledoc """
  Random functions that are needed, but have no home.
  If you're bored try refactoring them into more fitting 
  modules.
  """

  @doc """
  Returns a `NaiveDateTime.utc_now()` with microseconds
  truncated.  Ecto will not accept micro seconds when 
  inserting to a DB, and I always forget how to to do
  this until I read the error message
  """
  def ecto_naive_now() do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.truncate(:second)
  end

  defguard is_non_empty_binary(value) when is_binary(value) and byte_size(value) != 0
end
