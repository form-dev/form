#ifndef MPIDBG_H
#define MPIDBG_H

/** @file mpidbg.h
 *
 *  MPI APIs with the logging feature.
 *  NOTE: This file needs C99.
 */

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

/*
  	#[ Includes :
*/

#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <mpi.h>
#if defined(MPIDEBUGGING_DELAY_US) && MPIDEBUGGING_DELAY_US > 0
#include <unistd.h>  // for usleep()
#endif

#define MPIDBG_LINESIZE 1024
#define MPIDBG_BUFSIZE 128

/*
  	#] Includes : 
  	#[ Utilities :
 		#[ MPIDBG_RANK :
*/

static inline int MPIDBG_Get_rank(void) {
	return PF.me;  /* Assume we are working with ParFORM. */
}
#define MPIDBG_RANK MPIDBG_Get_rank()

/*
 		#] MPIDBG_RANK : 
 		#[ MPIDBG_Out :
*/

static inline void MPIDBG_Out(const char *file, int line, const char *func, const char *fmt, ...) {
	char buf[MPIDBG_LINESIZE];
	va_list ap;
	va_start(ap, fmt);
	snprintf(buf,MPIDBG_LINESIZE, "*** [%d] %10s %4d @ %-16s: ", MPIDBG_RANK, file, line, func);
	vsnprintf(buf + strlen(buf),MPIDBG_LINESIZE-strlen(buf), fmt, ap);
	va_end(ap);
	/* Assume fprintf with a line will work well even in multi-processes. */
	fprintf(stderr, "%s\n", buf);
}
#define MPIDBG_Out(...) MPIDBG_Out(file, line, func, __VA_ARGS__)

/*
 		#] MPIDBG_Out : 
 		#[ MPIDBG_insert_delay :
*/

static inline void MPIDBG_insert_delay(void)
{
#if defined(MPIDEBUGGING_DELAY_US) && MPIDEBUGGING_DELAY_US > 0
	usleep(MPIDEBUGGING_DELAY_US);
#endif
}

/*
 		#] MPIDBG_insert_delay : 
 		#[ MPIDBG_sprint_requests :
*/

static inline void MPIDBG_sprint_requests(char *buf, int count, const MPI_Request *requests)
{
	/* Assume sprintf never fail and returns >= 0... */
	buf += sprintf(buf, "(");
	int i, first = 1;
	for ( i = 0; i < count; i++ ) {
		if ( first ) {
			first = 0;
		}
		else {
			buf += sprintf(buf, ",");
		}
		if ( requests[i] != MPI_REQUEST_NULL ) {
			buf += sprintf(buf, "%d", i);
		}
		else {
			buf += sprintf(buf, "*");
		}
	}
	buf += sprintf(buf, ")");
}

/*
 		#] MPIDBG_sprint_requests : 
 		#[ MPIDBG_sprint_statuses :
*/

static inline void MPIDBG_sprint_statuses(char *buf, int count, const MPI_Request *old_requests, const MPI_Request *new_requests, const MPI_Status *statuses)
{
	/* Assume sprintf never fail and returns >= 0... */
	buf += sprintf(buf, "(");
	int i, first = 1;
	for ( i = 0; i < count; i++ ) {
		if ( first ) {
			first = 0;
		}
		else {
			buf += sprintf(buf, ",");
		}
		if ( old_requests[i] != MPI_REQUEST_NULL && new_requests[i] == MPI_REQUEST_NULL ) {
			int ret_size = 0;
			MPI_Get_count((MPI_Status *)&statuses[i], MPI_BYTE, &ret_size);
			buf += sprintf(buf, "(source=%d,tag=%d,size=%d)", statuses[i].MPI_SOURCE, statuses[i].MPI_TAG, ret_size);
		} else {
			buf += sprintf(buf, "*");
		}
	}
	buf += sprintf(buf, ")");
}

/*
 		#] MPIDBG_sprint_statuses : 
  	#] Utilities : 
  	#[ MPI APIs :
*/

/*
 * The followings are the MPI APIs with the logging.
 */

#define MPIDBG_EXTARG const char *file, int line, const char *func

/*
 		#[ MPI_Init :
*/

