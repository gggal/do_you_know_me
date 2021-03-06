defmodule Server.UserTest do
  use ExUnit.Case

  alias Server.{User, Game, Invitation, Score, Question}

  @username TestUtil.random_username()

  setup_all do
    assert %Server.User{username: @username, password: ""} |> DB.Repo.insert() |> elem(0) == :ok

    on_exit(fn -> %Server.User{username: @username} |> DB.Repo.delete() end)
  end

  test "check if a non-existent user exists" do
    assert false == User.exists?(TestUtil.random_username())
  end

  test "check if an existent user exists" do
    assert true == User.exists?(@username)
  end

  test "insert user with nil username" do
    assert false == User.insert(nil, "password")
  end

  test "insert user with nil password" do
    assert false == User.insert(TestUtil.random_username(), nil)
  end

  test "insert user with empty username" do
    assert false == User.insert("", "password")
  end

  test "insert user with empty password" do
    assert false == User.insert(TestUtil.random_username(), "")
  end

  test "insert user with duplicate username" do
    assert false == User.insert(@username, "password")
  end

  test "insert user with invalid format username" do
    assert false == User.insert("?", "password")
  end

  test "insert valid user" do
    to_insert = TestUtil.random_username()
    assert true == User.insert(to_insert, "password")

    on_exit(fn -> %User{username: to_insert} |> DB.Repo.delete() end)
  end

  test "check for correct password" do
    to_insert = TestUtil.random_username()
    assert true == User.insert(to_insert, "password")
    assert {:ok, true} == User.correct_password?(to_insert, "password")
    assert {:ok, false} == User.correct_password?(to_insert, "password1")

    on_exit(fn -> %User{username: to_insert} |> DB.Repo.delete() end)
  end

  test "validating password for non-existent user" do
    assert :err == User.correct_password?("no_such_user", "password")
  end

  test "password is hashed after insert" do
    to_insert = TestUtil.random_username()
    assert true == User.insert(to_insert, "password")
    %{password: hash} = DB.Repo.get(User, to_insert)
    assert hash != "password"
    on_exit(fn -> %User{username: to_insert} |> DB.Repo.delete() end)
  end

  test "delete user by non-existent username" do
    assert false == User.delete(TestUtil.random_username())
  end

  test "delete questions when deleting user" do
    sec_user = TestUtil.random_username()
    insert_user_with_metadata(sec_user)
    %{question1: q1, question2: q2} = DB.Repo.get_by(Game, %{user1: sec_user, user2: @username})

    assert true == User.delete(sec_user)
    assert nil == Question |> DB.Repo.get(q1)
    assert nil == Question |> DB.Repo.get(q2)
  end

  test "delete scores when deleting user" do
    sec_user = TestUtil.random_username()
    insert_user_with_metadata(sec_user)
    %{score1: s1, score2: s2} = DB.Repo.get_by(Game, %{user1: sec_user, user2: @username})

    assert true == User.delete(sec_user)
    assert nil == Score |> DB.Repo.get(s1)
    assert nil == Score |> DB.Repo.get(s2)
  end

  test "delete invitations when deleting user" do
    sec_user = TestUtil.random_username()
    insert_user_with_metadata(sec_user)

    assert true == User.delete(sec_user)
    assert nil == DB.Repo.get_by(Invitation, %{from: @username, to: sec_user})
  end

  test "delete games when deleting user" do
    sec_user = TestUtil.random_username()
    insert_user_with_metadata(sec_user)

    assert true == User.delete(sec_user)
    assert nil == DB.Repo.get_by(Game, %{user1: sec_user, user2: @username})
  end

  test "delete user successfully" do
    sec_user = TestUtil.random_username()
    insert_user_with_metadata(sec_user)

    assert true == User.delete(sec_user)
    assert nil == User |> DB.Repo.get(sec_user)
  end

  test "get all users" do
    assert is_list(User.all())
  end

  defp insert_user_with_metadata(sec_user) do
    {:ok, %{id: q1_id}} = %Question{} |> DB.Repo.insert()
    {:ok, %{id: q2_id}} = %Question{} |> DB.Repo.insert()
    {:ok, %{id: s1_id}} = %Score{} |> DB.Repo.insert()
    {:ok, %{id: s2_id}} = %Score{} |> DB.Repo.insert()

    assert %User{username: sec_user, password: ""} |> DB.Repo.insert() |> elem(0) == :ok
    assert %Invitation{from: @username, to: sec_user} |> DB.Repo.insert() |> elem(0) == :ok

    assert %Game{
             user1: sec_user,
             user2: @username,
             question1: q1_id,
             question2: q2_id,
             score1: s1_id,
             score2: s2_id,
             turn: false
           }
           |> DB.Repo.insert()
           |> elem(0) == :ok
  end
end
