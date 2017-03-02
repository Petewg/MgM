/*
 * src/include/pg_config_ext.h.win32.  This is generated manually, not by
 * autoheader, since we want to limit which symbols get defined here.
 */

/* Define to the name of a signed 64-bit integer type. */
#if ( defined( __BORLANDC__ ) && __BORLANDC__ < 1410 ) // 1410 or ?
#define PG_INT64_TYPE __int64
#else 
#define PG_INT64_TYPE long long int
#endif
