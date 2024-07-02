/*_ freq.c   Sun Oct 15 1989   Modified by: Walter Bright */
/* Written by Walter Bright */
/* Compile with: ZTC freq -ml (Use large model
	so strcmp() can handle far pointers.) */

/*
 *	Usage:	freq <infile >outfile
 *	Pipes work well here.
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<ctype.h>
#include	<handle.h>

struct tree {
	char __handle *word;
	int count;
	struct tree __handle *left;
	struct tree __handle *right;
};

int readword(char *w, int nbytes)
{
	int c;

	do {
		c = getchar();
		if (c == EOF)
			return 0;
	} while (!isalpha(c));

	do {
		if (nbytes > 1)
			{
			*w++ = c;
			nbytes--;
			}
		c = getchar();
	} while (isalnum(c));
	*w = 0;
	return 1;
}

void tree_insert(struct tree __handle * __handle *pt, char *w)
{
	int cmp;
	struct tree __handle *p;

	while ((p = *pt) != NULL)
		{
		if ((cmp = strcmp(w,p->word)) == 0)
			goto gotit;
		pt = (cmp < 0) ? &p->left : &p->right;
		}
	p = (struct tree __handle *) 
		handle_calloc(sizeof(struct tree));

	if (!p ||  (p->word = handle_strdup(w)) == NULL)
		{
		printf("Out of memory\n");
		exit(EXIT_FAILURE);
		}
	*pt = p;
gotit:
	p->count++;
}

tree_print(struct tree __handle *p)
{
	while (p)
		{
		tree_print(p->left);
		printf("%5d %s\n",p->count,(char far *)p->word);
		p = p->right;
		}
}

tree_free(struct tree __handle *p)
{
	struct tree __handle *pn;

	while (p)
		{
		handle_free(p->word);
		tree_free(p->left);
		pn = p->right;
		handle_free(p);
		p = pn;
		}
}

main()
{
	struct tree __handle *root = NULL;
	char word[32];

	while (readword(word,sizeof(word)))
		tree_insert(&root, word);
	tree_print(root);
	tree_free(root);
	return EXIT_SUCCESS;
}
