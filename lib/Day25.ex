defmodule Parallel do
  def pmap(collection, func) do
    collection
    |> Enum.map(&Task.async(fn -> func.(&1) end))
    |> Enum.map(fn task -> Task.await(task, 100_000_00) end)
  end
end

defmodule Day25 do
  def solve1(input) do
    connections = parse(input)

    unique =
      connections
      |> Enum.reduce([], fn {a, b}, acc -> [a | [b | acc]] end)
      |> Enum.uniq()
      |> Enum.shuffle()

    connections_map =
      unique
      |> Enum.reduce(%{}, fn n, acc ->
        Map.put(
          acc,
          n,
          Enum.filter(connections, fn {a, b} -> a == n || b == n end)
          |> Enum.reduce([], fn {a, b}, acc ->
            if a == n do
              [b | acc]
            else
              [a | acc]
            end
          end)
        )
      end)

    # |> IO.inspect()

    conns = select_connections(unique, [], connections_map)

    leftover = Enum.filter(connections, fn c -> !Enum.member?(conns, c) end)

    {node, _} = hd(leftover)
    {groupped1, leftover} = calculate_group_size(node, leftover, [node])

    {node, _} = hd(leftover)
    {groupped2, _} = calculate_group_size(node, leftover, [node])

    length(groupped1) * length(groupped2)
  end

  def select_connections(a, b, connections_map) do
    node_to_b_neighbours =
      a
      |> Enum.map(fn node ->
        {node, length(connections_map[node] |> Enum.filter(fn on -> Enum.member?(b, on) end))}
      end)
      |> Enum.sort_by(fn {_, c} -> c end, :desc)

    connections_between_a_and_b =
      Enum.reduce(node_to_b_neighbours, 0, fn {_n, c}, acc ->
        acc + c
      end)

    # IO.inspect(a, label: "A")
    # IO.inspect(b, label: "B")

    # IO.puts(
    #   "Connection count betweeen a=#{length(a)}, b=#{length(b)} is #{connections_between_a_and_b}"
    # )

    if connections_between_a_and_b == 3 do
      a
      |> Enum.map(fn node ->
        connections_map[node]
        |> Enum.map(fn on -> if Enum.member?(b, on), do: [{node, on}, {on, node}], else: nil end)
      end)
      |> List.flatten()
      |> Enum.filter(fn x -> x end)
      |> Enum.uniq()
    else
      {n, _} = hd(node_to_b_neighbours)
      # IO.inspect(n, label: "Selected #{n}")
      select_connections(List.delete(a, n), [n | b], connections_map)
    end
  end

  def solve2(_input) do
    "Push the big red button"
  end

  def calculate_group_size(node, connections, matched) do
    splitted =
      connections
      |> Enum.group_by(
        fn a ->
          {a1, a2} = a

          cond do
            a1 == node -> :match
            a2 == node -> :match
            true -> :nomatch
          end
        end,
        fn a -> a end
      )

    match = Map.get(splitted, :match, [])
    nomatch = Map.get(splitted, :nomatch, [])

    new_matched =
      match
      |> Enum.filter(fn {a, b} ->
        other =
          if a == node do
            b
          else
            a
          end

        if Enum.member?(matched, other), do: false, else: true
      end)
      |> Enum.map(fn {a, b} ->
        if a == node do
          b
        else
          a
        end
      end)

    if match == [] do
      {matched, nomatch}
    else
      new_matched
      |> Enum.reduce({matched ++ new_matched, nomatch}, fn tag, {matched, nomatch} ->
        calculate_group_size(tag, nomatch, matched)
      end)
    end
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.reduce([], fn line, acc ->
      # jqt: rhn xhk nvd
      [from, to_list] = line |> String.split(": ")
      to = to_list |> String.split(" ")
      (to |> Enum.map(fn t -> {from, t} end)) ++ acc
    end)
  end
end

defmodule Mix.Tasks.Day25 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/25.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day25.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day25.solve2(input))
  end
end
