- Instead of storing full copies of board, mutate the board but store the move

  - Store less data, but still able to undo
    - Undo either full rerun of changes
    - Or likely easier to do animation with: each action has the reverse action
  - Stupid idea (maybe): double entry bookkeeping for moves
    - [take waste, put spades]

# Features

- [x] Debug draw dest
- [x] Fuzzy hit detection (mouse pointer doesn't have to be over destination, just most of the card in hand)
- [x] Animation
- [ ] Use sokol
- [ ] emscripten
- [ ] Nice card artwork
- [ ] Win detection
- [ ] New game
- [ ] Screen shake!
- [ ] Messy mode
- [ ] Scoring
- [ ] Three-card draw
