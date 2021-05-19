defmodule Components.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :done, :boolean, default: false
    field :title, :string
    field :index, :integer

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :done])
    |> validate_required([:title, :done])
  end

  def changeset(todo, :index, attrs) do
    todo
    |> cast(attrs, [:index])
    |> validate_required([:index])
  end
end
