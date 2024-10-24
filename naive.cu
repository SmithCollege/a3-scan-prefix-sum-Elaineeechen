#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#define BLOCK_SIZE 256
#define N 1000

double get_clock() {
  struct timeval tv; int ok;
  ok = gettimeofday(&tv, (void *) 0);
  if (ok<0) { printf("gettimeofday error"); }
  return (tv.tv_sec * 1.0 + tv.tv_usec * 1.0E-6);
}

__global__ void prefix(int * X, int * Y) {
  int i = blockIdx.x*blockDim.x+threadIdx.x;
  if (i < N) {
     int sum = 0;
     for (int j = 0; j <= i; j++) {
         sum += X[j];
     }
     Y[i] = sum;
  }
}

int main() {
  int *x, *d_x, *y, *d_y;
  x = (int*)malloc(N*sizeof(int));
  y = (int*)malloc(N*sizeof(int));
  cudaMalloc(&d_x, N*sizeof(int));
  cudaMalloc(&d_y, N*sizeof(int));

  for (int i = 0; i < N; i++) {
    x[i] = 1;
  }

  cudaMemcpy(d_x, x, N*sizeof(int), cudaMemcpyHostToDevice);

  double t0 = get_clock();
  prefix<<<(N+BLOCK_SIZE-1)/BLOCK_SIZE, BLOCK_SIZE>>>(d_x,d_y);
  cudaDeviceSynchronize();
  double t1 = get_clock();

  cudaMemcpy(y, d_y, N*sizeof(int), cudaMemcpyDeviceToHost);

  printf("%s\n", cudaGetErrorString(cudaGetLastError()));
  for (int j = 0; j < N; j++) {
    printf("%d ", y[j]);
  }
  printf("\n");
  printf("Time: %f ns\n", (1000000000.0*(t1-t0)));

  cudaFree(d_x);
  cudaFree(d_y);
  free(x);
  free(y);

  return 0;
}