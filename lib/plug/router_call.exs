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
    router = get_router(conn.host, conn.path_info)
    router.call(conn, opts)
  end

  defp get_router("api." <> _, _path_info), do: FooWeb.Router
  defp get_router(_host, ["api", "v1" | _]), do: BarV1Web.Router
  defp get_router(_host, ["api", "v2" | _]), do: BazV2Web.Router
  defp get_router(_host, _path_info), do: LegacyWeb.Router
end
