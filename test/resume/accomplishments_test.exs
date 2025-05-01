defmodule Resume.AccomplishmentsTest do
  use Resume.DataCase

  alias Resume.Accomplishments

  describe "accomplishments" do
    alias Resume.Accomplishments.Accomplishment

    import Resume.AccountsFixtures, only: [user_scope_fixture: 0]
    import Resume.AccomplishmentsFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_accomplishments/1 returns all scoped accomplishments" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      accomplishment = accomplishment_fixture(scope)
      other_accomplishment = accomplishment_fixture(other_scope)
      assert Accomplishments.list_accomplishments(scope) == [accomplishment]
      assert Accomplishments.list_accomplishments(other_scope) == [other_accomplishment]
    end

    test "get_accomplishment!/2 returns the accomplishment with given id" do
      scope = user_scope_fixture()
      accomplishment = accomplishment_fixture(scope)
      other_scope = user_scope_fixture()
      assert Accomplishments.get_accomplishment!(scope, accomplishment.id) == accomplishment
      assert_raise Ecto.NoResultsError, fn -> Accomplishments.get_accomplishment!(other_scope, accomplishment.id) end
    end

    test "create_accomplishment/2 with valid data creates a accomplishment" do
      valid_attrs = %{name: "some name", description: "some description"}
      scope = user_scope_fixture()

      assert {:ok, %Accomplishment{} = accomplishment} = Accomplishments.create_accomplishment(scope, valid_attrs)
      assert accomplishment.name == "some name"
      assert accomplishment.description == "some description"
      assert accomplishment.user_id == scope.user.id
    end

    test "create_accomplishment/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Accomplishments.create_accomplishment(scope, @invalid_attrs)
    end

    test "update_accomplishment/3 with valid data updates the accomplishment" do
      scope = user_scope_fixture()
      accomplishment = accomplishment_fixture(scope)
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %Accomplishment{} = accomplishment} = Accomplishments.update_accomplishment(scope, accomplishment, update_attrs)
      assert accomplishment.name == "some updated name"
      assert accomplishment.description == "some updated description"
    end

    test "update_accomplishment/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      accomplishment = accomplishment_fixture(scope)

      assert_raise MatchError, fn ->
        Accomplishments.update_accomplishment(other_scope, accomplishment, %{})
      end
    end

    test "update_accomplishment/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      accomplishment = accomplishment_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Accomplishments.update_accomplishment(scope, accomplishment, @invalid_attrs)
      assert accomplishment == Accomplishments.get_accomplishment!(scope, accomplishment.id)
    end

    test "delete_accomplishment/2 deletes the accomplishment" do
      scope = user_scope_fixture()
      accomplishment = accomplishment_fixture(scope)
      assert {:ok, %Accomplishment{}} = Accomplishments.delete_accomplishment(scope, accomplishment)
      assert_raise Ecto.NoResultsError, fn -> Accomplishments.get_accomplishment!(scope, accomplishment.id) end
    end

    test "delete_accomplishment/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      accomplishment = accomplishment_fixture(scope)
      assert_raise MatchError, fn -> Accomplishments.delete_accomplishment(other_scope, accomplishment) end
    end

    test "change_accomplishment/2 returns a accomplishment changeset" do
      scope = user_scope_fixture()
      accomplishment = accomplishment_fixture(scope)
      assert %Ecto.Changeset{} = Accomplishments.change_accomplishment(scope, accomplishment)
    end
  end
end
