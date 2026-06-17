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
#include <flint/ulong_extras.h>

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

	The internal `padic_` coefficient carrier stores p explicitly.
	Its prime must match the active `PadicContext` before the coefficient
	is used in p-adic arithmetic.
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
	/* Scratch rational used by FORM <-> padic/fmpq conversions. */
	fmpq_t q1;
	/* Scratch integer used to check the prime stored in padic_. */
	fmpz_t prime;
} PADIC_AUX;

/*
	AT.padic_aux_ is allocated by StartPadicSystem() for all threads.
	When p-adics are not active this pointer is 0.
*/
#define PadicAux ((PADIC_AUX *)(AT.padic_aux_))
#define paux1 (PadicAux->p1)
#define paux2 (PadicAux->p2)
#define paux3 (PadicAux->p3)
#define pauxq1 (PadicAux->q1)
#define pauxprime (PadicAux->prime)

static WORD GetPadicInteger(fmpz_t in, WORD *out);
static void SetPadicInteger(fmpz_t out, UWORD *in, WORD count);
static int TestNativePadicShape(const WORD *fun);
static int UnpackedPadicKnownReduced(const padic_t in, const WORD *arg);
static void SetPadicRational(padic_t out, const fmpq_t in);
static void ReduceSmallPadicQuotient(fmpz_t unit, const fmpz_t modulus, const fmpq_t q, int bounded);
static int SmallPadicRationalFits(slong N, const fmpq_t q);
static void DivideSmallPadicRational(padic_t out, const fmpq_t q, int bounded);
static int MultiplyNegativePadicFraction(PHEAD padic_t out, const padic_t in, const fmpq_t q);
static const fmpz *CachedPadicModulus(fmpz_t scratch, slong N, slong v);
static void MultiplyReducedPadics(padic_t out, const padic_t left, const padic_t right, fmpz_t scratch);
static void AddReducedPadics(PHEAD padic_t out, const padic_t in1, const padic_t in2);
static int AddPadics(PHEAD WORD *outfun, WORD *in1, WORD *in2);
static int AddRatToPadic(PHEAD WORD *outfun, WORD *infun, UWORD *formrat, WORD nrat);

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
	fmpq_init(aux->q1);
	fmpz_init(aux->prime);
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
	fmpq_clear(aux->q1);
	fmpz_clear(aux->prime);
}
/*
 		#] ClearSinglePadicAux :
 		#[ AllocatePadicAux :
*/
static void AllocatePadicAux(void)
{
#ifdef WITHPTHREADS
	int id, totnum = AM.totalnumberofthreads;
	totnum += GetNumberOfSortBots(totnum - 1);
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
	int id, totnum = AM.totalnumberofthreads;
	totnum += GetNumberOfSortBots(totnum - 1);
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
			FLINT contexts cache nonnegative powers p^e, min <= e < max.
			Include p^N when representable. For N < 0 an empty range is sufficient
			and FLINT computes any needed positive powers on demand.
		*/
		ActivePadicContext = Malloc1(sizeof(padic_ctx_struct),"PadicContext");
		ctxmax = (N > 0) ? (slong)(N+(N < (FLINT_BITS == 64 ? INT64_MAX : INT32_MAX))) : 0;
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
 		#[ GetPadicInteger :

	Converts a FLINT integer to the internal FORM integer encoding.
	On the supported limb layout, copy positive integers directly from a
	read-only GMP view. Small integers, negative integers and other layouts
	use the shared conversion, including its established sign handling.
*/
static WORD GetPadicInteger(fmpz_t in, WORD *out)
{
#if BITSINWORD == 32 && FLINT_BITS == 64 && GMP_NUMB_BITS == 64 && GMP_NAIL_BITS == 0 && defined(mpz_limbs_read)
	slong n = fmpz_size(in), i;
	if ( n > 2 && fmpz_sgn(in) > 0 ) {
		mpz_t view;
		mp_srcptr limbs;
		WORD count = (WORD)(2*n);
		flint_mpz_init_set_readonly(view,in);
		limbs = mpz_limbs_read(view);
		for ( i = 0; i < n; i++ ) {
			out[2*i] = (WORD)(UWORD)limbs[i];
			out[2*i+1] = (WORD)(UWORD)(limbs[i] >> BITSINWORD);
		}
		flint_mpz_clear_readonly(view);
		if ( out[count-1] == 0 ) count--;
		return(count);
	}
#endif
	return(flint_fmpz_get_form(in,out));
}
/*
 		#] GetPadicInteger :
 		#[ SetPadicInteger :

	Converts the internal FORM integer encoding to a FLINT integer.
	On the supported limb layout, combine at most 256 FORM words in a fixed
	128-limb (1 KiB) buffer. Other layouts and sizes use the shared conversion.
*/
static void SetPadicInteger(fmpz_t out, UWORD *in, WORD count)
{
#if BITSINWORD == 32 && FLINT_BITS == 64 && GMP_NUMB_BITS == 64 && GMP_NAIL_BITS == 0
	LONG n = count, i;
	if ( n < 0 ) n = -n;
	if ( n > 4 && n <= 256 ) {
		ulong limbs[128];
		while ( n > 0 && in[n-1] == 0 ) n--;
		if ( n > 4 ) {
			for ( i = 0; i < (n+1)/2; i++ ) {
				limbs[i] = (ulong)in[2*i];
				if ( 2*i+1 < n ) limbs[i] |= (ulong)in[2*i+1] << BITSINWORD;
			}
			fmpz_set_ui_array(out,limbs,(slong)((n+1)/2));
			if ( count < 0 ) fmpz_neg(out,out);
			return;
		}
	}
#endif
	flint_fmpz_set_form(out,in,count);
}
/*
 		#] SetPadicInteger :
  	#] Helpers :
  	#[ Internal p-adic function format :
 		#[ Explanations :

	p-adic coefficients are stored in a special function padic_ whose 
	arguments contain the relevant p-adic information from the FLINT library:
	    padic_(p, v, N, u)
	where
	- p is the prime,
	- v is the p-adic valuation,
	- N is the precision stored with this coefficient,
	- u is the FLINT unit.

	The prime p must match the active p-adic context configured through
	#StartPadic / #EndPadic. Both p and u are stored as FORM integers with
	denominator 1 on input. Inactive normalization preserves the unit encoding.
	Active arithmetic packs units as -SNUMBER or a private PADICLIMBS object
	in a one-term argument with coefficient 1/1. Its positive length
	is PADICLIMBHEAD+n; its signed count is +/-n, followed by n unsigned
	FORM limbs, least significant first. Zero uses -SNUMBER. Recognition and
	FromPadic do not require an active context.

		#] Explanations :
 		#[ TestPadicLimbTerm :
*/
int TestPadicLimbTerm(const WORD *term)
{
	LONG n;
	if ( term[0] < PADICLIMBHEAD+5 || term[1] != PADICLIMBS ) return(0);
	if ( term[2] != term[0]-4 || term[3] == WORD_MIN_VALUE ) return(0);
	n = ABS(term[3]);
	if ( n == 0 || term[2] != PADICLIMBHEAD+n ) return(0);
	if ( (UWORD)term[PADICLIMBHEAD+n] == 0 ) return(0);
	return(term[term[0]-3] == 1 && term[term[0]-2] == 1
		&& term[term[0]-1] == 3);
}
/*
 		#] TestPadicLimbTerm :
 		#[ ExpandPadicArgument :
	Write a validated PADICLIMBS argument as an ordinary integer.
	Callers must provide enough output space and ensure the length fits in WORD.
*/
int ExpandPadicArgument(WORD *out, const WORD *arg)
{
	const WORD *limbs = arg+ARGHEAD+1+PADICLIMBHEAD;
	WORD count = arg[ARGHEAD+PADICLIMBHEAD];
	LONG n = ABS(count), size = ARGHEAD+2*n+2, i;
	*out++ = (WORD)size;
	*out++ = 0;
	FILLARG(out);
	*out++ = (WORD)(2*n+2);
	i = n; NCOPY(out,limbs,i);
	*out++ = 1;
	for ( i = 1; i < n; i++ ) *out++ = 0;
	*out = (WORD)(count < 0 ? -(2*n+1) : 2*n+1);
	return((int)size);
}
/*
 		#] ExpandPadicArgument :
 		#[ TestNativePadicShape :

	Checks the common padic_(p,v,N,u) encoding with WORD-sized p, v and N.
	The unit may be a small number or a compact limb term. Return 1 for a
	valid shape, otherwise 0 so TestPadic performs its general checks.
	This checks the encoding only; it does not certify a reduced unit.
*/
static int TestNativePadicShape(const WORD *fun)
{
	const WORD *arg;
	WORD length = fun[1];
	if ( length < FUNHEAD+8 ) return(0);
	arg = fun+FUNHEAD;
	if ( arg[0] != -SNUMBER || arg[1] <= 1
	 || arg[2] != -SNUMBER || arg[4] != -SNUMBER ) return(0);
	arg += 6;
	if ( arg[0] == -SNUMBER ) return(length == FUNHEAD+8);
	if ( length < FUNHEAD+6+ARGHEAD+PADICLIMBHEAD+5
	 || arg[0] != length-FUNHEAD-6
	 || arg[ARGHEAD] != arg[0]-ARGHEAD ) return(0);
	return(TestPadicLimbTerm(arg+ARGHEAD));
}
/*
 		#] TestNativePadicShape :
 		#[ TestPadic :

	Checks whether fun has the shape of a legal padic_ with its arguments:
	    padic_(p,v,N,u)

	Return value:
	- 1 if fun is a syntactically valid padic_ function,
	- 0 otherwise.
*/
int TestPadic(WORD *fun)
{
	WORD *f, *fstop;
	WORD nargs, nnum, i;
	if ( TestNativePadicShape(fun) ) return(1);
	f = fun + FUNHEAD;
	fstop = fun + fun[1];
	nargs = 0;
	while ( f < fstop ) {
		nargs++;
		NEXTARG(f);
	}
	if ( nargs != 4 || f != fstop ) return(0);

	f = fun + FUNHEAD;
	/* p: integer greater than 1. Matching the active prime is checked separately. */
	if ( *f == -SNUMBER ) {
		if ( f[1] <= 1 ) return(0);
		f += 2;
	}
	else {
		if ( *f < ARGHEAD+4 || f[*f-1] <= 0 ) return(0);
		nnum = (WORD)((f[*f-1]-1)/2);
		if ( nnum <= 0 ) return(0);
		if ( *f != ARGHEAD + 2*nnum + 2 ) return(0);
		if ( f[ARGHEAD] != 2*nnum + 2 ) return(0);
		if ( f[ARGHEAD+nnum+1] != 1 ) return(0);
		for ( i = 1; i < nnum; i++ ) {
			if ( f[ARGHEAD+nnum+1+i] != 0 ) return(0);
		}
		if ( (UWORD)f[ARGHEAD+1] <= 1 ) {
			for ( i = 1; i < nnum; i++ ) {
				if ( f[ARGHEAD+1+i] != 0 ) break;
			}
			if ( i == nnum ) return(0);
		}
		f += *f;
	}
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
	/* u: FORM integer or private wrapped limb-list. */
	if ( *f == -SNUMBER ) {
		f += 2;
	}
	else if ( *f > 0 && f[ARGHEAD] == *f-ARGHEAD && TestPadicLimbTerm(f+ARGHEAD) ) {
		return(1);
	}
	else {
		nnum = (WORD)((ABS(fstop[-1])-1)/2);
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
 		#[ CheckPadicPrime :

	Checks the prime of a structurally valid padic_ against the active context.
	A mismatch is fatal. With no active context there is nothing to compare.
*/
void CheckPadicPrime(WORD *fun)
{
	WORD *f = fun + FUNHEAD;
	int matches;

	if ( !PadicActive ) return;
	if ( *f == -SNUMBER ) {
		matches = fmpz_equal_si(PadicContext->p,(slong)f[1]);
	}
	else {
		WORD nnum = (WORD)((f[*f-1]-1)/2);
		GETIDENTITY

		flint_fmpz_set_form(pauxprime,(UWORD *)(f+ARGHEAD+1),nnum);
		matches = fmpz_equal(pauxprime,PadicContext->p);
	}
	if ( !matches ) {
		MLOCK(ErrorMessageLock);
		MesPrint("Prime in padic_ does not match the active p-adic prime.");
		MUNLOCK(ErrorMessageLock);
		Terminate(-1);
	}
}
/*
 		#] CheckPadicPrime :
 		#[ UnpackPadic :

	Converts the arguments of a padic_ function back into FLINT's padic_t.
	Callers must ensure that fun is a legal padic_ with decodable arguments,
	either by a successful TestPadic() call or by using output from PackPadic().
	The p-adic system must be active.
*/
static void UnpackPadic(padic_t out, WORD *fun)
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

	CheckPadicPrime(fun);

	/*
		Skip the checked prime, then read v, N, u.
	*/
	f = fun + FUNHEAD;
	NEXTARG(f);

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
	/* An ordinary integer's term consists only of its coefficient. */
	else if ( f[ARGHEAD] == ABS(f[*f-1])+1 ) {
		WORD size = f[*f-1], nnum = (WORD)((ABS(size)-1)/2);
		while ( nnum && f[ARGHEAD+nnum] == 0 ) nnum--;
		SetPadicInteger(padic_unit(out),(UWORD *)(f+ARGHEAD+1),
			(size < 0) ? -nnum : nnum);
	}
	else {
		SetPadicInteger(padic_unit(out),(UWORD *)(f+ARGHEAD+1+PADICLIMBHEAD),
			f[ARGHEAD+PADICLIMBHEAD]);
	}
	if ( UnpackedPadicKnownReduced(out,f) ) return;
	padic_reduce(out,PadicContext);
}
/*
 		#] UnpackPadic :
 		#[ PackPadic :

	Converts a FLINT's padic_t into FORM's internal padic notation:
	    padic_(p,v,N,u)
	Callers must provide enough output space for the packed function.
	The FLINT value must already be reduced: for nonzero values, p does not
	divide u and 0 < u < p^(N-v); zero has u = v = 0.

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

	v = (LONG)padic_val(in);
	N = (LONG)padic_prec(in);

	t = fun;
	*t++ = PADICFUN;
	t++; // fun[1] (function length) is filled at the end.
	FILLFUN(t);

	if ( fmpz_cmp_ui(PadicContext->p,WORD_MAX_VALUE) <= 0 ) {
		*t++ = -SNUMBER;
		*t++ = (WORD)fmpz_get_si(PadicContext->p);
	}
	else {
		arg = t + ARGHEAD + 1;
		nnum = GetPadicInteger(PadicContext->p,arg);
		arg += nnum;
		*arg++ = 1;
		for ( i = 1; i < nnum; i++ ) *arg++ = 0;
		*arg++ = 2*nnum+1;
		*t++ = ARGHEAD + 2*nnum + 2;
		*t++ = 0;
		FILLARG(t);
		*t++ = 2*nnum + 2;
		t = arg;
	}

	/*
		Pack valuation v and N:
		compact -SNUMBER when it fits in WORD, otherwise as a two-word
		long integer argument.
	*/
	for ( i = 0; i < 2; i++ ) {
		LONG value = i == 0 ? v : N;
		if ( value >= WORD_MIN_VALUE && value <= WORD_MAX_VALUE ) {
			*t++ = -SNUMBER;
			*t++ = (WORD)value;
		}
		else {
			x = LongAbs(value);
			*t++ = ARGHEAD + 6;
			*t++ = 0;
			FILLARG(t);
			*t++ = 6;
			*t++ = (WORD)(UWORD)x;
			*t++ = (WORD)(UWORD)(x >> BITSINWORD);
			*t++ = 1;
			*t++ = 0;
			*t++ = value < 0 ? -5 : 5;
		}
	}
	if ( fmpz_fits_si(padic_unit(in))
	  && (small = (LONG)fmpz_get_si(padic_unit(in)),
	      small >= WORD_MIN_VALUE && small <= WORD_MAX_VALUE) ) {
		*t++ = -SNUMBER;
		*t++ = (WORD)small;
	}
	else {
		arg = t + ARGHEAD + 1 + PADICLIMBHEAD;
		nnum = GetPadicInteger(padic_unit(in),arg);
		nabs = ABS(nnum);
		t[0] = ARGHEAD + 1 + PADICLIMBHEAD + nabs + 3;
		for ( i = 1; i < ARGHEAD; i++ ) t[i] = 0;
		t[ARGHEAD] = t[0] - ARGHEAD;
		t[ARGHEAD+1] = PADICLIMBS;
		t[ARGHEAD+2] = PADICLIMBHEAD + nabs;
		t[ARGHEAD+3] = nnum;
		t += *t;
		t[-3] = 1;
		t[-2] = 1;
		t[-1] = 3;
	}
	fun[1] = (WORD)(t - fun);
	return(fun[1]);
}
/*
 		#] PackPadic :
 		#[ PadicUnitKnownReduced :

	Certify a positive unit using exact bounds on p^k and divisibility.
	Near powers of two, p^k >= (2^b-k*(2^b-p))*2^(b*(k-1)).
	Uncertain bounds retain FLINT; imported units may reuse GMP's remainder.
*/
static int PadicUnitKnownReduced(const UWORD *limbs, WORD count, LONG v, LONG N, const fmpz *imported)
{
	ULONG p, k, bits, pbits, base, delta, lower, shift, top, rem = 0;
	LONG i, offset;
	int inrange;
	if ( count <= 0 || v >= N || fmpz_cmp_ui(PadicContext->p,WORD_MAX_VALUE) > 0 )
		return(0);
	p = (ULONG)fmpz_get_ui(PadicContext->p);
	k = (ULONG)N-(ULONG)v;
	bits = (ULONG)(count-1)*BITSINWORD+FLINT_BIT_COUNT(limbs[count-1]);
	pbits = FLINT_BIT_COUNT(p)-1;
	inrange = k >= bits || k*pbits >= bits;
	if ( !inrange ) {
		pbits = FLINT_BIT_COUNT(p-1);
		base = (ULONG)1 << pbits;
		delta = base-p;
		if ( delta == 0 || k <= (base-1)/delta ) {
			lower = base-k*delta;
			shift = pbits*(k-1);
			top = shift+FLINT_BIT_COUNT(lower);
			if ( bits < top ) inrange = 1;
			else if ( bits == top ) {
				i = (LONG)(shift/BITSINWORD); offset = (LONG)(shift%BITSINWORD);
				top = (ULONG)limbs[i] >> offset;
				if ( offset && i+1 < count )
					top |= (ULONG)limbs[i+1] << (BITSINWORD-offset);
				inrange = top < lower;
			}
		}
	}
	if ( !inrange ) return(0);
	if ( BITSINWORD == 32 && FLINT_BITS == 64 && GMP_NUMB_BITS == 64 && GMP_NAIL_BITS == 0
	 && imported && count >= 12 ) return(fmpz_fdiv_ui(imported,(ulong)p) != 0);
	for ( i = count-1; i >= 0; i-- ) rem = ((rem << BITSINWORD)+limbs[i]) % p;
	return(rem != 0);
}
/*
 		#] PadicUnitKnownReduced :
 		#[ UnpackedPadicKnownReduced :

	Checks whether the unit imported from a validated padic_ carrier is
	already reduced. Reuse its FORM limbs for the range bound and its
	FLINT integer for the divisibility check when useful. Return 1 only
	when both checks succeed within FLINT's supported exponent range;
	otherwise UnpackPadic must call padic_reduce.
*/
static int UnpackedPadicKnownReduced(const padic_t in, const WORD *arg)
{
	const UWORD *limbs;
	UWORD small;
	WORD count;
	slong N = padic_prec(in), v = padic_val(in);
	if ( N <= v || (ulong)N-(ulong)v
		> (ulong)(FLINT_BITS == 64 ? INT64_MAX : INT32_MAX) ) return(0);
	if ( *arg == -SNUMBER ) {
		if ( arg[1] <= 0 ) return(0);
		small = (UWORD)arg[1]; limbs = &small; count = 1;
	}
	else if ( arg[ARGHEAD] == ABS(arg[*arg-1])+1 ) {
		WORD size = arg[*arg-1];
		if ( size < 0 ) return(0);
		count = (WORD)((size-1)/2);
		limbs = (const UWORD *)(arg+ARGHEAD+1);
		while ( count && limbs[count-1] == 0 ) count--;
	}
	else {
		count = arg[ARGHEAD+PADICLIMBHEAD];
		limbs = (const UWORD *)(arg+ARGHEAD+1+PADICLIMBHEAD);
	}
	return(PadicUnitKnownReduced(limbs,count,v,N,padic_unit(in)));
}
/*
 		#] UnpackedPadicKnownReduced :
 		#[ NormalizePadicUnit :

	Normalize a lone coefficient only after the rational coefficient and any
	other p-adics have been combined. Leave an unchanged compact unit in place.
	Callers must have validated fun with TestPadic.
	Return 0 for unchanged, 1 for zero, or the packed length.
*/
int NormalizePadicUnit(PHEAD WORD *out, WORD *fun)
{
	GETBIDENTITY
	const WORD *arg = fun+FUNHEAD, *varg = fun+FUNHEAD;
	const UWORD *limbs = NULL;
	UWORD small;
	WORD count = 0;
	ULONG value;
	LONG v, N;
	int same = 0;
	NEXTARG(arg); NEXTARG(arg); NEXTARG(arg);
	NEXTARG(varg);
	if ( *varg == -SNUMBER ) v = varg[1];
	else {
		value = ((ULONG)(UWORD)varg[ARGHEAD+2] << BITSINWORD)
			+ (UWORD)varg[ARGHEAD+1];
		v = ULongToLong(varg[ARGHEAD+5] < 0 ? -value : value);
	}
	NEXTARG(varg);
	if ( *varg == -SNUMBER ) N = varg[1];
	else {
		value = ((ULONG)(UWORD)varg[ARGHEAD+2] << BITSINWORD)
			+ (UWORD)varg[ARGHEAD+1];
		N = ULongToLong(varg[ARGHEAD+5] < 0 ? -value : value);
	}
	if ( *arg == -SNUMBER ) {
		small = WordAbs(arg[1]);
		limbs = &small;
		count = small == 0 ? 0 : (arg[1] < 0 ? -1 : 1);
	}
	else if ( arg[ARGHEAD] != ABS(arg[*arg-1])+1 ) {
		count = arg[ARGHEAD+PADICLIMBHEAD];
		limbs = (const UWORD *)(arg+ARGHEAD+1+PADICLIMBHEAD);
	}
	if ( count > 0 && PadicUnitKnownReduced(limbs,count,v,N,NULL) ) return(0);
	UnpackPadic(paux1,fun);
	if ( padic_is_zero(paux1) ) return(1);
	if ( v == padic_val(paux1) && count > 0 ) {
		if ( *arg == -SNUMBER ) same = fmpz_equal_si(padic_unit(paux1),arg[1]);
#if GMP_NUMB_BITS % BITSINWORD == 0
		else if ( (fmpz_bits(padic_unit(paux1))+BITSINWORD-1)/BITSINWORD == (ulong)count ) {
			mpz_t unit;
			LONG i;
			flint_mpz_init_set_readonly(unit,padic_unit(paux1));
			same = 1;
			for ( i = 0; i < count; i++ ) {
				mp_limb_t limb = mpz_getlimbn(unit,(i*BITSINWORD)/GMP_NUMB_BITS);
				if ( limbs[i] != (UWORD)(limb >> ((i*BITSINWORD)%GMP_NUMB_BITS)) ) {
					same = 0; break;
				}
			}
			flint_mpz_clear_readonly(unit);
		}
#endif
	}
	if ( same ) return(0);
	return(PackPadic(out,paux1));
}
/*
 		#] NormalizePadicUnit :
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
		SetPadicInteger(fmpq_numref(result),num,sign*nnum);
	}
	else {
		fmpz_zero(fmpq_numref(result));
	}
	SetPadicInteger(fmpq_denref(result),den,nden);

	fmpq_canonicalise(result);
}
/*
		#] FormRatToFmpq :
 		#[ SetPadicRational :

	Converts a canonical rational to a p-adic at the output precision.
	Use the integer conversion or the small-fraction shortcut when possible.
	Other fractions use the general FLINT conversion.
*/
static void SetPadicRational(padic_t out, const fmpq_t in)
{
	if ( fmpz_is_one(fmpq_denref(in)) )
		padic_set_fmpz(out,fmpq_numref(in),PadicContext);
	else if ( SmallPadicRationalFits(padic_prec(out),in) ) {
		fmpz_set(padic_unit(out),fmpq_numref(in));
		padic_val(out) = 0;
		DivideSmallPadicRational(out,in,1);
	}
	else padic_set_fmpq(out,in,PadicContext);
}
/*
 		#] SetPadicRational :
 		#[ ReduceSmallPadicQuotient :

	Reduces the quotient modulo M = modulus after exact division.
	For a proper fraction and an input unit below M, the quotient is in
	(-M,2M), so one addition or subtraction suffices. Without that bound,
	use the general remainder operation.
*/
static void ReduceSmallPadicQuotient(fmpz_t unit, const fmpz_t modulus, const fmpq_t q, int bounded)
{
	if ( bounded && fmpz_cmpabs(fmpq_numref(q),fmpq_denref(q)) < 0 ) {
		if ( fmpz_sgn(unit) < 0 ) fmpz_add(unit,unit,modulus);
		else if ( fmpz_cmp(unit,modulus) >= 0 ) fmpz_sub(unit,unit,modulus);
	}
	else fmpz_mod(unit,unit,modulus);
}
/*
 		#] ReduceSmallPadicQuotient :
 		#[ SmallPadicRationalFits :

	Checks the precision and fraction bounds for the small-rational shortcut.
*/
static int SmallPadicRationalFits(slong N, const fmpq_t q)
{
	return(N > 0 && !fmpz_is_zero(fmpq_numref(q))
	 && fmpz_cmpabs(fmpq_numref(q),PadicContext->p) < 0
	 && fmpz_cmp_ui(fmpq_denref(q),1) > 0
	 && fmpz_cmp(fmpq_denref(q),PadicContext->p) < 0
	 && fmpz_cmp_ui(fmpq_denref(q),WORD_MAX_VALUE) <= 0);
}
/*
 		#] SmallPadicRationalFits :
 		#[ DivideSmallPadicRational :

	Divides the prepared unit numerator by the small fraction's denominator
	modulo p^(N-v). The caller has checked the fraction and set the valuation.
*/
static void DivideSmallPadicRational(padic_t out, const fmpq_t q, int bounded)
{
	slong N = padic_prec(out), v = padic_val(out);
	fmpz_t modulus;
	ulong d, inverse, remainder, correction;
	int owned;
	d = fmpz_get_ui(fmpq_denref(q));
	owned = _padic_ctx_pow_ui(modulus,(ulong)(N-v),PadicContext);
	inverse = n_invmod(fmpz_fdiv_ui(modulus,d),d);
	remainder = fmpz_fdiv_ui(padic_unit(out),d);
	correction = remainder ? d-n_mulmod2(remainder,inverse,d) : 0;
	fmpz_addmul_ui(padic_unit(out),modulus,correction);
	fmpz_divexact_ui(padic_unit(out),padic_unit(out),d);
	ReduceSmallPadicQuotient(padic_unit(out),modulus,q,bounded);
	if ( fmpz_is_zero(padic_unit(out)) ) padic_val(out) = 0;
	if ( owned ) fmpz_clear(modulus);
}
/*
 		#] DivideSmallPadicRational :
 		#[ MultiplyNegativePadicFraction :

	Multiplies a reduced input u*p^v, v < 0, by a small fraction a/d.
	Preserve the rational converted at N: c = (a+k*p^N)/d. Only u*k modulo
	p^-v contributes to u*c modulo p^(N-v). Correct the shortened numerator
	before exact division rather than converting a/d directly at N-v.

	Uses thread-local auxiliary integers as scratch, distinct from the
	input and output units. Both powers must already be cached.
	Return 1 when handled, or 0 to retain the general FLINT calculation.
*/
static int MultiplyNegativePadicFraction(PHEAD padic_t out, const padic_t in, const fmpq_t q)
{
	slong N = padic_prec(out), v = padic_val(in);
	fmpz *modulus = pauxprime, *low = padic_unit(paux2);
	fmpz_t base, lowmod;
	ulong d, inverse, remainder, correction;
	if ( v < -N || (ulong)N-(ulong)v > (ulong)(FLINT_BITS == 64 ? INT64_MAX : INT32_MAX) ) return(0);
	if ( _padic_ctx_pow_ui(base,(ulong)N,PadicContext) ) { fmpz_clear(base); return(0); }
	if ( _padic_ctx_pow_ui(lowmod,(ulong)-v,PadicContext) ) { fmpz_clear(lowmod); return(0); }
	d = fmpz_get_ui(fmpq_denref(q));
	inverse = n_invmod(fmpz_fdiv_ui(base,d),d);
	remainder = fmpz_fdiv_ui(fmpq_numref(q),d);
	correction = remainder ? d-n_mulmod2(remainder,inverse,d) : 0;
	fmpz_mul(modulus,base,lowmod);
	fmpz_mod(low,padic_unit(in),lowmod);
	fmpz_mul_ui(low,low,correction);
	fmpz_mod(low,low,lowmod);
	fmpz_mul(low,low,base);
	fmpz_mul(padic_unit(out),padic_unit(in),fmpq_numref(q));
	fmpz_add(padic_unit(out),padic_unit(out),low);
	inverse = n_invmod(fmpz_fdiv_ui(modulus,d),d);
	remainder = fmpz_fdiv_ui(padic_unit(out),d);
	correction = remainder ? d-n_mulmod2(remainder,inverse,d) : 0;
	fmpz_addmul_ui(padic_unit(out),modulus,correction);
	fmpz_divexact_ui(padic_unit(out),padic_unit(out),d);
	ReduceSmallPadicQuotient(padic_unit(out),modulus,q,padic_prec(in) <= N);
	padic_val(out) = fmpz_is_zero(padic_unit(out)) ? 0 : v;
	return(1);
}
/*
 		#] MultiplyNegativePadicFraction :
 		#[ CachedPadicModulus :

	Returns the modulus p^(N-v) from the existing context cache, or from
	the product of two cached powers when v is negative. Return NULL when
	the required powers or exponent range are unavailable.

	The initialized scratch integer must be distinct from the arithmetic
	operands. The returned pointer is borrowed and must not be cleared.
*/
static const fmpz *CachedPadicModulus(fmpz_t scratch, slong N, slong v)
{
	ulong exponent;
	if ( N <= v ) return(NULL);
	exponent = (ulong)N-(ulong)v;
	if ( exponent > (ulong)(FLINT_BITS == 64 ? INT64_MAX : INT32_MAX) ) return(NULL);
	if ( PadicContext->min <= (slong)exponent && (slong)exponent < PadicContext->max )
		return(PadicContext->pow+((slong)exponent-PadicContext->min));
	if ( N <= 0 || v >= 0 || v < -N
	 || N < PadicContext->min || N >= PadicContext->max
	 || -v < PadicContext->min || -v >= PadicContext->max ) return(NULL);
	fmpz_mul(scratch,PadicContext->pow+(N-PadicContext->min),
		PadicContext->pow+(-v-PadicContext->min));
	return(scratch);
}
/*
 		#] CachedPadicModulus :
 		#[ MultiplyReducedPadics :

	Multiplies two reduced p-adics at the output precision. Reduce the unit
	product with a cached modulus when the valuation sum is representable.
	Other cases use FLINT. The rational operand, if any, has already been
	converted at N, including when the other operand has negative valuation.
	The initialized scratch integer must be distinct from all operand units.
*/
static void MultiplyReducedPadics(padic_t out, const padic_t left, const padic_t right, fmpz_t scratch)
{
	slong v1 = padic_val(left), v2 = padic_val(right), v;
	slong maximum = FLINT_BITS == 64 ? INT64_MAX : INT32_MAX;
	slong minimum = FLINT_BITS == 64 ? INT64_MIN : INT32_MIN;
	const fmpz *modulus;
	if ( padic_is_zero(left) || padic_is_zero(right) ) { padic_zero(out); return; }
	if ( (v2 > 0 && v1 > maximum-v2) || (v2 < 0 && v1 < minimum-v2) ) goto fallback;
	v = v1+v2;
	if ( v >= padic_prec(out) ) { padic_zero(out); return; }
	modulus = CachedPadicModulus(scratch,padic_prec(out),v);
	if ( !modulus ) goto fallback;
	fmpz_mul(padic_unit(out),padic_unit(left),padic_unit(right));
	fmpz_mod(padic_unit(out),padic_unit(out),modulus);
	padic_val(out) = fmpz_is_zero(padic_unit(out)) ? 0 : v;
	return;
fallback:
	padic_mul(out,left,right,PadicContext);
}
/*
 		#] MultiplyReducedPadics :
 		#[ AddReducedPadics :

	Adds two reduced p-adics at the output precision, using the cached
	modulus when precision and valuation match. Other cases use FLINT.
	Uses the thread-local auxiliary integer as scratch for the modulus.
*/
static void AddReducedPadics(PHEAD padic_t out, const padic_t in1, const padic_t in2)
{
	slong N = padic_prec(out), v = padic_val(in1);
	const fmpz *modulus;
	/* The unit shortcut requires matching precision and valuation. */
	if ( v != padic_val(in2) || N != padic_prec(in1) || N != padic_prec(in2) ) goto fallback;
	modulus = CachedPadicModulus(pauxprime,N,v);
	if ( !modulus ) goto fallback;
	/* Each unit is below the modulus, so one subtraction suffices. */
	fmpz_add(padic_unit(out),padic_unit(in1),padic_unit(in2));
	if ( fmpz_cmp(padic_unit(out),modulus) >= 0 )
		fmpz_sub(padic_unit(out),padic_unit(out),modulus);
	padic_val(out) = v;
	/* Remove prime factors from the unit and update the valuation. */
	_padic_canonicalise(out,PadicContext);
	return;
fallback:
	padic_add(out,in1,in2,PadicContext);
}
/*
 		#] AddReducedPadics :
 		#[ AddRatToPadic :

	Adds a FORM rational coefficient to a padic_ function in infun.
	The rational is converted at the active output precision.

	Return value:
	- 0  on success, with a non-zero sum packed into outfun,
	- 1  if the sum is p-adic zero,
	- -1 on runtime/validation failure.
*/
static int AddRatToPadic(PHEAD WORD *outfun, WORD *infun, UWORD *formrat, WORD nrat)
{
	if ( !PadicActive ) return(-1);
	UnpackPadic(paux1,infun);
	FormRatToFmpq(pauxq1,formrat,nrat);
	padic_prec(paux2) = PadicPrecision;
	SetPadicRational(paux2,pauxq1);
	AddReducedPadics(BHEAD paux3,paux1,paux2);
	PackPadic(outfun,paux3);
	if ( padic_is_zero(paux3) ) return(1);
	return(0);
}
/*
 		#] AddRatToPadic :
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
	slong v;
	int handled = 0;
	if ( !PadicActive ) return(-1);
	UnpackPadic(paux1,infun);
	FormRatToFmpq(pauxq1,formrat,nrat);
	v = padic_val(paux1);
	if ( SmallPadicRationalFits(PadicPrecision,pauxq1) ) {
		/* Preserve rational conversion at the active precision. */
		if ( v < 0 ) handled = MultiplyNegativePadicFraction(BHEAD paux3,paux1,pauxq1);
		else {
			if ( v >= PadicPrecision ) padic_zero(paux3);
			else {
				fmpz_mul(padic_unit(paux3),padic_unit(paux1),fmpq_numref(pauxq1));
				padic_val(paux3) = v;
				DivideSmallPadicRational(paux3,pauxq1,padic_prec(paux1) <= PadicPrecision);
			}
			handled = 1;
		}
	}
	if ( !handled ) {
		padic_prec(paux2) = PadicPrecision;
		SetPadicRational(paux2,pauxq1);
		MultiplyReducedPadics(paux3,paux1,paux2,pauxprime);
	}
	PackPadic(outfun,paux3);
	if ( padic_is_zero(paux3) ) return(1);
	return(0);
}
/*
 		#] MulRatToPadic :
 		#[ AddPadics :

	Adds two padic_ functions (in1 + in2) and stores the sum in outfun.

	Return value:
	- 0  on success, with a non-zero sum packed into outfun,
	- 1  if the sum is p-adic zero,
	- -1 on runtime/validation failure.
*/
static int AddPadics(PHEAD WORD *outfun, WORD *in1, WORD *in2)
{
	if ( !PadicActive ) return(-1);
	UnpackPadic(paux1,in1);
	UnpackPadic(paux2,in2);
	AddReducedPadics(BHEAD paux3,paux1,paux2);
	PackPadic(outfun,paux3);
	if ( padic_is_zero(paux3) ) return(1);
	return(0);
}
/*
 		#] AddPadics :
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
	UnpackPadic(paux1,fun1);
	UnpackPadic(paux2,fun2);
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
	UnpackPadic(paux1,fun1);
	UnpackPadic(paux2,fun2);
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
	UnpackPadic(paux1,fun);
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
	    id padic(p?,v?,N?,u?) = makerational_(u,p^(N-v))*p^v;

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
	CheckPadicPrime(fun);

	// Skip the checked prime, then read v, N, u.
	arg = fun + FUNHEAD;
	NEXTARG(arg);
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
		u[0] = WordAbs(arg[1]);
	}
	else if ( arg[ARGHEAD] == ABS(arg[*arg-1])+1 ) {
		nu = (WORD)((ABS(arg[*arg-1])-1)/2);
		while ( nu && arg[ARGHEAD+nu] == 0 ) nu--;
		if ( arg[*arg-1] < 0 ) nu = -nu;
		for ( i = 0; i < ABS(nu); i++ ) u[i] = (UWORD)arg[ARGHEAD+1+i];
	}
	else {
		nu = arg[ARGHEAD+PADICLIMBHEAD];
		for ( i = 0; i < ABS(nu); i++ ) u[i] = (UWORD)arg[ARGHEAD+1+PADICLIMBHEAD+i];
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
	if ( TestPadic(fun) == 0 ) return(0);
	UnpackPadic(paux1,fun);

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
				CheckPadicPrime(t);
				return(Generator(BHEAD term,level));
			}
			t += t[1]; /* advance to the next function in the term */
		}
	}

	FormRatToFmpq(pauxq1,(UWORD *)tstop,ncoef);
	padic_prec(paux1) = PadicPrecision;
	SetPadicRational(paux1,pauxq1);
	if ( padic_is_zero(paux1) ) return(0);
	// Overwrite the old rational coefficient of the term by padic_(p,v,N,u)
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
	Each syntactically valid padic_(p,v,N,u) at the current execution level is
	converted to f(p,v,N,u), independently of the active context.
