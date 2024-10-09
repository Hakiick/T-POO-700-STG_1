defmodule EmailValidator do
  @w3c_email_regex ~r/^[\w.!#$%&’*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i

  def valid_email?(email) do
    Regex.match?(@w3c_email_regex, email)
  end
end
