#include <iostream>
#include <cstdlib>
#include <chrono>
#include "conway.h"
#include "conway_gpu.h"

#define p_init 0.2
#define pad    10

using namespace cgl;
using namespace cgl_gpu;
using namespace std;
using namespace std::chrono;

// aliases for types used in timing host code
using clock_type    = std::chrono::high_resolution_clock;
using duration_type = std::chrono::duration<double>;

// return the time in seconds since the get_time function was first called
// for demos only: not threadsafe
static double get_time() {
    static auto start_time = clock_type::now();
    return duration_type(clock_type::now()-start_time).count();
}


int main(int argc, char *argv[]) 
{
    // Get gridsize
    size_t nx  = atoi(argv[1]);
    size_t ny  = atoi(argv[2]);
    int n_iter = atoi(argv[3]);

    // Creting cpu population
    conway pcpu     = conway(nx,ny,pad,p_init,'o');
    // Creting gpu population
    conway_gpu pgpu = conway_gpu(nx,ny,pad,p_init,'o');

    // pcpu.print_grid();
    // cout << "\n\n";
    // pgpu.print_grid();

    // SIMULATE CPU
    auto start = get_time();
    pcpu.run(n_iter);
    // CPU time
    auto t_cpu = (get_time() - start);

    // SIMULATE GPU
    start = get_time();
    pgpu.run(n_iter);
    // CPU time
    auto t_gpu = (get_time() - start);

    // Compare final configuration of the grid
    auto err = 0;
    int** grid_cpu = pcpu.get_grid();
    int*  grid_gpu = pgpu.get_grid();
    size_t pos;
    for(auto i=0; i<pcpu.get_nx(); i++)
    {
        for(auto j=0; j<pcpu.get_ny(); j++)
        {
            pos = i*pgpu.get_ny()+j;
            err += (grid_cpu[i][j]-grid_gpu[pos]);
        }
    }

    // Printing benchmark
    cout << "---------------------------------------------------\n";
    cout << "grid size: " << (nx+pad)*(ny+pad) <<  " CPU: " << t_cpu << ", GPU: " << t_gpu << ", err: " << err << "\n";
    cout << "---------------------------------------------------\n";

    // pcpu.print_grid();
    // cout << "\n\n";
    // pgpu.print_grid();


}
