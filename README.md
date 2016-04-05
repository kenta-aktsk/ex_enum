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
defmodule MyApp.Status do
  use ExEnum
  row id: 0, type: :invalid, text: "invalid"
  row id: 1, type: :valid, text: "valid"
  accessor :type
end
```

Records can be accessed like below:

```elixir
alias MyApp.Status
Status.all
# => [%{id: 0, text: "invalid", type: :invalid},
# %{id: 1, text: "valid", type: :valid}]

Status.get(0)
# => %{id: 0, text: "invalid", type: :invalid}

Status.get_by(text: "valid", type: :valid)
# => %{id: 0, text: "valid", type: :valid}

Status.select([:text, :id])
# => [{"invalid", 0}, {"valid", 1}]

Status.select(:id)
# => [0, 1]

Status.invalid
# => %{id: 0, text: "invalid", type: :invalid}

status = Status.valid
status.id
# => 1
status.text
# => "valid"
status.type
# => :valid

Status.get!(-1)
# => ** (RuntimeError) no result

Status.get_by!(type: :wrong)
# => ** (RuntimeError) no result

```


You can use these functions with Phoenix view helpers like below:

```ex

# index.html.eex
<td><%= Status.get(user.status).text %></td>

# form.html.eex
<%= select f, :status, Status.select([:text, :id]), class: "form-control" %>

# show.html.eex
<%= Status.get(@user.status).text %>

```

## Gettext

You can use ex_enum with [Gettext](https://github.com/elixir-lang/gettext).

If you already have `MyApp.Gettext` module and `default.po` file for your target locale and if you want to translate `text` field of Status module, 
you can specify target field of translation like below:

```elixir
defmodule MyApp.Status do
  use ExEnum
  row id: 0, type: :invalid, text: "invalid"
  row id: 1, type: :valid, text: "valid"
  accessor :type
  translate :text
  # you can specify :backend and :domain. the above is same as:
  # translate :text, backend: MyApp.Gettext, domain: "default"
end
```

If you have Spanish `default.po` file, for example:

```
msgid "invalid"
msgstr "inválido"

msgid "valid"
msgstr "válido"
```

You can get translated text like below:

```ex
Gettext.put_locale(MyApp.Gettext, "es")
alias MyApp.Status

Status.get(0)
# => %{id: 0, text: "inválido", type: :invalid}

Status.select([:text, :id])
# => [{"inválido", 0}, {"válido", 1}]

```
