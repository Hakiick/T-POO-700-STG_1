defmodule TimeManagerWeb.ManageControllerTest do
  use TimeManagerWeb.ConnCase

  import TimeManager.AccountsFixtures

  alias TimeManager.Accounts.Manage

  @create_attrs %{

  }
  @update_attrs %{

  }
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all manage", %{conn: conn} do
      conn = get(conn, ~p"/api/manage")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create manage" do
    test "renders manage when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/manage", manage: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/manage/#{id}")

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/manage", manage: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update manage" do
    setup [:create_manage]

    test "renders manage when data is valid", %{conn: conn, manage: %Manage{id: id} = manage} do
      conn = put(conn, ~p"/api/manage/#{manage}", manage: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/manage/#{id}")

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, manage: manage} do
      conn = put(conn, ~p"/api/manage/#{manage}", manage: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete manage" do
    setup [:create_manage]

    test "deletes chosen manage", %{conn: conn, manage: manage} do
      conn = delete(conn, ~p"/api/manage/#{manage}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/manage/#{manage}")
      end
    end
  end

  defp create_manage(_) do
    manage = manage_fixture()
    %{manage: manage}
  end
end
