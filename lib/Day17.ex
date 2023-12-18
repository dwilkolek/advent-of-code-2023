defmodule Day17 do
  @top_limit 1_000_000
  @debug false

  def solve1(input) do
    solve(input, 1, 3)
  end

  def solve2(input) do
    solve(input, 4, 10)
  end

  def solve(input, min_step, max_step) do
    if @debug do
      Process.put("VALID_RECORD", @top_limit)
    end

    {map, {size_x, size_y}} =
      parse(input)

    start = {0, 0, 0, [{-1, -1}], [{{-1, -1}, 0}]}
    IO.puts("PARAMS: #{min_step} : #{max_step}")

    {min, _} =
      [1]
      |> Stream.cycle()
      |> Enum.reduce_while({@top_limit, [start]}, fn _, {min, queue} ->
        new_queue =
          queue
          |> Enum.map(fn state -> next_step(state, map, {size_x, size_y}, min_step, max_step) end)
          |> List.flatten()

        {new_min, _history, _s} =
          new_queue
          |> Enum.reduce({min, nil, nil}, fn {x, y, point, h, s}, acc ->
            {acc_min, _, _} = acc
            if x == size_x - 1 && y == size_y - 1, do: {min(point, acc_min), h, s}, else: acc
          end)

        if @debug do
          IO.puts("MIN(#{min} -> #{new_min}) Q(#{length(queue)} -> #{length(new_queue)})")
        end

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

    if @debug do
      Process.get("VALID_RECORD")
    end

    min
  end

  def cache_key({x, y, _points, _position_history, last_dir_steps}, min_steps, max_steps) do
    {last_dir, steps} = hd(last_dir_steps)

    {min_steps, max_steps, x, y, {last_dir, steps}}
  end

  def next_step(state, map, {size_x, size_y}, min_steps, max_steps) do
    {x, y, points, last_pos_hist, last_dir_steps} = state

    if @debug do
      IO.puts("PROCESSING {#{x}, #{y}}")
      print(last_pos_hist, map, {size_x, size_y}, {x, y})
    end

    {last_dir, steps} = hd(last_dir_steps)

    result =
      if Process.get(cache_key(state, min_steps, max_steps), @top_limit) >= points do
        possible_moves =
          if(steps <= min_steps - 1 && last_dir != {-1, -1},
            do: [last_dir],
            else: [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]
          )

        possible_moves
        |> Enum.map(fn dir ->
          {dir_x, dir_y} = dir
          cost = map[{x + dir_x, y + dir_y}]

          n_steps = if last_dir == dir, do: steps + 1, else: 1

          n_last_dir_steps =
            if last_dir == dir,
              do: [{last_dir, n_steps} | tl(last_dir_steps)],
              else: [{dir, n_steps} | last_dir_steps]

          next_best = points + (cost || @top_limit)

          goes_back = last_dir == {dir_x * -1, dir_y * -1}

          next_state =
            {x + dir_x, y + dir_y, next_best, [{x + dir_x, y + dir_y} | last_pos_hist],
             n_last_dir_steps}

          best = Process.get(cache_key(next_state, min_steps, max_steps), @top_limit)

          is_dest = {x + dir_x, y + dir_y} == {size_x - 1, size_y - 1}
          is_dest_min_step_req = n_steps >= min_steps
          isok = if is_dest, do: is_dest_min_step_req, else: true

          if @debug do
            if is_dest do
              if @debug do
                IO.puts(
                  "RECORD ns=#{n_steps} min=#{min_steps} req=#{is_dest_min_step_req} -> #{next_best}"
                )
              end

              if is_dest_min_step_req do
                if next_best < Process.get("VALID_RECORD", @top_limit) do
                  Process.put("VALID_RECORD", next_best)

                  if @debug do
                    IO.puts("<<RECORD>>")
                    print(last_pos_hist, map, {size_x, size_y}, {x + dir_x, y + dir_y})

                    IO.puts(
                      "VALID_RECORD ns=#{n_steps} min=#{min_steps} req=#{is_dest_min_step_req} -> #{next_best}"
                    )
                  end
                end
              end
            end
          end

          if cost != nil && n_steps <= max_steps && !goes_back && next_best < best && isok do
            Process.put(cache_key(next_state, min_steps, max_steps), next_best)

            if @debug do
              IO.puts(
                "OK: #{cost} & #{n_steps < max_steps} & #{!goes_back} & #{next_best < best}"
              )

              IO.inspect(possible_moves)
              print(last_pos_hist, map, {size_x, size_y}, {x + dir_x, y + dir_y})
              IO.puts("------------------")
            end

            next_state
          else
            if @debug do
              IO.puts(
                "FAILURE: #{cost} & #{n_steps < max_steps} & #{!goes_back} & (#{next_best} < #{best} = #{next_best < best})"
              )

              IO.inspect(possible_moves)

              # {x, y, points, last_pos_hist, last_dir_steps}
              print(last_pos_hist, map, {size_x, size_y}, {x + dir_x, y + dir_y})
              IO.puts("------------------")
            end

            nil
          end
        end)
        |> Enum.filter(fn x -> x != nil end)
      else
        if @debug do
          IO.puts("FAILURE FRONT CACHE")

          print(last_pos_hist, map, {size_x, size_y}, {x, y})
          IO.puts("------------------")
        end

        []
      end

    if @debug do
      IO.puts("RESULTS: ")

      result
      |> Enum.map(fn res ->
        {x, y, _points, last_pos_hist, _last_dir_steps} = res
        print(last_pos_hist, map, {size_x, size_y}, {x, y})
      end)

      IO.puts("------------------")
    end

    result
  end

  def print(history, map, size) do
    print(history, map, size, {-1, -1})
  end

  def print(history, map, {size_x, size_y}, special) do
    0..(size_y - 1)
    |> Enum.map(fn y ->
      0..(size_x - 1)
      |> Enum.map(fn x ->
        cond do
          special == {x, y} -> "?"
          Enum.member?(history, {x, y}) -> "#"
          true -> map[{x, y}]
        end
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
    x_size = hd(lines) |> String.length()
    y_size = length(lines)

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

    {map, {x_size, y_size}}
  end
end

defmodule Mix.Tasks.Day17 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/17.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day17.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day17.solve2(input))
  end
end
