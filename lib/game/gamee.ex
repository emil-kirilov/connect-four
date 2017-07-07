defmodule ConnectFour.Game.Gamee do
  use GenServer
  alias ConnectFour.Game.Board

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    {:ok, Board.build_board()}
  end

  # def build_board() do
  #   Matrix.new(10,10)
  # end

  def drop_coin(receiver_pid, player, column) do
    GenServer.call(receiver_pid, {:drop_coin, player, column})
  end

  def print_board(receiver_pid) do
    GenServer.cast(receiver_pid, :print_board)
  end

  # def drop_coin(receiver_pid, picked_column) when is_integer(picked_column) do
  #   # 0 < n < Matrix.width?
  #   GenServer.call(receiver_pid, {:drop_coin, picked_column})
  # end


  # def drop_coin(_receiver_pid, picked_column) do
  #   error = "unexpected column number, received: (#{inspect(picked_column)})"
  #   raise ArgumentError, error
  # end

  # def game_over(pid) do
  #   GenServer.call(pid, :stop)
  # end

  # def handle_call(:stop, _from, status) do
  #   {:stop, :normal, status}
  # end

  # Callbacks

  def handle_call({:drop_coin, player, picked_column}, _from, board) do
    new_board = Board.drop_coin(board, player, picked_column)
    Board.print_board(new_board)

    case Board.who_wins?(new_board) do
      :cross ->
        IO.puts "Cross won!"
        {:stop, :normal, board}
      :circle ->
        IO.puts "Circle won!"
        {:stop, :normal, board}
      _ ->
        {:reply, new_board, new_board}
    end
  end

  def handle_cast(:print_board, board) do
    Board.print_board(board)
    {:noreply, board}
  end

  # The column's content is listed from the top of the board towards the bottom
  # therefore I am inversing the row
  # def first_empty_cell(column) do
  #   Vector.length(column) - 1 -
  #   (Vector.reverse(column) |>
  #   Enum.find_index(fn (el) -> el == 0 end))
  # end

  # def update_column(column) do
  #   List.replace_at(
  #     Vector.to_list(column),
  #     first_empty_cell(column),
  #     1
  #   ) |>
  #   Vector.new
  # end

  # def update_board(new_column, board, index) do
  #   List.replace_at(
  #     Matrix.columns(board),
  #     index,
  #     new_column
  #   ) |>
  #   Enum.map(fn (vector) -> Vector.to_list(vector) end) |>
  #   Matrix.new(Matrix.height(board),Matrix.width(board)) |> # what if they change dinamically?
  #   Matrix.transpose
  # end

  # def print_board(board) do
  #   for row <- Matrix.rows(board), do: print_row(row)
  # end

  # def print_row(row) do
  #   IO.write "|"
  #   Enum.each(row, fn (cell) ->
  #     case cell do
  #       0 ->
  #         IO.write "   |"
  #       1 ->
  #         IO.write " x |"
  #       2 ->
  #         IO.write " o |"
  #     end
  #   end)
  #   border_size = Vector.length(row) * 2 + 1
  #   IO.write "\n" <> String.duplicate("- ", border_size) <> "\n"
  # end
end
