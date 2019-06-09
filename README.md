This is a Ruby script that uses recursion in order to solve a puzzle.

This is a classic wooden puzzle made of 13 segments of various lengths.
The shortest segment is a cube; other segments are twice as long, some are three times
as long. The lengths of the segments is in `main.rb` at line 5.

!(the puzzle deconstructed)[https://i.ibb.co/WBRtfgF/2019-06-09-21-41-53.jpg =250px]

The wooden segments are all interconnected using a strong elastic, through a whole pierced
longitudinally through each segment. They are crested at the ends, allowing the elastic to
bind two segments in various configurations, as you can see in the photos.

The object of the puzzle is to build a cube (or at least that's the object in this project.)

!(the cube)[https://i.ibb.co/RQGmMJF/2019-06-09-21-41-31.jpg =250px]

The algorithm found 7,236 solutions and they are all in `results.txt`. Alternatively you can
run the script yourself: `ruby main.rb`. (Ruby 2.5 was used in development.)

In each solution, the numbers represent the index of the segment (0 is one of the ends,
the little cube, and 12 is the little cube at the other end.)

Faces are number from near (face 0) to far (face 2).

This was a Sunday afternoon hobby project.