*/
int FromPadic(PHEAD WORD *term, WORD level, WORD target)
{
	GETBIDENTITY
	WORD *t, *first, *stop, *newterm, *out, *oldworkpointer = AT.WorkPointer;
	int len, retval;

	stop = term+*term;
	stop -= ABS(stop[-1]);
	for ( t = term+1; t < stop; t += t[1] ) {
		if ( *t == PADICFUN && TestPadic(t) ) break;
	}
	if ( t == stop ) return(Generator(BHEAD term,level));
	first = t;
	if ( AT.WorkPointer < term+*term ) AT.WorkPointer = term+*term;
	newterm = AT.WorkPointer; out = newterm+1;
	t = term+1; len = first-t;
	NCOPY(out,t,len);
	while ( t < stop ) {
		if ( t == first || (*t == PADICFUN && TestPadic(t)) ) {
			WORD *arg = t+FUNHEAD, *fun = out;
			NEXTARG(arg); NEXTARG(arg); NEXTARG(arg);
			len = arg-t; NCOPY(out,t,len);
			if ( *t == -SNUMBER ) {
				len = 2; NCOPY(out,t,len);
			}
			else if ( t[ARGHEAD] == ABS(t[*t-1])+1 ) {
				len = *t; NCOPY(out,t,len);
			}
			else {
				len = ExpandPadicArgument(out,t);
				out += len;
				NEXTARG(t);
			}
			fun[1] = (WORD)(out-fun);
			*fun = target;
		}
		else {
			len = t[1]; NCOPY(out,t,len);
		}
	}
	len = term+*term-stop; NCOPY(out,stop,len);
	*newterm = (WORD)(out-newterm);
	AT.WorkPointer = out;
	retval = Generator(BHEAD newterm,level);
	AT.WorkPointer = oldworkpointer;
	return(retval);
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
	int padicret;

	if ( !PadicActive ) return(0);

	s1 = *ps1;
	s2 = *ps2;
	coef1 = s1 + *s1; size1 = coef1[-1]; coef1 -= ABS(size1);
	coef2 = s2 + *s2; size2 = coef2[-1]; coef2 -= ABS(size2);

	/* Compare1 validated the final object as the p-adic coefficient. */
	if ( AT.SortPadicMode == 3 ) {
		/* Both coefficients are normalized padic_ records. */
		fun1 = s1+1; while ( fun1+fun1[1] < coef1 ) fun1 += fun1[1];
		fun2 = s2+1; while ( fun2+fun2[1] < coef2 ) fun2 += fun2[1];
	}
	else if ( AT.SortPadicMode == 1 ) {
		/* First coefficient is padic_, second is rational. */
		fun1 = s1+1; while ( fun1+fun1[1] < coef1 ) fun1 += fun1[1];
		fun2 = coef2;
	}
	else if ( AT.SortPadicMode == 2 ) {
		/* Second coefficient is padic_, first is rational. */
		fun2 = s2+1; while ( fun2+fun2[1] < coef2 ) fun2 += fun2[1];
		fun1 = coef1;
	}
	else {
		MLOCK(ErrorMessageLock);
		MesPrint("Illegal value %d for AT.SortPadicMode in AddWithPadic.",AT.SortPadicMode);
		MUNLOCK(ErrorMessageLock);
		Terminate(-1);
		return(0);
	}

	fun3 = TermMalloc("AddWithPadic");
	if ( AT.SortPadicMode == 3 ) padicret = AddPadics(BHEAD fun3,fun1,fun2);
	else if ( AT.SortPadicMode == 1 )
		padicret = AddRatToPadic(BHEAD fun3,fun1,(UWORD *)coef2,size2);
	else padicret = AddRatToPadic(BHEAD fun3,fun2,(UWORD *)coef1,size1);
	if ( padicret != 0 ) {
		TermFree(fun3,"AddWithPadic");
		/* Terms cancel. A failed conversion leaves the inputs intact. */
		if ( padicret > 0 ) *ps1 = *ps2 = 0;
		AT.SortPadicMode = 0;
		return(0);
	}

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
	int retval = 0, padicret;

	if ( !PadicActive ) return(0);

	coef1 = term1+*term1; size1 = coef1[-1]; coef1 -= ABS(size1);
	coef2 = term2+*term2; size2 = coef2[-1]; coef2 -= ABS(size2);
	/* Compare1 validated the final object as the p-adic coefficient. */
	if ( AT.SortPadicMode == 3 ) {
		fun1 = term1+1; while ( fun1+fun1[1] < coef1 ) fun1 += fun1[1];
		fun2 = term2+1; while ( fun2+fun2[1] < coef2 ) fun2 += fun2[1];
	}
	else if ( AT.SortPadicMode == 1 ) {
		fun1 = term1+1; while ( fun1+fun1[1] < coef1 ) fun1 += fun1[1];
		fun2 = coef2;
	}
	else if ( AT.SortPadicMode == 2 ) {
		fun2 = term2+1; while ( fun2+fun2[1] < coef2 ) fun2 += fun2[1];
		fun1 = coef1;
	}
	else {
		MLOCK(ErrorMessageLock);
		MesPrint("Illegal value %d for AT.SortPadicMode in MergeWithPadic.",AT.SortPadicMode);
		MUNLOCK(ErrorMessageLock);
		Terminate(-1);
		return(0);
	}

	fun3 = TermMalloc("MergeWithPadic");
	if ( AT.SortPadicMode == 3 ) padicret = AddPadics(BHEAD fun3,fun1,fun2);
	else if ( AT.SortPadicMode == 1 )
		padicret = AddRatToPadic(BHEAD fun3,fun1,(UWORD *)coef2,size2);
	else padicret = AddRatToPadic(BHEAD fun3,fun2,(UWORD *)coef1,size1);
	if ( padicret != 0 ) {
		TermFree(fun3,"MergeWithPadic");
		AT.SortPadicMode = 0;
		return(0);
	}
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

/*
 		#[ ConvertPadicLimbs32 :
*/
int ConvertPadicLimbs32(int32_t *out, LONG capacity, const int32_t *in,
	int sourcebits, int targetbits)
{
	LONG n, count, size, i;
	uint32_t high;
	if ( (sourcebits != 16 && sourcebits != 32)
	 || (targetbits != 16 && targetbits != 32) || in[0] != PADICLIMBS
	 || in[2] == INT32_MIN || in[2] == 0 ) return(-1);
	n = in[2] < 0 ? -(LONG)in[2] : in[2];
	if ( in[1] < PADICLIMBHEAD+1 || n != (LONG)in[1]-PADICLIMBHEAD
	 || in[1] > (sourcebits == 16 ? INT16_MAX : INT32_MAX) ) return(-1);
	if ( sourcebits > targetbits && n > (INT16_MAX-PADICLIMBHEAD+1)/2 )
		return(-2);
	high = (uint32_t)in[PADICLIMBHEAD+n-1];
	if ( sourcebits == 16 ) high &= 0xffffU;
	if ( high == 0 ) return(-1);
	count = n;
	if ( sourcebits < targetbits ) count = (n+1)/2;
	else if ( sourcebits > targetbits ) count = 2*n-(high <= 0xffffU);
	size = PADICLIMBHEAD+count;
	if ( size > capacity || size > (targetbits == 16 ? INT16_MAX : INT32_MAX) )
		return(-2);
	if ( out ) {
		out[0] = PADICLIMBS; out[1] = (int32_t)size;
		out[2] = (int32_t)(in[2] < 0 ? -count : count);
		for ( i = 0; i < count; i++ ) {
			uint32_t limb;
			if ( sourcebits < targetbits ) {
				limb = (uint32_t)in[PADICLIMBHEAD+2*i] & 0xffffU;
				if ( 2*i+1 < n ) limb |= ((uint32_t)in[PADICLIMBHEAD+2*i+1] & 0xffffU) << 16;
			}
			else if ( sourcebits > targetbits )
				limb = ((uint32_t)in[PADICLIMBHEAD+i/2] >> (16*(i%2))) & 0xffffU;
			else limb = (uint32_t)in[PADICLIMBHEAD+i];
			out[PADICLIMBHEAD+i] = (int32_t)limb;
		}
	}
	return((int)size);
}
/*
 		#] ConvertPadicLimbs32 :
*/
