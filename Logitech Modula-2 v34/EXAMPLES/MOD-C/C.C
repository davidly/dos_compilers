int far extInt=10;

char* s = "IntegerProcedure, param is %u \n";

void far pascal IntegerProcedure (x)
int x;
{
  printf (s,x);
};

void far pascal StringProcedure1 (x,string)
int x;
char* far string;
{
  printf (string);
  printf (" length received : %u \n",x);
};

void far pascal StringProcedure2 (string)
char* far string;
{
  printf (string);
  printf ("\n");
};

