/** @file padic.c
 *
 *  This file contains the p-adic runtime integration.
 *  The implementation follows the same integration points as float.c:
 *  - a dedicated internal function `padic_` used as coefficient carrier,
 *  - statement support (`ToPadic`) in compiler/executor,
 *  - normalization/sorting helper routines for coefficient arithmetic,
 *  - print support with `Format padicprint`.
 *
 *  The numerical backend is FLINT's padic module.
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
  	#[ Includes: padic.c
*/
#include "form3.h"
#include <stdio.h>
#include <string.h>

/*
 * FLINT's padic mpq conversion API requires gmp.h to be included before
 * flint headers.
 */
#include <gmp.h>
#if defined(WINDOWS)
// flint.h defines WORD(xx), which conflicts with the one defined in form3.h.
// see also flintinterface.h
#undef WORD
#endif

#include <flint/flint.h>
#include <flint/fmpz.h>
#include <flint/fmpq.h>
#include <flint/padic.h>

#if defined(WINDOWS)
// Redefine WORD here to match form3.h.
#undef WORD
#define WORD FORM_WORD
#endif

/*
	FORM keeps a single active p-adic context per run:
	- prime p
	- precision N
	The context is configured by #StartPadic / #EndPadic.

	Note: the internal `padic_` coefficient carrier does not store p itself.
	The active `PadicContext` is assumed when unpacking and
	operating on p-adic coefficients.
*/
#define PadicActive            AC.activePadic
#define PadicPrecision         AC.activePadicPrecision
#define ActivePadicContext     AC.activePadicContext
#define PadicContext           ((padic_ctx_struct *)(ActivePadicContext))

/*
	Thread-local aux storage. The pointer is stored in AT.padic_aux_.
*/
typedef struct PADIC_AUX_ {
	/*
		All p-adic operations are done through this per-thread scratch space.
		This avoids repeated init/clear churn while sorting/normalizing and keeps
		GMP/FLINT temporaries thread-local.
	*/
	padic_t p1;
	padic_t p2;
	padic_t p3;
	/* Used by PackPadic() to build a canonical (reduced) representation. */
	padic_t p4;
	/* Scratch rational used by FORM <-> padic/fmpq conversions. */
	fmpq_t q1;
} PADIC_AUX;

/*
	AT.padic_aux_ is allocated by StartPadicSystem() for all threads.
	When p-adics are not active this pointer is 0.
*/
#define PadicAux ((PADIC_AUX *)(AT.padic_aux_))
#define paux1 (PadicAux->p1)
#define paux2 (PadicAux->p2)
#define paux3 (PadicAux->p3)
#define paux4 (PadicAux->p4)
#define pauxq1 (PadicAux->q1)

