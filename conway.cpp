#include <iostream>
#include <stdlib.h>
#include <unistd.h>
#include "conway.h"
#include "array.h"

namespace cgl
{
    conway::conway()
    {
        // Define default parameters
        this->nx = 20;
        this->ny = 20;
        this->p_init   = 0.1;
        this->ind = '*';
        // Allocate grid
        this->grid = this->allocate_grid();
        // Initialize grid
        this->initialize_grid(this->p_init);
    }

    conway::conway(std::size_t nx, std::size_t ny, float p_init)
    {
        // Define default parameters
        this->nx = nx+1;
        this->ny = ny+1;
        this->p_init   = p_init;
        this->ind = '*';
        // Allocate grid
        this->grid = this->allocate_grid();
        // Initialize grid
        this->initialize_grid(this->p_init);
    }

    conway::conway(std::size_t nx, std::size_t ny, float p_init, char ind)
    {
        // Define default parameters
        this->nx = nx+1;
        this->ny = ny+1;
        this->p_init   = p_init;
        this->ind = ind;
        // Allocate grid
        this->grid = this->allocate_grid();
        // Initialize grid
        this->initialize_grid(this->p_init);
    }

    conway::conway(std::size_t nx, std::size_t ny, int** init, char ind)
    {
        // Define default parameters
        this->nx = nx+1;
        this->ny = ny+1;
        this->p_init   = p_init;
        this->ind = ind;
        // Allocate grid
        this->allocate_grid();
        // Initialize grid
        this->initialize_grid(init);
    }
    
    //____________________________________VISUALIZATION METHODS___________________________________//
    void conway::print_grid()
    {
        for(auto r=0; r<this->nx; r++) {
            for(auto c=0; c<this->ny; c++) {
                if(this->grid[r][c]) {
                    std::cout << this->ind;
                }
                else if(r==0 || r==this->nx-1 || c==0 || c==this->ny-1)
                {
                    std::cout << "x";
                }
                else 
                {
                    std::cout << ".";
                }
            }
            std::cout << "\n";
         }
    }
    
    //_________________________________________RUN METHODS________________________________________//
    void conway::run(int n_gens)
    {
        int gen = 0;
        while(gen<n_gens)
        {
            this->update_state();
            gen++;
        }
    }

    void conway::simulate(int n_gens)
    {
        system("clear");
        int gen = 0;
        this->print_grid();
        while(gen<n_gens)
        {
            this->run(1);
            this->print_grid();
            sleep(1);
            system("clear");
            gen++;
        }
        
    }

    int** conway::allocate_grid()
    {
        return zeros(this->nx, this->ny);
    }

    void conway::initialize_grid(float p_init)
    {
        // Random seed based on time 
        srand (time(NULL));

        for(auto r=1; r<this->nx-1; r++) {
            for(auto c=1; c<this->ny-1; c++) {
               if((float) rand()/RAND_MAX < p_init) this->grid[r][c] = 1;
            }
        }
    }

    void conway::initialize_grid(int** init_pop)
    {
        // Copy buffer to grid
        for(int r=1; r<this->nx-1; r++) {
            for(int c=1; c<this->ny-1; c++) {
                this->grid[r][c] = init_pop[r][c];
            }
        }
    }

    void conway::update_state()
    {
        // Temporary grid
        int n_live   = 0;
        int** buffer = this->allocate_grid();

        for(int r=1; r<this->nx-1; r++) {
            for(int c=1; c<this->ny-1; c++) {
                n_live = this->check_neighbors(r,c);
                buffer[r][c] = this->rules(this->grid[r][c], n_live);
            }
        }

        // Copy buffer to grid
        for(int r=0; r<this->nx; r++) {
            for(int c=0; c<this->ny; c++) {
                this->grid[r][c] = buffer[r][c];
            }
        }

        free(buffer);
    }

    int conway::check_neighbors(int i, int j)
    {
        int n = 0;
        for(auto r=i-1;r<=i+1;r++) 
        {
            for(auto c=j-1;c<=j+1;c++)
            {
                if(r==i && c==j) {
                    continue;
                }
                else {
                    n+=this->grid[r][c];
                }
            }
        }
        return n;
        // int n = 0;
        // if(i==0 && j>0 && j<this->ny) 
        // {
        //     n = this->grid[i][j-1]+this->grid[i][j+1]+this->grid[i+1][j-1]+
        //         this->grid[i+1][j]+this->grid[i+1][j+1];
        // }
        // if(j==0 && i>0 && i<this->nx) 
        // {
        //     n = this->grid[i-1][j]+this->grid[i-1][j]+
        //         this->grid[i+1][j]+this->grid[i+1][j+1];
        // }
        // if(i==0 && j==0) 
        // {
        //     n = this->grid[i][j+1]+this->grid[i+1][j]+this->grid[i+1][j+1];
        // }
        // if(i==this->nx-1)
        // {
        //     end_r = i;
        // }
        // if(j==0) 
        // {
        //     init_c = j;
        // }
        // if(j==this->ny-1)
        // {
        //     end_c = j;
        // }
        // return n;
    }

    int conway::rules(int state, int n)
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

    //_________________________________________GET METHODS________________________________________//
    void conway::get_grid()
    {}

    void conway::get_gridsize()
    {}

    void conway::get_nx()
    {}

    void conway::get_ny()
    {}
}
