defmodule Day05 do
  def solve1(input) do
    {seeds, mappings} = parse_input(input)

    seeds
    |> Enum.map(fn seed -> marsh_top_down(seed, mappings) end)
    |> Enum.min()
  end

  def solve2(input) do
    {seeds, mappings} = parse_input(input)

    seeds_grp =
      seeds
      |> Enum.chunk_every(2)
      |> Enum.map(fn [min, l] -> [min, min + l] end)

    List.foldl(mappings, seeds_grp, fn mapping, seed_ranges ->
      Enum.map(seed_ranges, fn seed_range -> split_range_by_mapping(seed_range, mapping) end)
      |> Enum.reduce([], fn l, acc ->
        l ++ acc
      end)
    end)
    |> List.flatten()
    |> Enum.min()
  end

  defp split_range_by_mapping(range, mapping) do
    [mapped, rest] =
      List.foldl(mapping, [[], range], fn mapping_range, acc ->
        [already_mapped, to_map] = acc

        if to_map != [] do
          [new_mapped, rest] = consume(to_map, mapping_range)
          [[new_mapped | already_mapped], rest]
        else
          [already_mapped, to_map]
        end
      end)

    [rest | mapped] |> Enum.filter(fn x -> x != [] end)
  end

  defp consume(range, mapping_range) do
    [range_min, range_max] = range
    [dest, source, length] = mapping_range
    new_min = max(range_min, source)
    new_max = min(range_max, source + length)

    d = source - dest

    if new_max < new_min do
      [[], [range_min, range_max]]
    else
      case [new_min, new_max] do
        [^range_min, ^range_max] -> [[range_min - d, range_max - d], []]
        [_, ^range_max] -> [[new_min - d, range_max - d], [range_min, new_min]]
        [^range_min, _] -> [[range_min - d, new_max - d], [new_max, range_max]]
        [_, _] -> [[], [range_min, range_max]]
      end
    end
  end

  defp parse_input(input) do
    input_groups =
      input
      |> String.split("\n\n")

    "seeds: " <> seeds_str = hd(input_groups)

    seeds =
      String.split(seeds_str, " ")
      |> Enum.map(fn x -> String.to_integer(String.trim(x)) end)

    mappings =
      tl(input_groups)
      |> Enum.map(&parse_mapping/1)

    {seeds, mappings}
  end

  defp parse_mapping(str) do
    tl(str |> String.split("\n"))
    |> Enum.map(fn row ->
      row
      |> String.split(" ")
      |> Enum.map(fn x -> String.to_integer(String.trim(x)) end)
    end)
  end

  defp marsh_top_down(id, mappings) do
    new_id =
      hd(mappings)
      |> Enum.find_value(fn [target, from, l] ->
        if from <= id and from + l > id, do: target + id - from
      end) || id

    if length(tl(mappings)) == 0 do
      new_id
    else
      marsh_top_down(new_id, tl(mappings))
    end
  end
end

defmodule Mix.Tasks.Day05 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/05.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day05.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day05.solve2(input))
  end
end
