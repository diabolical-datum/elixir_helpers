defmodule MyRepo do
  # use Ecto.Repo, otp_app: :my_app, adapter: Ecto.Adapters.Postgres

  @doc """
  Makes conditionally preloading with piping easier.

  For example, instead of writing:

      def update_comment(comment, attrs) do
        comment
        |> Comment.changeset(attrs)
        |> Repo.update()
        |> case do
          {:ok, updated_comment} ->
            {:ok, Repo.preload(updated_comment, :post)}

          {:error, changeset} ->
            {:error, changeset}
        end
      end

  It is possible to do the same with:

      def update_comment(comment, attrs) do
        comment
        |> Comment.changeset(attrs)
        |> Repo.update()
        |> Repo.maybe_preload(:post)
      end

  A given_result value of:
  * `{:ok, structs_or_struct_or_nil}` - calls preload and returns `{:ok, data}`
  * `:error` - returns `:error` without calling preload
  * `{:error, term}` returns `{:error, term}` without calling preload
  """
  defp maybe_preload(given_result, preload_arg, opts \\ [])
  defp maybe_preload({:ok, nil}, preload_arg, opts), do: {:ok, nil}

  defp maybe_preload({:ok, structs_or_struct}, preload_arg, opts) do
    opts = Keyword.merge(default_options(:preload), opts)
    {:ok, preload(structs_or_struct, preload_arg, opts)}
  end

  defp maybe_preload({:error, _term} = given_result, _preload_arg, _opts), do: given_result
  defp maybe_preload(:error, _preload_arg, _opts), do: :error

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
