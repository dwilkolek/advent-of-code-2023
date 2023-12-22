defmodule Day25 do
  def solve1(input) do

  end

  def solve2(input) do

  end
end

defmodule Mix.Tasks.Day25 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/25-test1.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day25.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day25.solve2(input))
  end
end
