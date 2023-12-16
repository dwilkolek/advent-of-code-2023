defmodule Day16 do
  def solve1(input) do
    {room, size} = parse(input)

    solve_for_entry(room, size)
  end

  def solve2(input) do
    {room, size} =
      parse(input)

    0..(size - 1)
    |> Enum.map(fn pos ->
      [{-1, pos, :right}, {size, pos, :left}, {pos, -1, :down}, {pos, size, :up}]
    end)
    |> List.flatten()
    |> Parallel.pmap(fn entry_beam ->
      solve_for_entry(room, size, entry_beam)
    end)
    |> Enum.max()
  end

  defp solve_for_entry(room, size), do: solve_for_entry(room, size, {-1, 0, :right})

  defp solve_for_entry(room, size, entry) do
    energized = process_beam(entry, room, size, %{})

    energized
    |> Enum.map(fn {{x, y, _}, _} -> {x, y} end)
    |> Enum.uniq()
    |> Enum.count()
  end

  defp process_beam(beam, room, size, energized) do
    {pos_x, pos_y, dir} = beam

    {next_x, next_y} =
      case dir do
        :up -> {pos_x, pos_y - 1}
        :down -> {pos_x, pos_y + 1}
        :right -> {pos_x + 1, pos_y}
        :left -> {pos_x - 1, pos_y}
      end

    if next_x >= size || next_y >= size || next_y < 0 || next_x < 0 ||
         energized[{next_x, next_y, dir}] != nil do
      energized
    else
      sym = room[{next_x, next_y}]
      energized = Map.put(energized, {next_x, next_y, dir}, true)

      new_beams =
        case {sym, dir} do
          {"|", :left} -> [{next_x, next_y, :up}, {next_x, next_y, :down}]
          {"|", :right} -> [{next_x, next_y, :up}, {next_x, next_y, :down}]
          {"-", :up} -> [{next_x, next_y, :left}, {next_x, next_y, :right}]
          {"-", :down} -> [{next_x, next_y, :left}, {next_x, next_y, :right}]
          {"/", :right} -> [{next_x, next_y, :up}]
          {"/", :left} -> [{next_x, next_y, :down}]
          {"/", :up} -> [{next_x, next_y, :right}]
          {"/", :down} -> [{next_x, next_y, :left}]
          {"\\", :right} -> [{next_x, next_y, :down}]
          {"\\", :left} -> [{next_x, next_y, :up}]
          {"\\", :up} -> [{next_x, next_y, :left}]
          {"\\", :down} -> [{next_x, next_y, :right}]
          _ -> [{next_x, next_y, dir}]
        end

      Enum.reduce(new_beams, energized, fn beam, acc ->
        process_beam(beam, room, size, acc)
      end)
    end
  end

  defp parse(input) do
    lines = input |> String.split("\n")
    size = hd(lines) |> String.length()

    room =
      lines
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, y}, acc ->
        Map.merge(
          acc,
          line
          |> String.split("", trim: true)
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {sym, x}, acc ->
            if sym != "." do
              Map.put(acc, {x, y}, sym)
            else
              acc
            end
          end)
        )
      end)

    {room, size}
  end
end

defmodule Mix.Tasks.Day16 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/16.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day16.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day16.solve2(input))
  end
end
