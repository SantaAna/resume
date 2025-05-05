defmodule Resume.Validations do
  @moduledoc """
  Custom changeset validations.
  """
  alias Ecto.Changeset

  import Ecto.Changeset

  @doc """
  Ensures that the `first_date` field is strictly before the `second_date` field.
  The value of the `first_date` field and teh `second_date` fields must be structs 
  from the same module, and that module must implement a `compare/2` function.

  You **must** run cast and validate that the two fields exist before running this validation.
  If either are missing or of an invalid type this function will raise.

  If the condition does not hold errors will be added to both fields in the changeset.
  """
  @spec validate_before(
          changeset :: Changeset.t(),
          first_date :: atom(),
          second_date :: atom()
        ) ::
          Changeset.t()
  def validate_before(%Changeset{valid?: false} = cs, _first_date, _second_date) do
    cs
  end

  def validate_before(%Changeset{} = cs, first_date, second_date)
      when is_atom(first_date) and is_atom(second_date) do
    case validate_before_comaparison(cs, first_date, second_date) do
      r when r in [:lt, :pass] ->
        cs

      r when r in [:gt, :eq] ->
        cs
        |> add_error(first_date, "must be before #{second_date}",
          additional: "#{first_date} must be before #{second_date}"
        )
        |> add_error(second_date, "must be after #{first_date}",
          additional: "#{second_date} must be after #{first_date}"
        )
    end
  end

  # compares values after checking that they are  structs from the same
  # module with a comapre funcion.  Errors are raised if not b/c we 
  # have no reasonable way to recover.
  defp validate_before_comaparison(cs, first_date, second_date) do
    first_date_value = cs.changes[first_date]
    second_date_value = cs.changes[second_date]

    case {first_date_value, second_date_value} do
      {%{__struct__: m} = f, %{__struct__: m} = s} ->
        if function_exported?(m, :compare, 2) do
          m.compare(f, s)
        else
          raise ArgumentError,
                "first_date and second_date module does not have a compare/2 function"
        end

      {nil, nil} ->
        :pass

      {_, _} ->
        raise ArgumentError,
              "invalid first_date and/or second_date values both must be structs from the same module"
    end
  end
end
