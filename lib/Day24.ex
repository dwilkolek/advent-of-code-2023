defmodule Day24 do
  @min 200_000_000_000_000
  @max 400_000_000_000_000

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
      case m do
        nil ->
          false

        {x, y, {{xa, ya, _, xad, yad, _}, {xb, yb, _, xbd, ybd, _}}} ->
          a_in_right_dir_y = if yad >= 0, do: y >= ya, else: y <= ya
          b_in_right_dir_y = if ybd >= 0, do: y >= yb, else: y <= yb
          a_in_right_dir_x = if xad >= 0, do: x >= xa, else: x <= xa
          b_in_right_dir_x = if xbd >= 0, do: x >= xb, else: x <= xb
          in_area = x >= @min && x <= @max && y >= @min && y <= @max

          in_area && b_in_right_dir_x && a_in_right_dir_y && b_in_right_dir_y && a_in_right_dir_x
      end
    end)
    |> Enum.count()
  end

  def solve2(input) do
    mat =
      parse(input)

    {px0, py0, pz0, vx0, vy0, vz0} = Enum.at(mat, 0)
    {px1, py1, pz1, vx1, vy1, vz1} = Enum.at(mat, 1)
    {px2, py2, _, vx2, vy2, _} = Enum.at(mat, 2)
    {px3, py3, _, vx3, vy3, _} = Enum.at(mat, 3)
    {px4, py4, _, vx4, vy4, _} = Enum.at(mat, 4)
    {px5, py5, _, vx5, vy5, _} = Enum.at(mat, 5)
    {px6, py6, _, vx6, vy6, _} = Enum.at(mat, 6)
    {px7, py7, _, vx7, vy7, _} = Enum.at(mat, 7)

    a = [
      vy0 - vy1,
      vx1 - vx0,
      py1 - py0,
      px0 - px1,
      vy2 - vy3,
      vx3 - vx2,
      py3 - py2,
      px2 - px3,
      vy4 - vy5,
      vx5 - vx4,
      py5 - py4,
      px4 - px5,
      vy6 - vy7,
      vx7 - vx6,
      py7 - py6,
      px6 - px7
    ]

    b = [
      px0 * vy0 - py0 * vx0 + py1 * vx1 - px1 * vy1,
      px2 * vy2 - py2 * vx2 + py3 * vx3 - px3 * vy3,
      px4 * vy4 - py4 * vx4 + py5 * vx5 - px5 * vy5,
      px6 * vy6 - py6 * vx6 + py7 * vx7 - px7 * vy7
    ]

    den = det4x4(a)

    pxr =
      det4x4([
        Enum.at(b, 0),
        Enum.at(a, 1),
        Enum.at(a, 2),
        Enum.at(a, 3),
        Enum.at(b, 1),
        Enum.at(a, 5),
        Enum.at(a, 6),
        Enum.at(a, 7),
        Enum.at(b, 2),
        Enum.at(a, 9),
        Enum.at(a, 10),
        Enum.at(a, 11),
        Enum.at(b, 3),
        Enum.at(a, 13),
        Enum.at(a, 14),
        Enum.at(a, 15)
      ]) / den

    pyr =
      det4x4([
        Enum.at(a, 0),
        Enum.at(b, 0),
        Enum.at(a, 2),
        Enum.at(a, 3),
        Enum.at(a, 4),
        Enum.at(b, 1),
        Enum.at(a, 6),
        Enum.at(a, 7),
        Enum.at(a, 8),
        Enum.at(b, 2),
        Enum.at(a, 10),
        Enum.at(a, 11),
        Enum.at(a, 12),
        Enum.at(b, 3),
        Enum.at(a, 14),
        Enum.at(a, 15)
      ]) / den

    vxr =
      det4x4([
        Enum.at(a, 0),
        Enum.at(a, 1),
        Enum.at(b, 0),
        Enum.at(a, 3),
        Enum.at(a, 4),
        Enum.at(a, 5),
        Enum.at(b, 1),
        Enum.at(a, 7),
        Enum.at(a, 8),
        Enum.at(a, 9),
        Enum.at(b, 2),
        Enum.at(a, 11),
        Enum.at(a, 12),
        Enum.at(a, 13),
        Enum.at(b, 3),
        Enum.at(a, 15)
      ]) / den

    t0 = (pxr - px0) / (vx0 - vxr)
    t1 = (pxr - px1) / (vx1 - vxr)
    vzr = (pz0 - pz1 + t0 * vz0 - t1 * vz1) / (t0 - t1)
    pzr = pz0 + t0 * (vz0 - vzr)

    pxr + pyr + pzr
  end

  def det3x3(m) do
    [m0, m1, m2, m3, m4, m5, m6, m7, m8] = m

    m0 * m4 * m8 + m1 * m5 * m6 + m2 * m3 * m7 -
      m0 * m5 * m7 - m1 * m3 * m8 - m2 * m4 * m6
  end

  def det4x4(m) do
    [m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15] = m

    m0 * det3x3([m5, m6, m7, m9, m10, m11, m13, m14, m15]) -
      m1 * det3x3([m4, m6, m7, m8, m10, m11, m12, m14, m15]) +
      m2 * det3x3([m4, m5, m7, m8, m9, m11, m12, m13, m15]) -
      m3 * det3x3([m4, m5, m6, m8, m9, m10, m12, m13, m14])
  end

  def cross_at(a, b) do
    {xa, ya, ea, oa} = a
    {xb, yb, eb, ob} = b

    det = xa * yb - xb * ya

    if det != 0 do
      adt =
        [
          [yb / det, -1 * ya / det],
          [-1 * xb / det, xa / det]
        ]

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
