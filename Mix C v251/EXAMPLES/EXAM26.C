main()         /* Example 2.6 */
{
   int xx,ii;
   int yy,jj;
   
   jj = ii = 0;

   xx = jj++ + ++jj;
   printf("xx = %d, jj = %d, ii = %d\n",xx,jj,ii);

   yy = jj *= xx++ + ++ii + 3;
   printf("yy = %d, jj = %d, xx = %d, ii = %d\n",
      yy,jj,xx,ii);

   ii = ++ii;
   printf("ii = %d\n",ii);

   printf("1st --yy = %d, 2nd --yy = %d",--yy,--yy);
}
