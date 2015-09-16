defmodule FlockServerTest do
  use ExUnit.Case

  setup do
    Application.ensure_all_started(:flock)
    on_exit fn ->
      Application.stop(:flock)
    end
    :ok
  end

  test "starting a node" do
    assert :test@localhost = Flock.Server.start_node(:test, %{})
    assert :pong = :net_adm.ping(:test@localhost)
    assert :x = Flock.Server.rpc(:test, String, :to_atom, ["x"])
    assert [:test@localhost] = Flock.Server.nodes
  end

  test "starting a node with apps" do
    assert :test@localhost = Flock.Server.start_node(:test, %{apps: [:sasl]})
    apps = Flock.Server.rpc(:test, :application, :which_applications, [])
    assert {:sasl, _, _} = :lists.keyfind(:sasl, 1, apps)
  end

  test "starting a node with config" do
    assert :test@localhost = Flock.Server.start_node(:test, %{config: ["config/test_config.exs"]})
    assert [foo: :bar] = Flock.Server.rpc(:test, :application, :get_all_env, [:dummy_app])
  end

  test "stopping a node" do
    Flock.Server.start_node(:test, %{})
    assert [:test@localhost] = Flock.Server.nodes
    assert :ok = Flock.Server.stop_node(:test)
    assert {:badrpc, :nodedown} = Flock.Server.rpc(:test, String, :to_atom, ["x"])
    assert [] = Flock.Server.nodes
  end

  test "stopping all node" do
    Flock.Server.start_node(:test1, %{})
    Flock.Server.start_node(:test2, %{})
    assert [:test2@localhost, :test1@localhost] = Flock.Server.nodes
    assert :ok = Flock.Server.stop_all
    assert {:badrpc, :nodedown} = Flock.Server.rpc(:test1, String, :to_atom, ["x"])
    assert [] = Flock.Server.nodes
  end

end
