# Conway's game of life

Implementation of Conway's game of life in C++ and CUDA.

### Game's rules

1. Any live cell with two or three live neighbours survives.
2. Any dead cell with three live neighbours becomes a live cell.
3. All other live cells die in the next generation. Similarly, all other dead cells stay dead.

### How to run

- To compile use the use: 
    1. nvcc -c conway_gpu.cu conway.cpp
    2. nvcc conway_gpu.o conway.o simulate.cu -o simulate

- To generate the data run:
    1. ./simulate cpu random
    2. ./simulate cpu spaceship
    3. ./simulate gpu random
    4. ./simulate gpu spaceship

- To plot the results run:
    1. ipython plotting random
    2. ipython plotting spaceship

#### Simulatuion with randomly initiated grid

![Random initiated grid](figures/RANDOM.gif)

#### Simulatuion with grid initiated with [30P5H2V0](https://bitstorm.org/gameoflife/lexicon/#bk5) spaceship

![30P5H2V0 spaceship](figures/30P5H2V0.gif)
