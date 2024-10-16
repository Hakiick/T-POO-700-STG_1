defmodule TimeManager.Notifications.SmsSender do
  def send_sms(to, message) do
    account_sid = "AC1bd23bd5d7020d33751e2e0d577dea2d"
    auth_token = "0e3c6a9817da7030da98ccde9192322a"
    from = "+33785590067" # Doit être un numéro de téléphone Twilio valide

    basic_auth = Base.encode64("#{account_sid}:#{auth_token}")

    body = URI.encode_www_form([
      From: from,
      To: to,
      Body: message
    ])

    headers = [
      {"Authorization", "Basic #{basic_auth}"},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    url = "https://api.twilio.com/2010-04-01/Accounts/#{account_sid}/Messages.json"

    HTTPoison.post(url, body, headers)
  end
end
