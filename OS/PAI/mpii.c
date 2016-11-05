 /*
 *Author: Manish Bhatt
 *Uses MPI to multiply created square matrix of A and B of size specified on the command line to give C.
 *recommend opening the output.txt file using textpad or something similar, and not notepad. 
 */

#include <mpi.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#define DEFAUlTSIZE = 100;			/* Size of matrices */


int SIZE = 10;

double **A, **B, **C;

double alloc_2d(double ***array, int n, int m) 
{
    /* allocate the n*m contiguous items */
    double *p = (double *)malloc(n*m*sizeof(double));
    if (!p) return -1;

    /* allocate the row pointers into the memory */
    (*array) = (double **)malloc(n*sizeof(double*));
    if (!(*array)) 
    {
        free(p);
        return -1;
    }

    /* set up the pointers into the contiguous memory */
    int i;
    for (i=0; i<n; i++) 
        (*array)[i] = &(p[i*m]);

    return 0.0;
}  


void fill_matrix(double **m)
{
  
  int i, j;
  for (i=0; i<SIZE; i++)
    for (j=0; j<SIZE; j++)
      m[i][j] =(double)(rand()/RAND_MAX % 100+100.0);
}

void print_matrix (double **m)
{
  int i, j = 0;
  for (i=0; i<SIZE; i++) {
    printf("\n\t| ");
    for (j=0; j<SIZE; j++)
      printf("%2f ", m[i][j]);
    printf("|");
  }
}



void main(int argc, char *argv[])
{
  
  //read the size from command line
 
  
  if (argc==2)
     SIZE = (int) strtol(argv[1], NULL, 0);
  //printf ("%d", SIZE);
  
  
  alloc_2d( &A, SIZE, SIZE);
  alloc_2d( &B, SIZE, SIZE);
  alloc_2d( &C, SIZE, SIZE);

  int myrank, P, from, to, i, j, k;
  int tag = 666;		/* any value will do */
  MPI_Status status;
  
  MPI_Init (&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &myrank);	/* who am i */
  MPI_Comm_size(MPI_COMM_WORLD, &P); /* number of processors */
  MPI_Barrier(MPI_COMM_WORLD); /* IMPORTANT */
  double start = MPI_Wtime();

 

  from = myrank * SIZE/P;
  to = (myrank+1) * SIZE/P;

  /* Process 0 fills the input matrices and broadcasts them to the rest */
  /* (actually, only the relevant stripe of A is sent to each process) */

  if (myrank==0) {
   
    fill_matrix(A);
    fill_matrix(B);

    
  }

  



  MPI_Bcast (&(B[0][0]), SIZE*SIZE, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  MPI_Scatter (&(A[0][0]), SIZE*SIZE/P, MPI_DOUBLE, &(A[from][0]), SIZE*SIZE/P, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  
  

  for (i=from; i<to; i++) 
    for (j=0; j<SIZE; j++) {
      C[i][j]=0;
      for (k=0; k<SIZE; k++)
	C[i][j] += A[i][k]*B[k][j];
    }
  MPI_Barrier (MPI_COMM_WORLD);

  MPI_Gather (&(C[from][0]), SIZE*SIZE/P, MPI_DOUBLE, &(C[0][0]), SIZE*SIZE/P, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  if (myrank==0) {
    printf("\n\n");
    print_matrix(A);
    printf("\n\n\t       * \n");
    print_matrix(B);
    printf("\n\n\t       = \n");
    print_matrix(C);
    printf("\n\n");
  }

  MPI_Barrier(MPI_COMM_WORLD); /* IMPORTANT */
  double end = MPI_Wtime();
  
  	
  if (myrank == 0) { 
	printf ( "%d, %d,  %f \n", P, SIZE, end-start);
}
  MPI_Finalize();
  
}




