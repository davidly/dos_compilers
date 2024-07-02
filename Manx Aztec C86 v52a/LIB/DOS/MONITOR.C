short monitor (lowpc, highpc, buffer, pockets, nfunc)
int (*lowpc)(), (*highpc)();
unsigned int *buffer;
int pockets, nfunc;
{
	return _monitor(lowpc,highpc,buffer,pockets,nfunc);
}
