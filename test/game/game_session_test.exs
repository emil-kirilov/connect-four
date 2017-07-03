defmodule ConnectFour.Game.GameSessionTest do
  use ExUnit.Case
  use Tensor
  alias ConnectFour.Game.GameSession

  doctest ConnectFour

  describe "build_board/0" do
    test "builds a 10x10 board" do
      matrix = GameSession.build_board()

      row = Matrix.row(matrix, 0)
      col = Matrix.column(matrix, 0)

      assert Vector.length(row) == 10
      assert Vector.length(col) == 10
    end
  end

  # After I make it a supervised process
  # describe "drop_disc/2" do
  #   test "expects and integer" do
  #     game_pid = Process.whereis(:drop_disc)
  #     reference = Process.monitor(game_pid)
  #     catch_exit do
  #       GameSession.drop_disc(game_pid, "1")
  #     end
  #     assert_received({:DOWN, ^reference, :process, ^game_pid, {%ArgumentError{}, _}})
  #   end
  # end

  describe "drop_disc/2" do
    test "raises an error if argument is not an integer" do
      assert_raise ArgumentError, fn ->
        {:ok, pid } = GameSession.start_link
        GameSession.drop_disc(pid, "1")
      end
    end

    #@tag :capture_log
    test "expects and integer" do
      {:ok, pid } = GenServer.start_link(GameSession, [])
      board = GameSession.drop_disc(pid, 1)

      assert Matrix.to_list(board) == [[0,0,0,0,0,0,0,0,0,0],
                                       [0,0,0,0,0,0,0,0,0,0],
                                       [0,0,0,0,0,0,0,0,0,0],
                                       [0,0,0,0,0,0,0,0,0,0],
                                       [0,0,0,0,0,0,0,0,0,0],
                                       [0,0,0,0,0,0,0,0,0,0],
                                       [0,0,0,0,0,0,0,0,0,0],
                                       [0,0,0,0,0,0,0,0,0,0],
                                       [0,0,0,0,0,0,0,0,0,0],
                                       [0,1,0,0,0,0,0,0,0,0]]
    end
  end

  describe "first_empty_cell/1" do
    test "finds the index of the first 0 (from right to left) in a vector" do
      assert GameSession.first_empty_cell(Vector.new([0,0,0,0])) == 3
      assert GameSession.first_empty_cell(Vector.new([0,0,0,1])) == 2
    end
  end

  describe "update_column/1" do
    test "replaces the first 0 (from right to left) in a vector" do
      assert GameSession.update_column(Vector.new([0,0,0,0])) == Vector.new([0,0,0,1])
      assert GameSession.update_column(Vector.new([0,0,0,1])) == Vector.new([0,0,1,1])
    end
  end

  describe "update_board/1" do
    test "replaces the column with the given index" do
      board = Matrix.new([[0,0],[0,0]],2,2)
      new_column = Vector.new([1,1])

      assert GameSession.update_board(new_column, board, 0) == Matrix.new([[1,0],[1,0]],2,2)
    end
  end
end
