#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#define N 1000

double get_clock() {
  struct timeval tv; int ok;
  ok = gettimeofday(&tv, (void *) 0);
  if (ok<0) { printf("gettimeofday error"); }
  return (tv.tv_sec * 1.0 + tv.tv_usec * 1.0E-6);
}

int main() {
  int* x = malloc(sizeof(int) * N);
  int* y = malloc(sizeof(int) * N);

  for (int i = 0; i < N; i++) {
    x[i] = 1;
  }

  double t0 = get_clock();

  y[0] = x[0];
  for (int i = 1; i < N; i++) {
    y[i] = y[i-1] + x[i];
  }

  double t1 = get_clock();

  for (int i = 0; i < N; i++) {
    printf("%d ", y[i]);
  }

  printf("\n");
  printf("Time: %f ns\n", 1000000000.0*(t1 - t0));

  free(x);
  free(y);

  return 0;
}
