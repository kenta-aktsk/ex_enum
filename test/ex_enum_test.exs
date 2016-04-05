defmodule ExEnumTest.Gettext do
  use Gettext, otp_app: :ex_enum
end

defmodule ExEnumTest do
  use ExUnit.Case
  doctest ExEnum

  defmodule Status do
    use ExEnum
    row id: 0, type: :invalid, text: "invalid"
    row id: 1, type: :valid, text: "valid"
    accessor :type
    translate :text, backend: ExEnumTest.Gettext, domain: "default"
  end

  defmodule Status2 do
    use ExEnum
    row id: 0, type: :invalid, text: "invalid"
    row id: 1, type: :valid, text: "valid"
    accessor :type
    translate :text
  end

  defmodule Color do
    use ExEnum
    row id: 0, type: :white, text: "white"
    row id: 1, type: :black, text: "black"
    accessor :type
  end

  setup_all do
    :ok
  end

  test "all" do
    list = [
      %{id: 0, type: :invalid, text: "invalid"},
      %{id: 1, type: :valid, text: "valid"}
    ]
    assert list == Status.all
  end

  test "get with valid parameter" do
    status = Status.get(0)
    assert status.id == 0
    assert status.type == :invalid
    assert status.text == "invalid"
  end

  test "get with wrong parameter" do
    status = Status.get(3)
    assert is_nil(status)

    assert_raise FunctionClauseError, fn ->
      _ = Status.get("1")
    end
  end

  test "get! with valid parameter" do
    status = Status.get(1)
    assert status.id == 1
    assert status.type == :valid
    assert status.text == "valid"
  end

  test "get! with wrong parameter" do
    assert_raise RuntimeError, fn ->
      _ = Status.get!(-1)
    end

    assert_raise FunctionClauseError, fn ->
      _ = Status.get!("1")
    end
  end

  test "get_by with valid parameter" do
    status = Status.get_by(id: 0)
    assert status.type == :invalid

    status = Status.get_by(id: 0, type: :invalid)
    assert status.text == "invalid"

    status = Status.get_by(text: "valid")
    assert status.type == :valid

    status = Status.get_by(text: "valid", type: :valid)
    assert status.id == 1
  end

  test "get_by with wrong parameter" do
    status = Status.get_by(id: -1)
    assert is_nil(status)

    status = Status.get_by(id: -1, type: :invalid)
    assert is_nil(status)

    status = Status.get_by(text: "this is vali")
    assert is_nil(status)

    status = Status.get_by(nam: "valid")
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
    assert status.text == "invalid"

    status = Status.get_by!(text: "valid")
    assert status.type == :valid

    status = Status.get_by!(text: "valid", type: :valid)
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
      _ = Status.get_by!(text: "this is vali")
    end

    assert_raise RuntimeError, fn ->
      _ = Status.get_by!(nam: "valid")
    end

    assert_raise ArgumentError, fn ->
      _ = Status.get_by!("invalid")
    end

    assert_raise ArgumentError, fn ->
      _ = Status.get_by!(%{id: 1})
    end
  end

  test "select with valid list parameter" do
    list = [
      {"invalid", 0},
      {"valid", 1}
    ]
    assert list == Status.select([:text, :id])

    list = [
      {:invalid, "invalid"},
      {:valid, "valid"}
    ]
    assert list == Status.select([:type, :text])
  end

  test "select with valid atom parameter" do
    list = [0, 1]
    assert list == Status.select(:id)

    list = [:invalid, :valid]
    assert list == Status.select(:type)
  end

  test "select with wrong parameter" do
    assert_raise FunctionClauseError, fn ->
      _ = Status.select({:text, :id})
    end

    assert_raise FunctionClauseError, fn ->
      _ = Status.select("text")
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

  test "japanese locale" do
    Gettext.put_locale(ExEnumTest.Gettext, "ja")

    status = Status.get(0)
    assert status.text == "無効"

    status = Status.get_by(id: 1)
    assert status.text == "有効"

    list = [
      {"無効", 0},
      {"有効", 1}
    ]
    assert list == Status.select([:text, :id])

    status = Status.invalid
    assert status.text == "無効"
  end

  test "japanese locale without specifying backend and domain" do
    Gettext.put_locale(ExEnumTest.Gettext, "ja")

    status = Status2.get(0)
    assert status.text == "無効"
  end

  test "without specifying translate" do
    color = Color.get(1)
    assert color.text == "black"
  end
end
