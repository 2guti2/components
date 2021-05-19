defmodule ComponentsWeb.AddTodoComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  alias Components.Todos

  def mount(socket) do
    {:ok, socket |> assign(todo_val: nil)}
  end

  def render(assigns) do
    ~L"""
      <form action="#" phx-submit="add" phx-target="<%= @myself %>">
        <%= text_input :todo, :title, placeholder: "What do you want to get done?", value: @todo_val %>
        <button phx-disable-with="Adding..." type="submit" onclick="window.clearForm(event)">Add</button>
      </form>
    """
  end

  def handle_event("add", %{"todo" => todo}, socket) do
    Todos.create_todo(todo)
    send self(), :update

    {:noreply, socket |> assign(todo_val: nil)}
  end
end
