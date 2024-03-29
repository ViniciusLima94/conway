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
        void check_neighbors(int *n, int* x, std::size_t nx, std::size_t ny)
        {
            auto i = threadIdx.x + blockDim.x*blockIdx.x;
            auto j = threadIdx.y + blockDim.y*blockIdx.y;

            if(i>0 && i<nx-1 && j>0 && j<ny-1)
            {
                // Position in the array based on matrix coordinates
                auto pos     = get_pos(i,j,ny);
                // Number of neighbors alive
                n[pos]       = x[pos-1]+x[pos+1] 
                              +x[get_pos(i-1,j-1,ny)]+x[get_pos(i-1,j,ny)]+x[get_pos(i-1,j+1,ny)]  
                              +x[get_pos(i+1,j-1,ny)]+x[get_pos(i+1,j,ny)]+x[get_pos(i+1,j+1,ny)]; 
            }
        }

        __global__
        void update_state(int *n, int* x, std::size_t nx, std::size_t ny)
        {
            // Shared memory

            auto i = threadIdx.x + blockDim.x*blockIdx.x;
            auto j = threadIdx.y + blockDim.y*blockIdx.y;


            if(i>0 && i<nx-1 && j>0 && j<ny-1)
            {
                // Position in the array based on matrix coordinates
                auto pos     = get_pos(i,j,ny);
                // Updating cells
                x[pos] = rules(x[pos],n[pos]); 
            }
        }
    } // namespace kernels

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
        // Allocate array to store number of alive neighbors
        this->n_alive = this->allocate_grid("device");
        // Initialize grid on host
        this->initialize_grid(this->p_init);
        // Copy state to device
        this->update_device();
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
        // Allocate array to store number of alive neighbors
        this->n_alive = this->allocate_grid("device");
        // Initialize grid
        this->initialize_grid(this->p_init);
        // Copy state to device
        this->update_device();
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
        // Allocate array to store number of alive neighbors
        this->n_alive = this->allocate_grid("device");
        // Initialize grid
        this->initialize_grid(this->p_init);
        // Copy state to device
        this->update_device();
    }

    conway_gpu::conway_gpu(std::size_t nx, std::size_t ny, int pad, int* init, char ind)
    {
        // Define default parameters
        this->pad = pad;
        this->nx  = nx+2*pad;
        this->ny  = ny+2*pad;
        this->ind = ind;
        // Allocate grid on host
        this->grid_host   = this->allocate_grid("host");
        this->grid_device = this->allocate_grid("device");
        // Allocate array to store number of alive neighbors
        this->n_alive = this->allocate_grid("device");
        // Initialize grid
        this->initialize_grid(init);
        // Copy state to device
        this->update_device();
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
            // Update state on device
            this->update_state(this->grid_device,this->nx,this->ny);
            gen++;
        }
        // Update grid on host
        this->update_host();
    }

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
        // srand (time(NULL));
        srand (0);

        size_t pos;
        for(auto r=this->pad; r<this->nx-this->pad; r++) {
            for(auto c=this->pad; c<this->ny-this->pad; c++) {
               pos = get_pos(r,c,this->ny);
               if((float) rand()/RAND_MAX < p_init) this->grid_host[pos] = 1;
            }
        }
    }

    void conway_gpu::initialize_grid(int* init)
    {
        size_t pos_grid, pos_init;
        for(auto r=0; r<this->nx-2*this->pad; r++) {
            for(auto c=0; c<this->ny-2*this->pad; c++) {
               pos_grid = get_pos(r+this->pad,c+this->pad,this->ny);
               pos_init = get_pos(r,c,this->ny-2*this->pad);
               this->grid_host[pos_grid] = init[pos_init];
            }
        }
    }

    void conway_gpu::update_state(int* x, std::size_t nx, std::size_t ny)
    {
        // Create block of threads
        dim3 block_dim(16,16);
        dim3 grid_dim((this->nx+block_dim.x-1)/block_dim.x,(this->ny+block_dim.y-1)/block_dim.y);
        // First find number of neighbors for each cell
        kernels::check_neighbors<<<grid_dim,block_dim>>>(this->n_alive,this->grid_device,this->nx,this->ny);
        // Update the cells in the GPU
        kernels::update_state<<<grid_dim,block_dim>>>(this->n_alive,this->grid_device,this->nx,this->ny);
    }

    int* conway_gpu::get_grid()
    {
        return this->grid_host;
    }

    int conway_gpu::get_gridsize()
    {
        return (this->nx-1)*(this->ny-1);
    }

    int conway_gpu::get_nx()
    {
        return this->nx;
    }

    int conway_gpu::get_ny()
    {
        return this->ny;
    }

    int conway_gpu::get_pad()
    {
        return this->pad;
    }

    void conway_gpu::save(const char* filename)
    {
        // Save results to file
        std::ofstream myfile;
        myfile.open(filename);

        size_t pos;

        for(auto r=0; r<this->nx; r++) {
            for(auto c=0; c<this->ny; c++) {
                pos = get_pos(r,c,this->ny);
                if(c<this->ny-1) myfile << this->grid_host[pos] << " ";
                else myfile << this->grid_host[pos];
            }
            myfile << "\n";
        }
        myfile.close();
    }
}
