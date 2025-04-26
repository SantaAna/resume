defmodule ResumeWeb.ThrottleLogin do
  use PlugAttack

  # Will block access to login page for 30 minutes after five attempts.
  rule "throttle login request", conn do
    if conn.method == "POST" and conn.path_info == ["users", "log-in"] do
      throttle(conn.remote_ip,
        period: 60_000 * 30,
        limit: 5,
        storage: {PlugAttack.Storage.Ets, Resume.PlugAttack.Storage}
      )
    end
  end
end
