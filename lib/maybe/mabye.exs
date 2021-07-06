defmodule Maybe do
  @moduledoc """
  The Maybe module provides functions to make piping easier with ok/error tuples or atoms.

  For example, instead of writing:

      def update_comment(comment, attrs) do
        comment
        |> Comment.changeset(attrs)
        |> Repo.update()
        |> case do
          {:ok, updated_comment} ->
            _ = broadcast_update(updated_comment)
            {:ok, updated_comment}

          {:error, changeset} ->
            {:error, changeset}
        end
        |> case do
          {:ok, updated_comment} ->
            {:ok, Repo.preload(updated_comment, :post)}

          {:error, changeset} ->
            {:error, changeset}
        end
      end

      defp broadcast_update(_updated_comment), do: :anything

  It is possible to do the same with:

      def update_comment(comment, attrs) do
        comment
        |> Comment.changeset(attrs)
        |> Repo.update()
        |> maybe_tap(&broadcast_update/1)
        |> maybe(&{:ok, Repo.preload(&1, :post)})
      end

      defp broadcast_update(_updated_comment), do: :anything

  """

  @doc """
  Calls the given function when passed `:ok` or `{:ok, value}`.

  A given_result value of:
  * `:ok` - calls fun without arguments
  * `{:ok, term}` - calls fun with one argument of `term`
  * `:error` - returns `:error` without calling the function
  * `{:error, term}` returns `{:error, term}` without calling the function
  """
  def maybe(given_result, fun)
  def maybe(:ok, fun) when is_function(fun, 0), do: fun.()
  def maybe({:ok, term}, fun) when is_function(fun, 1), do: fun.(term)
  def maybe(:error, fun) when is_function(fun, 0), do: :error
  def maybe(:error, fun) when is_function(fun, 1), do: :error
  def maybe({:error, _term} = given_result, fun) when is_function(fun, 0), do: given_result
  def maybe({:error, _term} = given_result, fun) when is_function(fun, 1), do: given_result

  @doc """
  Calls maybe/2 and ignores the return. Always returns given_result instead.

  Useful for conditionally running synchronous side effects in a pipeline.
  """
  def maybe_tap(given_result, fun) do
    _ = maybe(given_result, fun)
    given_result
  end
end
