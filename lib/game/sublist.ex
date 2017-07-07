# credit goes to https://github.com/alxndr/exercism/blob/master/elixir/sublist/sublist.exs
defmodule Sublist do

  def sublist_of?([], _), do: true
  def sublist_of?(_, []), do: false
  def sublist_of?(first, second) when length(first) > length(second), do: false
  def sublist_of?(first, second=[_|second_tail]) do
    if at_head_of?(first, second) do
      true
    else
      sublist_of?(first, second_tail)
    end
  end

  defp at_head_of?([], _), do: true
  defp at_head_of?([a|first_tail], [a|second_tail]) do
    first_tail
    |> at_head_of?(second_tail)
  end
  defp at_head_of?(_, _), do: false
end
