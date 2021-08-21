#include <iostream>
#include <fstream>
#include <cuda.h>
#include <curand_kernel.h>
#include <curand.h>
#include <stdlib.h>
#include <unistd.h>
#include "conway_gpu.h"
#include "util.h"

namespace cgl_gpu
{
    // In this case the rule set is declared outsid of class to be 
    // called in the kernel
    __host__ __device__
    int rules(int state, int n)
    {
        // Game rules        
        // Any live cell with two or three live neighbours survives.
        // Any dead cell with three live neighbours becomes a live cell.
        // All other live cells die in the next generation. Similarly, all other dead cells stay dead.
        int new_state = 0;
        
        if(state==1)
        {
            if(n==2 || n==3) new_state = 1;
            else new_state = 0;
        }
        else if(state==0)
        {
            if(n==3) new_state = 1;
            else new_state = 0;
        }
        return new_state;
    }

    namespace kernels 
    {
        __global__
        void update_state(int* x, std::size_t nx, std::size_t ny)
        {
            // Shared memory
            // extern __shared__ int buffer[];

            auto i = threadIdx.x + blockDim.x*blockIdx.x;
            auto j = threadIdx.y + blockDim.y*blockIdx.y;

            // Position in the array based on matrix coordinates
            size_t pos;
            // Number of neighbors alive
            int n_alive = 0;

            if(i>0 && i<nx-1 && j>0 && j<ny-1)
            {
                pos     = get_pos(i,j,ny);
                n_alive = x[pos-1]+x[pos+1]
                          +x[get_pos(i-1,j-1,ny)]+x[get_pos(i-1,j,ny)]+x[get_pos(i-1,j+1,ny)]
                          +x[get_pos(i+1,j-1,ny)]+x[get_pos(i+1,j,ny)]+x[get_pos(i+1,j+1,ny)];
                
                x[pos] = rules(x[pos],n_alive);
            }
            // __syncthreads();
        }
    }

    conway_gpu::conway_gpu()
    {
        // Define default parameters
        this->pad = 1;
        this->nx  = 20+2*this->pad;
        this->ny  = 20+2*this->pad;
        this->p_init   = 0.1;
        this->ind = '*';
        // Allocate grid on host
        this->grid_host   = this->allocate_grid("host");
        this->grid_device = this->allocate_grid("device");
        // Initialize grid on host
        this->initialize_grid(this->p_init);
    }

    conway_gpu::conway_gpu(std::size_t nx, std::size_t ny, int pad, float p_init)
    {
        // Define default parameters
        this->pad = pad;
        this->nx  = nx+2*pad;
        this->ny  = ny+2*pad;
        this->p_init = p_init;
        this->ind = '*';
        // Allocate grid
        this->grid_host   = this->allocate_grid("host");
        this->grid_device = this->allocate_grid("device");
        // Initialize grid
        this->initialize_grid(this->p_init);
    }

    conway_gpu::conway_gpu(std::size_t nx, std::size_t ny, int pad, float p_init, char ind)
    {
        // Define default parameters
        this->pad = pad;
        this->nx  = nx+2*pad;
        this->ny  = ny+2*pad;
        this->p_init = p_init;
        this->ind = ind;
        // Allocate grid on host
        this->grid_host   = this->allocate_grid("host");
        this->grid_device = this->allocate_grid("device");
        // Initialize grid
        this->initialize_grid(this->p_init);
    }

    conway_gpu::conway_gpu(std::size_t nx, std::size_t ny, int pad, int** init, char ind)
    {
        // Define default parameters
        this->pad = pad;
        this->nx  = nx+2*pad;
        this->ny  = ny+2*pad;
        this->ind = ind;
        // Allocate grid on host
        this->grid_host   = this->allocate_grid("host");
        this->grid_device = this->allocate_grid("device");
        // Initialize grid
        this->initialize_grid(init);
    }
    
    //____________________________________VISUALIZATION METHODS___________________________________//
    void conway_gpu::print_grid()
    {
        size_t pos;
        for(auto r=0; r<this->nx; r++) {
            for(auto c=0; c<this->ny; c++) {
                pos = get_pos(r,c,this->ny);
                if(this->grid_host[pos]) {
                    std::cout << this->ind;
                }
                else if(r==0 || r==this->nx-1 || c==0 || c==this->ny-1)
                {
                    std::cout << "x";
                }
                else 
                {
                    std::cout << " ";
                }
            }
            std::cout << "\n";
         }
    }
    
    //_________________________________________RUN METHODS________________________________________//
    void conway_gpu::run(int n_gens)
    {
        int gen = 0;
        while(gen<n_gens)
        {
            // Copy state to device
            this->update_device();
            // Update state on device
            this->update_state(this->grid_device,this->nx,this->ny);
            // Update grid on host
            this->update_host();
            gen++;
        }
    }

