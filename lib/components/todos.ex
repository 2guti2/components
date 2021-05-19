defmodule Components.Todos do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias Components.Repo

  alias Components.Todos.Todo

  @topic inspect(__MODULE__)
  @pub_sub Components.PubSub

  def subscribe do
    Phoenix.PubSub.subscribe(@pub_sub, @topic)
  end

  defp broadcast_change({:ok, result}, _) do
    Phoenix.PubSub.broadcast(@pub_sub, @topic, :update)

    {:ok, result}
  end

  defp update_index_priv(%Todo{:index => index} = todo, todo_index) when index == todo_index, do: list_todos()
  defp update_index_priv(%Todo{} = todo, todo_index) do
    Repo.transaction fn ->
      todos = Todo |> where([t], t.id != ^todo.id) |> Repo.all()
      for db_todo <- todos do
        db_todo
        |> Todo.changeset(:index, %{:index => new_index(db_todo.index, todo.index, todo_index)})
        |> Repo.update()
      end

      todo
      |> Todo.changeset(:index, %{:index => todo_index})
      |> Repo.update()
    end
    broadcast_change({:ok, nil}, [:todo, :updated])
  end

  def update_index(todo_id, todo_index) do
    todo = get_todo!(todo_id)
    update_index_priv(todo, todo_index)
  end

  defp reindex_todos() do
    Repo.transaction fn ->
      todos = list_todos()
      for {todo, index} <- Enum.with_index(todos) do
        todo
        |> Todo.changeset(:index, %{:index => index})
        |> Repo.update()
      end
    end
    broadcast_change({:ok, nil}, [:todo, :updated])
  end

  defp new_index(db_index, old_todo_index, new_todo_index) do
    cond do
      old_todo_index > db_index && new_todo_index <= db_index -> db_index + 1
      old_todo_index < db_index && new_todo_index >= db_index -> db_index - 1
      true -> db_index
    end
  end

  @doc """
  Returns the list of todos.

  ## Examples

      iex> list_todos()
      [%Todo{}, ...]

  """
  def list_todos do
    Todo
    |> order_by([t], asc: t.done, asc: t.index)
    |> Repo.all()
  end

  @doc """
  Gets a single todo.

  Raises `Ecto.NoResultsError` if the Todo does not exist.

  ## Examples

      iex> get_todo!(123)
      %Todo{}

      iex> get_todo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_todo!(id), do: Repo.get!(Todo, id)

  @doc """
  Creates a todo.

  ## Examples

      iex> create_todo(%{field: value})
      {:ok, %Todo{}}

      iex> create_todo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_todo(attrs \\ %{}) do
    %Todo{}
    |> Todo.changeset(attrs)
    |> Todo.changeset(:index, %{index: calculate_todo_index()})
    |> Repo.insert()
    |> broadcast_change([:todo, :created])
  end

  defp calculate_todo_index() do
    Repo.aggregate(from(t in "todos"), :count, :id)
  end

  @doc """
  Updates a todo.

  ## Examples

      iex> update_todo(todo, %{field: new_value})
      {:ok, %Todo{}}

      iex> update_todo(todo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
    |> broadcast_change([:todo, :updated])
  end

  @doc """
  Deletes a todo.

  ## Examples

      iex> delete_todo(todo)
      {:ok, %Todo{}}

      iex> delete_todo(todo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_todo(%Todo{} = todo) do
    Repo.delete(todo)
    reindex_todos()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking todo changes.

  ## Examples

      iex> change_todo(todo)
      %Ecto.Changeset{data: %Todo{}}

  """
  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end
end
