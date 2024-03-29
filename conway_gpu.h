// Header for Conway's game of life class definition
#include <cstddef>

namespace cgl_gpu
{
    namespace kernels
    {
        __global__
        void update_state(int* x, std::size_t nx, std::size_t ny);
    }
    class conway_gpu
    {
        private:
            // Grid size
            std::size_t nx, ny;
            // Padding of the board
            int pad;
            // Probability of initialize
            float p_init;
            // Number of alive neighbors for each cell
            int* n_alive;
            // Grid in host memory
            int* grid_host;
            // Grid in device memory
            int* grid_device;
            // Individual char representation
            char ind;
            // Allocate grid
            int* allocate_grid(const char* target);
            // Initialize grid
            void initialize_grid(float p_init);
            // Initialize grid
            void initialize_grid(int* init);
            // Copy data from host to device
            void update_device();
            // Copy data from device to host
            void update_host();
            // Update method
            void update_state(int* x, std::size_t nx, std::size_t ny);
        public:
            // Default constructor
            conway_gpu();
            // Con_structor defining grid size and initial population
            conway_gpu(std::size_t nx, std::size_t ny, int pad, float p_init);
            // Con_structor defining grid size and char representing and individual
            conway_gpu(std::size_t nx, std::size_t ny, int pad, float p_init, char ind);
            // Con_structor defining grid size and char representing and individual and initial state
            conway_gpu(std::size_t nx, std::size_t ny, int pad, int* init,   char ind);
            
            //____________________________________VISUALIZATION METHODS___________________________________//
            void print_grid();
            
            //_________________________________________RUN METHODS________________________________________//
            void run(int n_gens);

            //_________________________________________GET METHODS________________________________________//
            int* get_grid();
            int get_nx();
            int get_ny();
            int get_pad();
            int get_gridsize();
            
            void save(const char* filename);
    };
} // Conway's game of life (cgl) namespace
