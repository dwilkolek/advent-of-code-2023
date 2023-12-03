defmodule EnigineValue do
  defstruct x: -1, y: -1, value: 0, end_x: 0
end

defmodule SymbolPosition do
  defstruct x: -1, y: -1, symbol: ~c"."
end

defmodule Day03 do
  def solve1(input) do
    {numbers, symbols} = map_input(input)

    symbols
    |> Enum.map(fn sym ->
      Enum.filter(numbers, fn v ->
        sym.x >= v.x - 1 and sym.x <= v.end_x + 1 and sym.y >= v.y - 1 and sym.y <= v.y + 1
      end)
    end)
    |> List.flatten()
    |> Enum.map(fn v -> v.value end)
    |> Enum.sum()
  end

  def solve2(input) do
    {numbers, symbols} = map_input(input)

    symbols
    |> Enum.map(fn sym ->
      Enum.filter(numbers, fn v ->
        sym.x >= v.x - 1 and sym.x <= v.end_x + 1 and sym.y >= v.y - 1 and sym.y <= v.y + 1
      end)
    end)
    |> Enum.filter(fn matches -> length(matches) == 2 end)
    |> Enum.map(fn match ->
      Enum.reduce(match, 1, fn v, acc ->
        acc * v.value
      end)
    end)
    |> Enum.sum()
  end

  def map_input(input) do
    [left, _] = String.split(input, "\n", parts: 2)
    line_length = String.length(left)
    continous_input = String.replace(input, "\n", "")

    numbers = find_numbers(continous_input, line_length)
    symbols = find_symbols(continous_input, line_length)
    {numbers, symbols}
  end

  def find_numbers(input, line_length) do
    indexes = Regex.scan(~r/[0-9]+/, input, return: :index)
    numbers = Regex.scan(~r/[0-9]+/, input)

    Enum.zip(indexes, numbers)
    |> Enum.map(fn el ->
      {[{position, length}], [value]} = el
      {v, _} = Integer.parse(value)
      y = div(position, line_length)
      x = rem(position, line_length)
      %EnigineValue{x: x, y: y, value: v, end_x: length + x - 1}
    end)
  end

  def find_symbols(input, line_length) do
    indexes = Regex.scan(~r/[^.0-9\n]/, input, return: :index)
    numbers = Regex.scan(~r/[^.0-9\n]/, input)

    Enum.zip(indexes, numbers)
    |> Enum.map(fn el ->
      {[{position, _}], [symbol]} = el
      y = div(position, line_length)
      x = rem(position, line_length)
      %SymbolPosition{x: x, y: y, symbol: symbol}
    end)
  end
end

defmodule Mix.Tasks.Day03 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/03.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day03.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day03.solve2(input))
  end
end
