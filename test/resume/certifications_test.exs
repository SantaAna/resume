defmodule Resume.CertificationsTest do
  use Resume.DataCase

  alias Resume.Certifications

  describe "certifications" do
    alias Resume.Certifications.Certification

    import Resume.AccountsFixtures, only: [user_scope_fixture: 0]
    import Resume.CertificationsFixtures

    @invalid_attrs %{name: nil, description: nil, embedding_content: nil, last_embedded: nil}

    test "list_certifications/1 returns all scoped certifications" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      certification = certification_fixture(scope)
      other_certification = certification_fixture(other_scope)
      assert Certifications.list_certifications(scope) == [certification]
      assert Certifications.list_certifications(other_scope) == [other_certification]
    end

    test "get_certification!/2 returns the certification with given id" do
      scope = user_scope_fixture()
      certification = certification_fixture(scope)
      other_scope = user_scope_fixture()
      assert Certifications.get_certification!(scope, certification.id) == certification
      assert_raise Ecto.NoResultsError, fn -> Certifications.get_certification!(other_scope, certification.id) end
    end

    test "create_certification/2 with valid data creates a certification" do
      valid_attrs = %{name: "some name", description: "some description", embedding_content: "some embedding_content", last_embedded: ~N[2025-04-30 18:19:00]}
      scope = user_scope_fixture()

      assert {:ok, %Certification{} = certification} = Certifications.create_certification(scope, valid_attrs)
      assert certification.name == "some name"
      assert certification.description == "some description"
      assert certification.embedding_content == "some embedding_content"
      assert certification.last_embedded == ~N[2025-04-30 18:19:00]
      assert certification.user_id == scope.user.id
    end

    test "create_certification/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Certifications.create_certification(scope, @invalid_attrs)
    end

    test "update_certification/3 with valid data updates the certification" do
      scope = user_scope_fixture()
      certification = certification_fixture(scope)
      update_attrs = %{name: "some updated name", description: "some updated description", embedding_content: "some updated embedding_content", last_embedded: ~N[2025-05-01 18:19:00]}

      assert {:ok, %Certification{} = certification} = Certifications.update_certification(scope, certification, update_attrs)
      assert certification.name == "some updated name"
      assert certification.description == "some updated description"
      assert certification.embedding_content == "some updated embedding_content"
      assert certification.last_embedded == ~N[2025-05-01 18:19:00]
    end

    test "update_certification/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      certification = certification_fixture(scope)

      assert_raise MatchError, fn ->
        Certifications.update_certification(other_scope, certification, %{})
      end
    end

    test "update_certification/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      certification = certification_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Certifications.update_certification(scope, certification, @invalid_attrs)
      assert certification == Certifications.get_certification!(scope, certification.id)
    end

    test "delete_certification/2 deletes the certification" do
      scope = user_scope_fixture()
      certification = certification_fixture(scope)
      assert {:ok, %Certification{}} = Certifications.delete_certification(scope, certification)
      assert_raise Ecto.NoResultsError, fn -> Certifications.get_certification!(scope, certification.id) end
    end

    test "delete_certification/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      certification = certification_fixture(scope)
      assert_raise MatchError, fn -> Certifications.delete_certification(other_scope, certification) end
    end

    test "change_certification/2 returns a certification changeset" do
      scope = user_scope_fixture()
      certification = certification_fixture(scope)
      assert %Ecto.Changeset{} = Certifications.change_certification(scope, certification)
    end
  end
end
