defmodule Day09 do
  def solve1(input) do
    parse(input)
    |> Enum.map(fn line -> find_line_below(line) end)
    |> Enum.sum()
  end

  def solve2(input) do
  end

  def find_line_below(line) do
    last = hd(Enum.reverse(line))
    res = find_line_below(line, [])
    hd(res) + last
  end

  def find_line_below(line, acc) do
    result =
      line
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [a, b] -> b - a end)

    zeros = List.duplicate(0, length(result))

    if result == zeros do
      [0]
    else
      sub_result = find_line_below(result, [result | acc])
      from_row_below = hd(sub_result)

      last_here = hd(Enum.reverse(result))

      [from_row_below + last_here | sub_result]
    end
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.split(line, " ") |> Enum.map(&String.to_integer/1) end)
    |> IO.inspect()
  end
end

defmodule Mix.Tasks.Day09 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/09-test1.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day09.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day09.solve2(input))
  end
end
