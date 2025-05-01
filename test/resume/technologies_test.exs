defmodule Resume.TechnologiesTest do
  use Resume.DataCase

  alias Resume.Technologies

  describe "technologies" do
    alias Resume.Technologies.Technology

    import Resume.AccountsFixtures, only: [user_scope_fixture: 0]
    import Resume.TechnologiesFixtures

    @invalid_attrs %{name: nil, description: nil, embedding_content: nil}

    test "list_technologies/1 returns all scoped technologies" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      technology = technology_fixture(scope)
      other_technology = technology_fixture(other_scope)
      assert Technologies.list_technologies(scope) == [technology]
      assert Technologies.list_technologies(other_scope) == [other_technology]
    end

    test "get_technology!/2 returns the technology with given id" do
      scope = user_scope_fixture()
      technology = technology_fixture(scope)
      other_scope = user_scope_fixture()
      assert Technologies.get_technology!(scope, technology.id) == technology
      assert_raise Ecto.NoResultsError, fn -> Technologies.get_technology!(other_scope, technology.id) end
    end

    test "create_technology/2 with valid data creates a technology" do
      valid_attrs = %{name: "some name", description: "some description", embedding_content: "some embedding_content"}
      scope = user_scope_fixture()

      assert {:ok, %Technology{} = technology} = Technologies.create_technology(scope, valid_attrs)
      assert technology.name == "some name"
      assert technology.description == "some description"
      assert technology.embedding_content == "some embedding_content"
      assert technology.user_id == scope.user.id
    end

    test "create_technology/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Technologies.create_technology(scope, @invalid_attrs)
    end

    test "update_technology/3 with valid data updates the technology" do
      scope = user_scope_fixture()
      technology = technology_fixture(scope)
      update_attrs = %{name: "some updated name", description: "some updated description", embedding_content: "some updated embedding_content"}

      assert {:ok, %Technology{} = technology} = Technologies.update_technology(scope, technology, update_attrs)
      assert technology.name == "some updated name"
      assert technology.description == "some updated description"
      assert technology.embedding_content == "some updated embedding_content"
    end

    test "update_technology/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      technology = technology_fixture(scope)

      assert_raise MatchError, fn ->
        Technologies.update_technology(other_scope, technology, %{})
      end
    end

    test "update_technology/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      technology = technology_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Technologies.update_technology(scope, technology, @invalid_attrs)
      assert technology == Technologies.get_technology!(scope, technology.id)
    end

    test "delete_technology/2 deletes the technology" do
      scope = user_scope_fixture()
      technology = technology_fixture(scope)
      assert {:ok, %Technology{}} = Technologies.delete_technology(scope, technology)
      assert_raise Ecto.NoResultsError, fn -> Technologies.get_technology!(scope, technology.id) end
    end

    test "delete_technology/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      technology = technology_fixture(scope)
      assert_raise MatchError, fn -> Technologies.delete_technology(other_scope, technology) end
    end

    test "change_technology/2 returns a technology changeset" do
      scope = user_scope_fixture()
      technology = technology_fixture(scope)
      assert %Ecto.Changeset{} = Technologies.change_technology(scope, technology)
    end
  end
end
