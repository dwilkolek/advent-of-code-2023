defmodule Day10 do

  @debug :false

  def solve1(input) do
    {map, _, _} = parse(input)
    {start_x, start_y} = find_start(map)
    map = substitute_S(map, start_x, start_y)
    {_, _, history, _} = traverse(map, start_x, start_y)

    div(length(history), 2)
  end

  def traverse(map, start_x, start_y) do
    [
      {1, 0},
      {-1, 0},
      {0, -1},
      {0, 1}
    ]
    |> Stream.cycle()
    |> Enum.reduce_while({start_x, start_y, [], 0}, fn dir, acc ->
      {last_x, last_y, history, fail_count} = acc
      next_step = next_pos(dir, {last_x, last_y}, map)

      if next_step == nil || Enum.member?(history, next_step) do
        signal = if fail_count > 3, do: :halt, else: :cont
        {signal, {last_x, last_y, history, fail_count + 1}}
      else
        {next_step_x, next_step_y} = next_step
        signal = if map[{next_step_x, next_step_y}] == "S", do: :halt, else: :cont
        {signal, {next_step_x, next_step_y, [next_step | history], 0}}
      end
    end)
  end

  defp substitute_S(map, start_x, start_y) do
    [{sx1, sy1}, {sx2, sy2}] =
      [
        {1, 0},
        {-1, 0},
        {0, -1},
        {0, 1}
      ]
      |> Enum.map(fn dir -> next_pos(dir, {start_x, start_y}, map) end)
      |> Enum.filter(fn x -> x != nil end)

    s_susbstitute =
      case {sx1 - sx2, sy1 - sy2} do
        {1, -1} -> "F"
        {-1, 1} -> "J"
        {-1, -1} -> "7"
        {1, 1} -> "L"
      end

    Map.update!(map, {start_x, start_y}, fn _ -> s_susbstitute end)
  end

  def new_map(input, history) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.split(line, "", trim: true) end)
    |> Enum.with_index()
    |> Enum.map(fn {line, y} ->
      line
      |> Enum.with_index()
      |> Enum.map(fn {part, x} ->
        if Enum.member?(history, {x, y}) do
          "O"
        else
          part
        end
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
  end

  def solve2(input) do
    {map, _max_x, _max_y} = parse(input)
    {start_x, start_y} = find_start(map)
    map = substitute_S(map, start_x, start_y)
    {_, _, history, _} = traverse(map, start_x, start_y)

    print_map(map)

    {map, max_x, max_y} = expand(map)

    print_map(map)

    map = mark_edge(map, max_x, max_y)

    print_map(map)

    map = mark_neighbours(map)

    print_map(map)

    map = colapse_and_mark_visited_as_star(map, history)

    print_map(map)

    map = mark_neighbours(map)

    print_map(map)

    Map.values(map) |> Enum.filter(fn c -> c == "." end) |> Enum.count()
  end

  defp print_map(map) do
    if @debug do
      {max_x, max_y} =
        map
        |> Map.keys()
        |> Enum.reduce({0, 0}, fn {x, y}, {acc_x, acc_y} ->
          {max(acc_x, x), max(acc_y, y)}
        end)

      IO.puts(" ")
      IO.puts(" ")

      0..max_y
      |> Enum.map(fn y ->
        Enum.map(0..max_x, fn x ->
          map[{x, y}]
        end)
        |> Enum.join("")
      end)
      |> Enum.join("\n")
      |> IO.puts()

      IO.puts(" ")
      IO.puts(" ")
    end
  end

  defp mark_edge(map, max_x, max_y) do
    map
    |> Enum.reduce(%{}, fn {{x, y}, part}, acc ->
      is_dot = part == "."
      is_original = rem(x, 2) == 0 && rem(y, 2) == 0

      if is_original do
        case {x, y, is_dot} do
          {0, _, true} -> Map.put(acc, {x, y}, "O")
          {^max_x, _, true} -> Map.put(acc, {x, y}, "O")
          {_, 0, true} -> Map.put(acc, {x, y}, "O")
          {_, ^max_y, true} -> Map.put(acc, {x, y}, "O")
          {_, _, _} -> Map.put(acc, {x, y}, part)
        end
      else
        Map.put(acc, {x, y}, part)
      end
    end)
  end

  defp mark_neighbours(map) do
    map
    |> Enum.filter(fn {_, part} ->
      part == "O"
    end)
    |> List.foldl(map, fn {{x, y}, _part}, acc ->
      mark_neighbours({x, y}, acc)
    end)
  end

  defp mark_neighbours(pos, map) do
    {pos_x, pos_y} = pos

    [
      {-1, 0},
      {1, 0},
      {0, 1},
      {0, -1}
    ]
    |> List.foldl(map, fn {dir_x, dir_y}, acc ->
      case mark({pos_x + dir_x, pos_y + dir_y}, acc) do
        {:nop, new_map} -> new_map
        {:ok, new_map} -> mark_neighbours({pos_x + dir_x, pos_y + dir_y}, new_map)
      end
    end)
  end

  defp mark(pos, map) do
    part = map[pos]

    if part == "." do
      {:ok, Map.update!(map, pos, fn _x -> "O" end)}
    else
      {:nop, map}
    end
  end

  def next_pos(dir, current, map) do
    {current_x, current_y} = current
    {diff_x, diff_y} = dir
    current_part = map[{current_x, current_y}]
    next_part = map[{current_x + diff_x, current_y + diff_y}]

    possible = matching_parts(dir)
    in_reverse = matching_parts({-diff_x, -diff_y})

    if Enum.member?(possible, next_part) &&
         (current_part == "S" || Enum.member?(in_reverse, current_part)) do
      {current_x + diff_x, current_y + diff_y}
    end
  end

  defp matching_parts(dir) do
      case dir do
        # right
        {1, 0} -> ["J", "7", "-"]
        # left
        {-1, 0} -> ["L", "F", "-"]
        # bottom
        {0, -1} -> ["7", "F", "|"]
        # top
        {0, 1} -> ["J", "L", "|"]
      end
  end

  defp colapse_and_mark_visited_as_star(map, history) do
    map
    |> Enum.filter(fn {{x, y}, _} ->
      rem(x, 2) == 0 && rem(y, 2) == 0
    end)
    |> Enum.reduce(%{}, fn {{x, y}, c}, acc ->
      nc = if Enum.member?(history, {div(x, 2), div(y, 2)}), do: "*", else: c
      Map.put(acc, {div(x, 2), div(y, 2)}, nc)
    end)
  end

  defp expand(map) do
    {max_x, max_y} =
      map
      |> Map.keys()
      |> Enum.reduce({0, 0}, fn {x, y}, {acc_x, acc_y} ->
        {max(acc_x, x), max(acc_y, y)}
      end)

    horizontal_open = ["F", "L", "-"]
    horizontal_close = ["7", "J", "-"]
    vertival_open = ["F", "7", "|"]
    vertival_close = ["J", "L", "|"]
    {exp_max_x, exp_max_y} = {max_x * 2 + 2, max_y * 2 + 2}
    offset_x = 1
    offset_y = 1

    0..exp_max_y
    |> Enum.map(fn y ->
      0..exp_max_x
      |> Enum.map(fn x ->
        case [rem(x + offset_x, 2) == 0, rem(y + offset_y, 2) == 0] do
          [true, true] ->
            map[{div(x, 2), div(y, 2)}]

          [false, true] ->
            case {Enum.member?(horizontal_open, map[{div(x - 1, 2), div(y, 2)}]),
                  Enum.member?(horizontal_close, map[{div(x + 1, 2), div(y, 2)}])} do
              {false, false} -> "."
              {true, false} -> "."
              {false, true} -> "."
              {true, true} -> "-"
            end

          [true, false] ->
            case {Enum.member?(vertival_open, map[{div(x, 2), div(y - 1, 2)}]),
                  Enum.member?(vertival_close, map[{div(x, 2), div(y + 1, 2)}])} do
              {false, false} -> "."
              {true, false} -> "."
              {false, true} -> "."
              {true, true} -> "|"
            end

          [false, false] ->
            "."
        end
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
    |> parse()

    # |> IO.puts()
  end

  def parse(input) do
    map =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line -> String.split(line, "", trim: true) end)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, y}, acc ->
        mapped_line =
          line
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {part, x}, acc -> Map.put(acc, {x, y}, part) end)

        Map.merge(acc, mapped_line)
      end)

    {size_x, size_y} =
      map
      |> Map.keys()
      |> Enum.reduce({0, 0}, fn {x, y}, {acc_x, acc_y} ->
        {max(acc_x, x), max(acc_y, y)}
      end)

    {map, size_x, size_y}
  end

  defp find_start(map) do
    map
    |> Enum.find_value(fn {pos, v} -> if v == "S", do: pos end)
  end
end

defmodule Mix.Tasks.Day10 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/10.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day10.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day10.solve2(input))
  end
end
