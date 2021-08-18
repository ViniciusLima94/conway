#include <iostream>
#include "conway.h"

using namespace cgl;

int main() 
{
    int** a = new int*[11];
    for(int i = 0; i < 11; ++i)
        a[i] = new int[13];

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
    // int *a[11];
    
    for(int i=0; i<11; ++i) {
        for(int j=0; j<13; j++) {
            a[i][j]=init[i][j];
        }
    }

    for(auto i=0; i<11; i++)
    {
        for(auto j=0; j<13; j++) 
        {
            std::cout << a[i][j] << ", ";
        }
        std::cout << "\n";
    }

    conway pop1 = conway(11,13,a,'o');
    // conway pop1 = conway(40,100,0.15,'o');
    pop1.simulate(10000000);

    // std::cout << "gen 0\n";
    // pop1.print_grid();
    // std::cout << "\n\n";

    // for(auto i=0; i<10; i++)
    // {
    //     pop1.run(1);
    //     std::cout << "gen " << i+1 << "\n";
    //     pop1.print_grid();
    //     std::cout << "\n\n";
    // }
        

    // pop1.run(2);
    // std::cout << "\n\n";

    // pop1.print_grid();

    return 1;
}

