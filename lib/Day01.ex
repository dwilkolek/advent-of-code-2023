defmodule Day01 do
  def solve1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&find_calibration_value/1)
    |> Enum.sum()
  end

  def solve2(input) do
    input
    |> replace_text_numbers()
    |> String.split("\n", trim: true)
    |> Enum.map(&find_calibration_value/1)
    |> Enum.sum()
  end

  def replace_text_numbers(input) do
    input
    |> String.replace("one", "one1one")
    |> String.replace("two", "two2two")
    |> String.replace("three", "three3three")
    |> String.replace("four", "four4four")
    |> String.replace("five", "five5five")
    |> String.replace("six", "six6six")
    |> String.replace("seven", "seven7seven")
    |> String.replace("eight", "eight8eight")
    |> String.replace("nine", "nine9nine")
  end

  def find_calibration_value(sub_input) do
    sub_input
    |> String.replace(~r/[^0-9]/, "")
    |> (fn input -> String.at(input, 0) <> String.at(input, -1) end).()
    |> String.to_integer()
  end
end

defmodule Mix.Tasks.Day01 do
  use Mix.Task

  def run(_) do
    {:ok, input} = File.read("inputs/01.txt")
    IO.puts("--- Part 1 ---")
    IO.puts(Day01.solve1(input))
    IO.puts("")
    IO.puts("--- Part 2 ---")
    IO.puts(Day01.solve2(input))
  end
end