/*
 	#] Includes : 
  	#[ Helpers :
		#[ AllocatePadicPrintBuffer :
*/
/*
	Allocate a conservative print buffer for FLINT's p-adic series printing.
	FLINT owns the exact formatting; this just keeps the print buffer large
	enough: each coefficient c_n*p^n may need at most
		2*digits_p + digits_exp + 5
	characters as 0<= c_n < p.
	We also need room for surrounding parentheses and the string terminator.
*/
static void AllocatePadicPrintBuffer(LONG ncoeffs, const fmpz_t prime, LONG maxexp)
{
	size_t digits_p = fmpz_sizeinbase(prime,10), digits_exp = 1;

	if ( ncoeffs < 1 ) ncoeffs = 1;
	if ( digits_p == 0 ) digits_p = 1;
	while ( maxexp >= 10 ) {
		maxexp /= 10;
		digits_exp++;
	}

	if ( AO.padicspace ) M_free(AO.padicspace,"padicspace");
	AO.padicncoeffs = ncoeffs;
	AO.padicsize = (LONG)(ncoeffs*(2*digits_p + digits_exp + 5) + 3);
	AO.padicspace = (UBYTE *)Malloc1((size_t)AO.padicsize,"padicspace");
}
/*
 		#] AllocatePadicPrintBuffer :
 		#[ InitPadicAux :
*/
static void InitPadicAux(PADIC_AUX *aux, LONG prec)
{
	padic_init2(aux->p1, (slong)prec);
	padic_init2(aux->p2, (slong)prec);
	padic_init2(aux->p3, (slong)prec);
	padic_init2(aux->p4, (slong)prec);
	fmpq_init(aux->q1);
}
/*
 		#] InitPadicAux :
 		#[ ClearSinglePadicAux :
*/
static void ClearSinglePadicAux(PADIC_AUX *aux)
{
	padic_clear(aux->p1);
	padic_clear(aux->p2);
	padic_clear(aux->p3);
	padic_clear(aux->p4);
	fmpq_clear(aux->q1);
}
/*
 		#] ClearSinglePadicAux :
 		#[ AllocatePadicAux :
*/
static void AllocatePadicAux(void)
{
#ifdef WITHPTHREADS
	int id, totnum;
	totnum = AM.totalnumberofthreads;
#ifdef WITHSORTBOTS
	totnum = MaX(2 * AM.totalnumberofthreads - 3, AM.totalnumberofthreads);
#endif
	for ( id = 0; id < totnum; id++ ) {
		PADIC_AUX *aux;
		if ( AB[id]->T.padic_aux_ ) {
			ClearSinglePadicAux((PADIC_AUX *)(AB[id]->T.padic_aux_));
			M_free(AB[id]->T.padic_aux_,"AB[id]->T.padic_aux_");
			AB[id]->T.padic_aux_ = 0;
		}
		aux = Malloc1(sizeof(PADIC_AUX),"AB[id]->T.padic_aux_");
		InitPadicAux(aux,PadicPrecision);
		AB[id]->T.padic_aux_ = (void *)aux;
	}
#else
	PADIC_AUX *aux;
	/*
		Single-thread build: AT.padic_aux_ is the only instance.
	*/
	if ( AT.padic_aux_ ) {
		ClearSinglePadicAux((PADIC_AUX *)(AT.padic_aux_));
		M_free(AT.padic_aux_,"AT.padic_aux_");
		AT.padic_aux_ = 0;
	}
	aux = Malloc1(sizeof(PADIC_AUX),"AT.padic_aux_");
	InitPadicAux(aux,PadicPrecision);
	AT.padic_aux_ = (void *)aux;
#endif
}
/*
 		#] AllocatePadicAux :
 		#[ ClearPadicAux :
*/
static void ClearPadicAux(void)
{
#ifdef WITHPTHREADS
	int id, totnum;
	totnum = AM.totalnumberofthreads;
#ifdef WITHSORTBOTS
	totnum = MaX(2 * AM.totalnumberofthreads - 3, AM.totalnumberofthreads);
#endif
	for ( id = 0; id < totnum; id++ ) {
		if ( AB[id]->T.padic_aux_ ) {
			ClearSinglePadicAux((PADIC_AUX *)(AB[id]->T.padic_aux_));
			M_free(AB[id]->T.padic_aux_,"AB[id]->T.padic_aux_");
			AB[id]->T.padic_aux_ = 0;
		}
	}
#else
	if ( AT.padic_aux_ ) {
		ClearSinglePadicAux((PADIC_AUX *)(AT.padic_aux_));
		M_free(AT.padic_aux_,"AT.padic_aux_");
		AT.padic_aux_ = 0;
	}
#endif
}
/*
 		#] ClearPadicAux :
 		#[ StartPadicSystem :

	Initializes (or reinitializes) the single global p-adic context.
	Called by #StartPadic from the preprocessor.

	This function:
	- clears the previous context if active,
	- initializes FLINT's padic_ctx_struct for (p,N),
	- allocates per-thread scratch objects (AT.padic_aux_ / AB[id]->T.padic_aux_),
	- allocate buffer space for an output string.
*/
int StartPadicSystem(UBYTE *p, LONG N)
{
	fmpz_t prime;
	slong ctxmax;
	LONG maxexp;
	int error = 0;
	fmpz_init(prime);
	if ( fmpz_set_str(prime,(char *)p,10) || fmpz_cmp_ui(prime,1) <= 0 ) {
		MesPrint("@Illegal prime number in %#StartPadic: %s",p);
		error = 1;
	}
	else if ( fmpz_is_prime(prime) != 1 ) {
		MesPrint("@The first parameter in %#StartPadic should be prime: %s",p);
		error = 1;
	}
	if ( error == 0 ) {
		if ( PadicActive ) { // Clear the previous padic system
			ClearPadicSystem();
		}
		PadicPrecision = N;
		/*
			FLINT contexts cache nonnegative powers p^e, min <= e <= max and
			require 0 <= min <= max. For N < 0 an empty cache range is sufficient
			and FLINT computes any needed positive powers on demand.
		*/
		ActivePadicContext = Malloc1(sizeof(padic_ctx_struct),"PadicContext");
		ctxmax = (N > 0) ? (slong)N : 0;
		padic_ctx_init(PadicContext,prime,0,ctxmax,PADIC_SERIES);
		// Allocate the auxiliary variables
		AllocatePadicAux();
		// Allocate buffer space for an output string
		maxexp = ABS(N-1);
		AllocatePadicPrintBuffer((N > 0) ? N : 1,prime,maxexp);

		PadicActive = 1;
	}
	fmpz_clear(prime);
	return(error);
}
/*
 		#] StartPadicSystem :
 		#[ ClearPadicSystem :

	Releases all runtime state associated with p-adic arithmetic, including:
	- per-thread aux buffers,
	- the FLINT context,
	- cached print buffer AO.padicspace.
*/
void ClearPadicSystem(void)
{
	ClearPadicAux();
	if ( PadicActive ) {
		padic_ctx_clear(PadicContext);
	}
	if ( ActivePadicContext ) {
		M_free(ActivePadicContext,"PadicContext");
		ActivePadicContext = 0;
	}
	PadicActive = 0;
	PadicPrecision = 0;
	if ( AO.padicspace ) {
		M_free(AO.padicspace,"padicspace");
		AO.padicspace = 0;
	}
	AO.padicsize = 0;
	AO.padicncoeffs = 0;
}
/*
 		#] ClearPadicSystem :
  	#] Helpers :
  	#[ Internal p-adic function format :
 		#[ Explanations :

	p-adic coefficients are stored in a special function padic_ whose 
	arguments contain the relevant p-adic information from the FLINT library:
	    padic_(v, N, u)
	where
	- v is the p-adic valuation,
	- N is the precision stored with this coefficient,
	- u is the FLINT unit.

	The prime p is not stored in the function. It is supplied by the active 
	p-adic context configured through #StartPadic / #EndPadic. The unit
	u is stored in the numerator of a normal FORM integer with denominator 1. 
	Note: we could store p in the denominator as p cannot divide u.

		#] Explanations :
 		#[ TestPadic :

	Checks whether fun has the shape of a legal padic_ with its arguments:
	    padic_(v,N,u)

	Return value:
	- 1 if fun is a syntactically valid padic_ function,
	- 0 otherwise.
*/
int TestPadic(WORD *fun)
{
	WORD *f, *fstop;
	WORD nargs, nnum, i;

	f = fun + FUNHEAD;
	fstop = fun + fun[1];
	nargs = 0;
	while ( f < fstop ) {
		nargs++;
		NEXTARG(f);
	}
	if ( nargs != 3 || f != fstop ) return(0);

	f = fun + FUNHEAD;
	/* v: signed LONG argument */
	if ( *f == -SNUMBER ) {
		f += 2;
	}
	else {
		if ( *f != ARGHEAD+6 ) return(0);
		if ( ABS(f[ARGHEAD+5]) != 5 ) return(0);
		if ( f[ARGHEAD+3] != 1 ) return(0);
		if ( f[ARGHEAD+4] != 0 ) return(0);
		f += *f;
	}
	/* N: signed LONG argument.  FLINT supports absolute precision at,
	   above, and below O(p^0). */
	if ( *f == -SNUMBER ) {
		f += 2;
	}
	else {
		if ( *f != ARGHEAD+6 ) return(0);
		if ( ABS(f[ARGHEAD+5]) != 5 ) return(0);
		if ( f[ARGHEAD+3] != 1 ) return(0);
		if ( f[ARGHEAD+4] != 0 ) return(0);
		f += *f;
	}
	/* u: FORM integer (-SNUMBER or long integer n/1). */
	if ( *f == -SNUMBER ) {
		f += 2;
	}
	else {
		nnum = (WORD)((ABS(f[*f-1])-1)/2);
		if ( nnum <= 0 ) return(0);
		if ( *f != ARGHEAD + 2*nnum + 2 ) return(0);
		if ( f[ARGHEAD] != 2*nnum + 2 ) return(0);
		/* Denominator must be exactly 1. */
		f += ARGHEAD + nnum + 1;
		if ( f[0] != 1 ) return(0);
		for ( i = 1; i < nnum; i++ ) {
			if ( f[i] != 0 ) return(0);
		}
	}
	return(1);
}
/*
 		#] TestPadic :
 		#[ UnpackPadic :

	Converts the arguments of a padic_ function back into FLINT's padic_t.
	We shouldn't come here if the p-adic system is turned off. 

	Return value:
	- 0  on success,
	- -1 if fun is not a valid internal p-adic function.
*/
static int UnpackPadic(padic_t out, WORD *fun)
{
	WORD *f;
	ULONG x;

	if ( !PadicActive ) {
		MLOCK(ErrorMessageLock);
		MesPrint("Illegal attempt at using a padic_ function without proper startup.");
		MesPrint("Please use %#StartPadic <p>,<N> first.");
		MUNLOCK(ErrorMessageLock);
		Terminate(-1);
	}

	if ( TestPadic(fun) == 0 ) return(-1);

	/*
		Read the argument triplet in order: v, N, u.
	*/
	f = fun + FUNHEAD;

	/*
		TestPadic() already validated the arguments of padic_, 
		so we can safely decode v, N and u here.
	*/
	if ( *f == -SNUMBER ) {
		padic_val(out) = (slong)f[1];
		f += 2;
	}
	else {
		x = ((ULONG)(UWORD)f[ARGHEAD+2] << BITSINWORD) + (UWORD)f[ARGHEAD+1];
		padic_val(out) = (f[ARGHEAD+5] < 0) ? -(slong)x : (slong)x;
		f += *f;
	}

	if ( *f == -SNUMBER ) {
		padic_prec(out) = (slong)f[1];
		f += 2;
	}
	else {
		x = ((ULONG)(UWORD)f[ARGHEAD+2] << BITSINWORD) + (UWORD)f[ARGHEAD+1];
		padic_prec(out) = (f[ARGHEAD+5] < 0) ? -(slong)x : (slong)x;
		f += *f;
	}

	/*
		Decode the unit u.
	*/
	if ( *f == -SNUMBER ) {
		fmpz_set_si(padic_unit(out),(slong)(f[1]));
	}
	else {
		WORD size, nnum;
		size = f[*f-1];
		nnum = (WORD)((ABS(size)-1)/2);
		flint_fmpz_set_form(padic_unit(out),(UWORD *)(f+ARGHEAD+1),
			(size < 0) ? -nnum : nnum);
	}

	padic_reduce(out,PadicContext);
	return(0);
}
/*
 		#] UnpackPadic :
 		#[ PackPadic :

	Converts a FLINT's padic_t into FORM's internal padic notation:
	    padic_(v,N,u)

	Return value:
	- the number of WORDs written to fun.
*/
static int PackPadic(WORD *fun, padic_t in)
{
	WORD *t;
	LONG v, N, small;
	ULONG x;
	WORD *arg;
	WORD nnum, nabs, i;
	GETIDENTITY

	/*
		Normalize first so the (v,N,u) triplet is canonical.
	*/
	padic_set(paux4,in,PadicContext);
	padic_reduce(paux4,PadicContext);
	v = (LONG)padic_val(paux4);
	N = (LONG)padic_prec(paux4);

	/*
		We now fill the function with the three arguments:
		valuation v, precision N, and unit u.
	*/
	t = fun;
	*t++ = PADICFUN;
	t++; // fun[1] (function length) is filled at the end.
	FILLFUN(t);

	/*
		Pack valuation v:
		compact -SNUMBER when it fits in WORD, otherwise as a two-word
		long integer argument.
	*/
	if ( v >= WORD_MIN_VALUE && v <= WORD_MAX_VALUE ) {
		*t++ = -SNUMBER;
		*t++ = (WORD)v;
	}
	else {
		x = ( v < 0 ) ? (ULONG)(-v) : (ULONG)v;
		*t++ = ARGHEAD + 6;
		*t++ = 0;
		FILLARG(t);
		*t++ = 6;
		*t++ = (UWORD)x;
		*t++ = (UWORD)(x >> BITSINWORD);
		*t++ = 1;
		*t++ = 0;
		*t++ = (v < 0) ? -5 : 5;
	}
	/*
		Pack precision N.
	*/
	if ( N >= WORD_MIN_VALUE && N <= WORD_MAX_VALUE ) {
		*t++ = -SNUMBER;
		*t++ = (WORD)N;
	}
	else {
		x = ( N < 0 ) ? (ULONG)(-N) : (ULONG)N;
		*t++ = ARGHEAD + 6;
		*t++ = 0;
		FILLARG(t);
		*t++ = 6;
		*t++ = (UWORD)x;
		*t++ = (UWORD)(x >> BITSINWORD);
		*t++ = 1;
		*t++ = 0;
		*t++ = (N < 0) ? -5 : 5;
	}
	/*
		Pack unit u in the numerator of a FORM integer.
		use -SNUMBER for small values, otherwise FORM long-integer.
	*/
	if ( fmpz_fits_si(padic_unit(paux4))
	  && (small = (LONG)fmpz_get_si(padic_unit(paux4)),
	      small >= WORD_MIN_VALUE && small <= WORD_MAX_VALUE) ) {
		*t++ = -SNUMBER;
		*t++ = (WORD)small;
	}
	else {
		arg = t + ARGHEAD + 1;
		// Numerator
		nnum = flint_fmpz_get_form(padic_unit(paux4),arg);
		nabs = ABS(nnum);
		// Denominator 
		arg += nabs;
		*arg++ = 1;
		for ( i = 1; i < nabs; i++ ) *arg++ = 0;
		*arg++ = ( nnum < 0 ) ? -(2*nabs+1) : (2*nabs+1);
		// Arghead etc.
		*t++ = ARGHEAD + 2*nabs + 2;
		*t++ = 0; 
		FILLARG(t);
		*t++ = 2*nabs + 2;
		t = arg;
	}
	fun[1] = t - fun;
	return(fun[1]);
}
/*
 		#] PackPadic :
  	#] Internal p-adic function format :
  	#[ Rekenen :
		#[ FormRatToFmpq :

	Converts the internal FORM rational coefficient encoding (formrat/ratsize)
	to a FLINT rational fmpq.

	Maybe this should be moved to flintinterface.cc?
*/
static void FormRatToFmpq(fmpq_t result, UWORD *formrat, WORD ratsize)
{
	WORD nnum, nden;
	UWORD *num, *den;
	int sign = 1;

	if ( ratsize < 0 ) {
		sign = -1;
		ratsize = -ratsize;
	}

	nnum = nden = (ratsize-1)/2;
	num = formrat;
	den = formrat + nnum;
	/* Remove padding */
	while ( nnum > 0 && num[nnum-1] == 0 ) nnum--;
	while ( nden > 0 && den[nden-1] == 0 ) nden--;

	if ( nnum > 0 ) {
		flint_fmpz_set_form(fmpq_numref(result),num,sign*nnum);
	}
	else {
		fmpz_zero(fmpq_numref(result));
	}
	flint_fmpz_set_form(fmpq_denref(result),den,nden);

	fmpq_canonicalise(result);
}
/*
		#] FormRatToFmpq :
 		#[ MulRatToPadic :

	Multiplies an existing `padic_` coefficient by a FORM rational coefficient.
	This is used by Normalize() when a term contains both a numeric coefficient
	and a `padic_` function.

	Return value:
	- 0  on success, with a non-zero product packed into outfun,
	- 1  if the product is p-adic zero,
	- -1 on runtime/validation failure.
*/
int MulRatToPadic(PHEAD WORD *outfun, WORD *infun, UWORD *formrat, WORD nrat)
{
	if ( !PadicActive ) return(-1);
	if ( UnpackPadic(paux1,infun) ) return(-1);
	FormRatToFmpq(pauxq1,formrat,nrat);
	padic_set_fmpq(paux2,pauxq1,PadicContext);
	padic_mul(paux3,paux1,paux2,PadicContext);
	PackPadic(outfun,paux3);
	if ( padic_is_zero(paux3) ) return(1);
	return(0);
}
/*
 		#] MulRatToPadic :
 		#[ MulPadics :

	Multiplies two padic_ functions (fun1 * fun2) and stores the
	product as a new padic_ function in fun3.

	Return value:
	- 0  on success, with a non-zero product packed into fun3,
	- 1  if the product is p-adic zero,
	- -1 on runtime/validation failure.
*/
int MulPadics(PHEAD WORD *fun3, WORD *fun1, WORD *fun2)
{
	if ( !PadicActive ) return(-1);
	if ( UnpackPadic(paux1,fun1) ) return(-1);
	if ( UnpackPadic(paux2,fun2) ) return(-1);
	padic_mul(paux3,paux1,paux2,PadicContext);
	PackPadic(fun3,paux3);
	if ( padic_is_zero(paux3) ) return(1);
	return(0);
}
/*
 		#] MulPadics :
 		#[ DivPadics :

	Divides two padic_ functions (fun1 / fun2) and stores the
	quotient as a new padic_ function in fun3.
	Division by zero is a fatal runtime error.

	Return value:
	- 0  on success, with a non-zero quotient packed into fun3,
	- 1  if the quotient is p-adic zero,
	- -1 on runtime/validation failure.
*/
int DivPadics(PHEAD WORD *fun3, WORD *fun1, WORD *fun2)
{
	if ( !PadicActive ) return(-1);
	if ( UnpackPadic(paux1,fun1) ) return(-1);
	if ( UnpackPadic(paux2,fun2) ) return(-1);
	if ( padic_is_zero(paux2) ) {
		MLOCK(ErrorMessageLock);
		MesPrint("Division by zero in p-adic arithmetic.");
		MUNLOCK(ErrorMessageLock);
		Terminate(-1);
		return(-1);
	}
	padic_div(paux3,paux1,paux2,PadicContext);
	PackPadic(fun3,paux3);
	if ( padic_is_zero(paux3) ) return(1);
	return(0);
}
/*
 		#] DivPadics :
		#[ InvPadic :

	Computes the inverse 1/fun and stores the result as a new padic_ function
	in outfun. Division by zero is a fatal runtime error.

	Return value:
	- 0  on success, with a non-zero inverse packed into outfun,
	- 1  if the inverse is p-adic zero,
	- -1 on runtime/validation failure.
*/
int InvPadic(PHEAD WORD *outfun, WORD *fun)
{
	if ( !PadicActive ) return(-1);
	if ( UnpackPadic(paux1,fun) ) return(-1);
	if ( padic_is_zero(paux1) ) {
		MLOCK(ErrorMessageLock);
		MesPrint("Division by zero in p-adic arithmetic.");
		MUNLOCK(ErrorMessageLock);
		Terminate(-1);
		return(-1);
	}
	padic_inv(paux3,paux1,PadicContext);
	PackPadic(outfun,paux3);
	if ( padic_is_zero(paux3) ) return(1);
	return(0);
}
/*
		#] InvPadic :
		#[ PadicReconstruct :

	Reconstructs a FORM rational coefficient from a p-adic coefficient.

	This mirrors the FORM-level recipe

	    FromPadic, padic;
	    id padic(v?,N?,u?) = makerational_(u,`$prime'^(N-v))*$prime^v;

	but calls the same low-level reconstruction routines used by makerational_
	directly. The output is a full FORM coefficient, including the final signed
	length word. A return value of -1 is non-fatal: no unique reconstruction was
	found or an intermediate value does not fit local number storage, so
	PadicToRat should leave the original padic_ untouched.
*/
static int PadicReconstruct(PHEAD UWORD *out, WORD *nratout, WORD *fun)
{
	fmpz_t modulus, ppower;
	UWORD *u, *mod, *formpower;
	WORD *arg;
	WORD nu, nmod, npower, nred, i;
	ULONG x;
	slong v, N, modexp;
	int retval = -1;

	if ( TestPadic(fun) == 0 ) return(-1);

	// Read the argument triplet in order: v, N, u.
	arg = fun + FUNHEAD;
	if ( *arg == -SNUMBER ) {
		v = (slong)arg[1];
		arg += 2;
	}
	else {
		x = ((ULONG)(UWORD)arg[ARGHEAD+2] << BITSINWORD) + (UWORD)arg[ARGHEAD+1];
		v = (arg[ARGHEAD+5] < 0) ? -(slong)x : (slong)x;
		arg += *arg;
	}
	if ( *arg == -SNUMBER ) {
		N = (slong)arg[1];
		arg += 2;
	}
	else {
		x = ((ULONG)(UWORD)arg[ARGHEAD+2] << BITSINWORD) + (UWORD)arg[ARGHEAD+1];
		N = (arg[ARGHEAD+5] < 0) ? -(slong)x : (slong)x;
		arg += *arg;
	}

	if ( *arg == -SNUMBER && arg[1] == 0 ) {
		out[0] = 0;
		out[1] = 1;
		*nratout = INCLENG(1);
		out[2] = (UWORD)ABS(*nratout);
		return(0);
	}
	modexp = N - v;
	if ( modexp <= 0 ) return(-1);

	fmpz_init(modulus);
	fmpz_init(ppower);
	u = NumberMalloc("PadicReconstruct");
	mod = NumberMalloc("PadicReconstruct");
	formpower = NumberMalloc("PadicReconstruct");

	if ( *arg == -SNUMBER ) {
		nu = (arg[1] < 0) ? -1 : 1;
		u[0] = (arg[1] < 0) ? (UWORD)(-arg[1]) : (UWORD)arg[1];
	}
	else {
		nu = (WORD)((ABS(arg[*arg-1])-1)/2);
		if ( arg[*arg-1] < 0 ) nu = -nu;
		for ( i = 0; i < ABS(nu); i++ ) u[i] = (UWORD)arg[ARGHEAD+1+i];
	}

	/* mod = modulus = p^(N-v). */
	fmpz_pow_ui(modulus,PadicContext->p,(ulong)modexp);
	nmod = flint_fmpz_get_form(modulus,(WORD *)mod);

	/*
		Match makerational_: rational reconstruction works with the residue
		class u mod p^(N-v), so reduce u in place when it lies outside the
		modulus range. The quotient is not needed.
	*/
	if ( BigLong(u,ABS(nu),mod,nmod) >= 0 ) {
		UWORD *quotient = NumberMalloc("PadicReconstruct");
		UWORD *remainder = NumberMalloc("PadicReconstruct");
		WORD nquot, nrem;

		if ( DivLong(u,nu,mod,nmod,quotient,&nquot,remainder,&nrem) ) {
			NumberFree(remainder,"PadicReconstruct");
			NumberFree(quotient,"PadicReconstruct");
			goto ClearAndReturn;
		}
		for ( i = 0; i < ABS(nrem); i++ ) u[i] = remainder[i];
		nu = nrem;
		NumberFree(quotient,"PadicReconstruct");
		NumberFree(remainder,"PadicReconstruct");
		if ( nu == 0 ) {
			out[0] = 0;
			out[1] = 1;
			nred = 1;
			goto StoreCoefficient;
		}
	}
	if ( ABS(nu) == 1 && nmod == 1
	 && u[0] <= (UWORD)WORD_MAX_VALUE
	 && mod[0] <= (UWORD)WORD_MAX_VALUE ) {
		WORD num, den;
		WORD sign = (nu < 0) ? -1 : 1;

		if ( MakeRational((WORD)u[0],(WORD)mod[0],&num,&den) ) goto ClearAndReturn;
		if ( sign < 0 ) num = -num;
		if ( num < 0 ) {
			out[0] = (UWORD)(-num);
			nred = -1;
		}
		else {
			out[0] = (UWORD)num;
			nred = 1;
		}
		out[1] = (UWORD)den;
	}
	else {
		if ( MakeLongRational(BHEAD u,nu,mod,nmod,out,&nred) ) {
			goto ClearAndReturn;
		}
	}

	/*
		The reconstruction above returns only the rational unit. Now apply the
		p-adic valuation with FORM's rational arithmetic so the coefficient is
		normalized in the same way as makerational_ output.
	*/
	if ( v > 0 ) {
		fmpz_pow_ui(ppower,PadicContext->p,(ulong)v);
		npower = flint_fmpz_get_form(ppower,(WORD *)formpower);
		if ( Mully(BHEAD out,&nred,formpower,npower) ) goto ClearAndReturn;
	}
	else if ( v < 0 ) {
		fmpz_pow_ui(ppower,PadicContext->p,(ulong)(-v));
		npower = flint_fmpz_get_form(ppower,(WORD *)formpower);
		if ( Divvy(BHEAD out,&nred,formpower,npower) ) goto ClearAndReturn;
	}

StoreCoefficient:
	*nratout = INCLENG(nred);
	out[2*ABS(nred)] = (UWORD)ABS(*nratout);
	retval = 0;

ClearAndReturn:
	NumberFree(formpower,"PadicReconstruct");
	NumberFree(mod,"PadicReconstruct");
	NumberFree(u,"PadicReconstruct");
	fmpz_clear(ppower);
	fmpz_clear(modulus);
	return(retval);
}
/*
		#] PadicReconstruct :
  	#] Rekenen :
  	#[ Printing :
		#[ PrintPadic :

	Formats a padic_ function for printing in series mode as:
		(c_v*p^v + ... + c_{N-1}*p^(N-1))
	with v the valuation and N the precision.

	The resulting C string is stored in AO.padicspace and the return value
	is the string length, or 0 if no printable p-adic string was produced.
*/
int PrintPadic(WORD *fun)
{
	GETIDENTITY
	char *out, *series;
	slong v, N;
	size_t n;
	LONG ncoeffs, maxexp;

	if ( !PadicActive ) return(0);
	if ( UnpackPadic(paux1,fun) ) return(0);

	v = padic_val(paux1);
	N = padic_prec(paux1);

	if ( N <= v ) ncoeffs = 1;
	else ncoeffs = (LONG)(N-v);

	/* Grow the print buffer when it needs to accomodate more coefficients. */
	if ( ncoeffs > AO.padicncoeffs ) {
		maxexp = MaX(ABS((LONG)v),(LONG)N);
		AllocatePadicPrintBuffer(ncoeffs,PadicContext->p,maxexp);
	}

	out = (char *)AO.padicspace;
	out[0] = '(';
	series = padic_get_str(out+1,paux1,PadicContext);
	if ( series == 0 ) return(0);
	n = strlen(series);

	out[1+n] = ')';
	out[2+n] = 0;
	return((int)(n+2));
}
/*
 		#] PrintPadic :
  	#] Printing :
  	#[ Compiler/runtime statements :
 		#[ CoToPadic :

	Compiler front-end for the `ToPadic;` statement.
	This only validates syntax and records the action; the actual conversion is
	performed on terms at execution time by ToPadic().
*/
int CoToPadic(UBYTE *s)
{
	if ( !PadicActive ) {
		MesPrint("&Illegal attempt to convert to padic_ without activating p-adic numbers.");
		MesPrint("&Forgotten %#startpadic instruction?");
		return(1);
	}
	while ( *s == ' ' || *s == ',' || *s == '\t' ) s++;
	if ( *s ) {
		MesPrint("&Illegal argument(s) in ToPadic statement: '%s'",s);
		return(1);
	}
	Add2Com(TYPETOPADIC);
	return(0);
}
/*
 		#] CoToPadic :
 		#[ CoPadicToRat :

	Compiler front-end for the `PadicToRat;` statement.
	The runtime action is implemented by PadicToRat().
*/
int CoPadicToRat(UBYTE *s)
{
	if ( !PadicActive ) {
		MesPrint("&Illegal attempt to convert from padic_ without activating p-adic numbers.");
		MesPrint("&Forgotten %#startpadic instruction?");
		return(1);
	}
	while ( *s == ' ' || *s == ',' || *s == '\t' ) s++;
	if ( *s ) {
		MesPrint("&Illegal argument(s) in PadicToRat statement: '%s'",s);
		return(1);
	}
	Add2Com(TYPEPADICTORAT);
	return(0);
}
/*
 		#] CoPadicToRat :
		#[ CoFromPadic :

	Compiler front-end for the `FromPadic, f;` statement.
	The target must be a declared regular function.
*/
int CoFromPadic(UBYTE *s)
{
	WORD numfun;
	int type;
	UBYTE *t, c;

	while ( *s == ' ' || *s == ',' || *s == '\t' ) s++;
	t = SkipAName(s);
	if ( t == 0 ) goto syntaxerror;
	c = *t; *t = 0;
	type = GetName(AC.varnames,s,&numfun,NOAUTO);
	*t = c;
	if ( type != CFUNCTION || functions[numfun].spec != 0
	  || numfun + FUNCTION == PADICFUN ) goto syntaxerror;
	while ( *t == ' ' || *t == ',' || *t == '\t' ) t++;
	if ( *t ) goto syntaxerror;
	Add3Com(TYPEFROMPADIC,numfun+FUNCTION);
	return(0);

syntaxerror:
	MesPrint("&FromPadic statement needs one declared regular function for its argument");
	return(1);
}
/*
		#] CoFromPadic :
 		#[ ToPadic :

	Runtime implementation of `ToPadic;`.

	This replaces the current rational coefficient by an explicit padic_ function
	and sets the rational coefficient to 1/1. The sign is absorbed into the
	p-adic value. If the coefficient is already 1/1 and the term already ends
	with a proper padic_ function we are done immediately.
*/
int ToPadic(PHEAD WORD *term, WORD level)
{
	GETBIDENTITY
	WORD *t, *tstop, nsize, ncoef;

	if ( !PadicActive ) return(1);

	t = term + *term;
	ncoef = t[-1];          
	nsize = ABS(ncoef);     
	tstop = t - nsize;      

	/* If there is already a proper padic_, with rational coefficient 1/1 we are done. */
	if ( ncoef == 3 && t[-2] == 1 && t[-3] == 1 ) {
		t = term + 1;
		while ( t < tstop ) {
			if ( *t == PADICFUN && (t+t[1] == tstop) && TestPadic(t) ) {
				return(Generator(BHEAD term,level));
			}
			t += t[1]; /* advance to the next function in the term */
		}
	}

	FormRatToFmpq(pauxq1,(UWORD *)tstop,ncoef);
	padic_set_fmpq(paux1,pauxq1,PadicContext);
	if ( padic_is_zero(paux1) ) return(0);
	// Overwrite the old rational coefficient of the term by padic_(v,N,u) 
	// and append rational coefficient 1/1.
	PackPadic(tstop,paux1);
	tstop += tstop[1]; /* advance past the newly written padic_ */
	*tstop++ = 1;
	*tstop++ = 1;
	*tstop++ = 3;
	*term = tstop - term;
	AT.WorkPointer = tstop;
	return(Generator(BHEAD term,level));
}
/*
 		#] ToPadic :
 		#[ PadicToRat :

	Runtime implementation of `PadicToRat;`.

	This finds a terminal `padic_` coefficient record and converts it back to a
	FORM rational coefficient by rational reconstruction. If no reconstruction
	exists at the current precision, the padic_ coefficient is left untouched.
*/
int PadicToRat(PHEAD WORD *term, WORD level)
{
	GETBIDENTITY
	static int warnflag = 1;
	WORD *tstop, *t, *stop, *from, nsize, nsign, ncoef, i;
	UWORD *rat;

	if ( !PadicActive ) return(1);

	tstop = term + *term;
	nsize = ABS(tstop[-1]);
	nsign = tstop[-1] < 0 ? -1 : 1;
	tstop -= nsize;
	t = term + 1;
	/*
		The term must end in a single proper padic_ function, followed by a unit
		coefficient 1/1 (the sign is carried separately in tstop[-1]).
	*/
	while ( t < tstop ) {
		if ( *t == PADICFUN && t + t[1] == tstop && TestPadic(t)
		 && nsize == 3 && tstop[0] == 1 && tstop[1] == 1 ) break;
		t += t[1];
	}
	if ( t < tstop ) {
		rat = (UWORD *)TermMalloc("PadicToRat");
		if ( PadicReconstruct(BHEAD rat,&ncoef,t) ) {
			if ( warnflag ) {
				MLOCK(ErrorMessageLock);
				if ( warnflag ) {
					MesPrint("%w Warning: p-adic coefficient could not be reconstructed in PadicToRat");
					warnflag = 0;
				}
				MUNLOCK(ErrorMessageLock);
			}
			TermFree((WORD *)rat,"PadicToRat");
			return(Generator(BHEAD term,level));
		}
		if ( rat[0] == 0 && rat[1] == 1 && ncoef == 3 ) {
			TermFree((WORD *)rat,"PadicToRat");
			return(0);
		}
		stop = (WORD *)(((UBYTE *)term) + AM.MaxTer);
		if ( t + ABS(ncoef) > stop ) {
			MLOCK(ErrorMessageLock);
			MesPrint("Term too complex after p-adic to rational conversion. MaxTermSize = %10l",
				AM.MaxTer/sizeof(WORD));
			MUNLOCK(ErrorMessageLock);
			TermFree((WORD *)rat,"PadicToRat");
			Terminate(-1);
			return(1);
		}
		from = (WORD *)rat;
		i = ABS(ncoef);
		NCOPY(t,from,i)
		t[-1] = ncoef*nsign;
		*term = t - term;
		TermFree((WORD *)rat,"PadicToRat");
	}
	return(Generator(BHEAD term,level));
}
/*
 		#] PadicToRat :
		#[ FromPadic :

	Runtime implementation of `FromPadic, f;`.
	Each syntactically valid padic_(v,N,u) at the current execution level is
	rewritten in place to f(v,N,u).
*/
int FromPadic(PHEAD WORD *term, WORD level, WORD target)
{
	GETBIDENTITY
	WORD *t, *tstop;

	tstop = term + *term;
	tstop -= ABS(tstop[-1]);
	t = term + 1;
	while ( t < tstop ) {
		if ( *t == PADICFUN && TestPadic(t) ) *t = target;
		t += t[1];
	}
	return(Generator(BHEAD term,level));
}
/*
		#] FromPadic :
  	#] Compiler/runtime statements :
  	#[ Sorting :
 		#[ AddWithPadic :

	Sort helper used when two otherwise identical terms differ only in their
	coefficient and that coefficient involves padic_.

	Compare1() in sort.c sets AT.SortPadicMode to indicate which term(s) carry a
	padic_ coefficient record:
	- 3: both terms end with a proper padic_ record
	- 1: only *ps1 has padic_, *ps2 has a rational coefficient
	- 2: only *ps2 has padic_, *ps1 has a rational coefficient

	AddWithPadic computes the p-adic sum and rewrites *ps1 to contain exactly one
	padic_ record and a unit coefficient 1/1. It tries to reuse term space in
	place and otherwise allocates in the sort buffer.
*/
int AddWithPadic(PHEAD WORD **ps1, WORD **ps2)
{
	GETBIDENTITY
	SORTING *S = AT.SS;
	WORD *coef1, *coef2, size1, size2, *fun1, *fun2, *fun3;
	WORD *s1, *s2, *t1, *t2, i, j, jj;

	if ( !PadicActive ) return(0);

	s1 = *ps1;
	s2 = *ps2;
	coef1 = s1 + *s1; size1 = coef1[-1]; coef1 -= ABS(size1);
	coef2 = s2 + *s2; size2 = coef2[-1]; coef2 -= ABS(size2);

	if ( AT.SortPadicMode == 3 ) {
		/* Both coefficients are padic_: unpack and apply external +/- sign. */
		fun1 = s1+1; while ( fun1 < coef1 && fun1[0] != PADICFUN ) fun1 += fun1[1];
		fun2 = s2+1; while ( fun2 < coef2 && fun2[0] != PADICFUN ) fun2 += fun2[1];
		UnpackPadic(paux1,fun1);
		if ( size1 < 0 ) padic_neg(paux1,paux1,PadicContext);
		UnpackPadic(paux2,fun2);
		if ( size2 < 0 ) padic_neg(paux2,paux2,PadicContext);
	}
	else if ( AT.SortPadicMode == 1 ) {
		/* First coefficient is padic_, second is rational. */
		fun1 = s1+1; while ( fun1 < coef1 && fun1[0] != PADICFUN ) fun1 += fun1[1];
		UnpackPadic(paux1,fun1);
		if ( size1 < 0 ) padic_neg(paux1,paux1,PadicContext);
		fun2 = coef2;
		FormRatToFmpq(pauxq1,(UWORD *)coef2,size2);
		padic_set_fmpq(paux2,pauxq1,PadicContext);
	}
	else if ( AT.SortPadicMode == 2 ) {
		/* Second coefficient is padic_, first is rational. */
		fun2 = s2+1; while ( fun2 < coef2 && fun2[0] != PADICFUN ) fun2 += fun2[1];
		UnpackPadic(paux2,fun2);
		if ( size2 < 0 ) padic_neg(paux2,paux2,PadicContext);
		fun1 = coef1;
		FormRatToFmpq(pauxq1,(UWORD *)coef1,size1);
		padic_set_fmpq(paux1,pauxq1,PadicContext);
	}
	else {
		MLOCK(ErrorMessageLock);
		MesPrint("Illegal value %d for AT.SortPadicMode in AddWithPadic.",AT.SortPadicMode);
		MUNLOCK(ErrorMessageLock);
		Terminate(-1);
		return(0);
	}

	padic_add(paux3,paux1,paux2,PadicContext);
	if ( padic_is_zero(paux3) ) {
		/* Terms cancel. */
		*ps1 = *ps2 = 0;
		AT.SortPadicMode = 0;
		return(0);
	}

	fun3 = TermMalloc("AddWithPadic");
	PackPadic(fun3,paux3);

	if ( AT.SortPadicMode == 3 ) {
		/* Prefer overwriting an existing padic_ record in-place if it fits. */
		if ( fun1[1] == fun3[1] ) {
Over1:
			i = fun3[1]; t1 = fun1; t2 = fun3; NCOPY(t1,t2,i);
			*t1++ = 1; *t1++ = 1; *t1++ = 3;
			*s1 = t1-s1; goto Finished;
		}
		else if ( fun2[1] == fun3[1] ) {
Over2:
			i = fun3[1]; t1 = fun2; t2 = fun3; NCOPY(t1,t2,i);
			*t1++ = 1; *t1++ = 1; *t1++ = 3;
			*s2 = t1-s2; *ps1 = s2; goto Finished;
		}
		else if ( fun1[1] >= fun3[1] ) goto Over1;
		else if ( fun2[1] >= fun3[1] ) goto Over2;
	}
	else if ( AT.SortPadicMode == 1 ) {
		if ( fun1[1] >= fun3[1] ) goto Over1;
		else if ( fun3[1]+3 <= ABS(size2) ) goto Over2;
	}
	else if ( AT.SortPadicMode == 2 ) {
		if ( fun2[1] >= fun3[1] ) goto Over2;
		else if ( fun3[1]+3 <= ABS(size1) ) goto Over1;
	}

	jj = fun1-s1;
	/* Required space: prefix + padic_ record + coefficient words (1,1,3). */
	j = jj+fun3[1]+3;
	if ( (S->sFill + j) >= S->sTop2 ) {
		/* Make space in the sort buffer and refresh pointers. */
		GarbHand();
		s1 = *ps1;
		fun1 = s1+jj;
	}
	t1 = S->sFill;
	for ( i = 0; i < jj; i++ ) *t1++ = s1[i];
	i = fun3[1]; s1 = fun3; NCOPY(t1,s1,i);
	*t1++ = 1; *t1++ = 1; *t1++ = 3;
	*ps1 = S->sFill;
	**ps1 = t1-*ps1;
	S->sFill = t1;

Finished:
	*ps2 = 0;
	TermFree(fun3,"AddWithPadic");
	AT.SortPadicMode = 0;
	if ( **ps1 > AM.MaxTer/((LONG)(sizeof(WORD))) ) {
		MLOCK(ErrorMessageLock);
		MesPrint("Term too complex after p-adic addition in sort. MaxTermSize = %10l",
			AM.MaxTer/sizeof(WORD));
		MUNLOCK(ErrorMessageLock);
		Terminate(-1);
	}
	return(1);
}
/*
  		#] AddWithPadic :
  		#[ MergeWithPadic :

	Variant of AddWithPadic used during patch merging: it computes the p-adic sum
	and rewrites term1 in-place if possible, otherwise it shifts/overwrites
	memory so that *interm1 points to the updated term.
*/
int MergeWithPadic(PHEAD WORD **interm1, WORD **interm2)
{
	GETBIDENTITY
	WORD *coef1, *coef2, size1, size2, *fun1, *fun2, *fun3, *tt;
	WORD jj, *t1, *t2, i, *term1 = *interm1, *term2 = *interm2;
	int retval = 0;

	if ( !PadicActive ) return(0);

	coef1 = term1+*term1; size1 = coef1[-1]; coef1 -= ABS(size1);
	coef2 = term2+*term2; size2 = coef2[-1]; coef2 -= ABS(size2);
	if ( AT.SortPadicMode == 3 ) {
		fun1 = term1+1; while ( fun1 < coef1 && fun1[0] != PADICFUN ) fun1 += fun1[1];
		fun2 = term2+1; while ( fun2 < coef2 && fun2[0] != PADICFUN ) fun2 += fun2[1];
		UnpackPadic(paux1,fun1);
		if ( size1 < 0 ) padic_neg(paux1,paux1,PadicContext);
		UnpackPadic(paux2,fun2);
		if ( size2 < 0 ) padic_neg(paux2,paux2,PadicContext);
	}
	else if ( AT.SortPadicMode == 1 ) {
		fun1 = term1+1; while ( fun1 < coef1 && fun1[0] != PADICFUN ) fun1 += fun1[1];
		UnpackPadic(paux1,fun1);
		if ( size1 < 0 ) padic_neg(paux1,paux1,PadicContext);
		fun2 = coef2;
		FormRatToFmpq(pauxq1,(UWORD *)coef2,size2);
		padic_set_fmpq(paux2,pauxq1,PadicContext);
	}
	else if ( AT.SortPadicMode == 2 ) {
		fun2 = term2+1; while ( fun2 < coef2 && fun2[0] != PADICFUN ) fun2 += fun2[1];
		fun1 = coef1;
		FormRatToFmpq(pauxq1,(UWORD *)coef1,size1);
		padic_set_fmpq(paux1,pauxq1,PadicContext);
		UnpackPadic(paux2,fun2);
		if ( size2 < 0 ) padic_neg(paux2,paux2,PadicContext);
	}
	else {
		MLOCK(ErrorMessageLock);
		MesPrint("Illegal value %d for AT.SortPadicMode in MergeWithPadic.",AT.SortPadicMode);
		MUNLOCK(ErrorMessageLock);
		Terminate(-1);
		return(0);
	}

	padic_add(paux3,paux1,paux2,PadicContext);
	if ( padic_is_zero(paux3) ) {
		AT.SortPadicMode = 0;
		return(0);
	}

	fun3 = TermMalloc("MergeWithPadic");
	PackPadic(fun3,paux3);
	if ( AT.SortPadicMode == 3 ) {
		if ( fun1[1] + ABS(size1) == fun3[1] + 3 ) {
OnTopOf1:
			/* The new (padic_ + 1/1) fits exactly on top of the old suffix. */
			t1 = fun3; t2 = fun1;
			for ( i = 0; i < fun3[1]; i++ ) *t2++ = *t1++;
			*t2++ = 1; *t2++ = 1; *t2++ = 3;
			retval = 1;
		}
		else if ( fun1[1] + ABS(size1) > fun3[1] + 3 ) {
Shift1:
			/* There is slack in term1; shift the tail down and rewrite in place. */
			t2 = term1 + *term1; tt = t2;
			*--t2 = 3; *--t2 = 1; *--t2 = 1;
			t1 = fun3 + fun3[1];
			for ( i = 0; i < fun3[1]; i++ ) *--t2 = *--t1;
			t1 = fun1;
			while ( t1 > term1 ) *--t2 = *--t1;
			*t2 = tt-t2; term1 = t2;
			retval = 1;
		}
		else {
			jj = fun3[1]-fun1[1]+3-ABS(size1);
Over1:
			/* term1 needs to grow: move the start pointer back by jj words. */
			t2 = term1-jj; t1 = term1;
			while ( t1 < fun1 ) *t2++ = *t1++;
			term1 -= jj;
			*term1 += jj;
			for ( i = 0; i < fun3[1]; i++ ) *t2++ = fun3[i];
			*t2++ = 1; *t2++ = 1; *t2++ = 3;
			retval = 1;
		}
	}
	else if ( AT.SortPadicMode == 1 ) {
		if ( fun1[1] + ABS(size1) == fun3[1] + 3 ) goto OnTopOf1;
		else if ( fun1[1] + ABS(size1) > fun3[1] + 3 ) goto Shift1;
		else {
			jj = fun3[1]-fun1[1]+3-ABS(size1);
			goto Over1;
		}
	}
	else {
		if ( fun3[1] + 3 == ABS(size1) ) goto OnTopOf1;
		else if ( fun3[1] + 3 < ABS(size1) ) goto Shift1;
		else {
			jj = fun3[1]+3-ABS(size1);
			goto Over1;
		}
	}
	*interm1 = term1;
	TermFree(fun3,"MergeWithPadic");
	AT.SortPadicMode = 0;
	return(retval);
}
/*
 		#] MergeWithPadic :
  	#] Sorting :
*/
