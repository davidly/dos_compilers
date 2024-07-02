
_stkover()
{
	write(2, "STACK OVERFLOW, INCREASE STACK SIZE\n", 36);
	_exit(100);
}
