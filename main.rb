require __dir__ + '/toy.rb'

# First, we create the toy, unravelled.
$toy = []
[1, 2, 2, 3, 2, 2, 3, 2, 2, 3, 2, 2, 1].each_with_index {|s, idx| $toy << Piece.new(size: s, id: idx.to_s)}

# Then, we create an empty cube.
cube = Cube.new

# We place the first segment into a corner.
cube.place!(piece: $toy[0], orientation: :vertical_up, c: C.new(0, 0, 2))

$debug = false
$solution_counter = 0

# And we recurse through all possibilities.
def work(toy_index, cube)
  if $debug && cube.available_heads.empty?
    puts "\t" * toy_index + "Working for piece #{toy_index} but it has no available heads; recursing."
  end

  if $debug
    puts "\t" * toy_index + "Working for piece #{toy_index} which has #{cube.available_heads.count} available heads. Cube:"
    cube.display_in_line(toy_index)
  end

  cube.available_heads.each do |available_head|
    cah = C.new(available_head[:face], available_head[:row], available_head[:left])

    puts "\t" * toy_index + "Attempting to place piece #{toy_index} from head #{cah.to_s}" if $debug

    [:vertical_up, :vertical_down, :sideways_right, :sideways_left, :long_far, :long_near].each do |orientation|
      if cube.place! piece: $toy[toy_index], orientation: orientation, c: cah
        puts "\t" * toy_index + "\tPlaced piece #{toy_index} in orientation #{orientation}" if $debug

        if cube.complete?
          $solution_counter += 1
          puts "====================== SOLUTION #{$solution_counter} FOUND! ==========================="
          cube.display_in_line
        else
          if toy_index <= $toy.size && !cube.available_heads.empty?
            work(toy_index + 1, cube.clone2)
          else
            puts "\t" * toy_index + "Not progressing to piece #{toy_index + 1}, no available heads." if $debug
          end
        end

        puts "\t" * toy_index + "Undo orientation #{orientation} and progressing to the next one." if $debug
        cube.undo!
      else
        puts "\t" * toy_index + "\t\tTried to place piece #{toy_index} in orientation #{orientation} but it didn't work" if $debug
      end
    end
    puts "\t" * toy_index + "Tried all possible orientations, moving to the next available head." if $debug
  end
  puts "\t" * toy_index + "Tried all available heads. Recurse back from piece #{toy_index} to piece #{toy_index - 1}." if $debug
end

work(1, cube)

