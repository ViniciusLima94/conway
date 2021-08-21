# Conway's game of life

Implementation of Conway's game of life in C++.

### Game's rules

1. Any live cell with two or three live neighbours survives.
2. Any dead cell with three live neighbours becomes a live cell.
3. All other live cells die in the next generation. Similarly, all other dead cells stay dead.

### How to run

- To compile use the **CPU** version use: nvcc simulate.cpp conway.cpp
- To compile use the **GPU** version use: nvcc -c conway_gpu.cu & nvcc conway_gpu.o simulate.cu

To plot the results of the simulation use: ipython plotting.py

In simulate.cu if SPACESHIP is set to false simulate a randomly initiated grid.

![Random initiated grid](figures/RANDOM.gif)

Otherwise it will run the [30P5H2V0](https://bitstorm.org/gameoflife/lexicon/#bk5) spaceship (CPU only)

![30P5H2V0 spaceship](figures/30P5H2V0.gif)
