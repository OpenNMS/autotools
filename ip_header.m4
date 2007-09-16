dnl check for a struct based on the first argument
AC_DEFUN([ONMS_CHECK_IP_STRUCT],
	[
		AC_CHECK_TYPE(
			[struct $1],
			[
				AC_DEFINE(
					AS_TR_CPP([HAVE_STRUCT_$1]),
					[1],
					[struct $1 needed for IP headers]
				)
			],
			[],
			[
				#include <sys/types.h>
				#include <netinet/in.h>
				#include <netinet/in_systm.h>
				#include <netinet/ip.h>
				$2
			]
		)
	]
)

dnl check for an entry in the IP struct
AC_DEFUN([ONMS_CHECK_IP_STRUCT_ENTRY],
	[
		AC_MSG_CHECKING([for ip->$2])
		AC_TRY_COMPILE(
			[
				#include <sys/types.h>
				#include <netinet/in.h>
				#include <netinet/in_systm.h>
				#include <netinet/ip.h>
			],
			[
				#if defined(HAVE_STRUCT_IP)
				struct ip ip;
				#elif defined(HAVE_STRUCT_IPHDR)
				struct iphdr ip;
				#endif
			
				ip.$2 = 0;
			],
			[
				AC_DEFINE(
					AS_TR_CPP([ONMS_IP_$1]),
					[$2],
					[the $2 entry in the IP struct]
				)
				AC_MSG_RESULT(yes)
			],
			AC_MSG_RESULT(no)
		)
	]
)

dnl check for an entry in the ICMP struct
AC_DEFUN([ONMS_CHECK_ICMP_STRUCT_ENTRY],
	[
		AC_MSG_CHECKING([for icmp->$2])
		AC_TRY_COMPILE(
			[
				#include <sys/types.h>
				#include <netinet/in.h>
				#include <netinet/in_systm.h>
				#include <netinet/ip.h>
				#include <netinet/ip_icmp.h>
			],
			[
				#if defined(HAVE_STRUCT_ICMP)
				struct icmp icmp;
				#elif defined(HAVE_STRUCT_ICMPHDR)
				struct icmphdr icmp;
				#endif
			
				icmp.$2 = 0;
			],
			[
				AC_DEFINE(
					AS_TR_CPP([ICMP_$1]),
					[$2],
					[the $2 entry in the ICMP struct]
				)
				AC_MSG_RESULT(yes)
			],
			AC_MSG_RESULT(no)
		)
	]
)

