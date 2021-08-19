#include <iostream>
#include <unistd.h>
#include "conway.h"

using namespace cgl;

int main() 
{

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
    

    // for(auto i=0; i<11; i++)
    // {
    //     for(auto j=0; j<13; j++) 
    //     {
    //         std::cout << a[i][j] << ", ";
    //     }
    //     std::cout << "\n";
    // }
    //
    // initializers::spaceship ship;

    // ship.nx = 10;
    // ship.ny = 10;
    // ship->init = zeros(ship.nx, ship.ny);

    conway pop1 = conway(11,13,50, ship, '*');
    // conway pop1 = conway(40,100,10,0.2,'o');
    // pop1.simulate(1000000000);
    // system("clear");
    // pop1.print_grid();
    int gen=0;
    while(true)
    {
            std::cout<< "gen: " << gen << "\n";
            pop1.run(1);
            pop1.print_grid();
            sleep(1);
            system("clear");
            gen++;
    }
    // std::cout<<"\n";
    // std::cout<<pop1.get_nx();
    // std::cout<<"\n";
    // std::cout<<pop1.get_ny();
    // std::cout<<"\n";
    // std::cout<<pop1.get_pad();
    // std::cout<<"\n";

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

