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
    grid += [pd.read_csv(f"data/gen{i}_{sim}_cpu.txt", header=None, delimiter=" ").values]

grid_gpu = []
for i in range(n_iter):
    grid_gpu += [pd.read_csv(f"data/gen{i}_{sim}_gpu.txt", header=None, delimiter=" ").values]

if sim=="spaceship":
    _fs = (10,10)
elif sim=="random":
    _fs = (20,8)

for i in range(n_iter):
    plt.figure(figsize=_fs)
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
    plt.suptitle(sim, fontsize=15)
    plt.savefig(f"figures/gen{i}_{sim}.png",dpi=150,bbox_inches='tight')
    plt.close()

