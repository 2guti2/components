defmodule Components.Repo.Migrations.TodosAddIndex do
  use Ecto.Migration

  def change do
    alter table("todos") do
      add :index, :integer
    end
  end
end
