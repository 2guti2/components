defmodule ComponentsWeb.TodoComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  alias Components.Todos

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
      <div draggable="true" id="<%= @todo.id %>" class="item draggable p-4">
        <div>
          <div class="d-inline">
            <i class="bi bi-grip-horizontal"></i>
          </div>
          <input
            type="checkbox"
            phx-value-id="<%= @todo.id %>"
            phx-target="<%= @myself %>"
            phx-click="toggle_done"
            <%= if @todo.done do "checked" end %>
          >
          <span class="<%= if @todo.done do "strike" end %>">
            <%= @todo.title %>
          </span>
        </div>
        <div>
          <button
            class="btn action"
            phx-click="delete"
            phx-target="<%= @myself %>"
            phx-value-id="<%= @todo.id %>"
          >
            <i class="bi bi-trash"></i>
          </button>
        </div>
      </div>
    """
  end

  def handle_event("toggle_done", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    Todos.update_todo(todo, %{done: !todo.done})
    send self(), :update

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    Todos.get_todo!(id)
    |> Todos.delete_todo()
    send self(), :update

    {:noreply, socket}
  end
end
