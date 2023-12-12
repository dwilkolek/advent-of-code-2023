defmodule Day11 do
  def solve1(input) do
    solve(input, 2)
  end

  def solve2(input) do
    solve(input, 1_000_000)
  end

  def solve(input, expansion_speed) do
    map = input |> parse()

    map = expand_universe(map, expansion_speed)

    galaxies =
      map
      |> Enum.reduce([], fn {{x, y}, c}, acc -> if c != ".", do: [{x, y} | acc], else: acc end)

    {_, distances} =
      galaxies
      |> List.foldl({tl(galaxies), []}, fn galaxy, {other_galaxies, distances} ->
        if length(other_galaxies) == 0 do
          {other_galaxies, distances}
        else
          new_distances =
            other_galaxies |> Enum.map(fn other_galaxy -> dist(galaxy, other_galaxy) end)

          {
            tl(other_galaxies),
            distances ++ new_distances
          }
        end
      end)

    distances |> Enum.sum()
  end

  def dist(galaxy_a, galaxy_b) do
    {x1, y1} = galaxy_a
    {x2, y2} = galaxy_b

    abs(x2 - x1) + abs(y2 - y1)
  end

  defp expand_universe(map, expansion_speed) do
    {max_x, max_y} = universe_size(map)
    eff_expansion_speed = expansion_speed - 1

    empty_y =
      0..max_y
      |> Enum.filter(fn y ->
        Enum.filter(map, fn {{_, ey}, c} -> ey == y && c != "." end) |> Enum.count() == 0
      end)

    empty_x =
      0..max_x
      |> Enum.filter(fn x ->
        Enum.filter(map, fn {{ex, _}, c} -> ex == x && c != "." end) |> Enum.count() == 0
      end)

    map
    |> Enum.reduce(%{}, fn {{x, y}, c}, acc ->
      if c != "." do
        new_boost_x = empty_x |> Enum.filter(fn ex -> ex < x end) |> Enum.count()
        new_boost_y = empty_y |> Enum.filter(fn ey -> ey < y end) |> Enum.count()

        Map.put(
          acc,
          {x + new_boost_x * eff_expansion_speed, y + new_boost_y * eff_expansion_speed},
          c
        )
      else
        acc
      end
    end)
  end

  defp universe_size(map) do
    {max_x, max_y} =
      map
      |> Map.keys()
      |> Enum.reduce({0, 0}, fn {x, y}, {acc_x, acc_y} ->
        {max(acc_x, x), max(acc_y, y)}
      end)

    {max_x, max_y}
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, acc ->
      Map.merge(
        acc,
        line
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {char, x}, acc ->
          Map.put(acc, {x, y}, char)
        end)
      )
    end)
  end
end

defmodule Mix.Tasks.Day11 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/11.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day11.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day11.solve2(input))
  end
end
