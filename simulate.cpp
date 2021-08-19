#include <iostream>
#include <unistd.h>
#include <string>
#include "conway.h"

#define SPACESHIP false

using namespace cgl;

int main() 
{
    int n_iter;
    conway pop1;

    if(SPACESHIP==true) 
    {
        n_iter = 100;
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

        int** ship = new int*[11];
        for(int i = 0; i < 11; ++i)
            ship[i] = new int[13];

        for(int i=0; i<11; ++i) {
            for(int j=0; j<13; j++) {
                ship[i][j]=init[i][j];
            }
        }
        pop1 = conway(11,13,50, ship, '*');
    }
    else
    {
        n_iter = 300;
        pop1 = conway(40,100,10,0.2,'o');
    }
    std::string s;
    int gen = 0;
    s       =  "data/gen"+std::to_string(gen)+".txt";
    pop1.save(s.c_str());
    gen++;
    while(gen<n_iter)
    {
            std::cout<< "gen: " << gen << "\n";
            pop1.run(1);
            pop1.print_grid();
            sleep(1);
            system("clear");
            s =  "data/gen"+std::to_string(gen)+".txt";
            pop1.save(s.c_str());
            gen++;
    }

    return 1;
}

