defmodule ExEnum.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :ex_enum,
     version: @version,
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps, 

     # Hex
     description: description,
     package: package]
  end

  defp description do
    """
    Enum library for Elixir inspired by ActiveHash::Enum.
    """
  end

  defp package do
    [maintainers: ["Kenta Katsumata"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/kenta-aktsk/ex_enum"},
     files: ~w(mix.exs README.md LICENSE lib)]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:gettext, "~> 0.9"},
     {:ex_doc, "~> 0.11", only: :docs}]
  end
end
