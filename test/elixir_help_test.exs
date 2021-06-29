defmodule ElixirHelpTest do
  use ExUnit.Case
  doctest ElixirHelp

  test "greets the world" do
    assert ElixirHelp.hello() == :world
  end
end
