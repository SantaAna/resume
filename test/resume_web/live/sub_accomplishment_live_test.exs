defmodule ResumeWeb.SubAccomplishmentLiveTest do
  use ResumeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resume.SubAccomplishmentsFixtures

  @create_attrs %{name: "some name", description: "some description"}
  @update_attrs %{name: "some updated name", description: "some updated description"}
  @invalid_attrs %{name: nil, description: nil}

  setup :register_and_log_in_user

  defp create_sub_accomplishment(%{scope: scope}) do
    sub_accomplishment = sub_accomplishment_fixture(scope)

    %{sub_accomplishment: sub_accomplishment}
  end

  describe "Index" do
    setup [:create_sub_accomplishment]

    test "lists all subaccomplishments", %{conn: conn, sub_accomplishment: sub_accomplishment} do
      {:ok, _index_live, html} = live(conn, ~p"/subaccomplishments")

      assert html =~ "Listing Subaccomplishments"
      assert html =~ sub_accomplishment.name
    end

    test "saves new sub_accomplishment", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/subaccomplishments")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Sub accomplishment")
               |> render_click()
               |> follow_redirect(conn, ~p"/subaccomplishments/new")

      assert render(form_live) =~ "New Sub accomplishment"

      assert form_live
             |> form("#sub_accomplishment-form", sub_accomplishment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#sub_accomplishment-form", sub_accomplishment: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/subaccomplishments")

      html = render(index_live)
      assert html =~ "Sub accomplishment created successfully"
      assert html =~ "some name"
    end

    test "updates sub_accomplishment in listing", %{conn: conn, sub_accomplishment: sub_accomplishment} do
      {:ok, index_live, _html} = live(conn, ~p"/subaccomplishments")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#subaccomplishments-#{sub_accomplishment.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/subaccomplishments/#{sub_accomplishment}/edit")

      assert render(form_live) =~ "Edit Sub accomplishment"

      assert form_live
             |> form("#sub_accomplishment-form", sub_accomplishment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#sub_accomplishment-form", sub_accomplishment: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/subaccomplishments")

      html = render(index_live)
      assert html =~ "Sub accomplishment updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes sub_accomplishment in listing", %{conn: conn, sub_accomplishment: sub_accomplishment} do
      {:ok, index_live, _html} = live(conn, ~p"/subaccomplishments")

      assert index_live |> element("#subaccomplishments-#{sub_accomplishment.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#subaccomplishments-#{sub_accomplishment.id}")
    end
  end

  describe "Show" do
    setup [:create_sub_accomplishment]

    test "displays sub_accomplishment", %{conn: conn, sub_accomplishment: sub_accomplishment} do
      {:ok, _show_live, html} = live(conn, ~p"/subaccomplishments/#{sub_accomplishment}")

      assert html =~ "Show Sub accomplishment"
      assert html =~ sub_accomplishment.name
    end

    test "updates sub_accomplishment and returns to show", %{conn: conn, sub_accomplishment: sub_accomplishment} do
      {:ok, show_live, _html} = live(conn, ~p"/subaccomplishments/#{sub_accomplishment}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/subaccomplishments/#{sub_accomplishment}/edit?return_to=show")

      assert render(form_live) =~ "Edit Sub accomplishment"

      assert form_live
             |> form("#sub_accomplishment-form", sub_accomplishment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#sub_accomplishment-form", sub_accomplishment: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/subaccomplishments/#{sub_accomplishment}")

      html = render(show_live)
      assert html =~ "Sub accomplishment updated successfully"
      assert html =~ "some updated name"
    end
  end
end
