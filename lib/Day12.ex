defmodule Parallel do
  def pmap(collection, func) do
    collection
    |> Enum.map(&Task.async(fn -> func.(&1) end))
    |> Enum.map(fn task -> Task.await(task, 100_000_00) end)
  end
end

defmodule Day12 do
  def solve1(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line -> parse_line(line) end)
    |> solve()
  end

  def solve2(input) do
    duplicate_count = 5

    input
    |> String.split("\n")
    |> Enum.map(fn line -> parse_line(line) end)
    |> Enum.map(fn {springs, broken_pattern} ->
      {List.duplicate(springs |> Enum.join(""), duplicate_count)
       |> Enum.join("?")
       |> String.split("", trim: true),
       List.duplicate(broken_pattern, duplicate_count) |> List.flatten()}
    end)
    |> solve()
  end

  defp solve(lines) do
    lines
    |> Parallel.pmap(fn {springs, broken_pattern} ->
      proceed(springs, broken_pattern, :on_break, "")
    end)
    |> Enum.sum()
  end

  defp parse_line(line) do
    [springs_str, broken_pattern_str] =
      line
      |> String.split(" ", trim: true)

    springs = String.split(springs_str, "", trim: true)

    broken_pattern =
      String.split(broken_pattern_str, ",", trim: true)
      |> Enum.map(fn n -> String.to_integer(n) end)

    {springs, broken_pattern}
  end

  defp optimizer(springs, pattern) do
    case {springs == [], length(pattern) > 0} do
      {true, true} ->
        :fail

      {true, false} ->
        :success

      _ ->
        :continue
    end
  end

  defp memoized_proceed(springs, pattern, state, solution) do
    if v = Process.get({springs, pattern, state}) do
      v
    else
      v = proceed(springs, pattern, state, solution)
      Process.put({springs, pattern, state}, v)
      v
    end
  end

  defp proceed(springs, pattern, state, solution) do
    optimizer_decision = optimizer(springs, pattern)

    case optimizer_decision do
      :fail ->
        0

      :success ->
        1

      :continue ->
        [spring | spring_tail] = springs

        case pattern do
          [] ->
            if spring == "." || spring == "?",
              do:
                proceed(
                  spring_tail,
                  pattern,
                  state,
                  "." <> solution
                ),
              else: 0

          _ ->
            [current_pattern | pattern_tail] = pattern

            {next_state_if_consumed, next_current_pattern_if_consumed} =
              case {current_pattern == 1} do
                {true} -> {:lf_break, pattern_tail}
                {false} -> {:in_progress, [current_pattern - 1 | pattern_tail]}
              end

            case {state, spring} do
              {:on_break, "?"} ->
                memoized_proceed(
                  spring_tail,
                  next_current_pattern_if_consumed,
                  next_state_if_consumed,
                  "#" <> solution
                ) + memoized_proceed(spring_tail, pattern, state, "." <> solution)

              {:in_progress, "?"} ->
                proceed(
                  spring_tail,
                  next_current_pattern_if_consumed,
                  next_state_if_consumed,
                  "#" <> solution
                )

              {:lf_break, "."} ->
                proceed(
                  spring_tail,
                  pattern,
                  :on_break,
                  "." <> solution
                )

              {:lf_break, "?"} ->
                proceed(
                  spring_tail,
                  pattern,
                  :on_break,
                  "." <> solution
                )

              {:on_break, "."} ->
                proceed(
                  spring_tail,
                  pattern,
                  :on_break,
                  "." <> solution
                )

              {:on_break, "#"} ->
                proceed(
                  spring_tail,
                  next_current_pattern_if_consumed,
                  next_state_if_consumed,
                  "#" <> solution
                )

              {:in_progress, "#"} ->
                proceed(
                  spring_tail,
                  next_current_pattern_if_consumed,
                  next_state_if_consumed,
                  "#" <> solution
                )

              {_, _} ->
                0
            end
        end
    end
  end
end

defmodule Mix.Tasks.Day12 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/12.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day12.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day12.solve2(input))
  end
end
