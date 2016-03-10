# ExEnum

ExEnum is an enum library for Elixir, inspired by [ActiveHash::Enum](https://github.com/zilkey/active_hash#enum).

## Installation

Add ex_enum to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:ex_enum, github: "kenta-aktsk/ex_enum"}]
end
```

Ensure ex_enum is started before your application:

```elixir
def application do
  [applications: [:ex_enum]]
end
```

## Usage

Add module and define records and accessor like below:

```elixir
defmodule Status do
  use ExEnum
  row id: 0, type: :invalid, text: "this is invalid"
  row id: 1, type: :valid, text: "this is valid"
  accessor :type
end
```

Records can be accessed like below:

```elixir
Status.all
# => [%{id: 0, text: "this is invalid", type: :invalid},
# %{id: 1, text: "this is valid", type: :valid}]

Status.get(0)
# => %{id: 0, text: "this is invalid", type: :invalid}

Status.get_by(text: "this is valid", type: :valid)
# => %{id: 0, text: "this is valid", type: :valid}

Status.invalid
# => %{id: 0, text: "this is invalid", type: :invalid}

status = Status.valid
status.id
# => 1
status.text
# => "this is valid"
status.type
# => :valid

Status.get!(-1)
# => ** (RuntimeError) no result

Status.get_by!(type: :wrong)
# => ** (RuntimeError) no result

```
