/* Tiny BLAS smoke test: calls a real Fortran-ABI BLAS symbol so the linker
   has to resolve it. dasum_ exists in OpenBLAS, Netlib, MKL (lp64), and
   Apple Accelerate. */
extern double dasum_(int *n, double *x, int *incx);

int main(void) {
  int n = 3, incx = 1;
  double x[3] = {1.0, -2.0, 3.0};
  return (int)dasum_(&n, x, &incx) == 6 ? 0 : 1;
}
