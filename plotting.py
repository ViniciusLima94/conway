import numpy             as np
import pandas            as pd
import matplotlib.pyplot as plt

import sys

try:
    sim = sys.argv[-1]
    assert sim in ["spaceship","random"]
except:
    sim = "spaceship"

# Number of iterations used
n_iter = 100

grid = []
for i in range(n_iter):
    grid += [pd.read_csv(f"data/gen{i}.txt", header=None, delimiter=" ").values]

if sim=="spaceship":

    for i in range(n_iter):
        plt.figure(figsize=(6,10))
        # CPU
        plt.title(f"spaceship - generation {i}", fontsize=15)
        plt.imshow(grid[i],aspect="auto",cmap="gray_r")
        plt.axis('off')
        plt.savefig(f"figures/gen{i}.png",dpi=100, bbox_inches='tight')
        #  plt.savefig(f"figures/gen{i}.png",dpi=100)
        plt.close()

elif sim=="random":

    grid_gpu = []
    for i in range(n_iter):
        grid_gpu += [pd.read_csv(f"data/gen{i}_gpu.txt", header=None, delimiter=" ").values]

    for i in range(n_iter):
        plt.figure(figsize=(20,8))
        # CPU
        plt.subplot(1,2,1)
        plt.title(f"cpu - generation {i}", fontsize=15)
        plt.imshow(grid[i],aspect="auto",cmap="gray_r")
        plt.axis('off')
        # GPU
        plt.subplot(1,2,2)
        plt.title(f"gpu - generation {i}", fontsize=15)
        plt.imshow(grid_gpu[i],aspect="auto",cmap="gray_r")
        plt.axis('off')
        plt.savefig(f"figures/gen{i}.png",dpi=100,bbox_inches='tight')
        #  plt.savefig(f"figures/gen{i}.png",dpi=100)
        plt.close()

