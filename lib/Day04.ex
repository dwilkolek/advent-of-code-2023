defmodule CardProjection do
  defstruct card_id: 0, produce: []
end

defmodule Day04 do
  def solve1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, points] =
        line
        |> String.split(": ", trim: true, parts: 2)

      [winning, picks] =
        points
        |> String.split(" | ", trim: true, parts: 2)

      winning_numbers = String.split(winning, ~r/[ ]+/) |> Enum.filter(fn x -> x != "" end)
      picked_numbers = String.split(picks, ~r/[ ]+/) |> Enum.filter(fn x -> x != "" end)

      matches = Enum.filter(picked_numbers, fn x -> Enum.member?(winning_numbers, x) end)

      result =
        matches
        |> Enum.with_index()
        |> Enum.reduce(0, fn {_, index}, acc ->
          :math.pow(2, index)
        end)

      result
    end)
    |> Enum.sum()
  end

  def solve2(input) do
    agg =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [card, points] =
          line
          |> String.split(": ", trim: true, parts: 2)

        "Card " <> card_id_str = card
        card_id = String.trim(card_id_str)
        [winning, picks] =
          points
          |> String.split(" | ", trim: true, parts: 2)

        winning_numbers = String.split(winning, ~r/[ ]+/) |> Enum.filter(fn x -> x != "" end)
        picked_numbers = String.split(picks, ~r/[ ]+/) |> Enum.filter(fn x -> x != "" end)

        matches = Enum.filter(picked_numbers, fn x -> Enum.member?(winning_numbers, x) end)

        # IO.puts("#{card_id}: matches: #{length(matches)}")
        # IO.inspect(card_id)
        {from, _} = Integer.parse(card_id)
        to = from + length(matches)

        # %{card_id => length(matches)}
        %{card_id => %CardProjection{card_id: card_id, produce: tl(Enum.to_list(from..to))}}
      end)
      |> Enum.reduce(fn m, acc -> Map.merge(acc, m) end)
      |> IO.inspect()

    agg
    |> Enum.map(fn {card_id, _} ->
      x = count_cards(card_id, agg, 0)
      # IO.puts("#{card_id} scored #{x}")
      x + 1
    end)
    |> IO.inspect()
    |> Enum.sum()
    # count_cards("1", agg, 0)
    |> IO.inspect()
    "TOD"
  end

  def count_cards(id, agg, level) do
    # IO.puts("#{id} -> #{length(agg["#{id}"].produce)} @ #{level}")

    result =
      Enum.map(agg["#{id}"].produce, fn sub_id ->
        1 + count_cards(sub_id, agg, level + 1)
      end)
      |> Enum.sum()
  end
end

defmodule Mix.Tasks.Day04 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/04.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day04.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day04.solve2(input))
  end
end
