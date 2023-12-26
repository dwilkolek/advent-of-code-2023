defmodule Day22 do
  def solve1(input) do
    bricks = parse(input)
    bricks = bricks |> settle(false)

    bricks
    |> Parallel.pmap(fn brick ->
      other = bricks |> Enum.filter(fn x -> x != brick end)
      new_order = settle(other, true)

      if other != new_order do
        0
      else
        1
      end
    end)
    |> Enum.sum()
  end

  def solve2(input) do
    bricks = parse(input)
    bricks = bricks |> settle(false)

    bricks
    |> Parallel.pmap(fn brick ->
      other = bricks |> Enum.filter(fn x -> x != brick end)
      new_order = settle(other, true)
      Enum.zip(other, new_order) |> Enum.filter(fn {a, b} -> a != b end) |> Enum.count()
    end)
    |> Enum.sum()
  end

  def settle(bricks, failfast) do
    z_max =
      bricks
      |> Enum.reduce(0, fn {_, _, {z1, z2}}, acc ->
        max(acc, max(z1, z2))
      end)

    new_bricks = 1..z_max
    |> Enum.reduce([], fn pz, acc ->
      Enum.filter(bricks, fn {_, _, {z1, z2}} -> min(z1, z2) == pz end)
      |> Enum.reduce(acc, fn brick, acc ->
        acc ++ [move_down(brick, acc)]
      end)
    end)
    if (failfast == true) do
      new_bricks
    else
      if bricks != new_bricks do
        settle(new_bricks, failfast)
      else
        new_bricks
      end
    end

  end


  def move_down({{x1, x2}, {y1, y2}, {z1, z2}}, stack) do
    minz =
      x1..x2
      |> Enum.map(fn x ->
        y1..y2
        |> Enum.map(fn y ->
          stack =
            stack
            |> Enum.filter(fn {{bx1, bx2}, {by1, by2}, {bz1, bz2}} ->
              Enum.member?(bx1..bx2, x) && Enum.member?(by1..by2, y) &&
                max(bz1, bz2) < min(z1, z2)
            end)
            |> Enum.map(fn {_, _, {bz1, bz2}} ->
              max(bz1, bz2)
            end)

          if stack == [], do: 1, else: 1 + (stack |> Enum.max())
        end)
      end)
      |> List.flatten()
      |> Enum.max()

    diff = min(z1, z2) - minz
    {{x1, x2}, {y1, y2}, {z1 - diff, z2 - diff}}
  end

  # def surface({{x1, x2}, {y1, y2}, {z1, z2}}, bottom) do
  #   if bottom do
  #     {{x1, x2}, {y1, y2}, {min(z1, z2), min(z1, z2)}}
  #   else
  #     {{x1, x2}, {y1, y2}, {max(z1, z2), max(z1, z2)}}
  #   end
  # end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn l ->
      [start_block, end_block] = l |> String.split("~")

      [xs, ys, zs] =
        start_block |> String.split(",") |> Enum.map(fn x -> String.to_integer(x) end)

      [xe, ye, ze] =
        end_block |> String.split(",") |> Enum.map(fn x -> String.to_integer(x) end)

      {{xs, xe}, {ys, ye}, {zs, ze}}
    end)
    |> Enum.sort(fn {_, _, {z1, _}}, {_, _, {z2, _}} -> z1 < z2 end)
  end
end

defmodule Mix.Tasks.Day22 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/22.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day22.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day22.solve2(input))
  end
end
