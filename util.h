#include <cuda.h>

using namespace std;

// Get position of array based on matrix indexes
__host__ __device__
size_t get_pos(size_t row, size_t col, size_t n_cols)
{
    return row*n_cols+col; 
}

static void cuda_check_status(cudaError_t status) {
    if(status != cudaSuccess) {
        std::cerr << "error: CUDA API call : "
                  << cudaGetErrorString(status) << std::endl;
        exit(1);
    }
}


///////////////////////////////////////////////////////////////////////////////
// allocating memory
///////////////////////////////////////////////////////////////////////////////

template <typename T>
T* malloc_host(size_t N, T value=T()) {
    T* ptr = (T*)(malloc(N*sizeof(T)));
    std::fill(ptr, ptr+N, value);

    return ptr;
}

// allocate space on GPU for n instances of type T
template <typename T>
T* malloc_device(size_t n) {
    void* p;
    auto status = cudaMalloc(&p, n*sizeof(T));
    cuda_check_status(status);
    return (T*)p;
}

// allocate managed memory
template <typename T>
T* malloc_managed(size_t n, T value=T()) {
    T* p;
    auto status = cudaMallocManaged(&p, n*sizeof(T));
    cuda_check_status(status);
    std::fill(p, p+n, value);
    return p;
}

template <typename T>
T* malloc_pinned(size_t N, T value=T()) {
    T* ptr = nullptr;
    cudaHostAlloc((void**)&ptr, N*sizeof(T), 0);

    std::fill(ptr, ptr+N, value);

    return ptr;
} 

///////////////////////////////////////////////////////////////////////////////
// copying memory
///////////////////////////////////////////////////////////////////////////////


// copy n*T from host to device
template <typename T>
void copy_to_device(T* from, T* to, size_t n) {
    cuda_check_status( cudaMemcpy(to,from,n*sizeof(T),cudaMemcpyHostToDevice) );
    // cudaFree(from);
}

// copy n*T from device to host
template <typename T>
void copy_to_host(T* from, T* to, size_t n) {
    cuda_check_status( cudaMemcpy(to,from,n*sizeof(T),cudaMemcpyDeviceToHost) );
    // cudaFree(from);
}

