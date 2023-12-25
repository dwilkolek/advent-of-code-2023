defmodule Day19 do
  def solve1(input) do
    {queues, items} = parse(input)
    items
    |> Enum.map(fn item ->
      eval_rules(item, "in", queues)
    end)
    |> Enum.filter(& &1)
    |> Enum.map(fn item ->
      Map.get(item, "x") + Map.get(item, "m") + Map.get(item, "a") + Map.get(item, "s")
    end)
    |> Enum.sum()
  end

  def solve2(input) do
    {queues, _} = parse(input)

    eval_rules2(
      {%{
         "x" => 1..4000,
         "m" => 1..4000,
         "a" => 1..4000,
         "s" => 1..4000
       }, "in"},
      queues,
      []
    )
    |> Enum.map(fn m ->
      Enum.count(m["x"]) * Enum.count(m["m"]) * Enum.count(m["a"]) * Enum.count(m["s"])
    end)
    |> Enum.sum()
  end

  def eval_rules2({item, label}, queues, done) do
    {queue, left} =
      queues[label]
      |> List.foldl({[], {item, label}}, fn rule, {processed, left} ->
        if left do
          {item, label} = left

          case rule do
            {:noop, target} ->
              {[{item, target} | processed], nil}

            {:eval, prop, ">", value, target} ->
              index = Enum.find_index(Map.get(item, prop), fn x -> x === value + 1 end)

              if index do
                {a, b} = Range.split(Map.get(item, prop), index)

                {[{Map.put(item, prop, b), target} | processed], {Map.put(item, prop, a), label}}
              else
                _first..last//_ = Map.get(item, prop)

                if last > value do
                  {[{item, target} | processed], nil}
                else
                  {processed, {item, label}}
                end
              end

            {:eval, prop, "<", value, target} ->
              index = Enum.find_index(Map.get(item, prop), fn x -> x === value end)

              if index do
                {a, b} = Range.split(Map.get(item, prop), index)

                {[{Map.put(item, prop, a), target} | processed], {Map.put(item, prop, b), label}}
              else
                _first..last//_ = Map.get(item, prop)

                if last < value do
                  {[{item, target} | processed], nil}
                else
                  {processed, {item, label}}
                end
              end
          end
        else
          {processed, nil}
        end
      end)

    if left != nil do
      IO.inspect(left)
      throw("oops")
    end

    queue
    # |> IO.inspect()
    |> Enum.filter(fn {m, _} ->
      Range.to_list(m["x"]) != [] && Range.to_list(m["m"]) != [] && Range.to_list(m["a"]) != [] &&
        Range.to_list(m["s"]) != []
    end)
    |> Enum.reduce(done, fn {item, label}, done ->
      case label do
        "A" -> [item | done]
        "R" -> done
        _ -> eval_rules2({item, label}, queues, done)
      end
    end)
  end

  def eval_rules(item, label, queues) do
    target =
      queues[label]
      |> Enum.find_value(fn rule ->
        case rule do
          {:noop, target} ->
            target

          {:eval, prop, ">", value, target} ->
            if Map.get(item, prop) > value do
              target
            end

          {:eval, prop, "<", value, target} ->
            if Map.get(item, prop) < value do
              target
            end

          _ ->
            nil
        end
      end)

    case target do
      "A" -> item
      "R" -> nil
      _ -> eval_rules(item, target, queues)
    end
  end

  def parse(input) do
    [queues, items] = input |> String.split("\n\n")
    {queues |> parse_queues(), items |> parse_items()}
  end

  def parse_items(items) do
    items
    |> String.split("\n")
    |> Enum.map(fn item ->
      [x, m, a, s] = Regex.scan(~r/[0-9]+/, item) |> List.flatten()

      %{
        "x" => String.to_integer(x),
        "m" => String.to_integer(m),
        "a" => String.to_integer(a),
        "s" => String.to_integer(s)
      }
    end)
  end

  def parse_queues(queues) do
    queues
    |> String.split("\n")
    |> Enum.map(fn qdef ->
      [label, rules_str] = qdef |> String.replace_suffix("}", "") |> String.split("{")

      rules =
        rules_str
        |> String.split(",", trim: true)
        |> Enum.map(fn rs ->
          if String.split(rs, ":") |> length() == 1 do
            {:noop, rs}
          else
            [<<param, operator, rem::binary>>, target_label] = rs |> String.split(":")

            {:eval, List.to_string([param]), List.to_string([operator]), String.to_integer(rem),
             List.to_string([target_label])}
          end
        end)

      {label, rules}
    end)
    |> Enum.reduce(%{}, fn {label, rules}, acc ->
      Map.put(acc, label, rules)
    end)
  end
end

defmodule Mix.Tasks.Day19 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/19.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day19.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day19.solve2(input))
  end
end
