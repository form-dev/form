/* #[ License : */
/*
 *   Copyright (C) 1984-2026 J.A.M. Vermaseren
 *   When using this file you are requested to refer to the publication
 *   J.A.M.Vermaseren "New features of FORM" math-ph/0010025
 *   This is considered a matter of courtesy as the development was paid
 *   for by FOM the Dutch physics granting agency and we would like to
 *   be able to track its scientific use to convince FOM of its value
 *   for the community.
 *
 *   This file is part of FORM.
 *
 *   FORM is free software: you can redistribute it and/or modify it under the
 *   terms of the GNU General Public License as published by the Free Software
 *   Foundation, either version 3 of the License, or (at your option) any later
 *   version.
 *
 *   FORM is distributed in the hope that it will be useful, but WITHOUT ANY
 *   WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 *   FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 *   details.
 *
 *   You should have received a copy of the GNU General Public License along
 *   with FORM.  If not, see <http://www.gnu.org/licenses/>.
 */
/* #] License : */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

// A timing routine for debugging. Only on Unix (where sys/time.h is available).
#ifdef UNIX

#include <sys/time.h>
#include <cstdlib>
#include <cstdio>
#include <string>

#ifndef timersub
/* timersub is not in POSIX, but presents on most BSD derivatives.
   This implementation is borrowed from glibc. (TU 23 Oct 2011) */
#define timersub(a, b, result) \
	do { \
		(result)->tv_sec = (a)->tv_sec - (b)->tv_sec; \
		(result)->tv_usec = (a)->tv_usec - (b)->tv_usec; \
		if ((result)->tv_usec < 0) { \
			--(result)->tv_sec; \
			(result)->tv_usec += 1000000; \
		} \
	} while (0)
#endif

bool starttime_set = false;
timeval starttime;

/* DEBUG_EXCL_START: debug timing helpers; all call sites are under #ifdef DEBUG/#ifdef DEBUGALL which the build never defines */
double thetime () {
	if (!starttime_set) {
		gettimeofday(&starttime,NULL);
		starttime_set=true;
	}
	
  timeval now,diff;
  gettimeofday(&now,NULL);
  timersub(&now,&starttime,&diff);
  return diff.tv_sec+diff.tv_usec/1000000.0;
}

std::string thetime_str() {
	char res[10];
	snprintf (res,10,"%.4lf", thetime());
	return res;
/* DEBUG_EXCL_STOP */
}

#endif  // UNIX
