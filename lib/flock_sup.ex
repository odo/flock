defmodule Flock.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [%{id: Flock.Server, type: :worker,  start: {Flock.Server, :start_link, []}}]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
