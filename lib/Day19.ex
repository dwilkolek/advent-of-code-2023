defmodule Day19 do
  def solve1(input) do
    {queues, items} = parse(input) |> IO.inspect()

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
    {queues, _} = parse(input) |> IO.inspect()
    # hehe, it will take too long... need to make it on ranges 🙄
    0..4000
    |> Enum.map(fn x ->
      0..4000 |> Enum.each(fn m ->
        IO.puts("#{x}:#{m}")
        0..4000 |> Enum.each(fn a ->
          0..4000 |> Enum.each(fn s ->
            eval_rules(
              %{
              "x" => x,
              "m" => m,
              "a" => a,
              "s" => s
            }, "in", queues)
          end)
        end)
      end)
    end)
    |> List.flatten()
    |> Enum.filter(& &1)
    |> Enum.map(fn item ->
      Map.get(item, "x") + Map.get(item, "m") + Map.get(item, "a") + Map.get(item, "s")
    end)
    |> Enum.sum()
  end

  def eval_rules(item, label, queues) do
    target = queues[label]
    |> Enum.find_value(fn rule ->
      # {type, prop, comp, value, target} = rule
      # IO.inspect(rule)

      case rule do
        {:noop, target} ->
          target

        {:eval, prop, ">", value, target} ->
          # IO.puts("> #{Map.get(item, prop)}, #{value} --> #{target}")
          if Map.get(item, prop) > value do
            target
          end

        {:eval, prop, "<", value, target} ->
          # IO.puts("< #{Map.get(item, prop)}, #{value} --> #{target}")
          if Map.get(item, prop) < value do
            target
          end

        _ ->
          # IO.puts("????")
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
      IO.inspect(qdef)
      [label, rules_str] = qdef |> String.replace_suffix("}", "") |> String.split("{")

      rules =
        rules_str
        |> String.split(",", trim: true)
        |> Enum.map(fn rs ->
          if String.split(rs, ":") |> length() == 1 do
            {:noop, rs}
          else
            [<<param, operator, rem::binary>>, target_label] = rs |> String.split(":")
            {:eval, List.to_string([param]), List.to_string([operator]), String.to_integer(rem), List.to_string([target_label])}
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
