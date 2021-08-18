#include <iostream>
#include "conway.h"

using namespace cgl;

int main() 
{
    conway pop1 = conway(40,40,0.1,'o');
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

