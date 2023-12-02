defmodule Day02 do
  @max_red 12
  @max_green 13
  @max_blue 14

  def solve1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&get_game_id_if_possible/1)
    |> Enum.sum()
  end

  def solve2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&get_game_power/1)
    |> Enum.sum()
  end

  def get_game_id_if_possible(game) do
    [game, cubes] = String.split(game, ": ", trim: true)

    game_id =
      game
      |> String.replace_prefix("Game ", "")
      |> String.to_integer()

    is_valid =
      String.split(cubes, "; ", trim: true)
      |> Enum.map(&single_game_set/1)
      |> Enum.all?(fn cubes ->
        cubes.r <= @max_red and cubes.g <= @max_green and cubes.b <= @max_blue
      end)

    if is_valid do
      game_id
    else
      0
    end
  end

  def get_game_power(game) do
    [_, cubes] = String.split(game, ": ", trim: true)

    cubes
      |> String.split("; ", trim: true)
      |> Enum.map(&single_game_set/1)
      |> Enum.reduce(%{r: 0, g: 0, b: 0}, fn x, acc ->
        %{r: max(acc.r, x.r), g: max(acc.g, x.g), b: max(acc.b, x.b)}
      end)
      |> (fn x -> x.r * x.g * x.b end).()
  end

  def single_game_set(set_str) do
    set_str
    |> String.split(", ", trim: true)
    |> Enum.map(fn x ->
      {count, color} = Integer.parse(x)

      cond do
        color == " red" ->
          %{r: count, g: 0, b: 0}

        color == " green" ->
          %{r: 0, g: count, b: 0}

        color == " blue" ->
          %{r: 0, g: 0, b: count}
      end
    end)
    |> Enum.reduce(%{r: 0, g: 0, b: 0}, fn x, acc ->
      %{r: acc.r + x.r, g: acc.g + x.g, b: acc.b + x.b}
    end)
  end
end

defmodule Mix.Tasks.Day02 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/02.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day02.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day02.solve2(input))
  end
end
