defmodule ExEnumTest do
  use ExUnit.Case
  doctest ExEnum

  defmodule Status do
    use ExEnum
    item id: 0, type: :invalid, name: "this is invalid"
    item id: 1, type: :valid, name: "this is valid"
    accessor :type
  end

  setup_all do
    :ok
  end

  test "all" do
    list = [
      %{id: 0, type: :invalid, name: "this is invalid"},
      %{id: 1, type: :valid, name: "this is valid"}
    ]
    assert list == Status.all
  end

  test "get with valid parameter" do
    status = Status.get(0)
    assert status.id == 0
    assert status.type == :invalid
    assert status.name == "this is invalid"
  end

  test "get with wrong parameter" do
    status = Status.get(3)
    assert is_nil(status)
  end

  test "get! with valid parameter" do
    status = Status.get(1)
    assert status.id == 1
    assert status.type == :valid
    assert status.name == "this is valid"
  end

  test "get! with wrong parameter" do
    assert_raise RuntimeError, fn -> 
      _ = Status.get!(-1)
    end
  end

  test "get_by with valid parameter" do
    status = Status.get_by(id: 0)
    assert status.type == :invalid

    status = Status.get_by(id: 0, type: :invalid)
    assert status.name == "this is invalid"

    status = Status.get_by(name: "this is valid")
    assert status.type == :valid

    status = Status.get_by(name: "this is valid", type: :valid)
    assert status.id == 1
  end

  test "get_by with wrong parameter" do
    status = Status.get_by(id: -1)
    assert is_nil(status)

    status = Status.get_by(id: -1, type: :invalid)
    assert is_nil(status)

    status = Status.get_by(name: "this is vali")
    assert is_nil(status)

    status = Status.get_by(nam: "this is valid")
    assert is_nil(status)

    assert_raise ArgumentError, fn -> 
      _ = Status.get_by("invalid")
    end

    assert_raise ArgumentError, fn -> 
      _ = Status.get_by(%{id: 1})
    end
  end

  test "get_by! with valid parameter" do
    status = Status.get_by!(id: 0)
    assert status.type == :invalid

    status = Status.get_by!(id: 0, type: :invalid)
    assert status.name == "this is invalid"

    status = Status.get_by!(name: "this is valid")
    assert status.type == :valid

    status = Status.get_by!(name: "this is valid", type: :valid)
    assert status.id == 1
  end

  test "get_by! with wrong parameter" do
    assert_raise RuntimeError, fn ->
      _ = Status.get_by!(id: -1)
    end

    assert_raise RuntimeError, fn ->
      _ = Status.get_by!(id: -1, type: :invalid)
    end

    assert_raise RuntimeError, fn ->
      _ = Status.get_by!(name: "this is vali")
    end

    assert_raise RuntimeError, fn ->
      _ = Status.get_by!(nam: "this is valid")
    end

    assert_raise ArgumentError, fn -> 
      _ = Status.get_by!("invalid")
    end

    assert_raise ArgumentError, fn -> 
      _ = Status.get_by!(%{id: 1})
    end
  end

  test "accessor with valid function name" do
    status = Status.invalid
    assert status.id == 0
    assert status.type == :invalid
  end

  test "accessor with wrong function name" do
    assert_raise UndefinedFunctionError, fn -> 
      _ = Status.nodef
    end
  end
end
