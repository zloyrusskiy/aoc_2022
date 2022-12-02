defmodule Solution do
  def part1(input) do
    convert_input_to_rps_pairs(input, &choise_fn1/2)
    |> Enum.map(fn {yours, opponent} ->
      calc_choise_score(yours) +
        (calc_result_from_pairs({yours, opponent}) |> get_result_score)
    end)
    |> Enum.sum()
  end

  def part2(input) do
    convert_input_to_rps_pairs(input, &choise_fn2/2)
    |> Enum.map(fn {yours, opponent} ->
      calc_choise_score(yours) +
        (calc_result_from_pairs({yours, opponent}) |> get_result_score)
    end)
    |> Enum.sum()
  end

  defp choise_fn1(yours, _) do
    case(yours) do
      "X" -> :rock
      "Y" -> :paper
      "Z" -> :scissors
    end
  end

  defp choise_fn2(yours, opponent) do
    needed_result = case(yours) do
      "X" -> :lose
      "Y" -> :draw
      "Z" -> :win
    end

    case({needed_result, opponent}) do
      {:win, :rock} -> :paper
      {:win, :paper} -> :scissors
      {:win, :scissors} -> :rock
      {:draw, :rock} -> :rock
      {:draw, :paper} -> :paper
      {:draw, :scissors} -> :scissors
      {:lose, :rock} -> :scissors
      {:lose, :paper} -> :rock
      {:lose, :scissors} -> :paper
    end
  end

  defp calc_choise_score(choise) do
    case choise do
      :rock -> 1
      :paper -> 2
      :scissors -> 3
    end
  end

  defp calc_result_from_pairs({yours, opponent}) do
    case {yours, opponent} do
      {:rock, :scissors} -> :win
      {:scissors, :paper} -> :win
      {:paper, :rock} -> :win
      {:rock, :rock} -> :draw
      {:scissors, :scissors} -> :draw
      {:paper, :paper} -> :draw
      _ -> :lose
    end
  end

  defp get_result_score(result) do
    case result do
      :win -> 6
      :draw -> 3
      :lose -> 0
    end
  end

  defp convert_input_to_rps_pairs(input, choise_fn) do
    input
    |> Enum.map(fn line ->
      [opponent, yours | _] = String.split(line)

      rps_opponent =
        case(opponent) do
          "A" -> :rock
          "B" -> :paper
          "C" -> :scissors
        end

      {choise_fn.(yours, rps_opponent), rps_opponent}
    end)
  end
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