static inline int MPIDBG_Init(int* argc, char*** argv, MPIDBG_EXTARG)
{
	int ret = MPI_Init(argc, argv);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_Out("MPI_Init: OK");
	}
	else {
		MPIDBG_Out("MPI_Init: Failed");
	}
	return ret;
}
#define MPI_Init(...) MPIDBG_Init(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Init : 
 		#[ MPI_Finalize :
*/

static inline int MPIDBG_Finalize(MPIDBG_EXTARG)
{
	MPIDBG_Out("MPI_Finalize");
	int ret = MPI_Finalize();
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_Out("MPI_Finalize: OK");
	}
	else {
		MPIDBG_Out("MPI_Finalize: Failed");
	}
	return ret;
}
#define MPI_Finalize() MPIDBG_Finalize(__FILE__, __LINE__, __func__)

/*
 		#] MPI_Finalize : 
 		#[ MPI_Send :
*/

static inline int MPIDBG_Send(void *buf, int count, MPI_Datatype datatype, int dest, int tag, MPI_Comm comm, MPIDBG_EXTARG)
{
	MPIDBG_Out("MPI_Send: src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	int ret = MPI_Send(buf, count, datatype, dest, tag, comm);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_Out("MPI_Send: OK src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	}
	else {
		MPIDBG_Out("MPI_Send: Failed src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	}
	return ret;
}
#define MPI_Send(...) MPIDBG_Send(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Send : 
 		#[ MPI_Recv :
*/

static inline int MPIDBG_Recv(void* buf, int count, MPI_Datatype datatype, int source, int tag, MPI_Comm comm, MPI_Status *status, MPIDBG_EXTARG)
{
	MPI_Status st;
	if ( status == MPI_STATUS_IGNORE ) status = &st;
	MPIDBG_Out("MPI_Recv: src=%d dest=%d tag=%d", source, MPIDBG_RANK, tag);
	int ret = MPI_Recv(buf, count, datatype, source, tag, comm, status);
	if ( ret == MPI_SUCCESS ) {
		int ret_count = 0;
		MPI_Get_count(status, datatype, &ret_count);
		MPIDBG_Out("MPI_Recv: OK src=%d dest=%d tag=%d count=%d", status->MPI_SOURCE, MPIDBG_RANK, status->MPI_TAG, ret_count);
	}
	else {
		MPIDBG_Out("MPI_Recv: Failed src=%d dest=%d tag=%d", source, MPIDBG_RANK, tag);
	}
	return ret;
}
#define MPI_Recv(...) MPIDBG_Recv(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Recv : 
 		#[ MPI_Bsend :
*/

static inline int MPIDBG_Bsend(void* buf, int count, MPI_Datatype datatype, int dest, int tag, MPI_Comm comm, MPIDBG_EXTARG)
{
	MPIDBG_Out("MPI_Bsend: src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	int ret = MPI_Bsend(buf, count, datatype, dest, tag, comm);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_Out("MPI_Bsend: OK src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	}
	else {
		MPIDBG_Out("MPI_Bsend: Failed src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	}
	return ret;
}
#define MPI_Bsend(...) MPIDBG_Bsend(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Bsend : 
 		#[ MPI_Ssend :
*/

static inline int MPIDBG_Ssend(void* buf, int count, MPI_Datatype datatype, int dest, int tag, MPI_Comm comm, MPIDBG_EXTARG)
{
	MPIDBG_Out("MPI_Ssend: src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	int ret = MPI_Ssend(buf, count, datatype, dest, tag, comm);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_Out("MPI_Ssend: OK src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	}
	else {
		MPIDBG_Out("MPI_Ssend: Failed src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	}
	return ret;
}
#define MPI_Ssend(...) MPIDBG_Ssend(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Ssend : 
 		#[ MPI_Rsend :
*/

static inline int MPIDBG_Rsend(void* buf, int count, MPI_Datatype datatype, int dest, int tag, MPI_Comm comm, MPIDBG_EXTARG)
{
	MPIDBG_Out("MPI_Rsend: src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	int ret = MPI_Rsend(buf, count, datatype, dest, tag, comm);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_Out("MPI_Rsend: OK src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	}
	else {
		MPIDBG_Out("MPI_Rsend: Failed src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	}
	return ret;
}
#define MPI_Rsend(...) MPIDBG_Rsend(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Rsend : 
 		#[ MPI_Isend :
*/

static inline int MPIDBG_Isend(const void* buf, int count, MPI_Datatype datatype, int dest, int tag, MPI_Comm comm, MPI_Request *request, MPIDBG_EXTARG)
{
	MPIDBG_Out("MPI_Isend: src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	int ret = MPI_Isend(buf, count, datatype, dest, tag, comm, request);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_Out("MPI_Isend: OK src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	}
	else {
		MPIDBG_Out("MPI_Isend: Failed src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	}
	return ret;
}
#define MPI_Isend(...) MPIDBG_Isend(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Isend : 
 		#[ MPI_Ibsend :
*/

static inline int MPIDBG_Ibsend(void* buf, int count, MPI_Datatype datatype, int dest, int tag, MPI_Comm comm, MPI_Request *request, MPIDBG_EXTARG)
{
	MPIDBG_Out("MPI_Ibsend: src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	int ret = MPI_Ibsend(buf, count, datatype, dest, tag, comm, request);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_Out("MPI_Ibsend: OK src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	}
	else {
		MPIDBG_Out("MPI_Ibsend: Failed src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	}
	return ret;
}
#define MPI_Ibsend(...) MPIDBG_Ibsend(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Ibsend : 
 		#[ MPI_Issend :
*/

static inline int MPIDBG_Issend(void* buf, int count, MPI_Datatype datatype, int dest, int tag, MPI_Comm comm, MPI_Request *request, MPIDBG_EXTARG)
{
	MPIDBG_Out("MPI_Issend: src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	int ret = MPI_Issend(buf, count, datatype, dest, tag, comm, request);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_Out("MPI_Issend: OK src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	}
	else {
		MPIDBG_Out("MPI_Issend: Failed src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	}
	return ret;
}
#define MPI_Issend(...) MPIDBG_Issend(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Issend : 
 		#[ MPI_Irsend :
*/

static inline int MPIDBG_Irsend(void* buf, int count, MPI_Datatype datatype, int dest, int tag, MPI_Comm comm, MPI_Request *request, MPIDBG_EXTARG)
{
	MPIDBG_Out("MPI_Irsend: src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	int ret = MPI_Irsend(buf, count, datatype, dest, tag, comm, request);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_Out("MPI_Irsend: OK src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	}
	else {
		MPIDBG_Out("MPI_Irsend: Failed src=%d dest=%d tag=%d count=%d", MPIDBG_RANK, dest, tag, count);
	}
	return ret;
}
#define MPI_Irsend(...) MPIDBG_Irsend(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Irsend : 
 		#[ MPI_Irecv :
*/

static inline int MPIDBG_Irecv(void* buf, int count, MPI_Datatype datatype, int source, int tag, MPI_Comm comm, MPI_Request *request, MPIDBG_EXTARG)
{
	MPIDBG_Out("MPI_Irecv: src=%d dest=%d tag=%d", source, MPIDBG_RANK, tag);
	int ret = MPI_Irecv(buf, count, datatype, source, tag, comm, request);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_Out("MPI_Irecv: OK src=%d dest=%d tag=%d", source, MPIDBG_RANK, tag);
	}
	else {
		MPIDBG_Out("MPI_Irecv: Failed src=%d dest=%d tag=%d", source, MPIDBG_RANK, tag);
	}
	return ret;
}
#define MPI_Irecv(...) MPIDBG_Irecv(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Irecv : 
 		#[ MPI_Wait :
*/

static inline int MPIDBG_Wait(MPI_Request *request, MPI_Status *status, MPIDBG_EXTARG)
{
	MPI_Status st;
	if ( status == MPI_STATUS_IGNORE ) status = &st;
	char buf1[MPIDBG_BUFSIZE * 1], buf2[MPIDBG_BUFSIZE * 1];
	MPI_Request old_request = *request;
	MPIDBG_sprint_requests(buf1, 1, request);
	MPIDBG_Out("MPI_Wait: rank=%d request=%s", MPIDBG_RANK, buf1);
	int ret = MPI_Wait(request, status);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_sprint_statuses(buf2, 1, request, &old_request, status);
		MPIDBG_Out("MPI_Wait: OK rank=%d request=%s result=%s", MPIDBG_RANK, buf1, buf2);
	}
	else {
		MPIDBG_Out("MPI_Wait: Failed rank=%d request=%s", MPIDBG_RANK, buf1);
	}
	return ret;
}
#define MPI_Wait(...) MPIDBG_Wait(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Wait : 
 		#[ MPI_Test :
*/

static inline int MPIDBG_Test(MPI_Request *request, int *flag, MPI_Status *status, MPIDBG_EXTARG)
{
	MPI_Status st;
	if ( status == MPI_STATUS_IGNORE ) status = &st;
	char buf1[MPIDBG_BUFSIZE * 1], buf2[MPIDBG_BUFSIZE * 1];
	MPI_Request old_request = *request;
	MPIDBG_sprint_requests(buf1, 1, request);
	MPIDBG_Out("MPI_Test: rank=%d request=%s", MPIDBG_RANK, buf1);
	int ret = MPI_Test(request, flag, status);
	if ( ret == MPI_SUCCESS ) {
		if ( *flag ) {
			MPIDBG_sprint_statuses(buf2, 1, request, &old_request, status);
			MPIDBG_Out("MPI_Test: OK rank=%d request=%s result=%s", MPIDBG_RANK, buf1, buf2);
		}
		else {
			MPIDBG_Out("MPI_Test: OK rank=%d request=%s flag=false", MPIDBG_RANK, buf1);
		}
	}
	else {
		MPIDBG_Out("MPI_Test: Failed rank=%d request=%s", MPIDBG_RANK, buf1);
	}
	return ret;
}
#define MPI_Test(...) MPIDBG_Test(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Test : 
 		#[ MPI_Waitany :
*/

static inline int MPIDBG_Waitany(int count, MPI_Request *array_of_requests, int *index, MPI_Status *status, MPIDBG_EXTARG)
{
	MPI_Status st;
	if ( status == MPI_STATUS_IGNORE ) status = &st;
	char buf1[MPIDBG_BUFSIZE * 1], buf2[MPIDBG_BUFSIZE * 1];
	MPI_Request old_requests[count];
	memcpy(old_requests, array_of_requests, sizeof(MPI_Request) * count);
	MPIDBG_sprint_requests(buf1, count, array_of_requests);
	MPIDBG_Out("MPI_Waitany: rank=%d request=%s", MPIDBG_RANK, buf1);
	int ret = MPI_Waitany(count, array_of_requests, index, status);
	if ( ret == MPI_SUCCESS ) {
		MPI_Status statuses[count];
		statuses[*index] = *status;
		MPIDBG_sprint_statuses(buf2, count, old_requests, array_of_requests, statuses);
		MPIDBG_Out("MPI_Waitany: OK rank=%d request=%s result=%s", MPIDBG_RANK, buf1, buf2);
	}
	else {
		MPIDBG_Out("MPI_Waitany: Failed rank=%d request=%s", MPIDBG_RANK, buf1);
	}
	return ret;
}
#define MPI_Waitany(...) MPIDBG_Waitany(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Waitany : 
 		#[ MPI_Testany :
*/

static inline int MPIDBG_Testany(int count, MPI_Request *array_of_requests, int *index, int *flag, MPI_Status *status, MPIDBG_EXTARG)
{
	MPI_Status st;
	if ( status == MPI_STATUS_IGNORE ) status = &st;
	char buf1[MPIDBG_BUFSIZE * 1], buf2[MPIDBG_BUFSIZE * 1];
	MPI_Request old_requests[count];
	memcpy(old_requests, array_of_requests, sizeof(MPI_Request) * count);
	MPIDBG_sprint_requests(buf1, count, array_of_requests);
	MPIDBG_Out("MPI_Testany: rank=%d request=%s", MPIDBG_RANK, buf1);
	int ret = MPI_Testany(count, array_of_requests, index, flag, status);
	if ( ret == MPI_SUCCESS ) {
		if ( *flag ) {
			MPI_Status statuses[count];
			statuses[*index] = *status;
			MPIDBG_sprint_statuses(buf2, count, old_requests, array_of_requests, statuses);
			MPIDBG_Out("MPI_Testany: OK rank=%d request=%s result=%s", MPIDBG_RANK, buf1, buf2);
		}
		else {
			MPIDBG_Out("MPI_Testany: OK rank=%d request=%s flag=false", MPIDBG_RANK, buf1);
		}
	}
	else {
		MPIDBG_Out("MPI_Testany: Failed rank=%d request=%s", MPIDBG_RANK, buf1);
	}
	return ret;
}
#define MPI_Testany(...) MPIDBG_Testany(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Testany : 
 		#[ MPI_Waitall :
*/

static inline int MPIDBG_Waitall(int count, MPI_Request *array_of_requests, MPI_Status *array_of_statuses, MPIDBG_EXTARG)
{
	MPI_Status st[count];
	if ( array_of_statuses == MPI_STATUSES_IGNORE ) array_of_statuses = st;
	char buf1[MPIDBG_BUFSIZE * count], buf2[MPIDBG_BUFSIZE * count];
	MPI_Request old_requests[count];
	memcpy(old_requests, array_of_requests, sizeof(MPI_Request) * count);
	MPIDBG_sprint_requests(buf1, count, array_of_requests);
	MPIDBG_Out("MPI_Waitall: rank=%d request=%s", MPIDBG_RANK, buf1);
	int ret = MPI_Waitall(count, array_of_requests, array_of_statuses);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_sprint_statuses(buf2, count, old_requests, array_of_requests, array_of_statuses);
		MPIDBG_Out("MPI_Waitall: OK rank=%d request=%s result=%s", MPIDBG_RANK, buf1, buf2);
	}
	else {
		MPIDBG_Out("MPI_Waitall: Failed rank=%d request=%s", MPIDBG_RANK, buf1);
	}
	return ret;
}
#define MPI_Waitall(...) MPIDBG_Waitall(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Waitall : 
 		#[ MPI_Testall :
*/

static inline int MPIDBG_Testall(int count, MPI_Request *array_of_requests, int *flag, MPI_Status *array_of_statuses, MPIDBG_EXTARG)
{
	MPI_Status st[count];
	if ( array_of_statuses == MPI_STATUSES_IGNORE ) array_of_statuses = st;
	char buf1[MPIDBG_BUFSIZE * count], buf2[MPIDBG_BUFSIZE * count];
	MPI_Request old_requests[count];
	memcpy(old_requests, array_of_requests, sizeof(MPI_Request) * count);
	MPIDBG_sprint_requests(buf1, count, array_of_requests);
	MPIDBG_Out("MPI_Testall: rank=%d request=%s", MPIDBG_RANK, buf1);
	int ret = MPI_Testall(count, array_of_requests, flag, array_of_statuses);
	if ( ret == MPI_SUCCESS ) {
		if ( *flag ) {
			MPIDBG_sprint_statuses(buf2, count, old_requests, array_of_requests, array_of_statuses);
			MPIDBG_Out("MPI_Testall: OK rank=%d request=%s result=%s", MPIDBG_RANK, buf1, buf2);
		}
		else {
			MPIDBG_Out("MPI_Testall: OK rank=%d request=%s flag=false", MPIDBG_RANK, buf1);
		}
	}
	else {
		MPIDBG_Out("MPI_Testall: Failed rank=%d request=%s", MPIDBG_RANK, buf1);
	}
	return ret;
}
#define MPI_Testall(...) MPIDBG_Testall(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Testall : 
 		#[ MPI_Waitsome :
*/

static inline int MPIDBG_Waitsome(int incount, MPI_Request *array_of_requests, int *outcount, int *array_of_indices, MPI_Status *array_of_statuses, MPIDBG_EXTARG)
{
	MPI_Status st[incount];
	if ( array_of_statuses == MPI_STATUSES_IGNORE ) array_of_statuses = st;
	char buf1[MPIDBG_BUFSIZE * incount], buf2[MPIDBG_BUFSIZE * incount];
	MPI_Request old_requests[incount];
	memcpy(old_requests, array_of_requests, sizeof(MPI_Request) * incount);
	MPIDBG_sprint_requests(buf1, incount, array_of_requests);
	MPIDBG_Out("MPI_Waitsome: rank=%d request=%s", MPIDBG_RANK, buf1);
	int ret = MPI_Waitsome(incount, array_of_requests, outcount, array_of_indices, array_of_statuses);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_sprint_statuses(buf2, incount, old_requests, array_of_requests, array_of_statuses);
		MPIDBG_Out("MPI_Waitsome: OK rank=%d request=%s result=%s", MPIDBG_RANK, buf1, buf2);
	}
	else {
		MPIDBG_Out("MPI_Waitsome: Failed rank=%d request=%s", MPIDBG_RANK, buf1);
	}
	return ret;
}
#define MPI_Waitsome(...) MPIDBG_Waitsome(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Waitsome : 
 		#[ MPI_Testsome :
*/

static inline int MPIDBG_Testsome(int incount, MPI_Request *array_of_requests, int *outcount, int *array_of_indices, MPI_Status *array_of_statuses, MPIDBG_EXTARG)
{
	MPI_Status st[incount];
	if ( array_of_statuses == MPI_STATUSES_IGNORE ) array_of_statuses = st;
	char buf1[MPIDBG_BUFSIZE * incount], buf2[MPIDBG_BUFSIZE * incount];
	MPI_Request old_requests[incount];
	memcpy(old_requests, array_of_requests, sizeof(MPI_Request) * incount);
	MPIDBG_sprint_requests(buf1, incount, array_of_requests);
	MPIDBG_Out("MPI_Testsome: rank=%d request=%s", MPIDBG_RANK, buf1);
	int ret = MPI_Testsome(incount, array_of_requests, outcount, array_of_indices, array_of_statuses);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_sprint_statuses(buf2, incount, old_requests, array_of_requests, array_of_statuses);
		MPIDBG_Out("MPI_Testsome: OK rank=%d request=%s result=%s", MPIDBG_RANK, buf1, buf2);
	}
	else {
		MPIDBG_Out("MPI_Testsome: Failed rank=%d request=%s", MPIDBG_RANK, buf1);
	}
	return ret;
}
#define MPI_Testsome(...) MPIDBG_Testsome(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Testsome : 
 		#[ MPI_Iprobe :
*/

static inline int MPIDBG_Iprobe(int source, int tag, MPI_Comm comm, int *flag, MPI_Status *status, MPIDBG_EXTARG)
{
	MPI_Status st;
	if ( status == MPI_STATUS_IGNORE ) status = &st;
	MPIDBG_Out("MPI_Iprobe: src=%d dest=%d tag=%d", source, MPIDBG_RANK, tag);
	MPIDBG_insert_delay();
	int ret = MPI_Iprobe(source, tag, comm, flag, status);
	if ( ret == MPI_SUCCESS ) {
		if ( *flag ) {
			int ret_size = 0;
			MPI_Get_count(status, MPI_BYTE, &ret_size);
			MPIDBG_Out("MPI_Iprobe: OK src=%d dest=%d tag=%d size=%d", status->MPI_SOURCE, MPIDBG_RANK, status->MPI_TAG, ret_size);
		}
		else {
			MPIDBG_Out("MPI_Iprobe: OK src=%d dest=%d tag=%d flag=false", source, MPIDBG_RANK, tag);
		}
	}
	else {
		MPIDBG_Out("MPI_Iprobe: Failed src=%d dest=%d tag=%d", source, MPIDBG_RANK, tag);
	}
	return ret;
}
#define MPI_Iprobe(...) MPIDBG_Iprobe(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Iprobe : 
 		#[ MPI_Probe :
*/

static inline int MPIDBG_Probe(int source, int tag, MPI_Comm comm, MPI_Status *status, MPIDBG_EXTARG)
{
	MPI_Status st;
	if ( status == MPI_STATUS_IGNORE ) status = &st;
	MPIDBG_Out("MPI_Probe: src=%d dest=%d tag=%d", source, MPIDBG_RANK, tag);
	int ret = MPI_Probe(source, tag, comm, status);
	if ( ret == MPI_SUCCESS ) {
		int ret_size = 0;
		MPI_Get_count(status, MPI_BYTE, &ret_size);
		MPIDBG_Out("MPI_Probe: OK src=%d dest=%d tag=%d size=%d", status->MPI_SOURCE, MPIDBG_RANK, status->MPI_TAG, ret_size);
	}
	else {
		MPIDBG_Out("MPI_Probe: Failed src=%d dest=%d tag=%d", source, MPIDBG_RANK, tag);
	}
	return ret;
}
#define MPI_Probe(...) MPIDBG_Probe(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Probe : 
 		#[ MPI_Cancel :
*/

static inline int MPIDBG_Cancel(MPI_Request *request, MPIDBG_EXTARG)
{
	MPIDBG_Out("MPI_Cancel", MPIDBG_RANK);
	int ret = MPI_Cancel(request);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_Out("MPI_Cancel: OK");
	}
	else {
		MPIDBG_Out("MPI_Cancel: Failed");
	}
	return ret;
}
#define MPI_Cancel(...) MPIDBG_Cancel(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Cancel : 
 		#[ MPI_Test_cancelled :
*/

static inline int MPIDBG_Test_cancelled(MPI_Status *status, int *flag, MPIDBG_EXTARG)
{
	MPIDBG_Out("MPI_Test_cancelled", MPIDBG_RANK);
	int ret = MPI_Test_cancelled(status, flag);
	if ( ret == MPI_SUCCESS ) {
		if ( *flag ) {
			MPIDBG_Out("MPI_Test_cancelled: OK flag=true");
		}
		else {
			MPIDBG_Out("MPI_Test_cancelled: OK flag=false");
		}
	}
	else {
		MPIDBG_Out("MPI_Test_cancelled: Failed");
	}
	return ret;
}
#define MPI_Test_cancelled(...) MPIDBG_Test_cancelled(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Test_cancelled : 
 		#[ MPI_Barrier :
*/

static inline int MPIDBG_Barrier(MPI_Comm comm, MPIDBG_EXTARG)
{
	MPIDBG_Out("MPI_Barrier");
	int ret = MPI_Barrier(comm);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_Out("MPI_Barrier: OK");
	}
	else {
		MPIDBG_Out("MPI_Barrier: Failed");
	}
	return ret;
}
#define MPI_Barrier(...) MPIDBG_Barrier(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Barrier : 
 		#[ MPI_Bcast :
*/

static inline int MPIDBG_Bcast(void* buffer, int count, MPI_Datatype datatype, int root, MPI_Comm comm, MPIDBG_EXTARG)
{
	MPIDBG_Out("MPI_Bcast: root=%d count=%d", root, count);
	int ret = MPI_Bcast(buffer, count, datatype, root, comm);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_Out("MPI_Bcast: OK root=%d count=%d", root, count);
	}
	else {
		MPIDBG_Out("MPI_Bcast: Failed root=%d count=%d", root, count);
	}
	return ret;
}
#define MPI_Bcast(...) MPIDBG_Bcast(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Bcast : 
 		#[ MPI_Reduce :
*/

static inline int MPIDBG_Reduce(const void *sendbuf, void *recvbuf, int count, MPI_Datatype datatype, MPI_Op op, int root, MPI_Comm comm, MPIDBG_EXTARG)
{
	MPIDBG_Out("MPI_Reduce: root=%d count=%d", root, count);
	int ret = MPI_Reduce(sendbuf, recvbuf, count, datatype, op, root, comm);
	if ( ret == MPI_SUCCESS ) {
		MPIDBG_Out("MPI_Reduce: OK root=%d count=%d", root, count);
	}
	else {
		MPIDBG_Out("MPI_Reduce: Failed root=%d count=%d", root, count);
	}
	return ret;
}
#define MPI_Reduce(...) MPIDBG_Reduce(__VA_ARGS__, __FILE__, __LINE__, __func__)

/*
 		#] MPI_Reduce : 
  	#] MPI APIs : 
*/

#endif  /* MPIDBG_H */
