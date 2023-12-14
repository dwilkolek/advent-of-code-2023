defmodule Day13 do
  @debug false

  def solve1(input) do
    solve(input, 0)
  end

  def solve2(input) do
    solve(input, 1)
  end

  def solve(input, allowed_errors) do
    input
    |> parse()
    |> Enum.map(fn lines ->
      {n_status, n_at} = find_reflection(lines, allowed_errors)
      {t_status, t_at} = find_reflection(transpoze(lines), allowed_errors)

      case {n_status, t_status, n_at < t_at} do
        {:ok, :fail, _} -> n_at * 100
        {:fail, :ok, _} -> t_at
        {:ok, :ok, true} -> n_at * 100
        {:ok, :ok, false} -> t_at
        _ -> throw("missing reflection")
      end
    end)
    |> Enum.sum()
  end

  defp find_reflection(lines, expected_errors) do
    {_width, height} = size(lines)

    print(lines)

    1..(height - 1)
    |> Enum.find_value(fn at ->
      slice = min(at, height - at)

      lines =
        if slice < at do
          Enum.drop(lines, at - slice)
        else
          lines
        end

      {top, bottom} = lines |> Enum.split(slice)
      bottom = Enum.take(bottom, slice)

      top_str = top |> Enum.join("") |> String.split("", trim: true)

      bottom_str =
        bottom
        |> Enum.map(fn l -> String.reverse(l) end)
        |> Enum.join("")
        |> String.reverse()
        |> String.split("", trim: true)

      error_count =
        Enum.zip(top_str, bottom_str)
        |> Enum.map(fn {t, b} -> t == b end)
        |> Enum.filter(fn f -> !f end)
        |> Enum.count()

      if error_count == expected_errors do
        {:ok, at}
      end
    end) || {:fail, -1}
  end

  defp parse(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(fn grid ->
      grid |> String.split("\n", trim: true)
    end)
  end

  defp size(lines) do
    {hd(lines) |> String.length(), length(lines)}
  end

  defp transpoze(lines) do
    new =
      lines
      |> Enum.map(fn l -> String.split(l, "", trim: true) end)
      |> Enum.zip()
      |> Enum.reduce([], fn tup, acc ->
        [Tuple.to_list(tup) |> Enum.reverse() |> Enum.join("") | acc]
      end)
      |> Enum.reverse()

    new
  end

  defp print(lines) do
    if @debug do
      IO.puts("\n")
      lines |> Enum.map(&IO.puts/1)

      IO.puts("\n")
    end

    lines
  end
end

defmodule Mix.Tasks.Day13 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/13.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day13.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day13.solve2(input))
  end
end
