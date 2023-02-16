defmodule TodoApi.Users.Todo do
  use Ecto.Schema
  require Logger

  import Ecto.Changeset

  schema "todos" do
    field :detail, :string
    field :order, :integer
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do

    todo
    |> cast(attrs, [:title, :detail, :order, :id])
    |> validate_required([:title, :detail])
    #    |> put_change(:order, lastOrder+1)
  end
end

