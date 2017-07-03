defmodule ConnectFour.Game.GameSession do
  use GenServer
  use Tensor

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    board = build_board()
    {:ok, board}
  end

  def build_board() do
    Matrix.new(10,10)
  end

  def drop_disc(receiver_pid, picked_column) when is_integer(picked_column) do
    # 0 < n < Matrix.width
    GenServer.call(receiver_pid, {:drop_disc, picked_column})
  end


  def drop_disc(_receiver_pid, picked_column) do
    error = "unexpected column number, received: (#{inspect(picked_column)})"
    raise ArgumentError, error
  end

  # Callbacks

  def handle_call({:drop_disc, picked_column}, _from, board) do
    # ako iska da oveflowne daskata?

    # new_board = Matrix.columns(board) |>
    #             Enum.at(picked_column) |>
    #             Vector.reverse |>
    #             place_disc_in_first_free_spot |>
    #             Vector.reverse |>
    #             replace_column(board, picked_column) |>
    #             Matrix.new(10, 10) # height could change?

    new_board = Matrix.columns(board) |>    # list of vectors
                Enum.at(picked_column) |>   # vector
                update_column |>            # vector
                update_board(board, picked_column)

    {:reply, new_board, new_board}
  end

  # The column's content is listed from the top of the board towards the bottom
  # therefore I am inversing the row
  def first_empty_cell(column) do
    Vector.length(column) - 1 -
    (Vector.reverse(column) |>
    Enum.find_index(fn (el) -> el == 0 end))
  end

  def update_column(column) do
    List.replace_at(
      Vector.to_list(column),
      first_empty_cell(column),
      1
    ) |>
    Vector.new
  end

  def update_board(new_column, board, index) do
    List.replace_at(
      Matrix.columns(board),
      index,
      new_column
    ) |>
    Enum.map(fn (vector) -> Vector.to_list(vector) end) |>
    Matrix.new(Matrix.height(board),Matrix.width(board)) |> # what if they change dinamically
    Matrix.transpose
  end
end
