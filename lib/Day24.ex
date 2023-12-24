defmodule Day24 do
  def solve1(_input) do

  end

  def solve2(_input) do

  end
end

defmodule Mix.Tasks.Day24 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/24-test1.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day24.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day24.solve2(input))
  end
end
