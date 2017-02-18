require "pp"
require "colorize"
require "pry"
require "rumoji"

@emo_square = Rumoji.decode(":foggy:") {|emoji| emoji.string}
@emo_bomb = Rumoji.decode(":bomb:") {|emoji| emoji.string}

class Board
  attr_reader :width, :height, :columns

  def initialize(width, height)
    @width = width
    @height = height 
    @columns = Array.new(height) { Array.new(width) { Square.new() } }
    @columns[0][1].bomb = true

    self.add_random_bombs
    self.populate_bomb_count
  end

  def to_s
    s = ""
    
    self.columns.each_index do |i|
      
      self.columns[i].each_index do |j|
        if (self.columns[i][j].checked && self.columns[i][j].bomb)
          #print @emo_bomb + "\s" + "\s"
          s += "b" +"\s" + "\s"
        elsif (self.columns[i][j].checked && !self.columns[i][j].bomb)
          s += self.columns[i][j].surrounding_bombs.to_s + "\s" + "\s"
        else
          #print @emo_square + "\s" + "\s"
          s += "P" + "\s" + "\s"
        end
      end
      s += "\n"
    end
    return s
  end


  def add_random_bombs
    self.columns.each_index { |i| 
      self.columns[i].each_index { |j| 
        if (Random.rand() < 0.05) 
          self.columns[i][j].bomb = true
        else
          self.columns[i][j].bomb = false
        end
      }
    } 
  end

  def populate_bomb_count
    self.columns.each_index { |i| 
      self.columns[i].each_index{ |j| 
        self.check_neighbors(i, j)
      }
    }
  end

  def check_neighbors(i, j)
    deltas = [[-1,-1],  [0,-1], [1,-1],
              [-1, 0],  [0, 0], [1, 0],
              [-1, 1],  [0, 1], [1, 1]]
    bomb_count = 0
    deltas.each do |delta|
      row = i + delta[0]
      col = j + delta[1]
      if !(row > self.width - 1 || col > self.height - 1 || row == -1 || col == -1)
        if (self.columns[row][col].bomb)
          bomb_count += 1
        end
      end
    self.columns[i][j].surrounding_bombs = bomb_count
    end
  end

  def cascade(i, j)
    deltas = [[-1,-1],  [0,-1], [1,-1],
              [-1, 0],  [0, 0], [1, 0],
              [-1, 1],  [0, 1], [1, 1]]
    deltas.each do |delta|
      row = i + delta[0]
      col = j + delta[1]
      if (row > self.width - 1 || col > self.height - 1 || row == -1 || col == -1)
        next
      end
      if self.columns[row][col].checked 
        next
      end
      self.columns[row][col].checked = true
      if self.columns[row][col].surrounding_bombs == 0
        self.cascade(row, col)
      else
        return
      end
    end

  end  
end


class Square 
  attr_accessor :bomb
  attr_accessor :checked 
  attr_accessor :surrounding_bombs

  def initialize(bomb=false, checked=false, surrounding_bombs=0)
    @checked = checked
    @bomb = bomb
    @surrounding_bombs = surrounding_bombs
  end
  
  def set_checked
    @checked = true 
  end
end




def bad_coords_error
 puts "YOU SUCK WRONG COORDINATES YOU RE KILL YOURSELF"
end

def user_input
 print "Wat coordinates would you like? "
 raw = gets
 @coords = raw.match(/.*?(\d+)[^\d]+(\d+).*?/).captures.map { |i| i.to_i }
 if @coords.length != 2
   bad_coords_error
 end
end

def game_loop(board)
 game_over = false
 print(board.to_s)

 while game_over == false
  print user_input
#   begin 
     grid_sq = board.columns[@coords[0]][@coords[1]]
     unless (@coords[0] < board.width && @coords[1] < board.height)
       bad_coords_error
     end
     grid_sq.set_checked
     if grid_sq.surrounding_bombs == 0
       board.cascade(@coords[0], @coords[1])
     end
     print(board.to_s)
     if (grid_sq.bomb)
       puts "YOU GOT BLOWN UP ! WAHOOO"
       game_over = true
     end     
#   FIXME needs better validation
#   rescue IndexError, NoMethodError
#     bad_coords_error
#   end
  end
end

def main
  dimensions = 10, 10
  board = Board.new(dimensions[0], dimensions[1])
  game_loop(board)
end

main