    // void conway_gpu::simulate(int n_gens)
    // {
    //     system("clear");
    //     int gen = 0;
    //     this->print_grid();
    //     while(gen<n_gens)
    //     {
    //         this->run(1);
    //         this->print_grid();
    //         sleep(1);
    //         system("clear");
    //         gen++;
    //     }
        
    // }

    int* conway_gpu::allocate_grid(const char* target)
    {
        int* ptr;
        if(target=="host") 
        {
            ptr = malloc_host<int>(this->nx*this->ny,0);
        }
        else if(target=="device") 
        {
            ptr = malloc_device<int>(this->nx*this->ny);
        }
        return ptr;
    }

    void conway_gpu::update_device()
    {
        copy_to_device<int>(this->grid_host,this->grid_device,this->nx*this->ny); 
    }

    void conway_gpu::update_host()
    {
        copy_to_host<int>(this->grid_device,this->grid_host,this->nx*this->ny); 
    }

    void conway_gpu::initialize_grid(float p_init)
    {
        // Random seed based on time 
        srand (time(NULL));

        size_t pos;
        for(auto r=this->pad; r<this->nx-this->pad; r++) {
            for(auto c=this->pad; c<this->ny-this->pad; c++) {
               pos = get_pos(r,c,this->ny);
               // std::cout<<pos<<"\n";
               if((float) rand()/RAND_MAX < p_init) this->grid_host[pos] = 1;
            }
        }
    }

    void conway_gpu::initialize_grid(int** init)
    {
        int pos = 0;
        for(auto r=0; r<this->nx-2*this->pad; r++) {
            for(auto c=0; c<this->ny-2*this->pad; c++) {
               pos = get_pos(r,c,this->ny);
               // this->grid[r+this->pad][c+this->pad] = init[r][c];
            }
        }
    }

    void conway_gpu::update_state(int* x, std::size_t nx, std::size_t ny)
    {
        // Testing
        dim3 block_dim(16,16);
        dim3 grid_dim((this->nx+block_dim.x-1)/block_dim.x,(this->ny+block_dim.y-1)/block_dim.y);
        kernels::update_state<<<grid_dim,block_dim>>>(this->grid_device,this->nx,this->ny);
    }
    // void conway_gpu::update_state()
    // {
    //     // Temporary grid
    //     int n_live   = 0;
    //     int** buffer = this->allocate_grid();

    //     for(int r=1; r<this->nx-1; r++) {
    //         for(int c=1; c<this->ny-1; c++) {
    //             n_live = this->check_neighbors(r,c);
    //             buffer[r][c] = this->rules(this->grid[r][c], n_live);
    //         }
    //     }

    //     // Copy buffer to grid
    //     for(int r=0; r<this->nx; r++) {
    //         for(int c=0; c<this->ny; c++) {
    //             this->grid[r][c] = buffer[r][c];
    //         }
    //     }

    //     free(buffer);
    // }

    // int conway_gpu::check_neighbors(int i, int j)
    // {
    //     int n = 0;
    //     for(auto r=i-1;r<=i+1;r++) 
    //     {
    //         for(auto c=j-1;c<=j+1;c++)
    //         {
    //             if(r==i && c==j) {
    //                 continue;
    //             }
    //             else {
    //                 n+=this->grid[r][c];
    //             }
    //         }
    //     }
    //     return n;
    // }

    // __host__ __device__
    // int conway_gpu::rules(int state, int n)
    // {
    //     // Game rules        
    //     // Any live cell with two or three live neighbours survives.
    //     // Any dead cell with three live neighbours becomes a live cell.
    //     // All other live cells die in the next generation. Similarly, all other dead cells stay dead.
    //     int new_state = 0;
        
    //     if(state==1)
    //     {
    //         if(n==2 || n==3) new_state = 1;
    //         else new_state = 0;
    //     }
    //     else if(state==0)
    //     {
    //         if(n==3) new_state = 1;
    //         else new_state = 0;
    //     }
    //     return new_state;
    // }

    //_________________________________________GET METHODS________________________________________//
    // int** conway_gpu::get_grid()
    // {
    //     return this->grid;
    // }

    // int conway_gpu::get_gridsize()
    // {
    //     return (this->nx-1)*(this->ny-1);
    // }

    // int conway_gpu::get_nx()
    // {
    //     return this->nx;
    // }

    // int conway_gpu::get_ny()
    // {
    //     return this->ny;
    // }

    // int conway_gpu::get_pad()
    // {
    //     return this->pad;
    // }

    // void conway_gpu::save(const char* filename)
    // {
    //     // Save results to file
    //     std::ofstream myfile;
    //     myfile.open(filename);

    //     for(auto r=0; r<this->nx; r++) {
    //         for(auto c=0; c<this->ny; c++) {
    //             if(c<this->ny-1) myfile << this->grid[r][c] << " ";
    //             else myfile << this->grid[r][c];
    //         }
    //         myfile << "\n";
    //     }
    //     myfile.close();
    // }
}
