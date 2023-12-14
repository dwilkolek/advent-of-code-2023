defmodule Day14 do
  def solve1(input) do
    {map, size} = input |> parse()

    map |>
    tilt(size, :N)
    |> sum_load(size)
  end

  def solve2(input) do
    cycles = 1_000_000_000
    {map, size} = input |> parse()

    {map, current_cycle} =
      Enum.reduce_while(0..(cycles - 1), {map, 0}, fn _, {map, current_cycle} ->
        cond do
          current_cycle == cycles - 1 ->
            {:halt, {map, current_cycle, true}}

          v = Process.get({map}) ->
            skip = current_cycle - v
            left = cycles - 1 - current_cycle

            {:halt, {map, current_cycle + div(left, skip) * skip}}

          true ->
            Process.put({map}, current_cycle)
            map = tilt(map, size, :N) |> tilt(size, :W) |> tilt(size, :S) |> tilt(size, :E)
            {:cont, {map, current_cycle + 1}}
        end
      end)

    map =
      Enum.reduce(current_cycle..(cycles - 1), map, fn _, map ->
        tilt(map, size, :N) |> tilt(size, :W) |> tilt(size, :S) |> tilt(size, :E)
      end)

    sum_load(map, size)
  end

  defp sum_load(map, size) do
    map
    |> Enum.map(fn {{_x, y}, c} ->
      if c == "O" do
        size - y
      else
        0
      end
    end)
    |> Enum.sum()
  end

  defp tilt(map, size, dir) do
    result =
      0..size
      |> Enum.reduce({%{}, %{}}, fn ref_point, {acc_map, current_barrier} ->
        map
        |> Enum.filter(fn {{x, y}, _} ->
          case dir do
            :N -> ref_point == y
            :W -> ref_point == x
            :S -> size - ref_point == y
            :E -> size - ref_point == x
          end
        end)
        |> Enum.reduce({acc_map, current_barrier}, fn {{x, y}, c}, {acc_map, current_barrier} ->
          {diff_x, diff_y} =
            case dir do
              :N -> {0, 1}
              :W -> {1, 0}
              :S -> {0, -1}
              :E -> {-1, 0}
            end

          case c do
            "#" ->
              {key, value} =
                case dir do
                  :N -> {x + diff_x, y + diff_y}
                  :W -> {y + diff_y, x + diff_x}
                  :S -> {x + diff_x, y + diff_y}
                  :E -> {y + diff_y, x + diff_x}
                end

              {Map.put(acc_map, {x, y}, c), Map.put(current_barrier, key, value)}

            "O" ->
              {next_x, next_y} =
                case dir do
                  :N -> {x, current_barrier[x] || 0}
                  :W -> {current_barrier[y] || 0, y}
                  :S -> {x, current_barrier[x] || size - 1}
                  :E -> {current_barrier[y] || size - 1, y}
                end

              {key, value} =
                case dir do
                  :N -> {next_x + diff_x, next_y + diff_y}
                  :W -> {next_y + diff_y, next_x + diff_x}
                  :S -> {next_x + diff_x, next_y + diff_y}
                  :E -> {next_y + diff_y, next_x + diff_x}
                end

              {Map.put(acc_map, {next_x, next_y}, c), Map.put(current_barrier, key, value)}
          end
        end)
      end)

    {new_map, _} = result

    new_map
  end

  defp parse(input) do
    lines =
      input
      |> String.split("\n")

    size = length(lines)

    map =
      lines
      |> Enum.with_index()
      |> Enum.map(fn {line, y} ->
        line
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.map(fn {c, x} -> {x, y, c} end)
      end)
      |> List.flatten()
      |> Enum.reduce(%{}, fn {x, y, c}, acc ->
        if c != ".", do: Map.put(acc, {x, y}, c), else: acc
      end)

    {map, size}
  end
end

defmodule Mix.Tasks.Day14 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/14.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day14.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day14.solve2(input))
  end
end
