defmodule Day23 do
  def solve1(input) do
    map = input |> parse()
    start = {1, 0}
    {size_x, size_y} = size(input)

    finish = {size_x - 1, size_y}

    traverse([start], finish, map)
    |> Enum.map(fn x ->
      Enum.count(x) - 1
    end)
    |> Enum.max()
  end

  def solve2(input) do
    map = input |> parse()
    start = {1, 0}
    {size_x, size_y} = size(input)

    finish = {size_x - 1, size_y}

    crossroads = map |> crossroads(start, {size_x, size_y})

    roads =
      crossroads
      |> Enum.reduce(%{}, fn x, acc ->
        {pos, paths} = find_road_to_other_crossroad(x, crossroads, map)
        Map.put(acc, pos, paths)
      end)

    traverse_paths({[start], 0}, roads, finish, 0)
  end

  def crossroads(map, start, size) do
    {sx, sy} = size

    crossroads =
      map
      |> Enum.filter(fn {_, c} ->
        c != "#"
      end)
      |> Enum.filter(fn {{x, y}, _c} ->
        res =
          [map[{x + 1, y}], map[{x - 1, y}], map[{x, y + 1}], map[{x, y - 1}]]
          |> Enum.filter(fn c -> Enum.member?([".", "<", ">", "^", "v"], c) end)
          |> Enum.count()

        res > 2
      end)
      |> Enum.map(fn {p, _} -> p end)

    [{sx - 1, sy} | [start | crossroads]]
  end

  def print({size_x, size_y}, track, map) do
    0..size_y
    |> Enum.each(fn y ->
      0..size_x
      |> Enum.map(fn x ->
        if Enum.find(track, fn {p, _} -> p == {x, y} end) != nil do
          "*"
        else
          map[{x, y}]
        end
      end)
      |> Enum.join()
      |> IO.puts()
    end)
  end

  def print_x({size_x, size_y}, map, marks) do
    0..size_y
    |> Enum.each(fn y ->
      0..size_x
      |> Enum.map(fn x ->
        if Enum.find(marks, fn p -> p == {x, y} end) != nil do
          "X"
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
    {String.length(hd(lines)) - 1, length(lines) - 1}
  end

  def traverse_paths({track, step_count}, roads, finish, max) do
    {x, y} = hd(track)

    if finish == {x, y} do
      max(step_count, max)
    else
      roads[{x, y}]
      |> Enum.filter(fn {to, _steps} ->
        !Enum.member?(track, to)
      end)
      |> Enum.reduce(max, fn {to, steps}, acc ->
        max(acc, traverse_paths({[to | track], step_count + steps}, roads, finish, acc))
      end)
    end
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

  def find_road_to_other_crossroad(from, crossroads, map) do
    dirs = [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    {x, y} = from

    paths =
      dirs
      |> Enum.map(fn {dx, dy} ->
        {x + dx, y + dy}
      end)
      |> Enum.filter(fn p ->
        case map[p] do
          ">" -> true
          "<" -> true
          "^" -> true
          "v" -> true
          "." -> true
          _ -> false
        end
      end)
      |> Enum.map(fn p ->
        follow(p, map, crossroads, from, 1)
      end)
      |> Enum.reduce([], fn {{ex, ey}, s}, acc ->
        [{{ex, ey}, s} | acc]
      end)

    {{x, y}, paths}
  end

  def follow(pos, map, crossroads, last, steps) do
    dirs = [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    {x, y} = pos

    if Enum.member?(crossroads, pos) do
      {pos, steps}
    else
      x =
        dirs
        |> Enum.map(fn {dx, dy} ->
          {{x + dx, y + dy}, {dx, dy}}
        end)
        |> Enum.filter(fn {p, _} ->
          p != last
        end)
        |> Enum.filter(fn {p, d} ->
          case {map[p], d} do
            {">", _} -> true
            {"<", _} -> true
            {"^", _} -> true
            {"v", _} -> true
            {".", _} -> true
            _ -> false
          end
        end)

      if length(x) > 1 do
        IO.inspect(x)
        throw("more than 1")
      end

      {next, _} = hd(x)
      follow(next, map, crossroads, pos, steps + 1)
    end
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
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
    {:ok, input} = File.read("inputs/23.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day23.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day23.solve2(input))
  end
end
