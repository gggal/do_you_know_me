defmodule CLI.Login do
  @behaviour CLI.Screen
  @moduledoc """
  The login screen is the first screen that users see. They need to log in
  mask authenticate in order to gain access to the game.
  """

  @doc """
  Log user in, proceeds with main menu.
  """
  @impl CLI.Screen
  def run() do
    CLI.Util.loop_until_correct_input(&prompt_and_read_input/0)
    {:succ, []}
  end

  defp prompt_and_read_input() do
    username = CLI.Util.read_input("Please enter your name: ")
    password = CLI.Util.read_password("Please enter your password: ")

    case Client.Worker.login(username, password) do
      :ok ->
        {:ok, "You successfully logged in! Let's play!"}

      {:err, reason} ->
        {:err, "Login failed: #{reason}"}
    end
  end
end
