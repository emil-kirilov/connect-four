defmodule ConnectFour.Game.BoardTest do
  use ExUnit.Case
  use Tensor

  import ExUnit.CaptureIO

  alias ConnectFour.Game.Board

  doctest ConnectFour

  describe "build_board/0" do
    test "builds a 10x10 board" do
      matrix = Board.build_board()

      row = Matrix.row(matrix, 0)
      col = Matrix.column(matrix, 0)

      assert Vector.length(row) == 10
      assert Vector.length(col) == 10
    end
  end

  # After I make it a supervised process
  # describe "drop_coin/2" do
  #   test "expects and integer" do
  #     game_pid = Process.whereis(:drop_coin)
  #     reference = Process.monitor(game_pid)
  #     catch_exit do
  #       Board.drop_coin(game_pid, "1")
  #     end
  #     assert_received({:DOWN, ^reference, :process, ^game_pid, {%ArgumentError{}, _}})
  #   end
  # end

  describe "drop_coin/3" do
    test "raises an error if argument is not an integer" do
      assert_raise ArgumentError, fn ->
        # {:ok, pid } = Board.start_link
        Board.build_board() |>
        Board.drop_coin(:cross, "1")
      end
    end

    #@tag :capture_log
    test "expects and integer" do
      board = Board.build_board() |>
              Board.drop_coin(:cross, 1)

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

  describe "first_empty_index /1" do
    test "finds the index of the first 0 (from right to left) in a vector" do
      assert Board.first_empty_index(Vector.new([0,0,0,0])) == 3
      assert Board.first_empty_index(Vector.new([0,0,0,1])) == 2
    end
  end

  describe "update_column/1" do
    test "replaces the first 0 (from right to left) in a vector" do
      assert Board.update_column(Vector.new([0,0,0,0]), :cross) == Vector.new([0,0,0,1])
      assert Board.update_column(Vector.new([0,0,0,1]), :cross) == Vector.new([0,0,1,1])
    end
  end

  describe "update_board/1" do
    test "replaces the column with the given index" do
      board = Matrix.new([[0,0],[0,0]],2,2)
      new_column = Vector.new([1,1])

      assert Board.update_board(new_column, board, 0) == Matrix.new([[1,0],[1,0]],2,2)
    end
  end

  describe "print_row/1" do
    test "print an empty row" do
      fun = fn ->
        Board.print_row(Vector.new([0,0])) == :ok
      end
      assert capture_io(fun) == "|   |   |\n- - - - - \n"
    end

    test "prints a row with occupied cells" do
      fun = fn ->
        Board.print_row(Vector.new([0,0,1,0,2,2])) == :ok
      end
      assert capture_io(fun) == "|   |   | x |   | o | o |\n- - - - - - - - - - - - - \n"
    end
  end

  describe "print_board/1" do
    test "prints the empty board" do
      fun = fn ->
        Board.print_board(Matrix.new([[0,0,0,0,0,0],[0,0,0,0,0,0]],2,6)) == :ok
      end
      assert capture_io(fun) == "- - - - - - - - - - - - - \n|   |   |   |   |   |   |\n- - - - - - - - - - - - - \n|   |   |   |   |   |   |\n- - - - - - - - - - - - - \n"
    end

    test "prints the board with occupied cells" do
      fun = fn ->
        Board.print_board(Matrix.new([[0,0,0,0,0,0],[0,0,1,0,2,2]],2,6)) == :ok
      end
      assert capture_io(fun) == "- - - - - - - - - - - - - \n|   |   |   |   |   |   |\n- - - - - - - - - - - - - \n|   |   | x |   | o | o |\n- - - - - - - - - - - - - \n"
    end
  end

  describe "player_sign/1" do
    test "returns 1 when player is :cross" do
      assert Board.player_sign(:cross) == 1
    end

    test "returns 2 when player is :circle" do
      assert Board.player_sign(:circle) == 2
    end
  end

  describe "who_wins?/1" do
    test "returns :cross when they win" do
      assert Board.who_wins?(Matrix.new([[1,1,1,1],[0,1,1,0],[0,0,0,0]],3,4)) == :cross
    end

    test "returns :circle when they win" do
      assert Board.who_wins?(Matrix.new([[2,2,2,2],[0,1,1,0],[0,0,0,0]],3,4)) == :circle
    end

    test "returns :noone when nobody wins" do
      assert Board.who_wins?(Matrix.new([[1,1,1,2],[0,1,1,0],[0,0,0,0]],3,4)) == :noone
    end
  end

  describe "winner_is?/1" do
    test ":cross wins if there are four consecutive 1s" do
      assert Board.winner_is?(:cross, Matrix.new([[1,1,1,1],[0,1,1,0],[0,0,0,0]],3,4)) == true
    end

    test ":cross does not win if there are no four consecutive 1s" do
      assert Board.winner_is?(:cross, Matrix.new([[1,1,2,1],[0,1,1,0],[0,0,0,0]],3,4)) == false
    end
  end

  describe "circle_wins?/1" do
    test ":circle wins if there are four consecutive 2s" do
      assert Board.winner_is?(:circle, Matrix.new([[2,2,2,2],[0,1,1,0],[0,0,0,0]],3,4)) == true
    end

    test ":circle does not win if there are no four consecutive 2s" do
      assert Board.winner_is?(:circle, Matrix.new([[2,2,2,1],[0,1,1,0],[0,0,0,0]],3,4)) == false
    end
  end
end
