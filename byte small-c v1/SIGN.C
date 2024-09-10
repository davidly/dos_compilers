/*
** sign -- return -1, 0, +1 depending on the sign of nbr
*/
sign(nbr)  int nbr;  {
  if(nbr>0) return 1;
  if(nbr==0) return 0;
  return -1;
  }
