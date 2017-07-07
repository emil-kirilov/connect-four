defmodule ConnectFour.Game.Board do
  use Tensor

  def build_board() do
    Matrix.new(10,10)
  end

  def drop_coin(board, player, column) when is_integer(column) do
    max_column = Matrix.width(board) - 1
    cond do
      column < 0 || column > max_column ->
        IO.puts "The selected column (#{inspect(column)}) is not valid! Select form the range [0,#{max_column}]"
        board
      true ->
        Matrix.columns(board) |>
        Enum.at(column) |>
        update_column(player) |>
        update_board(board, column)
    end
  end


  def drop_coin(_board, _player, column) do
    error = "unexpected column number, received: (#{inspect(column)})"
    raise ArgumentError, error
  end

  # Callbacks

  # def handle_call({:drop_coin, column}, _from, board) do
  #   # ako iska da oveflowne daskata?

  #   new_board = Matrix.columns(board) |>    # list of vectors
  #               Enum.at(column) |>   # vector
  #               update_column |>            # vector
  #               update_board(board, column)

  #   {:reply, new_board, new_board}
  # end

  def first_empty_index(column) do
    length(Enum.filter(column, fn (cell) -> cell == 0 end)) - 1
  end

  def update_column(column, player) do
    index = first_empty_index(column)
    case index do
      -1 ->
        IO.puts "This column is full. Pick another one!"
        column
      _ ->
        List.replace_at(
          Vector.to_list(column),
          index,
          player_sign(player)
        ) |>
        Vector.new
      end
  end

  def player_sign(:cross), do: 1
  def player_sign(:circle), do: 2
  def player_sign(_), do: 0

  def update_board(new_column, board, index) do
    List.replace_at(
      Matrix.columns(board),
      index,
      new_column
    ) |>
    Enum.map(fn (vector) -> Vector.to_list(vector) end) |>
    Matrix.new(Matrix.height(board),Matrix.width(board)) |>
    Matrix.transpose
  end

  def print_board(board) do
    IO.puts String.duplicate("- ", Matrix.width(board) * 2 + 1)
    for row <- Matrix.rows(board), do: print_row(row)
  end

  def print_row(row) do
    IO.write "|"
    Enum.each(row, fn (cell) ->
      case cell do
        0 ->
          IO.write "   |"
        1 ->
          IO.write " x |"
        2 ->
          IO.write " o |"
      end
    end)
    border_size = Vector.length(row) * 2 + 1
    IO.write "\n" <> String.duplicate("- ", border_size) <> "\n"
  end

  def who_wins?(board) do
    cond do
      winner_is?(:cross, board) ->
        :cross
      winner_is?(:circle, board) ->
        :circle
      true ->
        :noone
    end
  end

  def winner_is?(:cross, board) do
    check_hor_and_vert(board, [1,1,1,1])
  end

  def winner_is?(:circle, board) do
    check_hor_and_vert(board, [2,2,2,2])
  end

  def check_hor_and_vert(board, win_streak) do
    (Matrix.columns(board) |>
    Stream.map(fn(vector) -> Vector.to_list(vector) end) |>
    Stream.map(fn (column) -> win_streak |> Sublist.sublist_of?(column) end) |>
    Enum.any?(fn(bool) -> bool end) == true)

    ||

    (Matrix.to_list(board) |>
    Enum.map(fn (column) -> win_streak |> Sublist.sublist_of?(column) end) |>
    Enum.any?(fn(bool) -> bool end) == true)
  end
end
