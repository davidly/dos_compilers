#define NULL 0
#define st_alloc(size)  malloc((size)+2)

#if !defined(STRING)
typedef struct {
    int     length;
    char    string[80];
} STRING;
#endif

enum COMPVALUE {LESS, EQUAL, GREATER};

STRING *bldstr(s,len)
   char *s;
   int len;
{
   STRING *ss;
   ss = st_alloc(len);
   if (ss != NULL) {
      ss->length = len;
      memcpy(ss->string,s,len);
      }
   return ss;
   }

void getstr(str, arr, len)
   STRING *str;
   char *arr;
   int len;
{
   int size;
   if (str == NULL) memset(arr,' ',len);
   else {
      if (str->length > len) size = len; else size = str->length;
      memcpy(arr,str->string,size);
      if (size < len) memset(&arr[size],' ',len-size);
      }
   }

int len(str)
   STRING *str;
{
   return str->length;
   }

STRING *left$(str, position)
   STRING *str;
   int position;
{
   int size;
   STRING *s;
   if ((str == NULL) || (position < 0)) size = 0;
   else {
      if (position < str->length) size = position;
      else size = str->length;
      }
   s = st_alloc(size);
   if (s != NULL) {
      s->length = size;
      memcpy(s->string,str->string,size);
      }
   return s;
   }

STRING *right$(str, position)
   STRING *str;
   int position;
{
   int size;
   STRING *s;
   if (str == NULL) size = 0;
   else {
      if (position <= 0 || position > str->length) size = 0;
      else size = str->length-position+1;
      }
   s = st_alloc(size);
   if (s != NULL) {
      s->length = size;
      memcpy(s->string,&str->string[position-1],size);
      }
   return s;
   }

STRING *mid$(str, position, length)
   STRING *str;
   int position;
   int length;
{
   int size;
   STRING *s;
   if (str == NULL) size = 0;
   else {
      if (position <= 0) size = str->length;
      else if (position > str->length) size = 0;
      else size = str->length - position + 1;
      }
   if (length < size) size = length;
   s = st_alloc(size);
   if (s != NULL) {
      s->length = size;
      memcpy(s->string,&str->string[position-1],size);
      }
   return s;
   }

STRING *str$(length, ch)
   int length;
   int ch;
{
   STRING *s;
   s = st_alloc(length);
   if (s != NULL) {
      s->length = length;
      memset(s->string,ch,length);
      }
   return s;
   }

char character(s, position)
   STRING *s;
   int position;
{
   if (s == NULL) return '\r';
   if ((s->length <= 0) || (position <= 0) || (position > s->length))
      return '\r';
   return s->string[position-1];
   }

enum COMPVALUE cmpstr(s1, s2)
   STRING *s1;
   STRING *s2;
{
   int len;
   int cmp;
   if (s1 == s2) return EQUAL;
   if (s1 == NULL) return LESS;
   if (s2 == NULL) return GREATER;
   len = s1->length;
   if (s2->length < len) len = s2->length;
   cmp = memcmp(s1->string,s2->string,len);
   if (cmp < 0) return LESS;
   if (cmp > 0) return GREATER;
   if (s1->length > s2->length) return GREATER;
   if (s1->length < s2->length) return LESS;
   return EQUAL;
   }

STRING *conc(s1,s2)
   STRING *s1;
   STRING *s2;
{
   STRING *s;
   int size1, size2;
   if (s1 == NULL) size1 = 0; else size1 = s1->length;
   if (s2 == NULL) size2 = 0; else size2 = s2->length;
   s = st_alloc(size1+size2);
   if (s != NULL) {
      s->length = size1+size2;
      if (size1) memcpy(s->string,s1->string,size1);
      if (size2) memcpy(&s->string[size1],s2->string,size2);
      }
   return s;
   }

