class Minesweeper
  attr_accessor :size, :answer_board, :user_board, :bomb_positions
  SURROUNDING_CELLS = [[-1,-1], [-1,0], [-1,1], [0,-1], [0,1], [1,-1], [1,0], [1,1]]

  def initialize(size = 9)
    @size = size
    @total_bombs = (size == 9 ? 10 : 40)
    @answer_board = create_answer_board
    tally_bombs
    @user_board = make_board
  end

  def play_game
    until winner?
      display_board(@user_board)
      get_move
      # places move
    end
  end

  def winner? #compare flag positions with our bomb positions || count flags and positions
    # flag_positions == bomb_positions
    @bomb_positions.each do |position|
      return false if @user_board[position[0]][position[1]] != 'F'
    end
    true
  end

  def display_board(board) # change way info is stored in userboard, use that info to display
    board.each do |row|    # ex: :flag = 'F'
      p row
    end
  end

  def get_move
    print "Enter row,column of your move: "
    move = gets.chomp.split(/,/).map! { |num| num.to_i }

    until valid_move?(move) #add an invalid statement

      print "Enter row,column of your move: "
      move = gets.chomp.split(/,/).map! { |num| num.to_i }
    end
    print "Discover 'D' or flag 'F': "
    action = gets.chomp #translate action here
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
        @user_board[row][column] = "_" #discover call
      elsif action == "F"
        @user_board[row][column] = "F"
      end
    when "B"
      if action == "F"
        @user_board[row][column] = "F"
      elsif action == "D"
        raise "YouBlewUpError"
      end
    else
      if action == "F"
        @user_board[row][column] = "F"
      elsif action == "D"
        @user_board[row][column] = @answer_board[row][column]
      end
    end
  end

  def make_board
    board = Array.new(@size) { Array.new(@size) { '*' } }
  end

  def create_answer_board
    @answer_board = make_board
    @bomb_positions = []
    while bomb_positions.size < @total_bombs
      rand_row = rand(@size)
      rand_col = rand(@size)
      @bomb_positions << [rand_row, rand_col]
      @bomb_positions.uniq!
    end

    @bomb_positions.each do |bomb|
      @answer_board[bomb[0]][bomb[1]] = "B"
    end

    @answer_board
  end

  # SURROUNDING_CELLS = [[-1,-1], [-1,0], [-1,1], [0,-1], [0,1], [1,-1], [1,0], [1,1]]

  def tally_bombs
    # each position in answer board
      # skip if bomb
      # get surrounding cells
      # count the number of bombs in above
      # put into answer key

    @answer_board.each_with_index do |row, r_idx|
      row.each_with_index do |value, c_idx|
        next if @answer_board[r_idx][c_idx] == "B"
        bomb_tally = 0
        SURROUNDING_CELLS.each do |position|
          neighbor_cell = [r_idx + position[0], c_idx + position[1]]
          if valid_cell?(neighbor_cell)
            bomb_tally += increase_bomb_tally(neighbor_cell)
          end
        end
        @answer_board[r_idx][c_idx] = bomb_tally unless bomb_tally == 0
      end
    end

  end

  def increase_bomb_tally(neighbor_cell)
    if @answer_board[neighbor_cell[0]][neighbor_cell[1]] == 'B'
      1
    else
      0
    end
  end

  def valid_cell?(neighbor)
    neighbor[0].between?(0,8) && neighbor[1].between?(0, 8)
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