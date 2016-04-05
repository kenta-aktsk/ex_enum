defmodule ExEnum do
  defmacro __using__(_opts) do
    backend = Module.split(__CALLER__.module) |> List.first |> Module.concat(Gettext)
    quote location: :keep do
      import unquote(__MODULE__), only: [row: 1, accessor: 1, translate: 1, translate: 2]
      Module.register_attribute __MODULE__, :collection, accumulate: true
      Module.put_attribute __MODULE__, :accessor, nil
      Module.put_attribute __MODULE__, :translate, nil
      Module.put_attribute __MODULE__, :backend, unquote(backend)
      Module.put_attribute __MODULE__, :domain, "default"
      @before_compile unquote(__MODULE__)

      def get(id) when is_integer(id) do
        get_by(id: id)
      end
      def get!(id) when is_integer(id) do
        get(id) |> check_result!
      end
      def get_by(kw) do
        unless Keyword.keyword?(kw), do: unquote(__MODULE__).argument_type_error(kw, "keyword list")
        all |> Enum.find(&((kw -- Enum.into(&1, [])) == []))
      end
      def get_by!(kw) do
        get_by(kw) |> check_result!
      end
      def select(fields) when is_list(fields) do
        Enum.map all, fn(row) ->
          Enum.reduce fields, {}, fn(field, acc) ->
            Tuple.append(acc, row[field])
          end
        end
      end
      def select(field) when is_atom(field) do
        Enum.map all, &(&1[field])
      end
      defp check_result!(p) do
        p || raise RuntimeError, "no result"
      end
    end
  end

  defmacro row(kw) do
    unless Keyword.keyword?(kw) do
      unquote(__MODULE__).argument_type_error(kw, "keyword list")
    end
    quote location: :keep do
      @collection unquote(kw) |> Enum.into(%{})
    end
  end

  defmacro accessor(key) do
    unless is_atom(key) do
      unquote(__MODULE__).argument_type_error(key, "atom")
    end
    quote location: :keep do
      @accessor unquote(key)
    end
  end

  defmacro translate(key, kw \\ []) do
    unless is_atom(key) do
      unquote(__MODULE__).argument_type_error(key, "atom")
    end
    unless Keyword.keyword?(kw) do
      unquote(__MODULE__).argument_type_error(kw, "keyword list")
    end
    quote location: :keep do
      @translate unquote(key)
      @backend unquote(kw)[:backend] || @backend
      @domain unquote(kw)[:domain] || @domain
    end
  end

  defmacro __before_compile__(env) do
    collection = Module.get_attribute(env.module, :collection) |> Enum.reverse
    accessor = Module.get_attribute(env.module, :accessor)
    accessor_keys = case accessor do
      nil -> []
      key when is_atom(key) -> collection |> Enum.map(&(&1[key]))
    end

    access_methods = for func <- accessor_keys do
      quote location: :keep do
        def unquote(func)() do 
          get_by([{:"#{unquote(accessor)}", unquote(func)}])
        end
      end
    end

    quote location: :keep do
      defp do_translate(collection, nil), do: collection
      defp do_translate(collection, key) do
        Enum.map collection, fn(row) ->
          update_in(row[key], &Gettext.dgettext(@backend, @domain, &1))
        end
      end
      def all do
        unquote(Macro.escape(collection)) |> do_translate(@translate)
      end
      unquote(access_methods)
    end
  end

  def argument_type_error(arg, type) do
    raise ArgumentError, "argument `#{inspect arg}` must be a #{type}"
  end
end
