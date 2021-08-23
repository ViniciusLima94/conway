#include <iostream>
#include <assert.h>
#include <unistd.h>
#include <string>
#include "conway.h"
#include "conway_gpu.h"

#define n_iter 100

using namespace cgl;
using namespace cgl_gpu;

// Return the file name
std::string return_fn(int gen, std::string suffix)
{
    return "data/gen"+std::to_string(gen)+suffix+".txt";
}

// Method to create ship 30P5H2V0
void return_ship(int *ship) {
    // Initialize a spaceship
    int init[11][13] = {
        {0,0,0,0,1,0,0,0,0,0,0,0,0},
        {0,0,0,1,1,1,0,0,0,0,0,0,0},
        {0,0,1,1,0,1,1,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,1,0,1,0,1,0,1,0,0,1,0,0},
        {1,1,0,0,0,1,0,0,0,1,1,1,0},
        {1,1,0,0,0,1,0,0,0,0,0,0,1},
        {0,0,0,0,0,0,0,0,0,0,1,0,1},
        {0,0,0,0,0,0,0,0,1,0,1,0,0},
        {0,0,0,0,0,0,0,0,0,1,0,0,1},
        {0,0,0,0,0,0,0,0,0,0,0,0,1},
    };

    for(int i=0; i<11; ++i) {
        for(int j=0; j<13; j++) {
            ship[i*13+j]=init[i][j];
        }
    }
}

// Method to create ship 30P5H2V0
void return_ship(int **ship) {
    // Initialize a spaceship
    int init[11][13] = {
        {0,0,0,0,1,0,0,0,0,0,0,0,0},
        {0,0,0,1,1,1,0,0,0,0,0,0,0},
        {0,0,1,1,0,1,1,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,1,0,1,0,1,0,1,0,0,1,0,0},
        {1,1,0,0,0,1,0,0,0,1,1,1,0},
        {1,1,0,0,0,1,0,0,0,0,0,0,1},
        {0,0,0,0,0,0,0,0,0,0,1,0,1},
        {0,0,0,0,0,0,0,0,1,0,1,0,0},
        {0,0,0,0,0,0,0,0,0,1,0,0,1},
        {0,0,0,0,0,0,0,0,0,0,0,0,1},
    };

    for(int i=0; i<11; ++i) {
        for(int j=0; j<13; j++) {
            ship[i][j]=init[i][j];
        }
    }
}

int main(int argc, char *argv[]) 
{

    // Check the number of line arguments
    assert(argc==3);
    // Parse parameters
    std::string TARGET = argv[1]; 
    std::string INIT   = argv[2]; 
    assert(TARGET=="cpu"  || TARGET=="gpu");
    assert(INIT=="random" || INIT=="spaceship");

    // Suffix to save files
    std::string suffix = "_"+INIT+"_"+TARGET;

    if(TARGET=="cpu")
    {
        conway pop;

        if(INIT=="spaceship") 
        {
            int** ship = new int*[11];
            for(int i = 0; i < 11; ++i)
                ship[i] = new int[13];

            return_ship(ship);

            pop = conway(11,13,50, ship, '*');
        }
        else if(INIT=="random")
        {
            pop = conway(40,100,10,0.2,'o');
        }

        std::string s;
        int gen = 0;
        s       = return_fn(gen,suffix); 
        pop.save(s.c_str());
        pop.print_grid();
        gen++;
        while(gen<n_iter)
        {
                std::cout<< "gen: " << gen << "\n";
                pop.run(1);
                pop.print_grid();
                sleep(1);
                system("clear");
                s = return_fn(gen,suffix); 
                pop.save(s.c_str());
                gen++;
        }
    }
    else if(TARGET=="gpu")
    {
        conway_gpu pop;

        if(INIT=="spaceship")
        {
            int* ship = (int*) malloc(11*13 * sizeof(int));

            return_ship(ship);

            pop = conway_gpu(11,13,50,ship,'o');

        }
        else if(INIT=="random")
        {
            pop = conway_gpu(40,100,10,0.2,'o');
        }
        
        std::string s;
        int gen = 0;
        // s =  "data/gen"+std::to_string(gen)+"_gpu.txt";
        s = return_fn(gen,suffix); 
        pop.save(s.c_str());
        pop.print_grid();
        gen++;
        while(gen<n_iter)
        {
                std::cout<< "gen: " << gen << "\n";
                pop.run(1);
                pop.print_grid();
                sleep(1);
                system("clear");
                s = return_fn(gen,suffix); 
                pop.save(s.c_str());
                gen++;
        }
    }
    return 1;
}
