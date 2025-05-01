defmodule Resume.EducationsTest do
  use Resume.DataCase

  alias Resume.Educations

  describe "educations" do
    alias Resume.Educations.Education

    import Resume.AccountsFixtures, only: [user_scope_fixture: 0]
    import Resume.EducationsFixtures

    @invalid_attrs %{institution: nil, institution_type: nil, diploma_earned: nil, embedding_content: nil, last_embedded: nil}

    test "list_educations/1 returns all scoped educations" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      education = education_fixture(scope)
      other_education = education_fixture(other_scope)
      assert Educations.list_educations(scope) == [education]
      assert Educations.list_educations(other_scope) == [other_education]
    end

    test "get_education!/2 returns the education with given id" do
      scope = user_scope_fixture()
      education = education_fixture(scope)
      other_scope = user_scope_fixture()
      assert Educations.get_education!(scope, education.id) == education
      assert_raise Ecto.NoResultsError, fn -> Educations.get_education!(other_scope, education.id) end
    end

    test "create_education/2 with valid data creates a education" do
      valid_attrs = %{institution: "some institution", institution_type: "some institution_type", diploma_earned: "some diploma_earned", embedding_content: "some embedding_content", last_embedded: ~N[2025-04-30 18:22:00]}
      scope = user_scope_fixture()

      assert {:ok, %Education{} = education} = Educations.create_education(scope, valid_attrs)
      assert education.institution == "some institution"
      assert education.institution_type == "some institution_type"
      assert education.diploma_earned == "some diploma_earned"
      assert education.embedding_content == "some embedding_content"
      assert education.last_embedded == ~N[2025-04-30 18:22:00]
      assert education.user_id == scope.user.id
    end

    test "create_education/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Educations.create_education(scope, @invalid_attrs)
    end

    test "update_education/3 with valid data updates the education" do
      scope = user_scope_fixture()
      education = education_fixture(scope)
      update_attrs = %{institution: "some updated institution", institution_type: "some updated institution_type", diploma_earned: "some updated diploma_earned", embedding_content: "some updated embedding_content", last_embedded: ~N[2025-05-01 18:22:00]}

      assert {:ok, %Education{} = education} = Educations.update_education(scope, education, update_attrs)
      assert education.institution == "some updated institution"
      assert education.institution_type == "some updated institution_type"
      assert education.diploma_earned == "some updated diploma_earned"
      assert education.embedding_content == "some updated embedding_content"
      assert education.last_embedded == ~N[2025-05-01 18:22:00]
    end

    test "update_education/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      education = education_fixture(scope)

      assert_raise MatchError, fn ->
        Educations.update_education(other_scope, education, %{})
      end
    end

    test "update_education/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      education = education_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Educations.update_education(scope, education, @invalid_attrs)
      assert education == Educations.get_education!(scope, education.id)
    end

    test "delete_education/2 deletes the education" do
      scope = user_scope_fixture()
      education = education_fixture(scope)
      assert {:ok, %Education{}} = Educations.delete_education(scope, education)
      assert_raise Ecto.NoResultsError, fn -> Educations.get_education!(scope, education.id) end
    end

    test "delete_education/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      education = education_fixture(scope)
      assert_raise MatchError, fn -> Educations.delete_education(other_scope, education) end
    end

    test "change_education/2 returns a education changeset" do
      scope = user_scope_fixture()
      education = education_fixture(scope)
      assert %Ecto.Changeset{} = Educations.change_education(scope, education)
    end
  end
end
