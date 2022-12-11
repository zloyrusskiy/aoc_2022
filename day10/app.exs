defmodule Command do
  defstruct [:cmd, :cycles]
end

defmodule CPUState do
  defstruct [:cycle, :cur_instr, program: [], register: 1]
end

defmodule Solution do
  def part1(input) do
    parse_program(input)
    |> execute_program()
    |> Stream.drop(20)
    |> Stream.take_every(40)
    |> Stream.map(&(&1.cycle * &1.register))
    |> Enum.sum
  end

  def part2(input) do
    parse_program(input)
    |> execute_program()
    |> Stream.chunk_every(40)
    |> Stream.map(fn states ->
      Enum.map(states, fn state ->
        pos = rem(state.cycle, 40)
        if (pos in (state.register..state.register+2)) do
          "#"
        else
          "."
        end
      end)
      |> Enum.join("")
    end)
    |> Enum.to_list()
  end

  defp execute_program(program) when is_list(program) do
    Stream.unfold(%CPUState{cycle: 0, cur_instr: hd(program), program: tl(program)}, fn
      # end program
      %CPUState{cur_instr: nil, program: []} ->
        nil

      # instr executed
      state = %CPUState{
        cycle: cur_cycle,
        cur_instr: %Command{cmd: cmd, cycles: 0},
        program: [next | rest],
        register: register
      } ->
        new_register =
          case cmd do
            {:noop} -> register
            {:addx, val} -> register + val
          end

        {state, %{state | cycle: cur_cycle + 1, cur_instr: %{next | cycles: next.cycles - 1}, program: rest, register: new_register}}

      # execure last instr
      state = %CPUState{
        cycle: cur_cycle,
        cur_instr: %Command{cmd: cmd, cycles: 0},
        program: [],
        register: register
      } ->
        new_register =
          case cmd do
            {:noop} -> register
            {:addx, val} -> register + val
          end

        {state, %{state | cycle: cur_cycle + 1, cur_instr: nil, program: [], register: new_register}}


      # tick
      state = %CPUState{cycle: cur_cycle, cur_instr: cur_instr = %Command{cycles: cycles_left}} ->
        {state, %{state | cycle: cur_cycle + 1, cur_instr: %{cur_instr | cycles: cycles_left - 1}}}
    end)
  end

  defp parse_program(input) do
    input
    |> Enum.map(fn line ->
      case line do
        "noop" -> %Command{cmd: {:noop}, cycles: 1}
        "addx " <> num_str -> %Command{cmd: {:addx, String.to_integer(num_str)}, cycles: 2}
      end
    end)
  end
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
