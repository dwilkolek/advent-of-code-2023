defmodule Day07 do
  def solve1(input) do
    solve(input, false)
  end

  def solve2(input) do
    solve(input, true)
  end

  defp solve(input, with_joker) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      [hand, bid] = String.split(line, " ", parts: 2)
      {hand, String.to_integer(bid), score_hand(hand_str_to_hand(hand, with_joker))}
    end)
    |> Enum.sort(fn {a_hand, _a_bid, a_score}, {b_hand, _b_bid, b_score} ->
      sort_hands({a_hand, a_score}, {b_hand, b_score}, with_joker)
    end)
    |> Enum.with_index()
    |> Enum.map(fn {{_, bid, _}, rank} ->
      (rank + 1) * bid
    end)
    |> Enum.sum()
  end

  defp get_card_sort_value(a, with_joker) do
    card_value = %{
      "A" => 14,
      "K" => 13,
      "Q" => 12,
      "J" =>
        if with_joker do
          1
        else
          11
        end,
      "T" => 10,
      "9" => 9,
      "8" => 8,
      "7" => 7,
      "6" => 6,
      "5" => 5,
      "4" => 4,
      "3" => 3,
      "2" => 2
    }

    card_value[a]
  end

  defp sort_hands(a, b, with_joker) do
    {a_hand, a_score} = a
    {b_hand, b_score} = b

    if b_score == a_score do
      found =
        Enum.zip(
          String.split(a_hand, "", trim: true)
          |> Enum.map(fn x -> get_card_sort_value(x, with_joker) end),
          String.split(b_hand, "", trim: true)
          |> Enum.map(fn x -> get_card_sort_value(x, with_joker) end)
        )
        |> Enum.find_value(false, fn {a, b} ->
          if a == b do
            nil
          else
            if a < b, do: :ok, else: :rev
          end
        end)

      if found == :ok do
        true
      else
        false
      end
    else
      a_score < b_score
    end
  end

  def hand_str_to_hand(hand_str, with_joker) do
    String.split(hand_str, "", trim: true)
    |> Enum.sort(fn a, b ->
      av = get_card_sort_value(a, with_joker)
      bv = get_card_sort_value(b, with_joker)
      av > bv
    end)
    |> Enum.reduce(%{}, fn card, acc ->
      if with_joker && card == "J" do
        cards_order =
          Map.to_list(acc) |> Enum.sort(fn {_, a}, {_, b} -> a > b end)

        eff_card =
          if length(cards_order) == 0 do
            "A"
          else
            {card, _} = hd(cards_order)
            card
          end

        {_, new_acc} = Map.get_and_update(acc, eff_card, fn x -> {x, (x || 0) + 1} end)
        new_acc
      else
        {_, new_acc} = Map.get_and_update(acc, card, fn x -> {x, (x || 0) + 1} end)
        new_acc
      end
    end)
  end

  def score_hand(hand) do
    counts = Map.values(hand) |> Enum.sort(:desc)
    match = counts ++ List.duplicate(0, 5 - length(counts))

    case match do
      [5, _, _, _, _] -> 7
      [4, 1, _, _, _] -> 6
      [3, 2, _, _, _] -> 5
      [3, 1, 1, _, _] -> 4
      [2, 2, 1, _, _] -> 3
      [2, 1, 1, 1, _] -> 2
      [1, 1, 1, 1, 1] -> 1
    end
  end
end

defmodule Mix.Tasks.Day07 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/07.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day07.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day07.solve2(input))
  end
end
