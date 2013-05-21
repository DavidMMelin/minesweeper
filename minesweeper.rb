require 'yaml'

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
      save_game
      display_board(@user_board)
      get_move
      #loser?
    end
    display_board(@user_board)
    puts "CONGRATS, YOU WON!"
  end

  def save_game
    print "Would you like to save? (y or n): "
    response = gets.chomp
    if response == 'y'
      game_to_save = self.to_yaml
      File.open(Dir.pwd, 'w+') {|f| f.write(game_to_save) }
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
      row.each do |val|
        print " #{val} "
      end
      puts ""
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
    when "_"
      if action == "D"
        discover(move)
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

  def discover(move, valid_neighbors = [])
    row, col = move[0],move[1]
    if @answer_board[row][col].class == Fixnum
      @user_board[row][col] = @answer_board[row][col]
    else
      @user_board[row][col] = @answer_board[row][col]
      find_valid_neighbors(move).each do |cell|
        discover(cell, find_valid_neighbors(cell))
      end
    end
  end

  def find_valid_neighbors(move)
    valid_neighbors = []
    SURROUNDING_CELLS.each do |position|
      neighbor_cell = [move[0] + position[0], move[1] + position[1]]
      if valid_cell?(neighbor_cell) && @user_board[neighbor_cell[0]][neighbor_cell[1]] != "_"
        valid_neighbors << neighbor_cell
      end
    end
    valid_neighbors
  end

  def make_board
    board = Array.new(@size) { Array.new(@size) { '*' } }
  end

  def create_answer_board
    @answer_board = Array.new(@size) { Array.new(@size) { '_' } }
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

  def tally_bombs
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
    neighbor[0].between?(0,@size - 1) && neighbor[1].between?(0, @size - 1)
  end
end

game = Minesweeper.new(16)
game.display_board(game.answer_board)
puts " "
game.play_game