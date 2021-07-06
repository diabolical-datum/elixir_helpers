defmodule MyAppWeb.Plugs.RouterCall do
  @moduledoc """
  To use, replace the default `plug(MyAppWeb.Router)` with `MyAppWeb.Plugs.RouterCall`.

  Matching on conn attributes and calling the Router directly is favored over Plug.Router.forward/2
  or Phoneix.Router.forward/2 because they remove the leading path segments when forwarding.
  Without the leading path segments the forward functions can be heavy to implement in an existing
  project because of path helpers and other generators based on request path.
  """

  def init(opts), do: opts

  def call(conn, opts) do
    router = get_router(conn.method, conn.path_info)
    router.call(conn, opts)
  end

  defp get_router(_method, ["admin" | _]), do: AdminWeb.Router
  defp get_router(_method, ["api", "v1" | _]), do: ApiV1Web.Router
  defp get_router(_method, ["api", "v2" | _]), do: ApiV2Web.Router
  defp get_router(_method, _path_info), do: LegacyWeb.Router
end
