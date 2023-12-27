defmodule Day24 do
  def solve1(input) do
    mat =
      parse(input)
      |> Enum.map(fn o ->
        {x, y, _, dx, dy, _} = o
        b = -1 * (dy / dx * x - y)
        {dy / dx, -1, b, o}
      end)

    mat
    |> Enum.with_index()
    |> Enum.map(fn {a, ai} ->
      rest = mat |> Enum.drop(ai + 1)

      Enum.map(rest, fn b ->
        cross_at(a, b)
      end)
    end)
    |> List.flatten()
    |> Enum.filter(fn m ->
      min = 200000000000000
      max = 400000000000000
      # IO.inspect(m)


      case m do
        nil -> false
        {x, y, {{xa, ya, _, xad, yad, _}, {xb, yb, _, xbd, ybd, _}}} ->
          a_in_right_dir_y = if yad >= 0, do: y >= ya, else: y <= ya
          b_in_right_dir_y = if ybd >= 0, do: y >= yb, else: y <= yb
          a_in_right_dir_x = if xad >= 0, do: x >= xa, else: x <= xa
          b_in_right_dir_x = if xbd >= 0, do: x >= xb, else: x <= xb
          in_area = x >= min && x <= max && y >= min && y <= max
          # IO.puts("Reason: #{in_area}, #{a_in_right_dir_y}, #{b_in_right_dir_y}, #{a_in_right_dir_x}, #{b_in_right_dir_x}")
          in_area && b_in_right_dir_x && a_in_right_dir_y && b_in_right_dir_y && a_in_right_dir_x
      end
    end)
    # |> IO.inspect()
    |> Enum.count()
  end

  def solve2(_input) do
  end

  def cross_at(a, b) do
    {xa, ya, ea, oa} = a
    {xb, yb, eb, ob} = b
    # IO.puts("Cross of")
    # IO.inspect(a)
    # IO.inspect(b)

    det = xa * yb - xb * ya

    if det != 0 do
      adt =
        [
          [yb / det, -1 * ya / det],
          [-1 * xb / det, xa / det]
        ]

      # IO.puts("adt=")
      # IO.inspect(adt)

      b = [ea, eb]

      [x, y] =
        adt
        |> Enum.map(fn row ->
          Enum.zip(row, b) |> Enum.map(fn {a, b} -> a * b end) |> Enum.sum()
        end)

      {-1 * x, -1 * y, {oa, ob}}
    else
      nil
    end
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      [p, d] = line |> String.split(" @ ")

      [x, y, z] = p |> String.split(", ") |> Enum.map(fn x -> String.to_integer(x) end)

      [dx, dy, dz] =
        d |> String.split(", ") |> Enum.map(fn x -> String.to_integer(x |> String.trim()) end)

      {x, y, z, dx, dy, dz}
    end)
  end
end

defmodule Mix.Tasks.Day24 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/24.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day24.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day24.solve2(input))
  end
end
