#define  PI  3.141592654

main()            /* Example 6.8 */
{
  int    i;
  double sin();   /* standard library function for sine */
  double cos();   /* standard library function for cosine */
  double log();   /* standard library function for logarithm */

  /* 3 element array of pointers to functions returning double */
  double (*trig_function[3])();

  trig_function[0] = sin;
  trig_function[1] = cos;
  trig_function[2] = log;

  /* print the values of sin(PI), cos(PI), and log(PI) */
  for (i=0; i<3; i++) printf("%f\n", (*trig_function[i])(PI));
}
