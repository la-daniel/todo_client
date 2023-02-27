defmodule TodoApi.Todo do
  use Tesla
  require Logger
  # alias Tesla.Multipart
  plug Tesla.Middleware.Logger
  alias TodoApi.Todo.Task

  # plug Tesla.Middleware.BaseUrl, "http://172.20.0.3:4001"
  plug Tesla.Middleware.BaseUrl, "http://localhost:4001"
  # plug Tesla.Middleware.Headers, [{"authorization", "token xyz"}]
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.FormUrlencoded

  def list_tasks() do
    get("/tasks/")
  end

  def get_task(id) do
    get("/tasks/" <> id)
  end

  def delete_task(id) do
    IO.inspect(id)
    delete("/tasks/" <> id)
  end

  def update_task(task) do
    Logger.info("HALLO")
    IO.inspect(task)
    # mp = Multipart.new()
    # |> Multipart.add_content_type_param("charset=utf-8")
    # |> Multipart.add_field("todo", '{"detail": "Pwet", "id": "3", "title": "dsdTest Title 3"}')
    # IO.inspect(mp)
    patch("/tasks/" <> task["id"], %{"task" => task})
  end

  def change_task_order(id, newListOrder) do
    IO.inspect(newListOrder)
    post("/change_order", %{"id" => id, "newListOrder" => newListOrder})
  end

  def create_task(task_params) do
    IO.inspect(task_params)
    post("/tasks/", %{"task" => task_params})
  end

  def get_lists() do
    get("/lists/")
  end

  def create_list(list_params) do
    IO.inspect(list_params)
    post("/lists/", %{"list" => list_params})
  end

  def change_todo(%Task{} = todo, attrs \\ %{}) do
    Task.changeset(todo, attrs)
  end

  def get_all_todos() do
    get("/get_all_todos/")
  end

  def get_all_lists() do
    get("/get_all_lists/")
  end

  def get_list(id) do
    IO.inspect("Hallo")
    IO.inspect(id)
    get("/lists/" <> id)
  end

  def update_list(list) do
    Logger.info("HALLO")
    IO.inspect(list)
    # mp = Multipart.new()
    # |> Multipart.add_content_type_param("charset=utf-8")
    # |> Multipart.add_field("todo", '{"detail": "Pwet", "id": "3", "title": "dsdTest Title 3"}')
    # IO.inspect(mp)
    patch("/lists/" <> list["id"], %{"list" => list})
  end

  def delete_list(id) do
    IO.inspect(id)
    delete("/lists/" <> id)
  end

  def delete_comment(id) do
    IO.inspect(id)
    delete("/comments/" <> id)
  end

  def add_comment(comment) do
    post("/comments/", %{"comment" => comment})
  end
end
