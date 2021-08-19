# Conway's game of life

Implementation of Conway's game of life in C++.

### Game's rules

1. Any live cell with two or three live neighbours survives.
2. Any dead cell with three live neighbours becomes a live cell.
3. All other live cells die in the next generation. Similarly, all other dead cells stay dead.

### How to run

To compile use: g++ simulate.cpp conway.cpp

To plot the results of the simulation use: ipython plotting.py

In simulate.cpp if SPACESHIP is set to false simulate a randomly initiated grid.

![Random initiated grid](figures/RANDOM.gif)

Otherwise it will run the [30P5H2V0](https://bitstorm.org/gameoflife/lexicon/#bk5) spaceship.

![30P5H2V0 spaceship](figures/30P5H2V0.gif)
