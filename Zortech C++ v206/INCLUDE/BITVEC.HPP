#ifndef BITVECHPP
#define BITVECHPP

extern int _allocerr;

class bitvec {
    unsigned nbits;
    unsigned char *body;
public:
    bitvec(int n) {
        nbits = (n | 7)+1;
        body = new unsigned char[nbits/8];
        if (!body) { _allocerr = 1; return; }
        memset(body,'\0',nbits/8);
    }
    bitvec(bitvec& a) {
        nbits = a.nbits;
        body = new unsigned char[nbits/8];
        if (!body) { _allocerr = 1; return; }
        memmove(body,a.body,nbits/8);
    }
    ~bitvec() { delete body; }
    int operator[](int i)
        { return (body[i >> 3] & 1 << (i & 7))? 1: 0; }
    int set(int i) {
        if (i < 0 || i >= nbits)
            return 0;
        body[i >> 3] |= 1 << (i & 7);
        return 1;
    }
    int reset(int i) {
        if (i < 0 || i >= nbits)
            return 0;
        body[i >> 3] &= ~(1 << (i & 7));
        return 1;
    }
};
#endif
