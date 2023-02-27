defmodule TodoApiWeb.Todo do
  use TodoApiWeb, :live_view
  require Logger
  require Phoenix.Component
  # alias Mix.Tasks.Iex
  alias Mix.Task
  alias TodoApi.Todo.Task
  alias TodoApi.Todo.List
  alias TodoApi.Todo.Comment
  alias TodoApi.Todo

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_todo()
     |> assign_todo_list()
     |> assign_todo_changeset()
     |> assign_list_changeset()
     |> assign_changeset_edit()
     |> assign_changeset_title()
     |> assign_show_create()
     |> assign_comment_changeset()
     |> assign_show_edit_title()
     |> assign_show_comments()}
  end

  def assign_show_comments(socket) do
    socket
    |> assign(:selectedCommentsId, 0)
    |> assign(:showSelectedComments, false)
  end

  def assign_todo_list(socket) do
    {:ok, response} = Todo.get_all_lists()

    socket
    |> assign(:lists, response.body["data"])
  end

  def assign_todo(socket) do
    socket
    |> assign(:todo, %Task{})
  end

  def assign_show_edit_title(socket) do
    socket
    |> assign(:showEditListTitle, false)
    |> assign(:selectedEditListId, 0)
  end

  def assign_show_create(socket) do
    socket
    |> assign(:showCreateTask, false)
    |> assign(:showCreateList, false)
    |> assign(:selectedCreateListId, 0)
  end

  def assign_changeset_title(socket) do
    assign(socket, %{title_changeset: List.title_changeset(%List{}, %{})})
  end

  def assign_todo_changeset(socket) do
    assign(socket, %{task_changeset: Todo.change_todo(%Task{})})
  end

  def assign_list_changeset(socket) do
    assign(socket, %{list_changeset: List.changeset(%List{}, %{})})
  end

  def assign_changeset_edit(socket) do
    assign(socket, %{changeset_edit: Todo.change_todo(%Task{})})
  end

  def assign_comment_changeset(socket) do
    assign(socket, %{comment_changeset: Comment.changeset(%Comment{}, %{})})
  end

  def handle_event("delete", params, socket) do
    del_todo = params["todo"]
    Logger.info(del_todo)
    # Users.delete_todo(del_todo)
    Todo.delete_task(del_todo)
    {:ok, response} = Todo.get_all_lists()
    {:noreply, assign(socket, :lists, response.body["data"])}
  end

  def handle_event("delete_list", params, socket) do
    del_list = params["list-id"]
    Logger.info(del_list)
    # Users.delete_todo(del_todo)
    Todo.delete_list(del_list)
    {:ok, response} = Todo.get_all_lists()
    {:noreply, assign(socket, :lists, response.body["data"])}
  end

  def handle_event("delete_comment", params, socket) do
    del_comment = params["comment-id"]
    Logger.info(del_comment)
    # Users.delete_todo(del_todo)
    Todo.delete_comment(del_comment)
    {:ok, response} = Todo.get_all_lists()
    {:noreply, assign(socket, :lists, response.body["data"])}
  end


  def handle_event("validate_list", %{"list" => params}, socket) do
    changeset =
      %List{}
      |> List.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, list_changeset: changeset)}
  end

  def handle_event("validate_task", %{"task" => params}, socket) do
    changeset =
      %Task{}
      |> Task.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, task_changeset: changeset)}
  end

  def handle_event("validate_comment", %{"comment" => params}, socket) do
    changeset =
      %Comment{}
      |> Comment.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, comment_changeset: changeset)}
  end

  def handle_event("validate_edit", %{"todo" => params}, socket) do
    changeset =
      %Task{}
      |> Todo.change_todo(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset_edit: changeset)}
  end

  def handle_event("validate_title", %{"list" => params}, socket) do
    changeset =
      %List{}
      |> List.title_changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset_edit: changeset)}
  end

  def handle_event("edit", %{"task" => todo_params}, socket) do
    # {:ok, response} = Todo.get_todo(todo_params["id"])
    # update_todo = response.body
    # IO.inspect(update_todo)
    Todo.update_task(todo_params)
    # Ecto.Changeset.change(socket.assigns.changeset_edit, id: 0)
    # assign(socket, %{changeset_edit: Todo.change_todo(%Task{})})
    # Logger.info(socket.assigns.changeset_edit)
    {:ok, response} = Todo.list_tasks()

    {:noreply,
     assign(socket, lists: response.body["data"], changeset_edit: Todo.change_todo(%Task{}))}
  end

  def handle_event("move", todo_params, socket) do
    Logger.debug(todo_params)

    Todo.change_task_order(
      String.to_integer(todo_params["todo-id"], 10),
      String.to_integer(todo_params["move-to"], 10)
    )

    {:ok, response} = Todo.list_tasks()

    {:noreply, assign(socket, :lists, response.body["data"])}
  end

  def handle_event("save_list", %{"list" => list_params}, socket) do
    Todo.create_list(list_params)
    # IO.inspect(list_params)
    {:ok, response} = Todo.get_all_lists()

    {:noreply,
     assign(socket,
       lists: response.body["data"],
       list_changeset: List.changeset(%List{}, %{}),
       showCreateList: false
     )}
  end

  def handle_event("save_comment", %{"comment" => comment_params}, socket) do
    Todo.add_comment(comment_params)
    IO.inspect(comment_params)
    {:ok, response} = Todo.get_all_lists()

    {:noreply,
     assign(socket,
       lists: response.body["data"],
       comment_changeset: Comment.changeset(%Comment{}, %{})
     )}
  end

  def handle_event("save_task", %{"task" => task_params}, socket) do
    # IO.inspect(task_params)
    # IO.inspect(socket.assigns.selectedCreateListId)

    task_params =
      Map.put(task_params, "list_id", Integer.to_string(socket.assigns.selectedCreateListId))

    Todo.create_task(task_params)
    # IO.inspect(task_params)
    {:ok, response} = Todo.get_all_lists()

    {:noreply,
     assign(socket,
       lists: response.body["data"],
       task_changeset: Todo.change_todo(%Task{}),
       showCreateTask: false
     )}
  end

  def handle_event("toggle_create_list", _params, socket) do
    Logger.info("CREATE TOGGLED!")
    {:noreply, assign(socket, :showCreateList, !socket.assigns.showCreateList)}
  end

  def handle_event("toggle_create_task", params, socket) do
    {:noreply,
     assign(socket,
       showCreateTask: !socket.assigns.showCreateTask,
       selectedCreateListId: String.to_integer(params["list_id"])
     )}
  end

  def handle_event("edit_list_title", params, socket) do
    list_id = params["list-id"]
    {:ok, response} = Todo.get_list(list_id)
    list_body = response.body["data"]

    {:noreply,
     assign(socket,
       selectedEditListId: String.to_integer(params["list-id"]),
       showEditListTitle: true,
       title_changeset: List.title_changeset(%List{}, list_body)
     )}
  end

  def handle_event("edit_list_title_cancel", _params, socket) do
    IO.inspect("HATDOG")

    {:noreply,
     assign(socket,
       showEditListTitle: false,
       title_changeset: List.title_changeset(%List{}, %{})
     )}
  end

  def handle_event("start_edit", todo_params, socket) do
    Logger.info(todo_params["todo"])
    {:ok, response} = Todo.get_task(todo_params["todo"])
    todo_body = response.body["data"]
    # IO.inspect(response)

    {:ok, todo} =
      %Task{}
      |> Task.changeset(todo_body)
      |> Ecto.Changeset.apply_action(:update)

    # IO.inspect(todo)
    # Logger.info(todo)
    # IO.inspect(Todo.change_todo(todo).data)
    {:noreply, assign(socket, changeset_edit: Todo.change_todo(todo))}
  end

  def handle_event("edit_title", %{"list" => title_params}, socket) do
    list_id = title_params["id"]
    {:ok, response} = Todo.get_list(list_id)
    list_body = response.body["data"]
    IO.inspect(list_body)
    updatedList = Map.merge(list_body, title_params)
    Todo.update_list(updatedList)

    {:ok, response} = Todo.get_all_lists()

    {:noreply,
     assign(socket,
       lists: response.body["data"],
       list_changeset: List.changeset(%List{}, %{}),
       showEditListTitle: false
     )}
  end

  def handle_event("cancel_edit", _todo_params, socket) do
    {:noreply, assign(socket, %{changeset_edit: Todo.change_todo(%Task{})})}
  end

  # @selectedCommentsId and @showSelectedComments
  def handle_event("open_comments", params, socket) do
    {:noreply, assign(socket, selectedCommentsId: String.to_integer(params["todo"]), showSelectedComments: true)}
  end
  
  def handle_event("close_comments", _params, socket) do
    {:noreply, assign(socket, showSelectedComments: false)}
  end

  def handle_event(
        "dropped",
        %{
          "draggedId" => dragged_id,
          "dropzoneId" => drop_zone_id,
          "draggableIndex" => draggable_index
        },
        %{assigns: _assigns} = socket
      ) do
    Logger.warn(dragged_id)

    Logger.warn(drop_zone_id)

    Logger.warn(draggable_index)
    {:noreply, socket}
  end
end
