defmodule Day06 do
  def solve1(input) do
    ["Time: " <> time_str, "Distance: " <> distance] =
      input
      |> String.split("\n", trim: true, parts: 2)

    Enum.zip(
      time_str |> String.trim() |> String.split(~r/[ ]+/) |> Enum.map(&String.to_integer/1),
      distance |> String.trim() |> String.split(~r/[ ]+/) |> Enum.map(&String.to_integer/1)
    )
    |> Enum.map(fn {time, dist} ->
      0..time
      |> Enum.map(fn hold_time ->
        calc_result(hold_time, time)
      end)
      |> Enum.filter(fn my_dist -> my_dist > dist end)
      |> Enum.count()
    end)
    |> Enum.reduce(1, fn n, acc -> acc * n end)
  end

  def solve2(input) do
    ["Time: " <> time_str, "Distance: " <> distance_str] =
      input
      |> String.split("\n", trim: true, parts: 2)

    time = String.to_integer(String.replace(time_str, " ", ""))
    distance = String.to_integer(String.replace(distance_str, " ", ""))
    [a, b] = find_win_range([0, time], time, distance)
    searched = b - a + 1

    delta = :math.sqrt(time * time - 4 * (distance + 1))
    calculated = floor((time + delta) / 2.0) - ceil((time - delta) / 2.0) + 1

    ^searched = calculated
  end

  defp find_win_range(range, max_time, min_dist) do
    [from, to] = range
    pivot = from + div(to - from, 2)
    from_res = calc_result(from, max_time)
    pivot_res = calc_result(pivot, max_time)
    to_res = calc_result(to, max_time)

    case [from_res > min_dist, pivot_res > min_dist, to_res > min_dist] do
      [false, false, false] ->
        []

      [false, false, true] ->
        find_win_range([pivot + 1, to], max_time, min_dist)

      [false, true, false] ->
        [
          hd(find_win_range([from, pivot], max_time, min_dist)),
          hd(Enum.reverse(find_win_range([pivot + 1, to], max_time, min_dist)))
        ]

      [false, true, true] ->
        [hd(find_win_range([from, pivot], max_time, min_dist)), to]

      [true, false, false] ->
        find_win_range([from, pivot - 1], max_time, min_dist)

      [true, true, false] ->
        [pivot, hd(Enum.reverse(find_win_range([pivot, to], max_time, min_dist)))]

      [true, true, true] ->
        [from, to]
    end
  end

  defp calc_result(hold_time, max_time) do
    speed = hold_time
    (max_time - hold_time) * speed
  end
end

defmodule Mix.Tasks.Day06 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/06.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day06.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day06.solve2(input))
  end
end
