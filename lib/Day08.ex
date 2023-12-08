defmodule Day08 do
  def solve1(input) do
    {directions, map} = parse_input(input)

    {steps, _final_pos} =
      directions
      |> Stream.cycle()
      |> Enum.reduce_while({0, "AAA"}, fn dir, {step_count, position} ->
        if position == "ZZZ" do
          {:halt, {step_count, position}}
        else
          {l, r} = Map.get(map, position)

          case dir do
            "L" -> {:cont, {step_count + 1, l}}
            "R" -> {:cont, {step_count + 1, r}}
          end
        end
      end)

    steps
  end

  def solve2(input) do
    {directions, map} = parse_input(input)

    starting_positions =
      Map.keys(map)
      |> Enum.filter(fn pos -> String.ends_with?(pos, "A") end)

    Enum.map(starting_positions, fn starting_pos ->
      {steps, final_pos} =
        directions
        |> Stream.cycle()
        |> Enum.reduce_while({0, starting_pos}, fn dir, {step_count, position} ->
          if String.ends_with?(position, "Z") do
            {:halt, {step_count, position}}
          else
            {l, r} = Map.get(map, position)

            case dir do
              "L" -> {:cont, {step_count + 1, l}}
              "R" -> {:cont, {step_count + 1, r}}
            end
          end
        end)

      steps
    end)
    |> Enum.reduce(1, fn steps, acc -> Math.lcm(steps, acc) end)
  end

  defp parse_input(input) do
    [directions_str, hints_str] =
      input
      |> String.split("\n\n", trim: true, parts: 2)

    directions = String.split(directions_str, "", trim: true)

    map =
      hints_str
      |> String.split("\n")
      |> Enum.map(fn line ->
        <<source::binary-size(3), " = (", l::binary-size(3), ", ", r::binary-size(3), ")">> = line

        {source, l, r}
      end)
      |> Enum.reduce(%{}, fn {source, l, r}, acc ->
        Map.put(acc, source, {l, r})
      end)

    {directions, map}
  end
end

defmodule Mix.Tasks.Day08 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/08.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day08.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day08.solve2(input))
  end
end
