defmodule Day17 do
  @top_limit 1_000

  def solve1(input) do
    {map, size} =
      parse(input)

    start = {0, 0, 0, [{-1, -1}], [{{-1, -1}, 0}]}

    [1]
    |> Stream.cycle()
    |> Enum.reduce_while({@top_limit, [start]}, fn _, {min, queue} ->
      new_queue = queue |> Enum.map(fn state -> next_step(state, map, size) end) |> List.flatten()

      {new_min, history, s} =
        new_queue
        |> Enum.reduce({min, nil, nil}, fn {x, y, point, h, s}, acc ->
          {acc_min, _, _} = acc
          if x == size - 1 && y == size - 1, do: {min(point, acc_min), h, s}, else: acc
        end)

      if min != new_min do
        print(history, map, size)
      end

      IO.puts("MIN(#{min} -> #{new_min}) Q(#{length(queue)} -> #{length(new_queue)})")

      signal =
        if new_queue == [] do
          :halt
        else
          :cont
        end

      {signal,
       {new_min,
        new_queue
        |> Enum.sort(fn a, b ->
          {_, _, ap, _, _} = a
          {_, _, bp, _, _} = b

          ap < bp
        end)}}
    end)

    "TODO"
  end

  def solve2(_input) do
    ""
  end

  # {0, 1, 3, {0, 0}, [{{0, 1}, 0}, {{-1, -1}, 0}]}
  def cache_key({x, y, _points, _position_history, last_dir_steps}) do
    {last_dir, steps} = hd(last_dir_steps)

    {x, y, {last_dir, steps}}
  end

  def next_step(state, map, size) do
    {x, y, points, last_pos_hist, last_dir_steps} = state
    last_pos = hd(last_pos_hist)

    if x == size - 1 && y == size - 1 do
      best = Process.get(cache_key(state), @top_limit)
      IO.puts("Record: #{best}, #{points}")
    end

    if Process.get(cache_key(state), @top_limit) >= points do
      [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]
      |> Enum.map(fn dir ->
        {dir_x, dir_y} = dir
        {last_dir, steps} = hd(last_dir_steps)
        cost = map[{x + dir_x, y + dir_y}]
        # IO.puts("{{")
        # IO.inspect(last_dir)
        # IO.inspect(dir)

        n_steps = if last_dir == dir, do: steps + 1, else: 0
        # IO.inspect(n_steps)
        # IO.puts("}}")
        n_last_dir_steps =
          if last_dir == dir,
            do: [{last_dir, n_steps} | tl(last_dir_steps)],
            else: [{dir, 0} | last_dir_steps]

        next_best = points + (cost || @top_limit)

        goes_back = last_dir == {dir_x * -1, dir_y * -1}

        next_state =
          {x + dir_x, y + dir_y, next_best, [{x + dir_x, y + dir_y} | last_pos_hist],
           n_last_dir_steps}

        best = Process.get(cache_key(next_state), @top_limit)

        if cost != nil && n_steps <= 2 && !goes_back && next_best < best do
          Process.put(cache_key(next_state), next_best)
          next_state
        end
      end)
      |> Enum.filter(fn x -> x != nil end)
    else
      []
    end
  end

  def print(history, map, size) do
    0..(size - 1)
    |> Enum.map(fn y ->
      0..(size - 1)
      |> Enum.map(fn x ->
        if Enum.member?(history, {x, y}), do: "*", else: map[{x, y}]
      end)
      |> Enum.join("")
      |> IO.puts()
    end)

    IO.puts("")
  end

  def dist({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp parse(input) do
    lines = input |> String.split("\n")
    size = hd(lines) |> String.length()

    map =
      lines
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, y}, acc ->
        Map.merge(
          acc,
          line
          |> String.split("", trim: true)
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {sym, x}, acc ->
            Map.put(acc, {x, y}, String.to_integer(sym))
          end)
        )
      end)

    {map, size}
  end
end

defmodule Mix.Tasks.Day17 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/17-test1.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day17.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day17.solve2(input))
  end
end
