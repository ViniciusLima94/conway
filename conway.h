// Header for Conway's game of life class definition
#include <cstddef>

namespace cgl
{
    class conway
    {
        private:
            // Grid size
            std::size_t nx, ny;
            // Padding of the board
            int pad;
            // Probability of initialize
            float p_init;
            // Grid
            int** grid;
            // Individual char representation
            char ind;
            // Allocate grid
            int** allocate_grid();
            // Initialize grid
            void initialize_grid(float p_init);
            // Initialize grid
            void initialize_grid(int** init);
            // Update method
            void update_state();
            // Method to check how many live neighbors a given cell have
            int check_neighbors(int i, int j);
            // Apply the rules to a given cell
            int rules(int state, int n);
        public:
            // Default constructor
            conway();
            // Constructor defining grid size and initial population
            conway(std::size_t nx, std::size_t ny, int pad, float p_init);
            // Constructor defining grid size and char representing and individual
            conway(std::size_t nx, std::size_t ny, int pad, float p_init, char ind);
            // Constructor defining grid size and char representing and individual and initial state
            conway(std::size_t nx, std::size_t ny, int pad, int** init, char ind);
            
            //____________________________________VISUALIZATION METHODS___________________________________//
            void print_grid();
            
            //_________________________________________RUN METHODS________________________________________//
            void run(int n_gens);
            void simulate(int n_gens);

            //_________________________________________GET METHODS________________________________________//
            int** get_grid();
            int get_nx();
            int get_ny();
            int get_pad();
            int get_gridsize();
            
            //_________________________________________SET METHODS________________________________________//

    };
} // Conway's game of life (cgl) namespace
