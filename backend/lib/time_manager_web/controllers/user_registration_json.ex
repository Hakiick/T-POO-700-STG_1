defmodule TimeManagerWeb.UserRegistrationJSON do
  alias Ecto.Changeset

  # Function to render the result after user registration
  def show(%{user: user}) do
    %{
      message: "User created successfully",
      data: %{
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        inserted_at: user.inserted_at
      }
    }
  end

  # Function to render changeset errors
  def show(%{changeset: %Changeset{} = changeset}) do
    %{
      message: "User registration failed",
      errors: Changeset.traverse_errors(changeset, &translate_error/1)
    }
  end

  # Helper function to translate error messages
  defp translate_error({msg, opts}) do
    # Translate or format error messages here if needed
    # For simplicity, just returning the message
    msg
  end
end
