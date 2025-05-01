defmodule Resume.SkillsTest do
  use Resume.DataCase

  alias Resume.Skills

  describe "skills" do
    alias Resume.Skills.Skill

    import Resume.AccountsFixtures, only: [user_scope_fixture: 0]
    import Resume.SkillsFixtures

    @invalid_attrs %{name: nil, description: nil, embedding_content: nil}

    test "list_skills/1 returns all scoped skills" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      skill = skill_fixture(scope)
      other_skill = skill_fixture(other_scope)
      assert Skills.list_skills(scope) == [skill]
      assert Skills.list_skills(other_scope) == [other_skill]
    end

    test "get_skill!/2 returns the skill with given id" do
      scope = user_scope_fixture()
      skill = skill_fixture(scope)
      other_scope = user_scope_fixture()
      assert Skills.get_skill!(scope, skill.id) == skill
      assert_raise Ecto.NoResultsError, fn -> Skills.get_skill!(other_scope, skill.id) end
    end

    test "create_skill/2 with valid data creates a skill" do
      valid_attrs = %{name: "some name", description: "some description", embedding_content: "some embedding_content"}
      scope = user_scope_fixture()

      assert {:ok, %Skill{} = skill} = Skills.create_skill(scope, valid_attrs)
      assert skill.name == "some name"
      assert skill.description == "some description"
      assert skill.embedding_content == "some embedding_content"
      assert skill.user_id == scope.user.id
    end

    test "create_skill/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Skills.create_skill(scope, @invalid_attrs)
    end

    test "update_skill/3 with valid data updates the skill" do
      scope = user_scope_fixture()
      skill = skill_fixture(scope)
      update_attrs = %{name: "some updated name", description: "some updated description", embedding_content: "some updated embedding_content"}

      assert {:ok, %Skill{} = skill} = Skills.update_skill(scope, skill, update_attrs)
      assert skill.name == "some updated name"
      assert skill.description == "some updated description"
      assert skill.embedding_content == "some updated embedding_content"
    end

    test "update_skill/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      skill = skill_fixture(scope)

      assert_raise MatchError, fn ->
        Skills.update_skill(other_scope, skill, %{})
      end
    end

    test "update_skill/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      skill = skill_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Skills.update_skill(scope, skill, @invalid_attrs)
      assert skill == Skills.get_skill!(scope, skill.id)
    end

    test "delete_skill/2 deletes the skill" do
      scope = user_scope_fixture()
      skill = skill_fixture(scope)
      assert {:ok, %Skill{}} = Skills.delete_skill(scope, skill)
      assert_raise Ecto.NoResultsError, fn -> Skills.get_skill!(scope, skill.id) end
    end

    test "delete_skill/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      skill = skill_fixture(scope)
      assert_raise MatchError, fn -> Skills.delete_skill(other_scope, skill) end
    end

    test "change_skill/2 returns a skill changeset" do
      scope = user_scope_fixture()
      skill = skill_fixture(scope)
      assert %Ecto.Changeset{} = Skills.change_skill(scope, skill)
    end
  end
end
