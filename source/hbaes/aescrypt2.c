/*
 *  AES-256 file encryption program
 *
 *  Copyright (C) 2006-2011, Brainspark B.V.
 *
 *  This file is part of PolarSSL (http://www.polarssl.org)
 *  Lead Maintainer: Paul Bakker <polarssl_maintainer at polarssl.org>
 *
 *  All rights reserved.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef _CRT_SECURE_NO_DEPRECATE
#define _CRT_SECURE_NO_DEPRECATE 1
#endif

#if defined(_WIN32)
#include <windows.h>
#if !defined(_WIN32_WCE)
#include <io.h>
#endif
#else
#include <sys/types.h>
#include <unistd.h>
#endif

#include <wingdi.h>

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#include <hbapi.h>
#include "config.h"
#include "aes.h"
#include "sha2.h"

#define MODE_ENCRYPT    0
#define MODE_DECRYPT    1

#define USAGE   \
    "\n  aescrypt2 <mode> <input filename> <output filename> <key>\n" \
    "\n   <mode>: 0 = encrypt, 1 = decrypt\n" \
    "\n  example: aescrypt2 0 file file.aes hex:E76B2413958B00E193\n" \
    "\n"
HB_FUNC( CRYPTFILEAES )
{
    int ret = 1;

    int i, n;
    int mode, lastn;
    size_t keylen;
    FILE *fkey, *fin, *fout = NULL;

    const char *p;
    const char *filein = hb_parc( 1 );
    const char *fileout = hb_parc( 2 );
    const char *passkey = hb_parc( 3 );
    unsigned char IV[16];
    unsigned char key[512];
    unsigned char digest[32];
    unsigned char buffer[1024];

    aes_context aes_ctx;
    sha2_context sha_ctx;

#if defined(_WIN32_WCE)
    long filesize, offset;
#elif defined(_WIN32)
       LARGE_INTEGER li_size;
    __int64 filesize, offset;
#else
      off_t filesize, offset;
#endif

    mode = hb_parni( 4 );

    if( ( fin = fopen( filein, "rb" ) ) == NULL )
    {
        goto exit;
    }

    if( ( fout = fopen( fileout, "wb+" ) ) == NULL )
    {
        goto exit;
    }

    /*
     * Read the secret key and clean the command line.
     */
    if( ( fkey = fopen( passkey, "rb" ) ) != NULL )
    {
        keylen = fread( key, 1, sizeof( key ), fkey );
        fclose( fkey );
    }
    else
    {
        if( memcmp( passkey, "hex:", 4 ) == 0 )
        {
            p = &passkey[4];
            keylen = 0;

            while( sscanf( p, "%02X", &n ) > 0 &&
                   keylen < (int) sizeof( key ) )
            {
                key[keylen++] = (unsigned char) n;
                p += 2;
            }
        }
        else
        {
            keylen = strlen( passkey );

            if( keylen > (int) sizeof( key ) )
                keylen = (int) sizeof( key );

            memcpy( key, passkey, keylen );
        }
    }


#if defined(_WIN32_WCE)
    filesize = fseek( fin, 0L, SEEK_END );
#else
#if defined(_WIN32)
    /*
     * Support large files (> 2Gb) on Win32
     */
    li_size.QuadPart = 0;
    li_size.LowPart  =
        SetFilePointer( (HANDLE) _get_osfhandle( _fileno( fin ) ),
                        li_size.LowPart, &li_size.HighPart, FILE_END );

    if( li_size.LowPart == 0xFFFFFFFF && GetLastError() != NO_ERROR )
    {
        goto exit;
    }

    filesize = li_size.QuadPart;
#else
    if( ( filesize = lseek( fileno( fin ), 0, SEEK_END ) ) < 0 )
    {
        goto exit;
    }
