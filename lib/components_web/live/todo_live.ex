defmodule ComponentsWeb.TodoLive do
  use ComponentsWeb, :live_view
  alias Components.Todos

  def mount(_params, _session, socket) do
    Todos.subscribe()

    {:ok, fetch(socket)}
  end

  def render(assigns) do
    ~L"""
      <%= live_component @socket, ComponentsWeb.AddTodoComponent, id: "add_todo_component" %>

      <div phx-hook="Drag" id="drag">
        <div class="dropzone grid gap-3" id="pool">
          <%= for todo <- @todos do %>
            <%= live_component @socket, ComponentsWeb.TodoComponent, todo: todo, id: todo.id %>
          <% end %>
        </div>
      </div>
    """
  end

  def handle_event("dropped", %{"id" => id, "index" => index}, socket) do
    Todos.update_index(id, index)
    {:noreply, socket}
  end

  def handle_info(:update, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    socket |> assign(todos: Todos.list_todos())
  end
end
