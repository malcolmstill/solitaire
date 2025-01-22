- Instead of storing full copies of board, mutate the board but store the move

  - Store less data, but still able to undo
    - Undo either full rerun of changes
    - Or likely easier to do animation with: each action has the reverse action
  - Stupid idea (maybe): double entry bookkeeping for moves
    - [take waste, put spades]

- Can't place, say, 2 clubs on A clubs when A clubs is on clubs stack
- Can't pick up faceup group of cards, can only pick up top card