STRING *insert(substring, s, position)
   STRING *substring;
   STRING *s;
   int position;
{
   STRING *st;
   int size1, size2, pos;
   if (s == NULL) size1 = 0; else size1 = s->length;
   if (substring == NULL) size2 = 0; else size2 = substring->length;
   pos = position;
   if (pos <= 0) pos = 1;
   if (pos > size1) pos = size1+1;
   st = st_alloc(size1+size2);
   if (st != NULL) {
      st->length = size1+size2;
      memcpy(st->string,s->string,pos-1);
      memcpy(&st->string[pos-1],substring->string,size2);
      memcpy(&st->string[pos-1+size2],&s->string[pos-1],size1+1-pos);
      }
   return st;
   }

STRING *delete(str, position, length)
   STRING *str;
   int position;
   int length;

{
   STRING *st;
   int size;
   int pos = position;
   if (pos <= 0) {
      length = length-pos-1;
      pos = 1;
      }
   if (length < 0) length = 0;
   if (str == NULL) size = 0;
   else {
      if (pos > str->length) size = str->length;
      else if (pos+length > str->length) size = pos-1;
      else size = str->length-length;
      }
   st = st_alloc(size);
   if (st != NULL) {
      st->length = size;
      if (pos) memcpy(st->string,str->string,pos-1);
      if (size+1-pos)
         memcpy(&st->string[pos-1],&str->string[length+pos-1],size+1-pos);
      }
   return st;
   }

STRING *replace(oldstring, newstring, s)
   STRING *oldstring;
   STRING *newstring;
   STRING *s;
{
   STRING *st;
   int loc, size;
   int oldsz, newsz;
   loc = find(oldstring,s);
   if (loc == 0) return cpystr(s);
   oldsz = oldstring->length;
   newsz = newstring->length;
   size = s->length+newsz-oldsz;
   st = st_alloc(size);
   if (st != NULL) {
      st->length = size;
      memcpy(st->string,s->string,loc-1);
      memcpy(&st->string[loc-1],newstring->string,newsz);
      memcpy(&st->string[loc-1+newsz],&s->string[loc-1+oldsz],size-newsz-loc+1);
      }
   }

int find(substring, s)
   STRING *substring;
   STRING *s;
{
   int limit, at, size;
   if (s == NULL) return 0;
   if (substring == NULL) return (s->length > 0) ? 1 : 0;
   if (s->length == 0) return 0;
   if (substring->length == 0) return 1;
   limit = s->length - substring->length;
   at = 0;
   size = substring->length;
   while (at <= limit) {
      if (memcmp(&s->string[at],substring->string,size) == 0)
         return at+1;
      ++at;
      }
   return 0;
   }

STRING *cpystr(str)
   STRING *str;
{
   STRING *s;
   int size;
   if (str == NULL) size = 0; else size = str->length;
   s = st_alloc(size);
   if (s != NULL) {
      s->length = size;
      memcpy(s->string,str->string,size);
      }
   return s;
   }

int decodei(str)
   STRING *str;
{
   int sflag = 1, value = 0;
   int len;
   char c, *p;
   if (str == NULL) return 0;
   len = str->length;
   p = str->string;
   while (isspace(*p) && len != 0) ++p, --len;
   if (len == 0) return 0;
   if (*p == '+' || *p == '-') {
      if (*p == '-') sflag = -1;
      ++p;
      --len;
      }
   while (len--) {
      if (*p > 47 && *p < 58) value = 10*value+(*p++ - 48);
      else len = 0;
      }
    return value * sflag;
}

STRING *encodei(value)
   int value;
{
   STRING *st;
   char *p;
   char sign = ' ';
   int i;
   st = st_alloc(6);
   if (st == NULL) return NULL;
   st->length = 6;
   if (value < 0) {
      if (value == -32768) {
         memcpy(st->string,"-32768",6);
         return st;
         }
      sign = '-';
      value = -value;
      }
   p = &st->string[5];
   *p = (value % 10) + 48;
   value /= 10;
   for (i = 0; i < 5; ++i) {
      if (value == 0) {
         *--p = sign;
         sign = ' ';
         }
      else {
         *--p = (value % 10) + 48;
         value /= 10;
         }
      }
   return st;
   }
