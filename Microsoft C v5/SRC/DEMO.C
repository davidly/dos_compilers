main(argc, argv, envp)
	int argc;
	char **argv;
	char **envp;

	{
	register char **p;

	/* print out the argument list for this program */

	for (p = argv; argc > 0; argc--,p++) {
		printf("%s\n", *p);
		}

	/* print out the current environment settings.  Note that
	 * the environment table is terminated by a NULL entry
	 */

	for (p = envp; *p; p++) {
		printf("%s\n", *p);
		}

	exit(0);
	}
