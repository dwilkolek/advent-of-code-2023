defmodule Day23 do
  def solve1(input) do
    map = input |> parse()
    start = {1, 0}
    {size_x, size_y} = size(input)

    finish = {size_x - 2, size_y - 1}
    traverse([start], finish, map) |> Enum.map(fn x ->
      IO.puts("Track length #{ Enum.count(x)}")
      # print({size_x, size_y}, x, map)
      Enum.count(x) - 1 end) |> Enum.max()

  end

  def solve2(_input) do
  end

  def print({size_x, size_y}, track, map) do
    0..size_y
    |> Enum.each(fn y ->
      0..size_x |> Enum.map(fn x ->
        if Enum.find(track, fn {p, _} -> p == {x, y} end)  != nil do
          "*"
        else
          map[{x, y}]
        end
      end)
      |> Enum.join()
      |> IO.puts()

    end)
  end

  def size(input) do
    lines = input |> String.split("\n")
    {String.length(hd(lines)), length(lines)}
  end

  def traverse(track, finish, map) do
    {x, y} = hd(track)
    dirs = [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]

    if finish == {x, y} do
      [track]
    else
      dirs
      |> Enum.map(fn {dx, dy} ->
        {{x + dx, y + dy}, {dx, dy}}
      end)
      |> Enum.filter(fn {p, d} ->
        case {map[p], d, Enum.member?(track, p)} do
          {_, _, true} -> false
          {">", {1, 0}, _} -> true
          {"<", {-1, 0}, _} -> true
          {"^", {0, -1}, _} -> true
          {"v", {0, 1}, _} -> true
          {".", _, _} -> true
          _ -> false
        end
      end)
      |> Enum.reduce([], fn {p, _d}, acc ->
        acc ++ traverse([p | track], finish, map)
      end)
    end
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, acc ->
      Map.merge(
        acc,
        line
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {c, x}, acc ->
          Map.put(acc, {x, y}, c)
        end)
      )
    end)
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
