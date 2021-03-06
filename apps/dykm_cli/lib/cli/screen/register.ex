defmodule CLI.Register do
  @behaviour CLI.Screen
  @moduledoc """
  The login screen is the first screen that users see. They need to log in
  and authenticate in order to gain access to the game.
  """

  @doc """
  Registers user, proceeds with main menu.
  """
  @impl CLI.Screen
  def run() do
    CLI.Util.loop_until_correct_input(&prompt_and_read_input/0)
    {:succ, []}
  end

  defp prompt_and_read_input() do
    username = CLI.Util.read_input("Please enter your name: ")
    password = CLI.Util.read_password("Please enter your password: ")

    case Client.Worker.register(username, password) do
      :ok ->
        {:ok, "You successfully registered! Let's play!"}

      {:err, reason} ->
        {:err, "Registration failed: #{reason}"}
    end
  end
end
