defmodule ExEnum do
  defmacro __using__(_opts) do
    quote location: :keep do
      import unquote(__MODULE__), only: [row: 1, accessor: 1]
      Module.register_attribute __MODULE__, :collection, accumulate: true
      Module.put_attribute __MODULE__, :accessor, nil
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
      defp check_result!(p) do
        if p, do: p, else: raise RuntimeError, "no result"
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

  defmacro __before_compile__(env) do
    collection = Module.get_attribute(env.module, :collection) |> Enum.reverse
    accessor = Module.get_attribute(env.module, :accessor)
    access_methods = case accessor do
      nil -> []
      key when is_atom(key) -> collection |> Enum.map(&(&1[key]))
    end

    quoted = for func <- access_methods do
      quote location: :keep do
        def unquote(func)() do 
          get_by([{:"#{unquote(accessor)}", unquote(func)}])
        end
      end
    end

    quote location: :keep do
      def all, do: unquote(Macro.escape(collection))
      unquote(quoted)
    end
  end

  def argument_type_error(arg, type) do
    raise ArgumentError, "argument `#{inspect arg}` must be a #{type}"
  end
end
