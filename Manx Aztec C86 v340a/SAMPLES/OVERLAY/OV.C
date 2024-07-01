
main()
{
	int a;

    printf("overlay tester\n");
	a = ovloader("ov1", "first message");
	printf("in main. ov1 returned %d\n", a);
	a = ovloader("ov2", "second message");
	printf("in main. ov2 returned %d\n", a);
	printf("Press a key...");

	a = getchar();
	exit(0);
}

