defmodule TimeManagerWeb.UserControllerTest do
  use TimeManagerWeb.ConnCase

  import TimeManager.AccountsFixtures

  alias TimeManager.Accounts.User

  @create_attrs %{
    username: "some username",
    email: "some@mail.com"
  }
  @update_attrs %{
    username: "some updated username",
    email: "someupdated@mail.com"
  }
  @invalid_attrs %{username: nil, email: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "show" do
    test "get a users from mail and user name", %{conn: conn} do
      conn = get(conn, ~p"/api/users?email=Karl_le_pd@pd.com&username=Karl_le_pd")

      assert json_response(conn, 200)["data"] == %{
               "email" => "Karl_le_pd@pd.com",
               "id" => 1,
               "username" => "Karl_le_pd"
             }
    end

    test "get a users", %{conn: conn} do
      conn = get(conn, ~p"/api/users/1")

      assert json_response(conn, 200)["data"] == %{
               "email" => "Karl_le_pd@pd.com",
               "id" => 1,
               "username" => "Karl_le_pd"
             }
    end

    test "get a 404", %{conn: conn} do
      conn = get(conn, ~p"/api/users/999")
      assert json_response(conn, 404) == %{"error" => "User not found"}
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "id" => ^id,
               "email" => "some@mail.com",
               "username" => "some username"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "id" => ^id,
               "email" => "someupdated@mail.com",
               "username" => "some updated username"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, ~p"/api/users/#{user}")
      assert response(conn, 204)

      conn = get(conn, ~p"/api/users/#{user}")
      assert response(conn, 404)
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
