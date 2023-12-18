defmodule Day18 do
  @big_value 500_000
  def solve1(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      [dir, len, _] = String.split(line, " ", trim: true)
      {dir, String.to_integer(len)}
    end)
    |> solve()
  end

  def solve2(input) do
    path =
      input
      |> String.split("\n")
      |> Enum.map(fn line ->
        [_dir, _len, color] = String.split(line, " ", trim: true)

        color =
          color
          |> String.replace_prefix("(#", "")
          |> String.replace_suffix(")", "")

        [lenhex, [dirhex]] =
          color |> String.split("", trim: true) |> Enum.chunk_every(5)

        dir =
          case dirhex do
            "0" -> "R"
            "1" -> "D"
            "2" -> "L"
            "3" -> "U"
          end

        {dir, String.to_integer(lenhex |> Enum.join(""), 16)}
      end)

    perimiter =
      path
      |> Enum.map(fn {_, len} ->
        len
      end)
      |> Enum.sum()

    perimiter = div(perimiter, 2) + 1

    vertices =
      path
      |> Enum.reduce([{@big_value, @big_value}], fn {dir, len}, acc ->
        {diff_x, diff_y} =
          case dir do
            "R" -> {1, 0}
            "D" -> {0, -1}
            "L" -> {-1, 0}
            "U" -> {0, 1}
          end

        {x, y} = hd(acc)

        [{x + diff_x * len, y + diff_y * len} | acc]
      end)

    vertices = vertices |> Enum.take(length(vertices) - 1)
    shoelace(vertices) + perimiter
  end

  def shoelace(vertices) do
    sum =
      vertices
      |> Enum.chunk_every(2, 1)
      |> Enum.map(fn cross ->
        if length(cross) == 1 do
          [{x1, y1}] = cross
          {x2, y2} = hd(vertices)
          x1 * y2 - x2 * y1
        else
          [{x1, y1}, {x2, y2}] = cross
          x1 * y2 - x2 * y1
        end
      end)
      |> Enum.sum()

    # IO.puts("Shoelace: #{div(sum, 2)}")
    div(sum, 2)
  end

  def solve(path) do
    {edge, _pos} =
      path
      |> Enum.reduce({%{}, {@big_value, @big_value}}, fn {dir, len}, {acc, {x, y}} ->
        {diff_x, diff_y} =
          case dir do
            "R" -> {1, 0}
            "D" -> {0, 1}
            "L" -> {-1, 0}
            "U" -> {0, -1}
          end

        border =
          len..1
          |> Enum.map(fn step ->
            {x + step * diff_x, y + step * diff_y}
          end)

        border_map =
          border
          |> Enum.reduce(%{}, fn {x, y}, acc ->
            Map.put(acc, {x, y}, :edge)
          end)

        {Map.merge(acc, border_map), hd(border)}
      end)

    {m_min_x, m_min_y} =
      edge
      |> Map.keys()
      |> Enum.reduce({@big_value, @big_value}, fn {x, y}, {a_min_x, a_min_y} ->
        {min(a_min_x, x), min(a_min_y, y)}
      end)

    {edge, size_x, size_y} =
      edge
      |> Map.keys()
      |> Enum.reduce({%{}, -1, -1}, fn {x, y}, {acc, ax, ay} ->
        {Map.put(acc, {x - m_min_x + 1, y - m_min_y + 1}, :edge), max(ax, x - m_min_x + 2),
         max(ay, y - m_min_y + 2)}
      end)

    marked_map =
      mark_around({0, 0}, {size_x, size_y}, edge)

    outer = marked_map |> Map.values() |> Enum.filter(fn x -> x == :outer end) |> Enum.count()

    total = (size_x + 1) * (size_y + 1)

    total - outer
  end

  def print(map, {size_x, size_y}) do
    0..size_y
    |> Enum.map(fn y ->
      0..size_x
      |> Enum.map(fn x ->
        case map[{x, y}] do
          :outer -> "*"
          :edge -> "#"
          nil -> "."
        end
      end)
      |> Enum.join()
      |> IO.puts()
    end)
  end

  def mark_around({x, y}, {size_x, size_y}, map) do
    if x >= 0 && y >= 0 && x <= size_x && y <= size_y && map[{x, y}] == nil do
      map = Map.put(map, {x, y}, :outer)
      map = mark_around({x, y + 1}, {size_x, size_y}, map)
      map = mark_around({x, y - 1}, {size_x, size_y}, map)
      map = mark_around({x + 1, y}, {size_x, size_y}, map)
      map = mark_around({x - 1, y}, {size_x, size_y}, map)
      map
    else
      map
    end
  end
end

defmodule Mix.Tasks.Day18 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/18.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day18.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day18.solve2(input))
  end
end
