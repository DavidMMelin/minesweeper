class Minesweeper
  attr_accessor :size, :answer_board, :user_board

  def initialize(size = 9)
    @size = size
    @total_bombs = (size == 9 ? 10 : 40)
    @answer_board = create_answer_board
    @user_board = make_board
  end

  def play_game
    until game_over?
      display_board(@user_board)
      get_move
    end
  end

  def game_over?
    false
  end

  def display_board(board)
    board.each do |row|
      p row
    end
  end

  def get_move
    print "Enter row,column of your move: "
    move = gets.chomp.split(/,/).map! { |num| num.to_i }

    until valid_move?(move)
      print "Enter row,column of your move: "
      move = gets.chomp.split(/,/).map! { |num| num.to_i }
    end
    print "Discover 'D' or flag 'F': "
    action = gets.chomp
    place_move(move, action)
  end

  def valid_move?(move)
    row, col = move[0], move[1]
    @user_board[row][col] == "*"
  end

  def place_move(move, action)
    row, column = move[0], move[1]
    case @answer_board[row][column]
    when "*"
      if action == "D"
        @user_board[row][column] = "_"
      else
        @user_board[row][column] = "F"
      end
    when "B"
      raise "YouBlewUpError"
    end
  end

  def make_move

    update_board(move)

  end

  def update_board
    #use tree to open up all empty spaces if blank space
    #put 1, 2, 3 on non-bomb spaces
  end

  def make_board
    board = Array.new(@size){Array.new(@size) {'*'} }
  end

  def create_answer_board
    @answer_board = make_board
    bomb_positions = []
    while bomb_positions.size < @total_bombs
      rand_row = rand(@size)
      rand_col = rand(@size)
      bomb_positions << [rand_row, rand_col]
      bomb_positions.uniq!
    end

    bomb_positions.each do |bomb|
      @answer_board[bomb[0]][bomb[-1]] = "B"
    end

    @answer_board
  end

end

game = Minesweeper.new
game.display_board(game.answer_board)
puts " "
game.play_game
# p game.user_board


# p game.answer_board
# p game.total_bombs
#p game.answer_board