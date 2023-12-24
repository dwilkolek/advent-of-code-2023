defmodule Day21 do
  def solve1(input) do
    map = parse(input)
    {start, _} = map |> Enum.find(fn {_, c} -> c == "S" end)
    fill(start, map, 64)
  end

  def solve2(input) do
    map = parse(input)
    {start, _} = map |> Enum.find(fn {_, c} -> c == "S" end)
    {size_x, size_y} = size(map)
    {sx, sy} = start
    steps = 26_501_365
    grid_width = div(steps, size_x) - 1

    odd = :math.pow(div(grid_width, 2) * 2 + 1, 2)
    even = :math.pow(div(grid_width + 1, 2) * 2, 2)

    odd_points = fill(start, map, size_x * 2 + 1)
    even_points = fill(start, map, size_x * 2)

    corner_t = fill({size_x - 1, sy}, map, size_x - 1)
    corner_r = fill({sx, 0}, map, size_x - 1)
    corner_b = fill({0, sy}, map, size_x - 1)
    corner_l = fill({sx, size_x - 1}, map, size_x - 1)

    small_tr = fill({size_x - 1, 0}, map, div(size_x, 2) - 1)
    small_tl = fill({size_x - 1, size_x - 1}, map, div(size_x, 2) - 1)
    small_br = fill({0, 0}, map, div(size_x, 2) - 1)
    small_bl = fill({0, size_y - 1}, map, div(size_x, 2) - 1)

    large_tr = fill({size_x - 1, 0}, map, div(size_x * 3, 2) - 1)
    large_tl = fill({size_x - 1, size_x - 1}, map, div(size_x * 3, 2) - 1)
    large_br = fill({0, 0}, map, div(size_x * 3, 2) - 1)
    large_bl = fill({0, size_y - 1}, map, div(size_x * 3, 2) - 1)

    odd * odd_points + even * even_points +
      corner_t + corner_r + corner_b + corner_l +
      (grid_width + 1) * (small_tr + small_tl + small_bl + small_br) +
      grid_width * (large_tr + large_tl + large_bl + large_br)
  end

  def fill(positions, map, step) do
    take_step(%{}, [positions], map, step)
    |> Enum.filter(fn {{_, _}, s} -> rem(s, 2) == 0 end)
    |> Enum.map(fn {x, _} -> x end)
    |> Enum.count()
  end

  def size(map) do
    map
    |> Enum.reduce({0, 0}, fn {{x, y}, _}, {ax, ay} ->
      {max(ax, x + 1), max(ay, y + 1)}
    end)
  end

  def print(map, matching) do
    {map_x, map_y} = size(map)

    0..map_y
    |> Enum.map(fn y ->
      0..map_x
      |> Enum.map(fn x ->
        s = Enum.member?(matching, {x, y})

        if s && map[{x, y}] != "S" do
          "O"
        else
          map[{x, y}]
        end
      end)
      |> Enum.join()
      |> IO.puts()
    end)
  end

  def take_step(collector, positions, map, step) do
    collector =
      positions
      |> Enum.reduce(collector, fn pos, collector ->
        Map.put(collector, pos, step)
      end)

    to_check =
      collector
      |> Enum.filter(fn {_pos, v} -> v == step end)
      |> Parallel.pmap(fn {{x, y}, _v} ->
        [
          {x, y + 1},
          {x, y - 1},
          {x + 1, y},
          {x - 1, y}
        ]
      end)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.filter(fn p ->
        v = map[p]
        (v == "S" || v == ".") && collector[p] == nil
      end)

    if step > 0, do: take_step(collector, to_check, map, step - 1), else: collector
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {l, y}, acc ->
      Map.merge(
        acc,
        l
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {c, x}, acc -> Map.put(acc, {x, y}, c) end)
      )
    end)
  end
end

defmodule Mix.Tasks.Day21 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/21.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day21.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day21.solve2(input))
  end
end
