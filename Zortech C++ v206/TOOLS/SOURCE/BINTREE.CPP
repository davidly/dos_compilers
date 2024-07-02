#include <bintree.hpp>

typedef void (* PFC)(int,char*);
extern void default_error(int, char*);
static PFC gbsearch_handler = default_error;

void* bintree::insert(void* p, int& n)
{
    node *last = NULL, *current = root;
    int cmp;

    if (!p) {
        gbsearch_handler(EBADARG,"gbsearch - insert called with nullpointer");
        return NULL;
    }
    while (current) {
        if ((cmp = (*cf)(p, current->body)) == 0)
            break;
        else {
            last = current;
            if (cmp < 0)
                current = current->left;
            else
                current = current->right;
        }
    }
    if (!current) {
        node *nn = new node;
        if (!nn)
            gbsearch_handler(ENOMEM,"gbsearch - not enough memory");
        nn->body = p;
        nn->left = nn->right = NULL;
        if (!last)
            root = nn;
        else if (cmp < 0)
            last->left = nn;
        else
            last->right = nn;
        n = 1;
        return(p);
    } else {
        n = 0;
        return(current->body);
    }
}

int bintree::remove(void* p)
{
    node *last = NULL, *current = root, *marked, *successor;
    int branch,cmp = 0;

    if (!p) {
        gbsearch_handler(EBADARG,"gbsearch - remove called with null pointer");
        return -1;
    }
    while (current) {
        branch = cmp;   // remember which way we moved last
        if ((cmp = (*cf)(p, current->body)) == 0)
            break;
        else {
            last = current;
            if (cmp < 0)
                current = current->left;
            else
                current = current->right;
        }
    }
    if (current) {
        marked = current;
        if (!(current->left || current->right))
            successor = NULL;             // no substitute required
        else if (!current->left)
            successor = current->right;   // right sub-tree only
        else if (!current->right)
            successor = current->left;    // left sub-tree only
        else {
            successor = current = current->right;
            while (current->left)   // seek to lowest value in right sub-tree
                current = current->left;
            current->left = marked->left;   // hang left sub-tree on there
        }
        if (last) {
            if (branch < 0)
                last->left = successor;
            else
                last->right = successor;
        } else
            root = successor;
        delete marked->body;
        delete marked;
        return(0);
    } else
        return(-1);
}

void* bintree::seek(void* p)
{
    node *last = NULL, *current = root;
    int cmp;

    while (current) {
        if ((cmp = (*cf)(p, current->body)) == 0)
            return(current->body);
        else {
            last = current;
            if (cmp < 0)
                current = current->left;
            else
                current = current->right;
        }
    }
    return(NULL);
}

void bintree::inorder(node* n, int first)
{
    node *current;

    if (first)
        current = root;
    else
        current = n;
    if (current) {
        inorder(current->left,0);
        (* visit)(current->body);
        inorder(current->right,0);
    }
}

void bintree::cleanup(node* n, int first)
{
    node *current;
    if (first) {
#ifdef DEBUG
        cout << "Tree destructor\n";
#endif
        current = root;
    } else
        current = n;
    if (current) {
        cleanup(current->left,0);
        cleanup(current->right,0);
        delete current->body;
        delete current;
    }
}

PFC set_gbsearch_handler(PFC handler)
{
    PFC loc = gbsearch_handler;
    gbsearch_handler = handler;
    return loc;
}
