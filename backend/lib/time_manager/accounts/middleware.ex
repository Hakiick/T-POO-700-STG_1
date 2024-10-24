defmodule TimeManager.Accounts.Middleware do
  use Guardian.Plug.Pipeline,
    otp_app: :time_manager,
    error_handler: TimeManager.ErrorHandler,
    module: TimeManager.Guardian

  # If there is an authorization header, restrict it to an access token and validate it
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  # Ensure the token is valid 
  plug Guardian.Plug.EnsureAuthenticated
  # Load the user if either of the verifications worked
  plug Guardian.Plug.LoadResource
end
