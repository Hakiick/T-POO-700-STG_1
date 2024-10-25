defmodule TimeManager.Guardian do
  use Guardian, otp_app: :time_manager

  alias TimeManager.Accounts

  # Encode user information into JWT claims
  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  # Decode JWT claims back into a user
  def resource_from_claims(claims) do
    id = claims["sub"]

    case Accounts.get_user!(%{"id" => id}) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end
