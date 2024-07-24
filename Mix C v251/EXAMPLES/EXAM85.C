#include <stdio.h> /* include standard IO header */
#include "struct2.h" /* include structure header */
#include "labelio.c" /* include getlabel & putlabel */

menu(option)
char *option;
{
    puts("\n\nA) add a label");
    puts("D) delete a label");
    puts("P) print labels");
    puts("Q) quit\n");
    printf("   Enter option --> ");
    scanf("%c%*c", option);
}

struct label *first_label;

main()
{
    char   option;
    for(;;) {     /* loop forever */
       menu(&option);
       switch (toupper(option)) {
           case 'A' : add_label()   ; break;
           case 'D' : delete_label(); break;
           case 'P' : print_labels(); break;
           case 'Q' : exit(0);
           default  : puts("*** invalid option ***");
       }
    }
}

add_label()
{
    struct label *new_label, *current_label;
    new_label = calloc(1, sizeof(struct label));
    if (new_label != NULL) {
        new_label->next = NULL;
        getlabel(new_label);
        if (first_label == NULL) first_label = new_label;
        else {
            current_label = first_label;
            while (current_label->next != NULL)
                current_label = current_label->next;
            current_label->next = new_label;
        }
    }
    else printf("<<< Out of Memory >>>\n");
}

delete_label()
{
    struct label *current_label, *previous_label;
    char   first[15], last[15];
    printf("Enter the name : ");
    scanf("%s%s%*c", first, last);
    current_label = first_label;
    while (current_label != NULL) {
        if (strcmp(current_label->name.last, last) == 0 &&
            strcmp(current_label->name.first, first) == 0) break;
        else {
            previous_label = current_label;
            current_label = current_label->next;
        }
    }
    if (current_label == NULL) puts("*** Label not found ***");
    else {
        if (current_label == first_label)
            first_label = first_label->next;
        else
            previous_label->next = current_label->next;
        cfree(current_label);
    }
}

print_labels()
{
    struct label *current_label;
    current_label = first_label;
    puts("\n");
    while (current_label != NULL) {
        putlabel(current_label);
        current_label = current_label->next;
    }
}
