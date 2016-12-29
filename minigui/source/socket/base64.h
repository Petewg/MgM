
int b64encode_len(char *in);
int b64decode_len(char *in);

void b64encode(char *in, char *out);
void b64encodelen(char *in, char *out, int nLen, int nSubLen);
void b64decode(char *in, char *out);

char *b64encode_alloc(char *in);
char *b64decode_alloc(char *in);
