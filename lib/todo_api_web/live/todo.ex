defmodule TodoApiWeb.Todo do
  use TodoApiWeb, :live_view
  require Logger
  require Phoenix.Component
  alias TodoApi.Users
  alias TodoApi.Todoing

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_todo()
     |> assign_todo_list()
     |> assign_changeset()
     |> assign_changeset_edit()
     |> assign_show_create()}
  end

  def assign_todo_list(socket) do
    {:ok, response} = Todoing.list_todos()
    socket
    |> assign(:todos, response.body["data"])
  end

  def assign_todo(socket) do
    socket
    |> assign(:todo, %Users.Todo{})
  end

  def assign_show_create(socket) do
    socket
    |> assign(:showCreate, false)
  end

  def assign_changeset(socket) do
    assign(socket, %{changeset: Users.change_todo(%Users.Todo{})})
  end

  def assign_changeset_edit(socket) do
    assign(socket, %{changeset_edit: Users.change_todo(%Users.Todo{})})
  end

  def handle_event("delete", params, socket) do
    del_todo = params["todo"]
    Logger.info(del_todo)
    # Users.delete_todo(del_todo)
    Todoing.delete_todo(del_todo)
    {:ok, response} = Todoing.list_todos()
    {:noreply, assign(socket, :todos, response.body["data"])}
  end

  def handle_event("validate", %{"todo" => params}, socket) do
    changeset =
      %Users.Todo{}
      |> Users.change_todo(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("validate_edit", %{"todo" => params}, socket) do
    changeset =
      %Users.Todo{}
      |> Users.change_todo(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset_edit: changeset)}
  end

  def handle_event("edit", %{"todo" => todo_params}, socket) do
    # {:ok, response} = Todoing.get_todo(todo_params["id"])
    # update_todo = response.body
    # IO.inspect(update_todo)
    Todoing.update_todo(todo_params)
    # Ecto.Changeset.change(socket.assigns.changeset_edit, id: 0)
    # assign(socket, %{changeset_edit: Users.change_todo(%Users.Todo{})})
    # Logger.info(socket.assigns.changeset_edit)
    {:ok, response} = Todoing.list_todos()
    {:noreply,
     assign(socket, todos: response.body["data"], changeset_edit: Users.change_todo(%Users.Todo{}))}
  end

  def handle_event("move", todo_params, socket) do
    Logger.debug(todo_params)

    Todoing.change_todo_order(
      String.to_integer(todo_params["todo-id"], 10),
      String.to_integer(todo_params["move-to"], 10)
    )
    {:ok, response} = Todoing.list_todos()

    {:noreply, assign(socket, :todos,response.body["data"] )}
  end

  def handle_event("save", %{"todo" => todo_params}, socket) do
    Todoing.create_todo(todo_params)
         
    {:ok, response} = Todoing.list_todos()
    {:noreply, assign(socket, :todos, response.body["data"])}
  end

  def handle_event("toggle_create", _params, socket) do
    Logger.info("CREATE TOGGLED!")
    {:noreply, assign(socket, :showCreate, !socket.assigns.showCreate)}
  end

  def handle_event("start_edit", todo_params, socket) do
    # Logger.info(todo_params["todo"])
    {:ok, response} = Todoing.get_todo(todo_params["todo"])
    todo_body = response.body["data"]
    # IO.inspect(todo_body)
    {:ok, todo} = %Users.Todo{}
    |> Users.Todo.changeset(todo_body)
    |> Ecto.Changeset.apply_action(:insert)
    # IO.inspect( todo)
    # Logger.info(todo)
    # IO.inspect(socket.assigns.changeset_edit)
    {:noreply, assign(socket, %{changeset_edit: Users.change_todo(todo)})}
  end

  def handle_event("cancel_edit", _todo_params, socket) do
    {:noreply, assign(socket, %{changeset_edit: Users.change_todo(%Users.Todo{})})}
  end

  def handle_event("dropped", %{"draggedId" => dragged_id, "dropzoneId" => drop_zone_id,"draggableIndex" => draggable_index}, %{assigns: _assigns} = socket) do
    Logger.warn(dragged_id)

    Logger.warn(drop_zone_id)

    Logger.warn(draggable_index)
    {:noreply, socket}
  end

end
