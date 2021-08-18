#include <stdlib.h>

// From https://stackoverflow.com/questions/30464119/how-to-use-new-instead-of-malloc-to-allocate-a-2d-array-dynamically
int **array2D(int n_rows,int n_cols) {
    // allocate memories related to the number of rows
    int** matrix = new int*[n_rows];

    // allocate memories related to the number of columns of each row
    for(auto i = 0; i < n_rows; i++)
    {
        matrix[i] = new int[n_cols];
    }
    return matrix;
}

int **zeros(int n_rows,int n_cols) {
    int **matrix = array2D(n_rows,n_cols);

    for(auto i=0;i<n_rows;i++) {
        for(auto j=0;j<n_cols;j++) {
            matrix[i][j]=0;
        }
    }
    return matrix;
}
