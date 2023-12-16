defmodule Day15 do
  def solve1(input) do
    input
    |> String.split(",")
    |> Enum.map(fn word -> hash(word) end)
    |> Enum.sum()
  end

  def solve2(input) do
    input
    |> String.split(",")
    |> Enum.map(fn word ->
      [label, focal_length] = String.split(word, ~r/-|=/)
      focal_length = if focal_length == "", do: nil, else: String.to_integer(focal_length)
      {label, focal_length}
    end)
    |> Enum.reduce(%{}, fn {label, focal_length}, boxes ->
      box_id = hash(label)
      case focal_length do
        nil ->
          Map.update(boxes, box_id, [], fn old ->
            old |> Enum.filter(fn {l, _} -> l != label end)
          end)

        _ ->
          if Map.get(boxes, box_id, []) |> Enum.find(fn {l, _fl} -> l == label end) do
            Map.update(boxes, box_id, [], fn old ->
              old
              |> Enum.map(fn {l, fl} ->
                if l == label, do: {label, focal_length}, else: {l, fl}
              end)
            end)
          else
            Map.update(boxes, box_id, [{label, focal_length}], fn old ->
              old ++ [{label, focal_length}]
            end)
          end
      end
    end)
    |> Enum.map(fn {box_id, box} ->

      box |> Enum.with_index(1)
      |> Enum.map(fn {{_, fl}, slot} ->
        (box_id + 1) * slot * fl
      end)

    end)
    |> List.flatten()
    |> Enum.sum()
    |> IO.inspect()

    ""
  end

  defp hash(word) do
    word
    |> to_charlist()
    |> List.foldl(0, fn c, acc ->
      rem((acc + c) * 17, 256)
    end)
  end
end

defmodule Mix.Tasks.Day15 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/15.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day15.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day15.solve2(input))
  end
end
