defmodule TodoApi.Todoing do
  use Tesla
  require Logger
  # alias Tesla.Multipart
  plug Tesla.Middleware.Logger
  

  plug Tesla.Middleware.BaseUrl, "http://172.20.0.3:4001"
  # plug Tesla.Middleware.Headers, [{"authorization", "token xyz"}]
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.FormUrlencoded

  def list_todos() do
    get("/todos/")
  end

  def get_todo(id) do 
    Logger.info(id)
    get("/todos/"<>id)
  end

  def delete_todo(id) do
    IO.inspect(id)
    delete("/todos/"<>id)
  end

  def update_todo (todo) do
    Logger.info("HALLO")
    IO.inspect(todo)
    # mp = Multipart.new()
    # |> Multipart.add_content_type_param("charset=utf-8")
    # |> Multipart.add_field("todo", '{"detail": "Pwet", "id": "3", "title": "dsdTest Title 3"}')
    # IO.inspect(mp)
    patch("/todos/"<>todo["id"], %{"todo" => todo})
  end


  def change_todo_order(id, newListOrder ) do
    IO.inspect(newListOrder)
    post("/change_order", %{"id" => id, "newListOrder" => newListOrder})  
  end
  
  def create_todo(todo_params) do 
    IO.inspect(todo_params)
    post("/todos", %{"todo" => todo_params})
  end




end
