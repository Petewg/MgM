#include <stdlib.h>
#include <string.h>

static unsigned char b64e[] = {
   'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',   /*  0- 7 */
   'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',   /*  8-15 */
   'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',   /* 16-23 */
   'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',   /* 24-31 */
   'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',   /* 32-39 */
   'o', 'p', 'q', 'r', 's', 't', 'u', 'v',   /* 40-47 */
   'w', 'x', 'y', 'z', '0', '1', '2', '3',   /* 48-55 */
   '4', '5', '6', '7', '8', '9', '+', '/'    /* 56-63 */
};

static unsigned char b64d[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /* 0x00-0x0F */
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /* 0x10-0x1F */
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3e, 0x00, 0x00, 0x00, 0x3f, /* 0x20-0x2F */
   0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /* 0x30-0x3F */
   0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, /* 0x40-0x4F */
   0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, /* 0x50-0x5F */
   0x00, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, /* 0x60-0x6F */
   0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00  /* 0x70-0x7F */
};

static void b64enc (unsigned char *in, int inlen, unsigned char *out)
{
   unsigned char t0 = ( inlen > 0 ) ? in[ 0 ] : 0;
   unsigned char t1 = ( inlen > 1 ) ? in[ 1 ] : 0;
   unsigned char t2 = ( inlen > 2 ) ? in[ 2 ] : 0;

   if( inlen <= 0 )
      return;
   out[ 0 ] = b64e[ ( t0 >> 2 ) & 0x3f ];
   out[ 1 ] = b64e[ ( ( t0 << 4 ) & 0x30 ) | ( t1 >> 4 ) ];

   if( inlen <= 1 )
      return;
   out[ 2 ] = b64e[ ( ( t1 << 2 ) & 0x3c ) | ( t2 >> 6 ) ];

   if( inlen <= 2 )
      return;
   out[ 3 ] = b64e[ t2 & 0x3f ];
}

static void b64dec (unsigned char *in, int inlen, unsigned char *out)
{
   unsigned char t0 = ( inlen > 0 ) ? b64d[ in[ 0 ] & 0x7f ] : 0;
   unsigned char t1 = ( inlen > 1 ) ? b64d[ in[ 1 ] & 0x7f ] : 0;
   unsigned char t2 = ( inlen > 2 ) ? b64d[ in[ 2 ] & 0x7f ] : 0;
   unsigned char t3 = ( inlen > 3 ) ? b64d[ in[ 3 ] & 0x7f ] : 0;

   if( inlen <= 0 )
      return;
   out[ 0 ] = ( t0 << 2 ) | ( t1 >> 4 );
   if( inlen <= 1 )
   {
      out[ 1 ] = 0;
      return;
   }
   out[ 1 ] = ( t1 << 4 ) | ( ( t2 & 0x3c ) >> 2 );
   if( inlen <= 2 )
   {
      out[ 2 ] = 0;
      return;
   }
   out[ 2 ] = ( t2 << 6 ) | t3;
}

int b64encode_len (unsigned char *in)
{
   int l = strlen( ( const char * ) in);

   return 4 * ( ( l + 2 ) / 3 );
}

int b64decode_len (unsigned char *in)
{
   int l = strlen( ( const char * ) in);

   return 3 * ( ( l + 3 ) / 4 );
}

unsigned char *b64encode_alloc (unsigned char *in)
{
   int l = b64encode_len(in);
   unsigned char *n = malloc(l + 1);

   if( n != NULL )
   {
      n[ l-- ] = 0;
      while( l >= 0 )
         n[ l-- ] = '=';
   }
   return n;
}

void b64encode (unsigned char *in, unsigned char *out)
{
   int inlen = strlen( ( const char * ) in);

   while( inlen > 0 )
   {
      b64enc(in, inlen, out);
      inlen -= 3;
      in += 3;
      out += 4;
   }
}

void b64encodelen (unsigned char *in, unsigned char *out, int nLen, int nSubLen )
{
   int inlen = nLen;
   int nPos = 0;

   while( inlen > 0 )
   {
      b64enc(in, inlen, out);
      inlen -= 3;
      in += 3;
      out += 4;

      if( nSubLen > 0 )
      {
         nPos += 3;
         if( ( nPos % nSubLen ) == 0 )
         {
            out[ 0 ] = 13;
            out[ 1 ] = 10;
            out += 2;
         }
      }
   }
}

unsigned char *b64decode_alloc (unsigned char *in)
{
   int l = b64decode_len(in);
   unsigned char *n = malloc(l + 1);

   if( n != NULL )
      while( l >= 0 )
         n[ l-- ] = 0;

   return n;
}

void b64decode (unsigned char *in, unsigned char *out)
{
   int inlen = strlen( ( const char * ) in);

   while( inlen > 0 )
   {
      b64dec(in, inlen, out);
      inlen -= 4;
      in += 4;
      out += 3;
   }
}
