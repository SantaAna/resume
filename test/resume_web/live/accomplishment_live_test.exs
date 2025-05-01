defmodule ResumeWeb.AccomplishmentLiveTest do
  use ResumeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resume.AccomplishmentsFixtures

  @create_attrs %{name: "some name", description: "some description"}
  @update_attrs %{name: "some updated name", description: "some updated description"}
  @invalid_attrs %{name: nil, description: nil}

  setup :register_and_log_in_user

  defp create_accomplishment(%{scope: scope}) do
    accomplishment = accomplishment_fixture(scope)

    %{accomplishment: accomplishment}
  end

  describe "Index" do
    setup [:create_accomplishment]

    test "lists all accomplishments", %{conn: conn, accomplishment: accomplishment} do
      {:ok, _index_live, html} = live(conn, ~p"/accomplishments")

      assert html =~ "Listing Accomplishments"
      assert html =~ accomplishment.name
    end

    test "saves new accomplishment", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/accomplishments")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Accomplishment")
               |> render_click()
               |> follow_redirect(conn, ~p"/accomplishments/new")

      assert render(form_live) =~ "New Accomplishment"

      assert form_live
             |> form("#accomplishment-form", accomplishment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#accomplishment-form", accomplishment: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/accomplishments")

      html = render(index_live)
      assert html =~ "Accomplishment created successfully"
      assert html =~ "some name"
    end

    test "updates accomplishment in listing", %{conn: conn, accomplishment: accomplishment} do
      {:ok, index_live, _html} = live(conn, ~p"/accomplishments")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#accomplishments-#{accomplishment.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/accomplishments/#{accomplishment}/edit")

      assert render(form_live) =~ "Edit Accomplishment"

      assert form_live
             |> form("#accomplishment-form", accomplishment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#accomplishment-form", accomplishment: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/accomplishments")

      html = render(index_live)
      assert html =~ "Accomplishment updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes accomplishment in listing", %{conn: conn, accomplishment: accomplishment} do
      {:ok, index_live, _html} = live(conn, ~p"/accomplishments")

      assert index_live |> element("#accomplishments-#{accomplishment.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#accomplishments-#{accomplishment.id}")
    end
  end

  describe "Show" do
    setup [:create_accomplishment]

    test "displays accomplishment", %{conn: conn, accomplishment: accomplishment} do
      {:ok, _show_live, html} = live(conn, ~p"/accomplishments/#{accomplishment}")

      assert html =~ "Show Accomplishment"
      assert html =~ accomplishment.name
    end

    test "updates accomplishment and returns to show", %{conn: conn, accomplishment: accomplishment} do
      {:ok, show_live, _html} = live(conn, ~p"/accomplishments/#{accomplishment}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/accomplishments/#{accomplishment}/edit?return_to=show")

      assert render(form_live) =~ "Edit Accomplishment"

      assert form_live
             |> form("#accomplishment-form", accomplishment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#accomplishment-form", accomplishment: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/accomplishments/#{accomplishment}")

      html = render(show_live)
      assert html =~ "Accomplishment updated successfully"
      assert html =~ "some updated name"
    end
  end
end