#endif
#endif

    if( fseek( fin, 0, SEEK_SET ) < 0 )
    {
        goto exit;
    }

    if( mode == MODE_ENCRYPT )
    {
        /*
         * Generate the initialization vector as:
         * IV = SHA-256( filesize || filename )[0..15]
         */
        for( i = 0; i < 8; i++ )
            buffer[i] = (unsigned char)( filesize >> ( i << 3 ) );

         p = filein;

        sha2_starts( &sha_ctx, 0 );
        sha2_update( &sha_ctx, buffer, 8 );
        sha2_update( &sha_ctx, (unsigned char *) p, strlen( p ) );
        sha2_finish( &sha_ctx, digest );

        memcpy( IV, digest, 16 );

        /*
         * The last four bits in the IV are actually used
         * to store the file size modulo the AES block size.
         */
        lastn = (int)( filesize & 0x0F );

        IV[15] = (unsigned char)
            ( ( IV[15] & 0xF0 ) | lastn );

        /*
         * Append the IV at the beginning of the output.
         */
        if( fwrite( IV, 1, 16, fout ) != 16 )
        {
            goto exit;
        }

        /*
         * Hash the IV and the secret key together 8192 times
         * using the result to setup the AES context and HMAC.
         */
        memset( digest, 0,  32 );
        memcpy( digest, IV, 16 );

        for( i = 0; i < 8192; i++ )
        {
            sha2_starts( &sha_ctx, 0 );
            sha2_update( &sha_ctx, digest, 32 );
            sha2_update( &sha_ctx, key, keylen );
            sha2_finish( &sha_ctx, digest );
        }

        memset( key, 0, sizeof( key ) );
          aes_setkey_enc( &aes_ctx, digest, 256 );
        sha2_hmac_starts( &sha_ctx, digest, 32, 0 );

        /*
         * Encrypt and write the ciphertext.
         */
        for( offset = 0; offset < filesize; offset += 16 )
        {
            n = ( filesize - offset > 16 ) ? 16 : (int)
                ( filesize - offset );

            if( fread( buffer, 1, n, fin ) != (size_t) n )
            {
                goto exit;
            }

            for( i = 0; i < 16; i++ )
                buffer[i] = (unsigned char)( buffer[i] ^ IV[i] );

            aes_crypt_ecb( &aes_ctx, AES_ENCRYPT, buffer, buffer );
            sha2_hmac_update( &sha_ctx, buffer, 16 );

            if( fwrite( buffer, 1, 16, fout ) != 16 )
            {
                goto exit;
            }

            memcpy( IV, buffer, 16 );
        }

        /*
         * Finally write the HMAC.
         */
        sha2_hmac_finish( &sha_ctx, digest );

        if( fwrite( digest, 1, 32, fout ) != 32 )
        {
            goto exit;
        }
    }

    if( mode == MODE_DECRYPT )
    {
        unsigned char tmp[16];

        /*
         *  The encrypted file must be structured as follows:
         *
         *        00 .. 15              Initialization Vector
         *        16 .. 31              AES Encrypted Block #1
         *           ..
         *      N*16 .. (N+1)*16 - 1    AES Encrypted Block #N
         *  (N+1)*16 .. (N+1)*16 + 32   HMAC-SHA-256(ciphertext)
         */
        if( filesize < 48 )
        {
            goto exit;
        }

        if( ( filesize & 0x0F ) != 0 )
        {
            goto exit;
        }

        /*
         * Substract the IV + HMAC length.
         */
        filesize -= ( 16 + 32 );

        /*
         * Read the IV and original filesize modulo 16.
         */
        if( fread( buffer, 1, 16, fin ) != 16 )
        {
            goto exit;
        }

        memcpy( IV, buffer, 16 );
        lastn = IV[15] & 0x0F;

        /*
         * Hash the IV and the secret key together 8192 times
         * using the result to setup the AES context and HMAC.
         */
        memset( digest, 0,  32 );
        memcpy( digest, IV, 16 );

        for( i = 0; i < 8192; i++ )
        {
            sha2_starts( &sha_ctx, 0 );
            sha2_update( &sha_ctx, digest, 32 );
            sha2_update( &sha_ctx, key, keylen );
            sha2_finish( &sha_ctx, digest );
        }

        memset( key, 0, sizeof( key ) );
        aes_setkey_dec( &aes_ctx, digest, 256 );
        sha2_hmac_starts( &sha_ctx, digest, 32, 0 );

        /*
         * Decrypt and write the plaintext.
         */
        for( offset = 0; offset < filesize; offset += 16 )
        {
            if( fread( buffer, 1, 16, fin ) != 16 )
            {
                goto exit;
            }

            memcpy( tmp, buffer, 16 );
 
            sha2_hmac_update( &sha_ctx, buffer, 16 );
            aes_crypt_ecb( &aes_ctx, AES_DECRYPT, buffer, buffer );
   
            for( i = 0; i < 16; i++ )
                buffer[i] = (unsigned char)( buffer[i] ^ IV[i] );

            memcpy( IV, tmp, 16 );

            n = ( lastn > 0 && offset == filesize - 16 )
                ? lastn : 16;

            if( fwrite( buffer, 1, n, fout ) != (size_t) n )
            {
                goto exit;
            }
        }

        /*
         * Verify the message authentication code.
         */
        sha2_hmac_finish( &sha_ctx, digest );

        if( fread( buffer, 1, 32, fin ) != 32 )
        {
            goto exit;
        }

        if( memcmp( digest, buffer, 32 ) != 0 )
        {
            goto exit;
        }
    }

    ret = 0;
    
exit:
    if( fin )
        fclose( fin );
    if( fout )
        fclose( fout );

    memset( buffer, 0, sizeof( buffer ) );
    memset( digest, 0, sizeof( digest ) );

    memset( &aes_ctx, 0, sizeof(  aes_context ) );
    memset( &sha_ctx, 0, sizeof( sha2_context ) );

    hb_retni( ret );
}