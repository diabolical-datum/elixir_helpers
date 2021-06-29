defmodule MyRepo do
  # use Ecto.Repo, otp_app: :my_app, adapter: Ecto.Adapters.Postgres

  @doc """
  Compare to Ecto.Repo.Preloader.maybe_pmap/3
  https://github.com/elixir-ecto/ecto/blob/master/lib/ecto/repo/preloader.ex
  """
  def pmap(queryables_kw, opts \\ []) when is_list(queryables_kw) and is_list(opts) do
    if match?([_, _ | _], queryables_kw) and not checked_out?() do
      # We pass caller: self() so the ownership pool knows where to fetch the connection from and
      # set the proper timeouts. Note while the ownership pool uses '$callers' from pdict, it does
      # not do so in automatic mode, hence this line is still necessary.
      opts = Keyword.put_new(opts, :caller, self())

      queryables_kw
      |> Task.async_stream(fn {f, q} -> apply(__MODULE__, f, [q, opts]) end, timeout: :infinity)
      |> Enum.map(fn {:ok, data} -> data end)
    else
      Enum.map(queryables_kw, fn {f, q} -> apply(__MODULE__, f, [q, opts]) end)
    end
  end
end
