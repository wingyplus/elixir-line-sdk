defmodule LINELoginCmdTest do
  use ExUnit.Case
  doctest LINELoginCmd

  test "greets the world" do
    assert LINELoginCmd.hello() == :world
  end
end
