extern double dasum_(int *n, double *x, int *incx);

int main(void) {
  int n = 3, incx = 1;
  double x[3] = {1.0, -2.0, 3.0};
  return (int)dasum_(&n, x, &incx) == 6 ? 0 : 1;
}
