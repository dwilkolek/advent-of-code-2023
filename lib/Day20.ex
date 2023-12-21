defmodule Day20 do
  def solve1(input) do
    wiring = wire_up(input)

    {l, h, _, _} =
      1..1000
      |> Enum.reduce({0, 0, [], wiring}, fn i, {l, h, c, wiring} ->
        process_signal({"button", "broadcaster", false}, wiring, [], {l, h, c}, nil, i)
      end)

    IO.puts("Low: #{l}, High: #{h}")

    l * h
  end

  def solve2(input) do
    wiring = wire_up(input)

    [rxparent] =
      wiring
      |> Enum.filter(fn {_label, {_type, targets, _}} ->
        Enum.member?(targets, "rx")
      end)
      |> Enum.map(fn {label, _} ->
        label
      end)

    clockers =
      wiring
      |> Enum.filter(fn {_label, {_type, targets, _}} ->
        Enum.member?(targets, rxparent)
      end)
      |> Enum.map(fn {label, _} ->
        label
      end)

    clockers
    |> Enum.map(fn clock ->
      {_, _, _, btn_press_count} =
        [1]
        |> Stream.cycle()
        |> Enum.reduce_while({0, 0, [], wiring, 1}, fn _, {l, h, c, wiring, button_press_count} ->
          {l, h, nc, wiring} =
            process_signal(
              {"button", "broadcaster", false},
              wiring,
              [],
              {l, h, c},
              clock,
              button_press_count
            )

          c =
            if length(nc) > length(c) do
              [button_press_count | tl(nc)]
            else
              nc
            end

          if length(c) > 5 do
            [a, b | _] = c
            {:halt, {l, h, wiring, a - b}}
          else
            {:cont, {l, h, c, wiring, button_press_count + 1}}
          end
        end)

      IO.puts("Clock: #{clock} :: #{btn_press_count}")
      btn_press_count
    end)
    |> IO.inspect()
    |> Enum.reduce(1, fn x, acc -> lcm(x, acc) end)

    # ""
    # btn_press_count
  end

  def gcd(a, 0), do: abs(a)
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(a, b), do: div(abs(a * b), gcd(a, b))

  def wire_up(input) do
    wiring =
      input
      |> String.split("\n")
      |> Enum.map(fn l ->
        [label, targets] = l |> String.split(" -> ")
        targets = targets |> String.split(", ", trim: true)

        case label do
          "broadcaster" -> {label, {:bc, targets, nil}}
          <<"%", rem::binary>> -> {rem, {:ff, targets, false}}
          <<"&", rem::binary>> -> {rem, {:inv, targets, %{}}}
        end
      end)
      |> Enum.reduce(%{}, fn {label, {type, targets, signal}}, acc ->
        Map.put(acc, label, {type, targets, signal})
      end)

    wiring
    |> Enum.reduce(%{}, fn {label, definition}, acc ->
      definition =
        case definition do
          {:inv, targets, _} ->
            {:inv, targets,
             wiring
             |> Enum.filter(fn {_, {_, targets, _}} -> Enum.member?(targets, label) end)
             |> Enum.reduce(%{}, fn {l, _}, a -> Map.put(a, l, false) end)}

          # |> IO.inspect()

          p ->
            p
        end

      Map.put(acc, label, definition)
    end)

    # |> IO.inspect()
  end

  def process_signal(
        {from, to, signal},
        wiring,
        queue,
        {low_clounter, high_counter, clock_intervals},
        clock,
        btn_press_count
      ) do
    counter =
      if signal,
        do: {low_clounter, high_counter + 1, clock_intervals},
        else: {low_clounter + 1, high_counter, clock_intervals}

    # IO.inspect("Processing #{from} --#{signal}--> #{to}")
    # IO.inspect("wire: ")
    to_wire = wiring[to]

    {wiring, new_in_queue, clocked} =
      case to_wire do
        {:bc, targets, _state} ->
          {wiring, targets |> Enum.map(fn t -> {to, t, signal} end), false}

        {:ff, targets, state} ->
          if signal == false do
            {Map.put(wiring, to, {:ff, targets, !state}),
             targets |> Enum.map(fn x -> {to, x, !state} end), false}
          else
            {wiring, [], false}
          end

        {:inv, targets, state} ->
          state = Map.put(state, from, signal)
          emit_signal = state |> Enum.all?(fn {_, sig} -> sig == true end) == false

          {Map.put(wiring, to, {:inv, targets, state}),
           targets |> Enum.map(fn x -> {to, x, emit_signal} end), emit_signal && clock == to}

        nil ->
          {wiring, [], false}
      end

    counter =
      if clocked do
        {low_clounter, high_counter, clock_intervals} = counter
        {low_clounter, high_counter, [btn_press_count | clock_intervals]}
      else
        counter
      end

    queue = queue ++ new_in_queue

    if queue == [] do
      # IO.inspect(counter)
      {l, h, c} = counter
      {l, h, c, wiring}
    else
      [top | tail] = queue
      process_signal(top, wiring, tail, counter, clock, btn_press_count)
    end
  end
end

defmodule Mix.Tasks.Day20 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/20.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day20.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day20.solve2(input))
  end
end
