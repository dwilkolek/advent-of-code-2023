defmodule Day23 do
  def solve1(_input) do

  end

  def solve2(_input) do

  end
end

defmodule Mix.Tasks.Day23 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/23-test1.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day23.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day23.solve2(input))
  end
end
