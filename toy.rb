class Piece
  attr_reader :size
  attr_reader :id

  def initialize(size:, id:) # 1, 2 or 3
    @size, @id = size, id
  end
end

class C # coords
  attr_reader :face # counted from near to far
  attr_reader :row # counted from the bottom up
  attr_reader :left # counted from left to right

  def initialize face, row, left
    @face, @row, @left = face, row, left
  end

  def to_s
    "face #{@face}, row #{@row}, left #{@left}"
  end
end

class Cube
  attr_accessor :a
  attr_accessor :string_start
  attr_accessor :string_end

  # An array of VERTICAL FACES from near to far
  # A face is an array of ROWS from bottom to top
  # A row is an array of cells from left to right
  def initialize
    @a = Array.new(3){Array.new(3){Array.new(3)}}
  end

  def clone2
    Marshal.load(Marshal.dump(self))
  end

  def undo!
    @a, @string_start, @string_end = @memory[:a], @memory[:string_start], @memory[:string_end]
  end

  def place! piece:, orientation:, c:
    @memory = {
        a:            Marshal.load(Marshal.dump(@a)),
        string_start: Marshal.load(Marshal.dump(@string_start)),
        string_end:   Marshal.load(Marshal.dump(@string_end))
    }

    is_first           = @a.flatten.uniq == [nil]
    placed, string_end = place_private(piece, orientation, c)

    if placed
      @string_start = c if is_first
      @string_end   = string_end
    end

    placed
  end

  def fits? piece, orientation, c
    case orientation
    when :vertical_up
      return false if c.row + piece.size > 3
      return false unless [*c.row..(c.row + piece.size - 1)].map {|row| @a[c.face][row][c.left]}.uniq == [nil]

    when :vertical_down
      return false if c.row - piece.size < -1
      return false unless [*(c.row - piece.size + 1)..c.row].map {|row| @a[c.face][row][c.left]}.uniq == [nil]

    when :sideways_right
      return false if c.left + piece.size > 3
      return false unless [*c.left..(c.left + piece.size - 1)].map {|left| @a[c.face][c.row][left]}.uniq == [nil]

    when :sideways_left
      return false if c.left - piece.size < -1
      return false unless [*(c.left - piece.size + 1)..c.left].map {|left| @a[c.face][c.row][left]}.uniq == [nil]

    when :long_far
      return false if c.face + piece.size > 3
      return false unless [*c.face..(c.face + piece.size - 1)].map {|face| @a[face][c.row][c.left]}.uniq == [nil]

    when :long_near
      return false if c.face - piece.size < -1
      return false unless [*(c.face - piece.size + 1)..c.face].map {|face| @a[face][c.row][c.left]}.uniq == [nil]
    end
    true
  end

  def available_heads
    res = []
    [-1, 0, 1].each do |delta|
      possible = @string_end.face + delta
      res << {face: possible, row: @string_end.row, left: @string_end.left} if (0..2).include?(possible) && @a[possible][@string_end.row][@string_end.left].nil?
    end

    [-1, 0, 1].each do |delta|
      possible = @string_end.row + delta
      res << {face: @string_end.face, row: possible, left: @string_end.left} if (0..2).include?(possible) && @a[@string_end.face][possible][@string_end.left].nil?
    end

    [-1, 0, 1].each do |delta|
      possible = @string_end.left + delta
      res << {face: @string_end.face, row: @string_end.row, left: possible} if (0..2).include?(possible) && @a[@string_end.face][@string_end.row][possible].nil?
    end

    res
  end

  def complete?
    !@a.flatten.include?(nil)
  end

  def display_in_line(tabs = 0)
    puts "\t" * tabs + "             Face 0              Face 1              Face 2"
    [2, 1, 0].each do |row|
      rowcontent = ''

      [0, 1, 2].each do |face|
        rowcontent += [0, 1, 2].map do |left|
          sprintf('%2s', (@a[face][row][left] || '.'))
        end.join(' ') + '            '
      end

      puts "\t" * tabs + ' ' * 12 + rowcontent
    end
  end

  private

  # piece is an instance of +Piece+
  # orientation is :vertical, :sideways, :long (horizonal from near to far)
  def place_private piece, orientation, c
    return nil unless fits?(piece, orientation, c)
    case orientation
    when :vertical_up
      @a[c.face][c.row][c.left]     = piece.id
      @a[c.face][c.row + 1][c.left] = piece.id if piece.size > 1
      @a[c.face][c.row + 2][c.left] = piece.id if piece.size == 3

      string_end = C.new(c.face, c.row + piece.size - 1, c.left)

    when :vertical_down
      @a[c.face][c.row][c.left]     = piece.id
      @a[c.face][c.row - 1][c.left] = piece.id if piece.size > 1
      @a[c.face][c.row - 2][c.left] = piece.id if piece.size == 3

      string_end = C.new(c.face, c.row - piece.size + 1, c.left)

    when :sideways_right
      @a[c.face][c.row][c.left]     = piece.id
      @a[c.face][c.row][c.left + 1] = piece.id if piece.size > 1
      @a[c.face][c.row][c.left + 2] = piece.id if piece.size == 3

      string_end = C.new(c.face, c.row, c.left + piece.size - 1)

    when :sideways_left
      @a[c.face][c.row][c.left]     = piece.id
      @a[c.face][c.row][c.left - 1] = piece.id if piece.size > 1
      @a[c.face][c.row][c.left - 2] = piece.id if piece.size == 3

      string_end = C.new(c.face, c.row, c.left - piece.size + 1)

    when :long_far
      @a[c.face][c.row][c.left]     = piece.id
      @a[c.face + 1][c.row][c.left] = piece.id if piece.size > 1
      @a[c.face + 2][c.row][c.left] = piece.id if piece.size == 3

      string_end = C.new(c.face + piece.size - 1, c.row, c.left)

    when :long_near
      @a[c.face][c.row][c.left]     = piece.id
      @a[c.face - 1][c.row][c.left] = piece.id if piece.size > 1
      @a[c.face - 2][c.row][c.left] = piece.id if piece.size == 3

      string_end = C.new(c.face - piece.size + 1, c.row, c.left)
    end

    return true, string_end
  end

end