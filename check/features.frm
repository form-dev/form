#ifndef `TEST'
  #message Use -D TEST=XXX
  #terminate
#else
  #include `NAME_' # `TEST'
#endif
.end

*--#[ divmod_1 :
* Test div_, rem_ functions for monic univariate polynomials
#-
S x1;

L F1 = (x1+1)^2;
L F2 = (x1+1);
.sort
L F3 = div_(F1,F2);
L F4 = rem_(F1,F2);

P;
.end
assert succeeded?
assert result("F3")  =~ expr("1 + x1")
assert result("F4")  =~ expr("0")
*--#] divmod_1 :
*--#[ divmod_2 :
* Test div_, rem_ functions for non-monic univariate polynomials with remainder
#-
S x1;

L F1 = (2*x1+1)^2+3*x1+5;
L F2 = (2*x1+1);
.sort
L F3 = div_(F1,F2);
L F4 = rem_(F1,F2);

P;
.end
assert succeeded?
assert result("F3")  =~ expr("5/2 + 2*x1")
assert result("F4")  =~ expr("7/2")
*--#] divmod_2 :
*--#[ divmod_3 :
* Test div_, rem_ functions for non-monic multivariate polynomials without remainder
#-
S x1,x2;

L F1 = (2*x1*x2+1*x1)^2;
L F2 = (2*x1*x2+1*x1);
.sort
L F3 = div_(F1,F2);
L F4 = rem_(F1,F2);

P;
.end
assert succeeded?
assert result("F3")  =~ expr("x1 + 2*x1*x2")
assert result("F4")  =~ expr("0")
*--#] divmod_3 :
*--#[ divmod_4 :
* Test div_, rem_ functions for non-monic multivariate polynomials with remainder
#-
S x1,x2,x3;

L F1 = -7*x1*x2^9*x3+5*x1*x2^10*x3-3*x1^2*x2^3*x3^2+35*x1^2*x2^4*x3^4
-42*x1^2*x2^5*x3^2-25*x1^2*x2^5*x3^4+30*x1^2*x2^6*x3^2-8*x1^4*x2^5*x3^3+40*x1^5*x3^6
-48*x1^5*x2*x3^4+3*x1^6*x2^2*x3;
L F2 = x1*x2^5-5*x1^2*x3^3+6*x1^2*x2*x3;
L F3 = div_(F1,F2);
L F4 = rem_(F1,F2);

P;
.end
assert succeeded?
assert result("F3")  =~ expr("
      - 25/72*x3^5 + 12969970703125/2742118830047232*x3^30 - 5/12*x2*x3^3 +
      2593994140625/457019805007872*x2*x3^28 - 1/2*x2^2*x3 + 518798828125/
      76169967501312*x2^2*x3^26 + 103759765625/12694994583552*x2^3*x3^24 - 7*
      x2^4*x3 + 20751953125/2115832430592*x2^4*x3^22 + 5*x2^5*x3 + 29052734375/
      2821109907456*x2^5*x3^20 + 830078125/78364164096*x2^6*x3^18 + 830078125/
      78364164096*x2^7*x3^16 + 33203125/3265173504*x2^8*x3^14 + 6640625/
      725594112*x2^9*x3^12 + 5703125/725594112*x2^10*x3^10 + 765625/120932352*
      x2^11*x3^8 + 15625/3359232*x2^12*x3^6 + 625/209952*x2^13*x3^4 + 875/
      559872*x2^14*x3^2 + 25/46656*x2^15 - 20751953125/2821109907456*x1*x3^23
       - 4150390625/470184984576*x1*x2*x3^21 - 830078125/78364164096*x1*x2^2*
      x3^19 - 166015625/13060694016*x1*x2^3*x3^17 - 33203125/2176782336*x1*
      x2^4*x3^15 - 11328125/725594112*x1*x2^5*x3^13 - 78125/5038848*x1*x2^6*
      x3^11 - 296875/20155392*x1*x2^7*x3^9 - 21875/1679616*x1*x2^8*x3^7 - 625/
      62208*x1*x2^9*x3^5 - 625/93312*x1*x2^10*x3^3 - 25/7776*x1*x2^11*x3 +
      9765625/725594112*x1^2*x3^16 + 1953125/120932352*x1^2*x2*x3^14 + 390625/
      20155392*x1^2*x2^2*x3^12 + 78125/3359232*x1^2*x2^3*x3^10 + 15625/559872*
      x1^2*x2^4*x3^8 + 625/23328*x1^2*x2^5*x3^6 + 125/5184*x1^2*x2^6*x3^4 + 25/
      1296*x1^2*x2^7*x3^2 + 5/432*x1^2*x2^8 - 8*x1^3*x3^3 - 3125/93312*x1^3*
      x3^9 - 625/15552*x1^3*x2*x3^7 - 125/2592*x1^3*x2^2*x3^5 - 25/432*x1^3*
      x2^3*x3^3 - 5/72*x1^3*x2^4*x3 + 5/12*x1^4*x3^2 + 1/2*x1^4*x2
")
assert result("F4")  =~ expr("
      25/72*x1*x2^5*x3^5 - 12969970703125/2742118830047232*x1*x2^5*x3^30 + 5/
      12*x1*x2^6*x3^3 - 2593994140625/457019805007872*x1*x2^6*x3^28 + 1/2*x1*
      x2^7*x3 - 518798828125/76169967501312*x1*x2^7*x3^26 - 103759765625/
      12694994583552*x1*x2^8*x3^24 - 20751953125/2115832430592*x1*x2^9*x3^22
       - 29052734375/2821109907456*x1*x2^10*x3^20 - 830078125/78364164096*x1*
      x2^11*x3^18 - 830078125/78364164096*x1*x2^12*x3^16 - 33203125/3265173504
      *x1*x2^13*x3^14 - 6640625/725594112*x1*x2^14*x3^12 - 5703125/725594112*
      x1*x2^15*x3^10 - 765625/120932352*x1*x2^16*x3^8 - 15625/3359232*x1*x2^17
      *x3^6 - 625/209952*x1*x2^18*x3^4 - 875/559872*x1*x2^19*x3^2 - 25/46656*
      x1*x2^20 - 125/72*x1^2*x3^8 + 64849853515625/2742118830047232*x1^2*x3^33
       - 103759765625/2821109907456*x1^3*x3^26 - 5/432*x1^3*x2^13 + 48828125/
      725594112*x1^4*x3^19 - 15625/93312*x1^5*x3^12 - 1/2*x1^5*x2^6 + 25/12*
      x1^6*x3^5
")
*--#] divmod_4 :
*--#[ moebius_1 :
S i,x;
L F = sum_(i,1,200,moebius_(i)*x^i);
P;
.end:result;
assert succeeded?
# Sum[MoebiusMu[i] x^i, {i, 1, 200}] // InputForm
assert result("F") =~ expr("
 x - x^2 - x^3 - x^5 + x^6 - x^7 + x^10 - x^11 - x^13 + x^14 + x^15 - x^17 -
 x^19 + x^21 + x^22 - x^23 + x^26 - x^29 - x^30 - x^31 + x^33 + x^34 + x^35 -
 x^37 + x^38 + x^39 - x^41 - x^42 - x^43 + x^46 - x^47 + x^51 - x^53 + x^55 +
 x^57 + x^58 - x^59 - x^61 + x^62 + x^65 - x^66 - x^67 + x^69 - x^70 - x^71 -
 x^73 + x^74 + x^77 - x^78 - x^79 + x^82 - x^83 + x^85 + x^86 + x^87 - x^89 +
 x^91 + x^93 + x^94 + x^95 - x^97 - x^101 - x^102 - x^103 - x^105 + x^106 -
 x^107 - x^109 - x^110 + x^111 - x^113 - x^114 + x^115 + x^118 + x^119 +
 x^122 + x^123 - x^127 + x^129 - x^130 - x^131 + x^133 + x^134 - x^137 -
 x^138 - x^139 + x^141 + x^142 + x^143 + x^145 + x^146 - x^149 - x^151 -
 x^154 + x^155 - x^157 + x^158 + x^159 + x^161 - x^163 - x^165 + x^166 -
 x^167 - x^170 - x^173 - x^174 + x^177 + x^178 - x^179 - x^181 - x^182 +
 x^183 + x^185 - x^186 + x^187 - x^190 - x^191 - x^193 + x^194 - x^195 -
 x^197 - x^199
")
*--#] moebius_1 :
*--#[ moebius_2 :
S x,x1,x2;
CF f1,f2;
L F = 1;
multiply <f1(1)*x1^1>+...+<f1(10)*x1^10>;
multiply <f2(1)*x2^1>+...+<f2(10)*x2^10>;
id x1 = x;
id x2 = x^20;
.sort
S n;
id f1(n?) = moebius_(10000+n);
.sort
id f2(n?) = moebius_(20000+n);
P;
.end:result;
assert succeeded?
# Sum[MoebiusMu[10000 + i] MoebiusMu[20000 + j] x^(i + 20 * j), {i, 1, 10}, {j, 1, 10}] // InputForm
assert result("F") =~ expr("
-x^21 + x^22 - x^23 - x^25 - x^26 + x^27 + x^29 + x^30 - x^41 + x^42 - x^43 -
 x^45 - x^46 + x^47 + x^49 + x^50 + x^61 - x^62 + x^63 + x^65 + x^66 - x^67 -
 x^69 - x^70 + x^101 - x^102 + x^103 + x^105 + x^106 - x^107 - x^109 - x^110 -
 x^121 + x^122 - x^123 - x^125 - x^126 + x^127 + x^129 + x^130 - x^181 +
 x^182 - x^183 - x^185 - x^186 + x^187 + x^189 + x^190 - x^201 + x^202 -
 x^203 - x^205 - x^206 + x^207 + x^209 + x^210
")
*--#] moebius_2 :
*--#[ moebius_3 :
* corner cases, see #430
#do i=1,9
  L F`i' = moebius_(2^15-`i');
#enddo
#do i=1,9
  L G`i' = moebius_(2^31-`i');
#enddo
P;
.end
#time_dilation 4.0
# memory usage is so intense
#pend_if serial? && total_memory < 8_000_000_000
#pend_if threaded? && total_memory < 20_000_000_000
#pend_if mpi? && total_memory < 20_000_000_000
# too heavy on GitHub (often fails)
#pend_if github? && valgrind?
assert succeeded?
if wordsize >= 2
  assert result("F1") =~ expr("-1")
  assert result("F2") =~ expr("1")
  assert result("F3") =~ expr("1")
  assert result("F4") =~ expr("0")
  assert result("F5") =~ expr("-1")
  assert result("F6") =~ expr("1")
  assert result("F7") =~ expr("0")
  assert result("F8") =~ expr("0")
  assert result("F9") =~ expr("-1")
end
if wordsize >= 4
  assert result("G1") =~ expr("-1")
  assert result("G2") =~ expr("0")
  assert result("G3") =~ expr("-1")
  assert result("G4") =~ expr("0")
  assert result("G5") =~ expr("1")
  assert result("G6") =~ expr("-1")
  assert result("G7") =~ expr("1")
  assert result("G8") =~ expr("0")
  assert result("G9") =~ expr("-1")
end
*--#] moebius_3 :
*--#[ partitions_ :
* Test partitions function
#-
V p1,p2,p3,p4,p5,p6;
CF f1,f2,f3;

L F1 = partitions_(3,f1,2,f1,2,f1,2,p1,p2,p3,p4,p5,p6) - dd_(p1,p2,p3,p4,p5,p6);
L F2 = partitions_(0,f1,2,p1,p2,p3,p4,p5,p6) - dd_(p1,p2,p3,p4,p5,p6);
L F3 = partitions_(4,f1,2,f1,2,f2,1,f3,1,p1,p1,p1,p1,p1,p1) - 90*f1(p1,p1)^2*f2(p1)*f3(p1);
L F4 = partitions_(2,f1,2,f2,0,p1,p2,p3,p4,p5,p6) - distrib_(1,2,f1,f2,p1,p2,p3,p4,p5,p6);
id p1?.p2? = f1(p1,p2); * for dd_

P;
.end
assert succeeded?
assert result("F1")  =~ expr("0")
assert result("F2")  =~ expr("0")
assert result("F3")  =~ expr("0")
assert result("F4")  =~ expr("0")
*--#] partitions_ :
*--#[ AppendPath_unix :
#include foo/foo1.h
* foo/bar/p1.prc
#call p1
P;
.end
#:path foo:bar
#include foo1.h
* foo/bar/p2.prc
#call p2
P;
.end
#:path foo:bar
#include foo2.h
* bar/p1.prc
#call p1
P;
.end
#require unix?
#prepare write "foo/foo1.h", "#prependpath bar\n"
#prepare write "foo/foo2.h", "#appendpath bar\n"
#prepare write "foo/bar/p1.prc", "#procedure p1()\nL F=1234;\n#endprocedure\n"
#prepare write "foo/bar/p2.prc", "#procedure p2()\nL G=5678;\n#endprocedure\n"
#prepare write "bar/p1.prc", "#procedure p1()\nL H=9012;\n#endprocedure\n"
assert succeeded?
assert result("F") =~ expr("1234")
assert result("G") =~ expr("5678")
assert result("H") =~ expr("9012")
*--#] AppendPath_unix :
*--#[ AppendPath_windows :
#include foo\foo1.h
* foo/bar/p1.prc
#call p1
P;
.end
#:path foo;bar
#include foo1.h
* foo/bar/p2.prc
#call p2
P;
.end
#:path foo;bar
#include foo2.h
* bar/p1.prc
#call p1
P;
.end
#require windows?
#prepare write "foo/foo1.h", "#prependpath bar\n"
#prepare write "foo/foo2.h", "#appendpath bar\n"
#prepare write "foo/bar/p1.prc", "#procedure p1()\nL F=1234;\n#endprocedure\n"
#prepare write "foo/bar/p2.prc", "#procedure p2()\nL G=5678;\n#endprocedure\n"
#prepare write "bar/p1.prc", "#procedure p1()\nL H=9012;\n#endprocedure\n"
assert succeeded?
assert result("F") =~ expr("1234")
assert result("G") =~ expr("5678")
assert result("H") =~ expr("9012")
*--#] AppendPath_windows :
*--#[ TimeoutAfter_1 :
#procedure problematicprocedure
* Do nothing.
#endprocedure

#timeoutafter 1000
#call problematicprocedure
#timeoutafter 0
.end
#require unix?
assert succeeded?
*--#] TimeoutAfter_1 :
*--#[ TimeoutAfter_2 :
#procedure problematicprocedure
* Infinite loop.
  #do i=1,1
    #redefine i "0"
  #enddo
#endprocedure

#timeoutafter 1
#call problematicprocedure
#timeoutafter 0
.end
#require unix?
# Sometimes, FORM can terminate without printing the error message, so don't
# assert anything. We only test whether this hits the test suite timeout limit,
# or not. TODO in principle this can be considered to be a bug, to be looked at
# in the future.
# For parform, there is no attempt to ensure the master process recieves SIGALRM
# and not the workers.
#pend_if mpi?
*--#] TimeoutAfter_2 :
*--#[ dedup :
* Test deduplication
#-
Auto S n;
Auto V p;
CF f1,f2,f3,f,g;
T t1,t2,t3;

L F1 =
#do i = 1,20
  +ranperm_(f,<p1,p1>,...,<p50,p50>)
#enddo
;

L F2 = f1(1,2,3,p,1,1,2,2,p);
L F3 = f2(1,2,3,p,1,1,2,2,p);
L F4 = f3(1,2,3,p,1,1,2,2,p);
L F5 = t1(1,2,3,p,1,1,2,2,p);
L F6 = t2(1,2,3,p,1,1,2,2,p);
L F7 = t3(1,2,3,p,1,1,2,2,p);
L F8 = f1(1,2,1,100000000,n^4,100,n^4,n^5,-10000,p1.p2,p6,p1.p2);

id f(?a) = f(?a)*g(?a);
transform f,dedup(1,last);
repeat id g(?a,p?,?b,p?,?c) = g(?a,p,?b,?c);
id f(?a)*g(?a) = 0;

* Test functions
transform f1,dedup(1,last);
transform f2,dedup(3,last);
transform f3,dedup(1,5);

* Test tensors
transform t1,dedup(1,last);
transform t2,dedup(3,last);
transform t3,dedup(1,5);

P;
.end
assert succeeded?
assert result("F1")  =~ expr("0")
assert result("F2")  =~ expr("f1(1,2,3,p)")
assert result("F3")  =~ expr("f2(1,2,3,p,1,2)")
assert result("F4")  =~ expr("f3(1,2,3,p,1,2,2,p)")
assert result("F5")  =~ expr("t1(1,2,3,p)")
assert result("F6")  =~ expr("t2(1,2,3,p,1,2)")
assert result("F7")  =~ expr("t3(1,2,3,p,1,2,2,p)")
assert result("F8")  =~ expr("f1(1,2,100000000,n^4,100,n^5,-10000,p1.p2,p6)")
*--#] dedup :
*--#[ CoToTensor :
V p1,p2,q1,q2,nosquare;
Set pp:p1,p2;
CF f;
T Q1,functions;
#$q1 = q1;
#$Q1 = Q1;
L F0 = f(q1,q2) * p1.q1 * p2.q1 * q1.q1 * q1.q2;
#do i={1,...,7,11,...,17,51,61,71,72}
  L F`i' = F0;
#enddo
inexpression F1;
  totensor q1,Q1;
endinexpression;
inexpression F2;
  totensor nosquare,q1,Q1;
endinexpression;
inexpression F3;
  totensor functions,q1,Q1;
endinexpression;
inexpression F4;
  totensor nosquare,functions,q1,Q1;
endinexpression;
inexpression F5;
  totensor !pp,q1,Q1;
endinexpression;
inexpression F6;
  totensor !{p1},q1,Q1;
endinexpression;
inexpression F7;
  totensor nosquare,functions,!pp,q1,Q1;
endinexpression;

inexpression F11;
  totensor $q1,Q1;
endinexpression;
inexpression F12;
  totensor q1,$Q1;
endinexpression;
inexpression F13;
  totensor $q1,$Q1;
endinexpression;
inexpression F14;
  totensor Q1,q1;
endinexpression;
inexpression F15;
  totensor $Q1,q1;
endinexpression;
inexpression F16;
  totensor Q1,$q1;
endinexpression;
inexpression F17;
  totensor $Q1,$q1;
endinexpression;

inexpression F51;
  totensor !{p1,p2},q1,Q1;
endinexpression;

inexpression F61;
  totensor !p1,q1,Q1;
endinexpression;

inexpression F71;
  multiply replace_(q1,nosquare);
  totensor nosquare,functions;
endinexpression;

inexpression F72;
  multiply replace_(q1,nosquare);
  totensor nosquare,functions,nosquare,functions;
endinexpression;

P;
.end
assert succeeded?

assert result("F0") =~ expr("f(q1,q2)*p1.q1*p2.q1*q1.q1*q1.q2")
assert result("F1") =~ expr("f(q1,q2)*Q1(p1,p2,q2,N1_?,N1_?)")
assert result("F2") =~ expr("f(q1,q2)*Q1(p1,p2,q2)*q1.q1")
assert result("F3") =~ expr("f(N1_?,q2)*Q1(p1,p2,q2,N1_?,N2_?,N2_?)")
assert result("F4") =~ expr("f(N1_?,q2)*Q1(p1,p2,q2,N1_?)*q1.q1")
assert result("F5") =~ expr("f(q1,q2)*Q1(q2,N1_?,N1_?)*p1.q1*p2.q1")
assert result("F6") =~ expr("f(q1,q2)*Q1(p2,q2,N1_?,N1_?)*p1.q1")
assert result("F7") =~ expr("f(N1_?,q2)*Q1(q2,N1_?)*p1.q1*p2.q1*q1.q1")

assert result("F1") == result("F11")
assert result("F1") == result("F12")
assert result("F1") == result("F13")
assert result("F1") == result("F14")
assert result("F1") == result("F15")
assert result("F1") == result("F16")
assert result("F1") == result("F17")

assert result("F5") == result("F51")

assert result("F6") == result("F61")

assert result("F71") =~ expr("f(nosquare,q2)*functions(p1,p2,q2,N1_?,N1_?)")
assert result("F72") =~ expr("f(N1_?,q2)*functions(p1,p2,q2,N1_?)*nosquare.nosquare")
*--#] CoToTensor :
*--#[ Format_allfloat :
* See also Issue #216.
#-
Off stats;
S x;
L F = x - x^2 + 2*x^3 + 1/2*x^4 - 2/3*x^5;
.sort

#message (0) normal
#write " F = %E;", F
.sort

#message (1) Fortran
Format Fortran;
#write " F = %E;", F
.sort

* TODO: this combination doesn't work correctly, though no one may use
* single-precision Fortran seriously.
*
* #message Fortran,allfloat
* Format Fortran;
* Format allfloat;
* #write " F = %E;", F
* .sort

#message (2) DoubleFortran
Format DoubleFortran;
#write " F = %E;", F
.sort

#message (3) DoubleFortran,allfloat
Format DoubleFortran;
Format allfloat;
#write " F = %E;", F
.sort

#message (4) QuadrupleFortran
Format QuadrupleFortran;
#write " F = %E;", F
.sort

#message (5) QuadrupleFortran,allfloat
Format QuadrupleFortran;
Format allfloat;
#write " F = %E;", F
.sort

#message (6) Fortran90,.0_wp
Format Fortran90,.0_wp;  * forcibly allfloat
#write " F = %E;", F
.end
assert succeeded?
assert result("F", 0) =~ expr("x - x^2 + 2*x^3 + 1/2*x^4 - 2/3*x^5")
assert result("F", 1) =~ expr("x - x**2 + 2*x**3 + 1./2.*x**4 - 2./3.*x**5")
assert result("F", 2) =~ expr("x - x**2 + 2*x**3 + 1.D0/2.D0*x**4 - 2.D0/3.D0*x**5")
assert result("F", 3) =~ expr("x - x**2 + 2.D0*x**3 + 1.D0/2.D0*x**4 - 2.D0/3.D0*x**5")
assert result("F", 4) =~ expr("x - x**2 + 2*x**3 + 1.Q0/2.Q0*x**4 - 2.Q0/3.Q0*x**5")
assert result("F", 5) =~ expr("x - x**2 + 2.Q0*x**3 + 1.Q0/2.Q0*x**4 - 2.Q0/3.Q0*x**5")
assert result("F", 6) =~ expr("x - x**2 + 2.0_wp*x**3 + 1.0_wp/2.0_wp*x**4 - 2.0_wp/3.0_wp*x**5")
*--#] Format_allfloat :
*--#[ Format_noreset_linelen :
#-
Off stats;
Auto S x;
L F = (x1+...+x5)^3;
.sort

#message (0) normal,80
#write " F = %E;", F
.sort

#message (1) Fortran,72
Format Fortran;
#write " F = %E;", F
.sort

#message (2) C,50
Format 50;
Format C;
#write " F = %E;", F
.sort

#message (3) Fortran,50
Format Fortran;
#write " F = %E;", F
.end
assert succeeded?
assert result("F", 0) =~ expr("
     x5^3 + 3*x4*x5^2 + 3*x4^2*x5 + x4^3 + 3*x3*x5^2 + 6*x3*x4*x5 + 3*x3*x4^2
       + 3*x3^2*x5 + 3*x3^2*x4 + x3^3 + 3*x2*x5^2 + 6*x2*x4*x5 + 3*x2*x4^2 + 6
      *x2*x3*x5 + 6*x2*x3*x4 + 3*x2*x3^2 + 3*x2^2*x5 + 3*x2^2*x4 + 3*x2^2*x3
       + x2^3 + 3*x1*x5^2 + 6*x1*x4*x5 + 3*x1*x4^2 + 6*x1*x3*x5 + 6*x1*x3*x4
       + 3*x1*x3^2 + 6*x1*x2*x5 + 6*x1*x2*x4 + 6*x1*x2*x3 + 3*x1*x2^2 + 3*x1^2
      *x5 + 3*x1^2*x4 + 3*x1^2*x3 + 3*x1^2*x2 + x1^3
")
assert result("F", 1) =~ expr("
     x5**3 + 3*x4*x5**2 + 3*x4**2*x5 + x4**3 + 3*x3*x5**2 + 6*x3*x4*x5
     &  + 3*x3*x4**2 + 3*x3**2*x5 + 3*x3**2*x4 + x3**3 + 3*x2*x5**2 + 6
     & *x2*x4*x5 + 3*x2*x4**2 + 6*x2*x3*x5 + 6*x2*x3*x4 + 3*x2*x3**2 +
     & 3*x2**2*x5 + 3*x2**2*x4 + 3*x2**2*x3 + x2**3 + 3*x1*x5**2 + 6*x1
     & *x4*x5 + 3*x1*x4**2 + 6*x1*x3*x5 + 6*x1*x3*x4 + 3*x1*x3**2 + 6*
     & x1*x2*x5 + 6*x1*x2*x4 + 6*x1*x2*x3 + 3*x1*x2**2 + 3*x1**2*x5 + 3
     & *x1**2*x4 + 3*x1**2*x3 + 3*x1**2*x2 + x1**3
")
assert result("F", 2) =~ expr("
     pow(x5,3) + 3*x4*pow(x5,2) + 3*pow(x4,2)*x5
       + pow(x4,3) + 3*x3*pow(x5,2) + 6*x3*x4*x5
       + 3*x3*pow(x4,2) + 3*pow(x3,2)*x5 + 3*pow(
      x3,2)*x4 + pow(x3,3) + 3*x2*pow(x5,2) + 6*
      x2*x4*x5 + 3*x2*pow(x4,2) + 6*x2*x3*x5 + 6*
      x2*x3*x4 + 3*x2*pow(x3,2) + 3*pow(x2,2)*x5
       + 3*pow(x2,2)*x4 + 3*pow(x2,2)*x3 + pow(
      x2,3) + 3*x1*pow(x5,2) + 6*x1*x4*x5 + 3*x1*
      pow(x4,2) + 6*x1*x3*x5 + 6*x1*x3*x4 + 3*x1*
      pow(x3,2) + 6*x1*x2*x5 + 6*x1*x2*x4 + 6*x1*
      x2*x3 + 3*x1*pow(x2,2) + 3*pow(x1,2)*x5 + 3
      *pow(x1,2)*x4 + 3*pow(x1,2)*x3 + 3*pow(
      x1,2)*x2 + pow(x1,3)
")
assert result("F", 3) =~ expr("
     x5**3 + 3*x4*x5**2 + 3*x4**2*x5 + x4**3 + 3*
     & x3*x5**2 + 6*x3*x4*x5 + 3*x3*x4**2 + 3*
     & x3**2*x5 + 3*x3**2*x4 + x3**3 + 3*x2*x5**2
     &  + 6*x2*x4*x5 + 3*x2*x4**2 + 6*x2*x3*x5 +
     & 6*x2*x3*x4 + 3*x2*x3**2 + 3*x2**2*x5 + 3*
     & x2**2*x4 + 3*x2**2*x3 + x2**3 + 3*x1*x5**2
     &  + 6*x1*x4*x5 + 3*x1*x4**2 + 6*x1*x3*x5 +
     & 6*x1*x3*x4 + 3*x1*x3**2 + 6*x1*x2*x5 + 6*
     & x1*x2*x4 + 6*x1*x2*x3 + 3*x1*x2**2 + 3*
     & x1**2*x5 + 3*x1**2*x4 + 3*x1**2*x3 + 3*
     & x1**2*x2 + x1**3
")
*--#] Format_noreset_linelen :
*--#[ Float_1 :
#-
* Example from the FORM Workshop (Madrid 2023) slides, also in the manual.

#StartFloat 500b,MZV=15

Local F1 =
	-mzv_(8,1,1,5)
	+29056868/39414375*mzv_(2)^6*mzv_(3)
	-47576/40425*mzv_(2)^5*mzv_(5)
	-163291/18375*mzv_(2)^4*mzv_(7)
	-4/105*mzv_(2)^3*mzv_(3)^3
	-450797/11025*mzv_(2)^3*mzv_(9)
	+7/5*mzv_(2)^2*mzv_(3)^2*mzv_(5)
	+16/25*mzv_(2)^2*mzv_(3)*mzv_(5,3)
	+454049/1400*mzv_(2)^2*mzv_(11)
	-16/25*mzv_(2)^2*mzv_(5,3,3)
	+3*mzv_(2)*mzv_(3)^2*mzv_(7)
	+61/14*mzv_(2)*mzv_(3)*mzv_(5)^2
	+2/7*mzv_(2)*mzv_(3)*mzv_(7,3)
	+2172853/420*mzv_(2)*mzv_(13)
	-2/7*mzv_(2)*mzv_(7,3,3)
	+1/7*mzv_(2)*mzv_(5,5,3)
	-33/4*mzv_(3)^2*mzv_(9)
	-133/6*mzv_(3)*mzv_(5)*mzv_(7)
	-25/9*mzv_(3)*mzv_(9,3)
	-244/105*mzv_(5)^3
	-359/105*mzv_(5)*mzv_(7,3)
	+3/10*mzv_(7)*mzv_(5,3)
	+89/18*mzv_(9,3,3)
	+569/105*mzv_(7,3,5);
L F2 = mzv_(15);
Evaluate mzv_;
Print;
.sort

Skip F1,F2;
Local X = F1/F2;
ToRational;
Print;
.sort

#EndFloat
Local G1 = F1;
Local G2 = F2;

Print G1,G2;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("X") =~ expr("229903169/25200")
assert stdout =~ exact_pattern(<<'EOF')
   F1 =
      9.1234206877960755900164875575406726239325002222490534540605137258846994\
      916348297032751308227224952419629422497720599224543719959652966613231560\
      6913926e+03;
EOF
assert stdout =~ exact_pattern(<<'EOF')
   F2 =
      1.0000305882363070204935517285106450625876279487068581775065699328933322\
      671563422795730723343470175484943669684442492832530297757588781904321794\
      40477e+00;
EOF
assert stdout =~ exact_pattern(<<'EOF')
   G1 =
      float_(10,10,1,225649930152063087544280124519603661924016376904153173222\
      961313295752588365049496190204609112667217257624737508104376810254484309\
      3830597279756558899541412580219255737022507716035);
EOF
assert stdout =~ exact_pattern(<<'EOF')
   G2 =
      float_(10,10,1,247337966873870703631573653423368526098272821023387457752\
      643030990710929556575503489173572446024607642191456056189912528713904095\
      704444384800390830056125051605311704862654126);
EOF
*--#] Float_1 :
*--#[ evaluate_symbol :
#-
#StartFloat 64b

Symbol a,b;
Local PI0 = a*b;
Local PI1 = pi_;
Local PI2 = pi_*3;
Local PI3 = pi_*sqrt_(3);
Local PI4 = pi_*pi_*pi_;
Local PI5 = a*pi_*b;
Local PI6 = sqrt_(pi_);

Local EE1 = ee_;
Local EE2 = pi_*ee_;

Local EM1 = em_;

ToFloat;
Evaluate;

Print;
.end
#pend_if wordsize == 2
assert result("PI0") =~ expr("1.0e+00*a*b")
assert result("PI1") =~ expr("3.141592653589793238e+00")
assert result("PI2") =~ expr("9.424777960769379715e+00")
assert result("PI3") =~ expr("5.441398092702653552e+00")
assert result("PI4") =~ expr("3.100627668029982018e+01")
assert result("PI5") =~ expr("3.141592653589793238e+00*a*b")
assert result("PI6") =~ expr("1.772453850905516027e+00")
assert result("EE1") =~ expr("2.718281828459045235e+00")
assert result("EE2") =~ expr("8.539734222673567065e+00")
assert result("EM1") =~ expr("5.772156649015328606e-01")
*--#] evaluate_symbol :
*--#[ evaluate_symbol_pi :
#-
#StartFloat 128b

Local PI = pi_;
Local EE = ee_;
Local EM = em_;

ToFloat;
Evaluate pi_;

Print;
.end
#pend_if wordsize == 2
assert result("PI") =~ expr("3.1415926535897932384626433832795028842e+00")
assert result("EE") =~ expr("1.0e+00*ee_")
assert result("EM") =~ expr("1.0e+00*em_")
*--#] evaluate_symbol_pi :
*--#[ evaluate_symbol_ee :
#-
#StartFloat 160b

Local PI = pi_;
Local EE = ee_;
Local EM = em_;

ToFloat;
Evaluate ee_;

Print;
.end
#pend_if wordsize == 2
assert result("PI") =~ expr("1.0e+00*pi_")
assert result("EE") =~ expr("2.7182818284590452353602874713526624977572470937e+00")
assert result("EM") =~ expr("1.0e+00*em_")
*--#] evaluate_symbol_ee :
*--#[ evaluate_symbol_em :
#-
#StartFloat 192b

Local PI = pi_;
Local EE = ee_;
Local EM = em_;

ToFloat;
Evaluate em_;

Print;
.end
#pend_if wordsize == 2
assert result("PI") =~ expr("1.0e+00*pi_")
assert result("EE") =~ expr("1.0e+00*ee_")
assert result("EM") =~ expr("5.77215664901532860606512090082402431042159335939923598806e-01")
*--#] evaluate_symbol_em :
*--#[ evaluate_mzv_2 :
#-
L F = mzv_(2);
.sort

Hide;
#do digits=1,20
	#StartFloat `digits'd,MZV=2
	Local F`digits' = F;
	Evaluate mzv_;
	Print;
	.sort
	Hide;
	#endfloat
#enddo
.end
#pend_if wordsize == 2
assert result("F1") =~ expr("2e+00")
assert result("F2") =~ expr("1.6e+00")
assert result("F3") =~ expr("1.64e+00")
assert result("F4") =~ expr("1.645e+00")
assert result("F5") =~ expr("1.6449e+00")
assert result("F6") =~ expr("1.64493e+00")
assert result("F7") =~ expr("1.644934e+00")
assert result("F8") =~ expr("1.6449341e+00")
assert result("F9") =~ expr("1.64493407e+00")
assert result("F10") =~ expr("1.644934067e+00")
assert result("F11") =~ expr("1.6449340668e+00")
assert result("F12") =~ expr("1.64493406685e+00")
assert result("F13") =~ expr("1.644934066848e+00")
assert result("F14") =~ expr("1.6449340668482e+00")
assert result("F15") =~ expr("1.64493406684823e+00")
assert result("F16") =~ expr("1.644934066848226e+00")
assert result("F17") =~ expr("1.6449340668482264e+00")
assert result("F18") =~ expr("1.64493406684822644e+00")
assert result("F19") =~ expr("1.644934066848226436e+00")
assert result("F20") =~ expr("1.6449340668482264365e+00")
*--#] evaluate_mzv_2 : 
*--#[ evaluate_all_mzv_2-6 : 
#-
Symbol a,n,x,jj;
CFunction mzv;
#do weight=2,6
	L F`weight' = x^`weight'*mzv();
#enddo
* Generate all possible arguments
repeat id x^n?{>0}*mzv(?a) = sum_(jj,1,n, x^(n-jj)*mzv(?a,jj));
* Only keep convergent MZVs
id mzv(1,?a) = 0;
.sort

Hide;
#do weight=2,6
	#StartFloat 74b,MZV=`weight'
	Local MZV`weight' = F`weight';
	id mzv(?a) = mzv(?a)*mzv_(?a);
	Evaluate mzv_;
	Print +s;
	.sort
	Hide;
	#endfloat
#enddo
.end
#pend_if wordsize == 2
assert succeeded?
assert result("MZV2") =~ expr("
	   + 1.644934066848226436472e+00*mzv(2)
")
assert result("MZV3") =~ expr("
       + 1.2020569031595942854e+00*mzv(2,1)
       + 1.2020569031595942854e+00*mzv(3)
")
assert result("MZV4") =~ expr("
       + 1.082323233711138191516e+00*mzv(2,1,1)
       + 8.11742425283353643637e-01*mzv(2,2)
       + 2.70580808427784547879e-01*mzv(3,1)
       + 1.082323233711138191516e+00*mzv(4)
")
assert result("MZV5") =~ expr("
       + 1.036927755143369926331e+00*mzv(2,1,1,1)
       + 7.11566197550572432097e-01*mzv(2,1,2)
       + 2.288103976033537597687e-01*mzv(2,2,1)
       + 7.11566197550572432097e-01*mzv(2,3)
       + 9.655115998944373446565e-02*mzv(3,1,1)
       + 2.288103976033537597687e-01*mzv(3,2)
       + 9.655115998944373446565e-02*mzv(4,1)
       + 1.036927755143369926331e+00*mzv(5)
")
assert result("MZV6") =~ expr("
       + 1.017343061984449139715e+00*mzv(2,1,1,1,1)
       + 6.745239140339681404916e-01*mzv(2,1,1,2)
       + 2.137988682245925470996e-01*mzv(2,1,2,1)
       + 6.183495605712693078956e-01*mzv(2,1,3)
       + 8.848338245436871429433e-02*mzv(2,2,1,1)
       + 1.907518241220842136965e-01*mzv(2,2,2)
       + 7.922139756520716599903e-02*mzv(2,3,1)
       + 6.745239140339681404916e-01*mzv(2,4)
       + 4.053689727151973782905e-02*mzv(3,1,1,1)
       + 7.922139756520716599903e-02*mzv(3,1,2)
       + 3.230902899166988169841e-02*mzv(3,2,1)
       + 2.137988682245925470996e-01*mzv(3,3)
       + 1.748985316901140442593e-02*mzv(4,1,1)
       + 8.848338245436871429433e-02*mzv(4,2)
       + 4.053689727151973782905e-02*mzv(5,1)
       + 1.017343061984449139715e+00*mzv(6)
")
*--#] evaluate_all_mzv_2-6 :
*--#[ evaluate_all_euler_1-4 : 
Symbol a,n,x,jj;
CFunction euler;
#do weight=1,6
	L F`weight' = x^`weight'*euler();
#enddo
* Generate all possible arguments
repeat id x^n?{>0}*euler(?a) = sum_(jj,1,n, x^(n-jj)*euler(?a,-jj))+sum_(jj,1,n, x^(n-jj)*euler(?a,jj));
* Only keep convergent sums
id euler(1,?a) = 0;
.sort

Hide;
#do weight=1,4
	#StartFloat 74b,MZV=`weight'
	Local EULER`weight' = F`weight';
	id euler(?a) = euler(?a)*euler_(?a);
	Evaluate euler_;
	Print +s;
	.sort
	Hide;
	#endfloat
#enddo
.end
#pend_if wordsize == 2
assert succeeded?
assert result("EULER1") =~ expr("
       - 6.931471805599453094172e-01*euler(-1)
")
assert result("EULER2") =~ expr("
       - 8.224670334241132182362e-01*euler(-2)
       - 5.822405264650125059027e-01*euler(-1,-1)
       + 2.402265069591007123336e-01*euler(-1,1)
       + 1.644934066848226436472e+00*euler(2)
")
assert result("EULER3") =~ expr("
       - 9.015426773696957140498e-01*euler(-3)
       - 2.430703516700615775627e-01*euler(-2,-1)
       + 1.50257112894949285675e-01*euler(-2,1)
       - 3.888958461681063290997e-01*euler(-1,-2)
       + 2.140723708667062274342e-01*euler(-1,-1,-1)
       - 5.372131936080402009406e-01*euler(-1,-1,1)
       + 9.475300423012770572182e-02*euler(-1,1,-1)
       - 5.550410866482157995314e-02*euler(-1,1,1)
       + 2.695764795315278073874e-01*euler(-1,2)
       - 5.082152128046848508121e-01*euler(2,-1)
       + 1.2020569031595942854e+00*euler(2,1)
       + 1.2020569031595942854e+00*euler(3)
")
assert result("EULER4") =~ expr("
       - 9.470328294972459175765e-01*euler(-4)
       - 1.17875999650509326841e-01*euler(-3,-1)
       + 8.778567156865530203659e-02*euler(-3,1)
       - 2.029356063208384109093e-01*euler(-2,-2)
       + 5.465305273826365205925e-02*euler(-2,-1,-1)
       - 9.309712599176857714371e-02*euler(-2,-1,1)
       + 3.41591261665139137232e-02*euler(-2,1,-1)
       - 2.375236632261848595145e-02*euler(-2,1,1)
       + 1.626546673974200807756e-01*euler(-2,2)
       - 3.395454690873598695907e-01*euler(-1,-3)
       + 6.936803430285457740076e-02*euler(-1,-2,-1)
       - 1.1285749644390297273e-01*euler(-1,-2,1)
       + 2.410220753003005639135e-01*euler(-1,-1,-2)
       + 8.798553701050896029994e-02*euler(-1,-1,-1,-1)
       - 5.091676406429263452417e-02*euler(-1,-1,-1,1)
       + 2.02865795179889634385e-01*euler(-1,-1,1,-1)
       - 5.174790616738993863308e-01*euler(-1,-1,1,1)
       - 3.522826783975370883778e-01*euler(-1,-1,2)
       + 7.734090056675821939211e-02*euler(-1,1,-2)
       - 2.327506608672756416438e-02*euler(-1,1,-1,-1)
       + 4.075823915930925192076e-02*euler(-1,1,-1,1)
       - 1.413423721499000878947e-02*euler(-1,1,1,-1)
       + 9.618129107628477161979e-03*euler(-1,1,1,1)
       - 6.053489317192111168615e-02*euler(-1,1,2)
       + 4.551222386652609668434e-02*euler(-1,2,-1)
       - 3.289319519435604132636e-02*euler(-1,2,1)
       + 2.866757544385383102356e-01*euler(-1,3)
       - 5.685258800390969025941e-01*euler(2,-2)
       - 1.935553538130652468834e-01*euler(2,-1,-1)
       + 1.141234274160608451268e-01*euler(2,-1,1)
       - 4.336923770489551966887e-01*euler(2,1,-1)
       + 1.082323233711138191516e+00*euler(2,1,1)
       + 8.11742425283353643637e-01*euler(2,2)
       - 1.728452782389843861048e-01*euler(3,-1)
       + 2.70580808427784547879e-01*euler(3,1)
       + 1.082323233711138191516e+00*euler(4)
")
*--#] evaluate_all_euler_1-4 :
*--#[ evaluate_all_mzvhalf_1-6 : 
Symbol a,n,x,jj;
CFunction mzvhalf;
#do weight=1,6
	L F`weight' = x^`weight'*mzvhalf();
#enddo
* Generate all possible arguments
repeat id x^n?{>0}*mzvhalf(?a) = sum_(jj,1,n, x^(n-jj)*mzvhalf(?a,jj));
.sort

Hide;
#do weight=1,6
	#StartFloat 74b, MZV = `weight'
	Local MZVHALF`weight' = F`weight';
	id mzvhalf(?a) = mzvhalf(?a)*mzvhalf_(?a);
	Evaluate mzvhalf_;
	Print +s;
	.sort
	Hide;
	#endfloat
#enddo
.end
#pend_if wordsize == 2
assert succeeded?
assert result("MZVHALF1") =~ expr("
        +6.931471805599453094172e-01*mzvhalf(1)
")
assert result("MZVHALF2") =~ expr("
        +2.402265069591007123335e-01*mzvhalf(1,1)
       + 5.822405264650125059027e-01*mzvhalf(2)
")
assert result("MZVHALF3") =~ expr("
        +5.550410866482157995314e-02*mzvhalf(1,1,1)
       + 2.140723708667062274342e-01*mzvhalf(1,2)
       + 9.475300423012770572182e-02*mzvhalf(2,1)
       + 5.372131936080402009406e-01*mzvhalf(3)
")
assert result("MZVHALF4") =~ expr("
        +9.618129107628477161979e-03*mzvhalf(1,1,1,1)
       + 5.091676406429263452417e-02*mzvhalf(1,1,2)
       + 2.327506608672756416438e-02*mzvhalf(1,2,1)
       + 2.02865795179889634385e-01*mzvhalf(1,3)
       + 1.413423721499000878947e-02*mzvhalf(2,1,1)
       + 8.798553701050896029994e-02*mzvhalf(2,2)
       + 4.075823915930925192076e-02*mzvhalf(3,1)
       + 5.174790616738993863308e-01*mzvhalf(4)
")
assert result("MZVHALF5") =~ expr("
        +1.333355814642844342341e-03*mzvhalf(1,1,1,1,1)
       + 8.977079866463296833435e-03*mzvhalf(1,1,1,2)
       + 4.180785927505245511698e-03*mzvhalf(1,1,2,1)
       + 4.888837363087644124842e-02*mzvhalf(1,1,3)
       + 2.590491526783706529017e-03*mzvhalf(1,2,1,1)
       + 2.202353039232048705332e-02*mzvhalf(1,2,2)
       + 1.040778815345923684362e-02*mzvhalf(1,3,1)
       + 1.977851218733276555108e-01*mzvhalf(1,4)
       + 1.801653787038017905577e-03*mzvhalf(2,1,1,1)
       + 1.326622979787512352052e-02*mzvhalf(2,1,2)
       + 6.215468460408135423935e-03*mzvhalf(2,2,1)
       + 8.496239975196462665687e-02*mzvhalf(2,3)
       + 3.876067314665263762197e-03*mzvhalf(3,1,1)
       + 3.888005884184390429248e-02*mzvhalf(3,2)
       + 1.853078606546661304236e-02*mzvhalf(4,1)
       + 5.084005792422687074591e-01*mzvhalf(5)
")
assert result("MZVHALF6") =~ expr("
        +1.540353039338160995444e-04*mzvhalf(1,1,1,1,1,1)
       + 1.258876902820489070556e-03*mzvhalf(1,1,1,1,2)
       + 5.934649939092641274313e-04*mzvhalf(1,1,1,2,1)
       + 8.687699837464924332492e-03*mzvhalf(1,1,1,3)
       + 3.725016654823881497105e-04*mzvhalf(1,1,2,1,1)
       + 3.999767838591861292463e-03*mzvhalf(1,1,2,2)
       + 1.911985496708273694742e-03*mzvhalf(1,1,3,1)
       + 4.795057789712260825139e-02*mzvhalf(1,1,4)
       + 2.626471417724444826556e-04*mzvhalf(1,2,1,1,1)
       + 2.463136250615208192292e-03*mzvhalf(1,2,1,2)
       + 1.169869909499536413856e-03*mzvhalf(1,2,2,1)
       + 2.145129727375666323602e-02*mzvhalf(1,2,3)
       + 7.400960371731285392346e-04*mzvhalf(1,3,1,1)
       + 1.004682297311360973229e-02*mzvhalf(1,3,2)
       + 4.847461771043371713843e-03*mzvhalf(1,4,1)
       + 1.953981544864645991443e-01*mzvhalf(1,5)
       + 1.97232820211621153726e-04*mzvhalf(2,1,1,1,1)
       + 1.706168769515668670888e-03*mzvhalf(2,1,1,2)
       + 8.069036109476304022076e-04*mzvhalf(2,1,2,1)
       + 1.287224686067429263904e-02*mzvhalf(2,1,3)
       + 5.081857692654553033744e-04*mzvhalf(2,2,1,1)
       + 5.968128689077008853625e-03*mzvhalf(2,2,2)
       + 2.863764078749510138598e-03*mzvhalf(2,3,1)
       + 8.355552124728128937156e-02*mzvhalf(2,4)
       + 3.596008310955505224866e-04*mzvhalf(3,1,1,1)
       + 3.701399425949438029416e-03*mzvhalf(3,1,2)
       + 1.765926326069690097067e-03*mzvhalf(3,2,1)
       + 3.801462469797616251775e-02*mzvhalf(3,3)
       + 1.122469979658377667375e-03*mzvhalf(4,1,1)
       + 1.798212154990578314126e-02*mzvhalf(4,2)
       + 8.723003057596888427165e-03*mzvhalf(5,1)
       + 5.0409539780398855069e-01*mzvhalf(6)
")
*--#] evaluate_all_mzvhalf_1-6 : 
*--#[ evaluate_sin :
#StartFloat 24d
Symbol n;
CFunction sin;
Local SIN = sum_(n,4,27,sin(2*pi_*n/24)*sin_(2*pi_*n/24))+sin(4*pi_/13)*sin_(4*pi_/13)+sin(-1.2*pi_/13)*sin_(-1.2*pi_/13);
Evaluate sin_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("SIN") =~ expr("
       + 8.22983865893656394579617e-01*sin(4/13*pi_)
       + 8.66025403784438646763723e-01*sin(1/3*pi_)
       + 9.65925826289068286749743e-01*sin(5/12*pi_)
       + 1.0e+00*sin(1/2*pi_)
       + 9.65925826289068286749743e-01*sin(7/12*pi_)
       + 8.66025403784438646763723e-01*sin(2/3*pi_)
       + 7.07106781186547524400844e-01*sin(3/4*pi_)
       + 5.0e-01*sin(5/6*pi_)
       + 2.58819045102520762348899e-01*sin(11/12*pi_)
       - 2.58819045102520762348899e-01*sin(13/12*pi_)
       - 5.0e-01*sin(7/6*pi_)
       - 7.07106781186547524400844e-01*sin(5/4*pi_)
       - 8.66025403784438646763723e-01*sin(4/3*pi_)
       - 9.65925826289068286749743e-01*sin(17/12*pi_)
       - 1.0e+00*sin(3/2*pi_)
       - 9.65925826289068286749743e-01*sin(19/12*pi_)
       - 8.66025403784438646763723e-01*sin(5/3*pi_)
       - 7.07106781186547524400844e-01*sin(7/4*pi_)
       - 5.0e-01*sin(11/6*pi_)
       - 2.58819045102520762348899e-01*sin(23/12*pi_)
       + 2.58819045102520762348899e-01*sin(25/12*pi_)
       + 5.0e-01*sin(13/6*pi_)
       + 7.07106781186547524400844e-01*sin(9/4*pi_)
       - 2.8594567839868926206474e-01*sin( - 9.23076923076923076923077e-02*pi_
      )
")
*--#] evaluate_sin : 
*--#[ evaluate_cos :
#StartFloat 24d
Symbol n;
CFunction cos;
Local COS = sum_(n,4,27,cos(2*pi_*n/24)*cos_(2*pi_*n/24))+cos(-2^32*pi_/3)*cos_(-2^32*pi_/3)+cos(4*pi_/13)*cos_(4*pi_/13)+cos(-1.2*pi_/13)*cos_(-1.2*pi_/13)+cos(2^32*pi_/(2^32+1))*cos_(2^32*pi_/(2^32+1));
Evaluate cos_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("COS") =~ expr("
       - 5.0e-01*cos( - 4294967296/3*pi_)
       + 5.68064746731155802511808e-01*cos(4/13*pi_)
       + 5.0e-01*cos(1/3*pi_)
       + 2.58819045102520762348899e-01*cos(5/12*pi_)
       - 2.58819045102520762348899e-01*cos(7/12*pi_)
       - 5.0e-01*cos(2/3*pi_)
       - 7.07106781186547524400844e-01*cos(3/4*pi_)
       - 8.66025403784438646763723e-01*cos(5/6*pi_)
       - 9.65925826289068286749743e-01*cos(11/12*pi_)
       - 9.99999999999999999732484e-01*cos(4294967296/4294967297*pi_)
       - 9.65925826289068286749743e-01*cos(13/12*pi_)
       - 8.66025403784438646763723e-01*cos(7/6*pi_)
       - 7.07106781186547524400844e-01*cos(5/4*pi_)
       - 5.0e-01*cos(4/3*pi_)
       - 2.58819045102520762348899e-01*cos(17/12*pi_)
       + 2.58819045102520762348899e-01*cos(19/12*pi_)
       + 5.0e-01*cos(5/3*pi_)
       + 7.07106781186547524400844e-01*cos(7/4*pi_)
       + 8.66025403784438646763723e-01*cos(11/6*pi_)
       + 9.65925826289068286749743e-01*cos(23/12*pi_)
       + 1.0e+00*cos(2*pi_)
       + 9.65925826289068286749743e-01*cos(25/12*pi_)
       + 8.66025403784438646763723e-01*cos(13/6*pi_)
       + 7.07106781186547524400844e-01*cos(9/4*pi_)
       + 9.58245829109166210690747e-01*cos( - 9.23076923076923076923077e-02*
      pi_)
       - 1.0e+00*cos(pi_)
")
*--#] evaluate_cos : 
*--#[ evaluate_tan :
#StartFloat 24d
Symbol n;
CFunction tan;
Local TAN = sum_(n,4,27,tan(2*pi_*n/24)*tan_(2*pi_*n/24))+tan(4*pi_/13)*tan_(4*pi_/13)+tan(-1.2*pi_/13)*tan_(-1.2*pi_/13);
Evaluate tan_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("TAN") =~ expr("
         + tan_(1/2*pi_)*tan(1/2*pi_)
       + tan_(3/2*pi_)*tan(3/2*pi_)
       + 1.44875011278097222958133e+00*tan(4/13*pi_)
       + 1.73205080756887729352745e+00*tan(1/3*pi_)
       + 3.73205080756887729352745e+00*tan(5/12*pi_)
       - 3.73205080756887729352745e+00*tan(7/12*pi_)
       - 1.73205080756887729352745e+00*tan(2/3*pi_)
       + 1.0e+00*tan(3/4*pi_)
       - 5.77350269189625764509149e-01*tan(5/6*pi_)
       - 2.67949192431122706472554e-01*tan(11/12*pi_)
       + 2.67949192431122706472554e-01*tan(13/12*pi_)
       + 5.77350269189625764509149e-01*tan(7/6*pi_)
       + 1.0e+00*tan(5/4*pi_)
       + 1.73205080756887729352745e+00*tan(4/3*pi_)
       + 3.73205080756887729352745e+00*tan(17/12*pi_)
       - 3.73205080756887729352745e+00*tan(19/12*pi_)
       - 1.73205080756887729352745e+00*tan(5/3*pi_)
       + 1.0e+00*tan(7/4*pi_)
       - 5.77350269189625764509149e-01*tan(11/6*pi_)
       - 2.67949192431122706472554e-01*tan(23/12*pi_)
       + 2.67949192431122706472554e-01*tan(25/12*pi_)
       + 5.77350269189625764509149e-01*tan(13/6*pi_)
       + 1.0e+00*tan(9/4*pi_)
       - 2.9840534621947567190308e-01*tan( - 9.23076923076923076923077e-02*pi_
      )
")
*--#] evaluate_tan : 
*--#[ evaluate_asin :
#StartFloat 82b
CFunction asin;
Local ASIN = asin(0)*asin_(0)+2*asin(-1.0)*asin_(-1.0)/pi_+2*asin(1)*asin_(1)/pi_+asin(-0.7356)*asin_(-0.7356)+asin(4/13)*asin_(4/13)+asin(-3/2)*asin_(-3/2)+asin(5)*asin_(5);
Evaluate asin_, pi_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("ASIN") =~ expr("
       + asin_( - 3/2)*asin( - 3/2)
       + asin_(5)*asin(5)
       + 3.12766721941544958213894e-01*asin(4/13)
       - 8.26551974047654326578014e-01*asin( - 7.356e-01)
       - 1.0e+00*asin( - 1.0e+00)
       + 1.0e+00*asin(1)
")
*--#] evaluate_asin : 
*--#[ evaluate_acos :
#StartFloat 82b
CFunction acos;
Local ACOS = 2*acos(0)*acos_(0)/pi_+acos(-1.0)*acos_(-1.0)/pi_+acos(1)*acos_(1)+acos(-0.7356)*acos_(-0.7356)+acos(4/13)*acos_(4/13)+acos(-3/2)*acos_(-3/2)+acos(5)*acos_(5);
Evaluate acos_, pi_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("ACOS") =~ expr("
         + acos_( - 3/2)*acos( - 3/2)
       + acos_(5)*acos(5)
       + 1.25802960485335166101743e+00*acos(4/13)
       + 2.39734830084255094580934e+00*acos( - 7.356e-01)
       + 1.0e+00*acos( - 1.0e+00)
       + 1.0e+00*acos(0)
")
*--#] evaluate_acos : 
*--#[ evaluate_atan :
#StartFloat 82b
CFunction atan;
Local ATAN = atan(0)*atan_(0)+atan(-1.0)*atan_(-1.0)+atan(1)*atan_(1)+atan(-0.7356)*atan_(-0.7356)+atan(4/13)*atan_(4/13)+2*atan(-10^20)*atan_(-10^20)/pi_+2*atan(10^20)*atan_(10^20)/pi_;
Evaluate atan_, pi_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("ATAN") =~ expr("
       - 9.99999999999999999993634e-01*atan( - 100000000000000000000)
       + 2.98498931586179277935128e-01*atan(4/13)
       + 9.99999999999999999993634e-01*atan(100000000000000000000)
       - 6.34221230827067632052843e-01*atan( - 7.356e-01)
       - 7.85398163397448309615661e-01*atan( - 1.0e+00)
       + 7.85398163397448309615661e-01*atan(1)
")
*--#] evaluate_atan : 
*--#[ evaluate_atan2 :
#Startfloat 21d
CFunction atan2;
Local ATAN2 = atan2(0,0)*atan2_(0,0)
			+atan2(0,24)*atan2_(0,24)
			+atan2(24/13,0)*atan2_(24/13,0)
			+atan2(3,-1.45)*atan2_(3,-1.45)
			+atan2(0.54321,-1.2345)*atan2_(0.54321,-1.2345)
			+atan2(5.4321,-45/11)*atan2_(5.4321,-45/11);
Evaluate;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("ATAN2") =~ expr("
         + 1.57079632679489661923e+00*atan2(24/13,0)
       + 2.72706541948852419832e+00*atan2(5.4321e-01, - 1.2345e+00)
       + 2.21627784862167698618e+00*atan2(5.4321e+00, - 45/11)
       + 2.02102192305561165724e+00*atan2(3, - 1.45e+00)
")
*--#] evaluate_atan2 : 
*--#[ evaluate_sqrt :
#Startfloat 21d
CFunction sqrt;
Local SQRT = sqrt(0)*sqrt_(0)+sqrt(1)*sqrt_(1)+sqrt(1.456789)*sqrt_(1.456789)+sqrt(25/7)*sqrt_(25/7)+sqrt(-1)*sqrt_(-1)+sqrt(5932)*sqrt_(5932);
Evaluate sqrt_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("SQRT") =~ expr("
       + sqrt_(-1)*sqrt(-1)
       + 1.88982236504613613607e+00*sqrt(25/7)
       + 1.20697514473165519284e+00*sqrt(1.456789e+00)
       + 1.0e+00*sqrt(1)
       + 7.70194780558788258528e+01*sqrt(5932)
")
*--#] evaluate_sqrt : 
*--#[ evaluate_ln :
#Startfloat 60b
CFunction ln;
Local LN = ln(1)*ln_(1)+ln(0)*ln_(0)+ln(ee_)*ln_(ee_)+ln(2.71828)*ln_(2.71828)+ln(2/3)*ln_(2/3)+ln(-5)*ln_(-5);
Evaluate ln_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("LN") =~ expr("
       + ln_(ee_)*ln(ee_)
       + ln_(-5)*ln(-5)
       + ln_(0)*ln(0)
       - 4.05465108108164382e-01*ln(2/3)
       + 9.99999327347282003e-01*ln(2.71828e+00)
")
*--#] evaluate_ln : 
*--#[ evaluate_eexp :
#Startfloat 84b
CFunction exp;
Local EXP = exp(0)*eexp_(0)+exp(1)*eexp_(1)+exp(-10)*eexp_(-10)+exp(2/11)*eexp_(2/11)+exp(36124.5)*eexp_(36124.5);
Evaluate;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("EXP") =~ expr("
         + 1.199396102035385909645662e+00*exp(2/11)
       + 4.688258114961839863324201e+15688*exp(3.61245e+04)
       + 4.539992976248485153559152e-05*exp(-10)
       + 1.0e+00*exp(0)
       + 2.718281828459045235360287e+00*exp(1)
")
*--#] evaluate_eexp : 
*--#[ evaluate_li2 :
#Startfloat 18d
CFunction li2;
Local LI2 = li2(0)*li2_(0)+li2(1)*li2_(1)+li2(-1)*li2_(-1)+li2(1/2)*li2_(1/2)+li2(1.4)*li2_(1.4)+li2(-10)*li2_(-10);
Evaluate li2_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("LI2") =~ expr("
         + li2_(1.4e+00)*li2(1.4e+00)
       + li2_(-10)*li2(-10)
       + 5.82240526465012506e-01*li2(1/2)
       - 8.22467033424113218e-01*li2(-1)
       + 1.64493406684822644e+00*li2(1)
")
*--#] evaluate_li2 : 
*--#[ evaluate_gamma :
#Startfloat 131b
CFunction gamma;
Local GAMMA = gamma(-754)*gamma_(-754)+gamma(-1)*gamma_(-1)+gamma(0)*gamma_(0)+gamma(1)*gamma_(1)+gamma(563)*gamma_(563)*invfac_(562)+gamma(-3/2)*gamma_(-3/2)+gamma(3.456)*gamma_(3.456);
Evaluate gamma_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("GAMMA") =~ expr("
       + gamma_(-754)*gamma(-754)
       + gamma_(-1)*gamma(-1)
       + gamma_(0)*gamma(0)
       + 2.3632718012073547030642233111215269104e+00*gamma( - 3/2)
       + 3.1669090330100746768222387336126462899e+00*gamma(3.456e+00)
       + 1.0e+00*gamma(1)
       + 1.0e+00*gamma(563)
")

*--#] evaluate_gamma : 
*--#[ evaluate_agm :
#Startfloat 33b
CFunction agm,f;
Local AGM = agm(24,6)*agm_(24,6)+agm(24,0)*agm_(24,0)+agm(0,6)*agm_(0,6)+agm(24,-1)*agm_(24,-1)+agm(-1,6)*agm_(-1,6)+agm(0,-1)*agm_(0,-1)+agm(-1,0)*agm_(-1,0);
Evaluate agm_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("AGM") =~ expr("
       + agm_(-1,6)*agm(-1,6)
       + agm_(24,-1)*agm(24,-1)
       + 1.34581715e+01*agm(24,6)
")

*--#] evaluate_agm : 
*--#[ evaluate_sinh :
#Startfloat 96b
CFunction sinh;
Local SINH = sinh(0)*sinh_(0)+sinh(1.0)*sinh_(1.0)+sinh(ln_(2))*sinh_(ln_(2))+sinh(-ln_(2))*sinh_(-ln_(2));
Argument sinh_;
	Evaluate;
Endargument;
Evaluate sinh_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("SINH") =~ expr("
       - 7.5e-01*sinh( - ln_(2))
       + 7.5e-01*sinh(ln_(2))
       + 1.175201193643801456882381851e+00*sinh(1.0e+00)
")
*--#] evaluate_sinh : 
*--#[ evaluate_cosh :
#Startfloat 96b
CFunction cosh;
Local COSH = cosh(0)*cosh_(0)+cosh(1.0)*cosh_(1.0)+cosh(-1.0)*cosh_(-1.0)+cosh(ln_(2))*cosh_(ln_(2))+cosh(-ln_(2))*cosh_(-ln_(2));
Argument cosh_;
	Evaluate;
Endargument;
Evaluate cosh_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("COSH") =~ expr("
       + 1.25e+00*cosh( - ln_(2))
       + 1.25e+00*cosh(ln_(2))
       + 1.543080634815243778477905621e+00*cosh( - 1.0e+00)
       + 1.543080634815243778477905621e+00*cosh(1.0e+00)
       + 1.0e+00*cosh(0)
")
*--#] evaluate_cosh : 
*--#[ evaluate_tanh :
#Startfloat 96b
CFunction tanh;
Local TANH = tanh(0)*tanh_(0)+tanh(1.0)*tanh_(1.0)+tanh(-1.0)*tanh_(-1.0)+tanh(ln_(2))*tanh_(ln_(2))+tanh(-ln_(2))*tanh_(-ln_(2));
Argument tanh_;
	Evaluate;
Endargument;
Evaluate tanh_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("TANH") =~ expr("
       - 6.0e-01*tanh( - ln_(2))
       + 6.0e-01*tanh(ln_(2))
       - 7.615941559557648881194582826e-01*tanh( - 1.0e+00)
       + 7.615941559557648881194582826e-01*tanh(1.0e+00)
")
*--#] evaluate_tanh : 
*--#[ evaluate_asinh :
#Startfloat 21d
CFunction asinh;
Local ASINH = asinh(0)*asinh_(0)+asinh(1.0)*asinh_(1.0)+asinh(-1)*asinh_(-1);
Evaluate asinh_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("ASINH") =~ expr("
       + 8.81373587019543025233e-01*asinh(1.0e+00)
       - 8.81373587019543025233e-01*asinh(-1)
")
*--#] evaluate_asinh : 
*--#[ evaluate_acosh :
#Startfloat 21d
CFunction acosh;
Local ACOSH = acosh(0)*acosh_(0)+acosh(1.0)*acosh_(1.0)+acosh(-1)*acosh_(-1)+acosh(24/7)*acosh_(24/7);
Evaluate acosh_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("ACOSH") =~ expr("
       + acosh_(-1)*acosh(-1)
       + acosh_(0)*acosh(0)
       + 1.90331107830883818521e+00*acosh(24/7)
")
*--#] evaluate_acosh : 
*--#[ evaluate_atanh :
#Startfloat 21d
CFunction atanh;
Local ATANH = atanh(0)*atanh_(0)+atanh(1.0)*atanh_(1.0)+atanh(-1)*atanh_(-1)+atanh(24/7)*atanh_(24/7)+atanh(1/9)*atanh_(1/9)+atanh(-.54321)*atanh_(-.54321);
Evaluate atanh_;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("ATANH") =~ expr("
         + atanh_(24/7)*atanh(24/7)
       + atanh_(1.0e+00)*atanh(1.0e+00)
       + atanh_(-1)*atanh(-1)
       + 1.11571775657104877883e-01*atanh(1/9)
       - 6.08698087464190136361e-01*atanh( - 5.4321e-01)
")
*--#] evaluate_atanh : 
*--#[ strictrounding :
#StartFloat 6d
CFunction f;
Local F1 = 1.23456789e-4+f(1.0)+f(1.0000001);
Print;
.sort

Skip F1;
Local F2 = F1;
StrictRounding 4d;
Argument f;
	StrictRounding;
EndArgument;
Print;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("F1") =~ expr("1.23457e-04 + f(1.0e+00) + f(1.0e+00)")
assert result("F2") =~ expr("1.235e-04 + 2*f(1.0e+00)")
*--#] strictrounding : 
*--#[ chop :
#StartFloat 15d
#StartFloat 15d
Symbol x;
Local F1 = 4.7*x-1.0e-10*x^2+.2e-10*x^3-0.00005*x^4+x^5/1000000;
Local F2 = 4.7*x-1.0e-10*x^2+.2e-10*x^3-0.00005*x^4+x^5/1000000;
Local F3 = 4.7*x-1.0e-10*x^2+.2e-10*x^3-0.00005*x^4+x^5/1000000;
Local F4 = 4.7*x-1.0e-10*x^2+.2e-10*x^3-0.00005*x^4+x^5/1000000;
Local F5 = 4.7*x-1.0e-10*x^2+.2e-10*x^3-0.00005*x^4+x^5/1000000;
Print;
.sort
Skip;
NSkip F1;
Chop 1.0e-10;
.sort
Skip;
NSkip F2;
Chop 1/10000;
.sort
Skip;
NSkip F3;
Chop 7;
.sort
Skip;
NSkip F4;
Chop 10^-6;
.sort
Skip;
NSkip F5;
Chop 10^6;
.sort
Print;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("F1") =~ expr("4.7e+00*x - 1.0e-10*x^2 - 5.0e-05*x^4 + 1/1000000*x^5")
assert result("F2") =~ expr("4.7e+00*x + 1/1000000*x^5")
assert result("F3") =~ expr("1/1000000*x^5")
assert result("F4") =~ expr("4.7e+00*x - 5.0e-05*x^4 + 1/1000000*x^5")
assert result("F5") =~ expr("1/1000000*x^5")
*--#] chop : 
*--#[ pattern_float : 
#-
Off Statistics;
#StartFloat 10d
#message StartFloat
Symbol a,x1,...,x4;
CFunction f,g;
Vector p;
Local F = 1.0-2.0*a+3.0*f-4.0*p.p+5.0*p;
id 1.0 = 5;
id f?(?a) = g(?a);
id float_(?a) = g(?a);
id float_(x1?,x2?,x3?,x4?) = g(x1,x2,x3,x4);
Print;
.sort

#endfloat
#message endfloat
id float_(2,3,1,340282366920938463463374607431768211456) = 5;
id f?(?a) = g(?a);
id float_(?a) = g(?a);
id float_(x1?,x2?,x3?,x4?) = g(x1,x2,x3,x4);
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert stdout =~ exact_pattern(<<'EOF')
~~~StartFloat

   F =
       - 2.0e+00*a - 4.0e+00*p.p + 5.0e+00*p + 1.0e+00 + 3.0e+00*g;

~~~endfloat

   F =
       - a*float_(2,3,1,680564733841876926926749214863536422912)
       - p.p*float_(2,3,1,1361129467683753853853498429727072845824)
       + p*float_(2,3,1,1701411834604692317316873037158841057280)
       + float_(2,3,1,340282366920938463463374607431768211456)
       + g*float_(2,3,1,1020847100762815390390123822295304634368)
      ;
EOF
*--#] pattern_float :
*--#[ transform_float : 
#-
CFunction f;
Off Statistics;
#StartFloat 10d
#message StartFloat
Local F = 1.0*f(1,2,3);
Transform replace(1,last)=(xarg_,2*xarg_+1);
Print;
.sort

#endfloat
#message endfloat
Transform mulargs(1,last);
Print;
.end
#pend_if wordsize == 2
assert succeeded?
assert stdout =~ exact_pattern(<<'EOF')
~~~StartFloat

   F =
      1.0e+00*f(3,5,7);

~~~endfloat

   F =
      f(105)*float_(2,3,1,340282366920938463463374607431768211456);
EOF
*--#] transform_float :
*--#[ transform_float_error : 
#-
CFunction f,g;
Off Statistics;
#StartFloat 10d
Local F = 1.0*f(1,2,3)*g(3,2,1);
Transform float_, reverse(1,last);
Transform {float_,f}, addargs(1,last);
Print;
.sort

#endfloat
Transform float_, dropargs(1,last);
Transform {float_,f}, selectargs(1,2);
Print;
.end
#pend_if wordsize == 2
runtime_error?("Illegal use of a transform statement and float_")
runtime_error?("Illegal use of a transform statement and float_")
runtime_error?("Illegal use of a transform statement and float_")
runtime_error?("Illegal use of a transform statement and float_")
*--#] transform_float_error :
*--#[ argument_float :
#StartFloat 24d
CFunction f;
Symbol a,b,c,d;
#StartFloat 24d
Local F = 1.0 -2.0*f(a+5*b-3*c)+f(3.14*a*b);
Normalize;
MakeInteger;
Argument;
	Multiply 10*d;
EndArgument;
SplitArg;
FactArg;
Print;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("F") =~ expr("1.0e+00 + f(a,b,d,3.14e+01) + 2.0e+00*f(30,c,d,-50,b,d,-10,a,d)")
*--#] argument_float : 
*--#[ AddWithFloat :
* This tests AddWithFloat in float.c
#StartFloat 10d
Symbol x1,...,x4;
Local F = (x1+1.0*x2+x3+1.0*x4)^5;
id x1 = 1-x2-x3-x4;
Print;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("F") =~ expr("1")
*--#] AddWithFloat : 
*--#[ float_extremes :
#StartFloat 10d
CFunction f;
#do i = 0,62
	Local F`i' = 1.`i'e{2^`i'}*f({2^`i'});
	Local G`i' = 1.`i'e{-2^`i'}*f({2^`i'});
#enddo
Print;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("F0") =~ expr("1.0e+01*f(1)")
assert result("G0") =~ expr("1.0e-01*f(1)")
assert result("F1") =~ expr("1.1e+02*f(2)")
assert result("G1") =~ expr("1.1e-02*f(2)")
assert result("F2") =~ expr("1.2e+04*f(4)")
assert result("G2") =~ expr("1.2e-04*f(4)")
assert result("F3") =~ expr("1.3e+08*f(8)")
assert result("G3") =~ expr("1.3e-08*f(8)")
assert result("F4") =~ expr("1.4e+16*f(16)")
assert result("G4") =~ expr("1.4e-16*f(16)")
assert result("F5") =~ expr("1.5e+32*f(32)")
assert result("G5") =~ expr("1.5e-32*f(32)")
assert result("F6") =~ expr("1.6e+64*f(64)")
assert result("G6") =~ expr("1.6e-64*f(64)")
assert result("F7") =~ expr("1.7e+128*f(128)")
assert result("G7") =~ expr("1.7e-128*f(128)")
assert result("F8") =~ expr("1.8e+256*f(256)")
assert result("G8") =~ expr("1.8e-256*f(256)")
assert result("F9") =~ expr("1.9e+512*f(512)")
assert result("G9") =~ expr("1.9e-512*f(512)")
assert result("F10") =~ expr("1.1e+1024*f(1024)")
assert result("G10") =~ expr("1.1e-1024*f(1024)")
assert result("F11") =~ expr("1.11e+2048*f(2048)")
assert result("G11") =~ expr("1.11e-2048*f(2048)")
assert result("F12") =~ expr("1.12e+4096*f(4096)")
assert result("G12") =~ expr("1.12e-4096*f(4096)")
assert result("F13") =~ expr("1.13e+8192*f(8192)")
assert result("G13") =~ expr("1.13e-8192*f(8192)")
assert result("F14") =~ expr("1.14e+16384*f(16384)")
assert result("G14") =~ expr("1.14e-16384*f(16384)")
assert result("F15") =~ expr("1.15e+32768*f(32768)")
assert result("G15") =~ expr("1.15e-32768*f(32768)")
assert result("F16") =~ expr("1.16e+65536*f(65536)")
assert result("G16") =~ expr("1.16e-65536*f(65536)")
assert result("F17") =~ expr("1.17e+131072*f(131072)")
assert result("G17") =~ expr("1.17e-131072*f(131072)")
assert result("F18") =~ expr("1.18e+262144*f(262144)")
assert result("G18") =~ expr("1.18e-262144*f(262144)")
assert result("F19") =~ expr("1.19e+524288*f(524288)")
assert result("G19") =~ expr("1.19e-524288*f(524288)")
assert result("F20") =~ expr("1.2e+1048576*f(1048576)")
assert result("G20") =~ expr("1.2e-1048576*f(1048576)")
assert result("F21") =~ expr("1.21e+2097152*f(2097152)")
assert result("G21") =~ expr("1.21e-2097152*f(2097152)")
assert result("F22") =~ expr("1.22e+4194304*f(4194304)")
assert result("G22") =~ expr("1.22e-4194304*f(4194304)")
assert result("F23") =~ expr("1.23e+8388608*f(8388608)")
assert result("G23") =~ expr("1.23e-8388608*f(8388608)")
assert result("F24") =~ expr("1.24e+16777216*f(16777216)")
assert result("G24") =~ expr("1.24e-16777216*f(16777216)")
assert result("F25") =~ expr("1.25e+33554432*f(33554432)")
assert result("G25") =~ expr("1.25e-33554432*f(33554432)")
assert result("F26") =~ expr("1.26e+67108864*f(67108864)")
assert result("G26") =~ expr("1.26e-67108864*f(67108864)")
assert result("F27") =~ expr("1.27e+134217728*f(134217728)")
assert result("G27") =~ expr("1.27e-134217728*f(134217728)")
assert result("F28") =~ expr("1.28e+268435456*f(268435456)")
assert result("G28") =~ expr("1.28e-268435456*f(268435456)")
assert result("F29") =~ expr("1.29e+536870912*f(536870912)")
assert result("G29") =~ expr("1.29e-536870912*f(536870912)")
assert result("F30") =~ expr("1.3e+1073741824*f(1073741824)")
assert result("G30") =~ expr("1.3e-1073741824*f(1073741824)")
assert result("F31") =~ expr("1.31e+2147483648*f(2147483648)")
assert result("G31") =~ expr("1.31e-2147483648*f(2147483648)")
assert result("F32") =~ expr("1.32e+4294967296*f(4294967296)")
assert result("G32") =~ expr("1.32e-4294967296*f(4294967296)")
assert result("F33") =~ expr("1.33e+8589934592*f(8589934592)")
assert result("G33") =~ expr("1.33e-8589934592*f(8589934592)")
assert result("F34") =~ expr("1.34e+17179869184*f(17179869184)")
assert result("G34") =~ expr("1.34e-17179869184*f(17179869184)")
assert result("F35") =~ expr("1.35e+34359738368*f(34359738368)")
assert result("G35") =~ expr("1.35e-34359738368*f(34359738368)")
assert result("F36") =~ expr("1.36e+68719476736*f(68719476736)")
assert result("G36") =~ expr("1.36e-68719476736*f(68719476736)")
assert result("F37") =~ expr("1.37e+137438953472*f(137438953472)")
assert result("G37") =~ expr("1.37e-137438953472*f(137438953472)")
assert result("F38") =~ expr("1.38e+274877906944*f(274877906944)")
assert result("G38") =~ expr("1.38e-274877906944*f(274877906944)")
assert result("F39") =~ expr("1.39e+549755813888*f(549755813888)")
assert result("G39") =~ expr("1.39e-549755813888*f(549755813888)")
assert result("F40") =~ expr("1.4e+1099511627776*f(1099511627776)")
assert result("G40") =~ expr("1.4e-1099511627776*f(1099511627776)")
assert result("F41") =~ expr("1.41e+2199023255552*f(2199023255552)")
assert result("G41") =~ expr("1.41e-2199023255552*f(2199023255552)")
assert result("F42") =~ expr("1.42e+4398046511104*f(4398046511104)")
assert result("G42") =~ expr("1.42e-4398046511104*f(4398046511104)")
assert result("F43") =~ expr("1.43e+8796093022208*f(8796093022208)")
assert result("G43") =~ expr("1.43e-8796093022208*f(8796093022208)")
assert result("F44") =~ expr("1.44e+17592186044416*f(17592186044416)")
assert result("G44") =~ expr("1.44e-17592186044416*f(17592186044416)")
assert result("F45") =~ expr("1.45e+35184372088832*f(35184372088832)")
assert result("G45") =~ expr("1.45e-35184372088832*f(35184372088832)")
assert result("F46") =~ expr("1.46e+70368744177664*f(70368744177664)")
assert result("G46") =~ expr("1.46e-70368744177664*f(70368744177664)")
assert result("F47") =~ expr("1.47e+140737488355328*f(140737488355328)")
assert result("G47") =~ expr("1.47e-140737488355328*f(140737488355328)")
assert result("F48") =~ expr("1.48e+281474976710656*f(281474976710656)")
assert result("G48") =~ expr("1.48e-281474976710656*f(281474976710656)")
assert result("F49") =~ expr("1.49e+562949953421312*f(562949953421312)")
assert result("G49") =~ expr("1.49e-562949953421312*f(562949953421312)")
assert result("F50") =~ expr("1.5e+1125899906842624*f(1125899906842624)")
assert result("G50") =~ expr("1.5e-1125899906842624*f(1125899906842624)")
assert result("F51") =~ expr("1.51e+2251799813685248*f(2251799813685248)")
assert result("G51") =~ expr("1.51e-2251799813685248*f(2251799813685248)")
assert result("F52") =~ expr("1.52e+4503599627370496*f(4503599627370496)")
assert result("G52") =~ expr("1.52e-4503599627370496*f(4503599627370496)")
assert result("F53") =~ expr("1.53e+9007199254740992*f(9007199254740992)")
assert result("G53") =~ expr("1.53e-9007199254740992*f(9007199254740992)")
assert result("F54") =~ expr("1.54e+18014398509481984*f(18014398509481984)")
assert result("G54") =~ expr("1.54e-18014398509481984*f(18014398509481984)")
assert result("F55") =~ expr("1.55e+36028797018963968*f(36028797018963968)")
assert result("G55") =~ expr("1.55e-36028797018963968*f(36028797018963968)")
assert result("F56") =~ expr("1.56e+72057594037927936*f(72057594037927936)")
assert result("G56") =~ expr("1.56e-72057594037927936*f(72057594037927936)")
assert result("F57") =~ expr("1.57e+144115188075855872*f(144115188075855872)")
assert result("G57") =~ expr("1.57e-144115188075855872*f(144115188075855872)")
assert result("F58") =~ expr("1.58e+288230376151711744*f(288230376151711744)")
assert result("G58") =~ expr("1.58e-288230376151711744*f(288230376151711744)")
assert result("F59") =~ expr("1.59e+576460752303423488*f(576460752303423488)")
assert result("G59") =~ expr("1.59e-576460752303423488*f(576460752303423488)")
assert result("F60") =~ expr("1.6e+1152921504606846976*f(1152921504606846976)")
assert result("G60") =~ expr("1.6e-1152921504606846976*f(1152921504606846976)")
assert result("F61") =~ expr("1.61e+2305843009213693952*f(2305843009213693952)")
assert result("G61") =~ expr("1.61e-2305843009213693952*f(2305843009213693952)")
assert result("F62") =~ expr("1.62e+4611686018427387904*f(4611686018427387904)")
assert result("G62") =~ expr("1.62e-4611686018427387904*f(4611686018427387904)")
*--#] float_extremes : 
*--#[ MergeWithFloat :
* This tests MergeWithFloat in float.c
#: termsinsmall 16
On fewerstats 1;
#StartFloat 10d
Auto Symbol x;
* This tests most cases of MergeWithFloat
Local F = (x1+1.0*x2+x3+1.0*x4)^5;
id x1 = 1-x2-x3-x4;
.sort
* This tests a corncer case of MergeWithFloat
Local G = x1+...+x15+1.0*x16+2^320*x16;
Print;
.end
#pend_if wordsize == 2
assert succeeded?
assert result("F") =~ expr("1")
assert result("G") =~ expr("
      2.135987036e+96*x16 + x15 + x14 + x13 + x12 + x11 + x10 + x9 + x8 + x7
       + x6 + x5 + x4 + x3 + x2 + x1")
*--#] MergeWithFloat : 
*--#[ float_error :
Evaluate;
ToFloat;
ToRat;
.end
#pend_if wordsize == 2
assert compile_error?("Illegal attempt to evaluate a function without activating floating point numbers.")
assert compile_error?("Forgotten #startfloat instruction?")
assert compile_error?("Illegal attempt to convert to float_ without activating floating point numbers.")
assert compile_error?("Forgotten #startfloat instruction?")
assert compile_error?("Illegal attempt to convert from float_ without activating floating point numbers.")
assert compile_error?("Forgotten #startfloat instruction?")
*--#] float_error :
*--#[ format_and_floats :
#-
Off Statistics;
#Startfloat 10d
Symbol x,y;

Local test =
	+ 1
	+ 3*x
	+ 3/4*x^2
	+ (2^y-1)*x^3
	+ (2^y)*x^4
	+ 1/(2^y-1)*x^5
	+ 1/(2^y)*x^6
	+ 3/(2^y-1)*x^7
	+ 3/(2^y)*x^8
	+ (2^y)/(2^y-1)*x^9
	+ (2^y-1)/(2^y)*x^10
	+ (2^y)/(2^y+1)*x^11
	;
.sort
Drop;
Local test31 = replace_(y,31)*test;
Local test32 = replace_(y,32)*test;
ToFloat;
#message Raw
Format FloatPrecision off;
Print +s;
.sort

#message Mathematica
Format FloatPrecision 5d;
Format mathematica;
Print +s;
.sort

#message Maple
Format FloatPrecision 20b;
Format maple;
Print +s;
.sort

#message C
Format FloatPrecision;
Format c;
Print +s;
.sort

#message Fortran
Format Fortran;
Print +s;
.sort

#message Doublefortran
Format Doublefortran;
Print +s;
.sort

#message Quadfortran
Format Quadfortran;
Print +s;
.sort

#message Fortran90
Format Fortran90;
Print +s;
.sort

#message Fortran90_ki
Format Fortran90,_ki;
Print +s;
.end
#pend_if wordsize == 2
assert succeeded?
assert stdout =~ exact_pattern(<<'EOF')
~~~Raw

   test31 =
       + x*float_(2,3,1,1020847100762815390390123822295304634368)
       + x^2*float_(2,2,0,255211775190703847597530955573826158592)
       + x^3*float_(2,1,1,2147483647)
       + x^4*float_(2,3,1,730750818665451459101842416358141509827966271488)
       + x^5*float_(2,2,0,158456325102315651516285845520)
       + x^6*float_(2,2,0,158456325028528675187087900672)
       + x^7*float_(2,2,0,475368975306946954548857536560)
       + x^8*float_(2,2,0,475368975085586025561263702016)
       + x^9*float_(2,3,1,340282367079394788565690258948054056976)
       + x^10*float_(2,1,0,18446744065119617024)
       + x^11*float_(2,2,0,340282366762482138508632908505158778895)
       + float_(2,3,1,340282366920938463463374607431768211456)
      ;

   test32 =
       + x*float_(2,3,1,1020847100762815390390123822295304634368)
       + x^2*float_(2,2,0,255211775190703847597530955573826158592)
       + x^3*float_(2,1,1,4294967295)
       + x^4*float_(2,3,1,1461501637330902918203684832716283019655932542976)
       + x^5*float_(2,2,0,79228162532711081671548469249)
       + x^6*float_(2,2,0,79228162514264337593543950336)
       + x^7*float_(2,2,0,237684487598133245014645407747)
       + x^8*float_(2,2,0,237684487542793012780631851008)
       + x^9*float_(2,3,1,340282367000166625996085689103316680705)
       + x^10*float_(2,1,0,18446744069414584320)
       + x^11*float_(2,2,0,340282366841710300967557013907638845440)
       + float_(2,3,1,340282366920938463463374607431768211456)
      ;

~~~Mathematica

   test31 = (
       + 3.0*^+00*x
       + 7.5*^-01*x^2
       + 2.1475*^+09*x^3
       + 2.1475*^+09*x^4
       + 4.6566*^-10*x^5
       + 4.6566*^-10*x^6
       + 1.397*^-09*x^7
       + 1.397*^-09*x^8
       + 1.0*^+00*x^9
       + 1.0*^+00*x^10
       + 1.0*^+00*x^11
       + 1.0*^+00
      );

   test32 = (
       + 3.0*^+00*x
       + 7.5*^-01*x^2
       + 4.295*^+09*x^3
       + 4.295*^+09*x^4
       + 2.3283*^-10*x^5
       + 2.3283*^-10*x^6
       + 6.9849*^-10*x^7
       + 6.9849*^-10*x^8
       + 1.0*^+00*x^9
       + 1.0*^+00*x^10
       + 1.0*^+00*x^11
       + 1.0*^+00
      );

~~~Maple

   test31 =
       + 3.0e+00*x
       + 7.5e-01*x^2
       + 2.14748e+09*x^3
       + 2.14748e+09*x^4
       + 4.65661e-10*x^5
       + 4.65661e-10*x^6
       + 1.39698e-09*x^7
       + 1.39698e-09*x^8
       + 1.0e+00*x^9
       + 1.0e+00*x^10
       + 1.0e+00*x^11
       + 1.0e+00
      ;

   test32 =
       + 3.0e+00*x
       + 7.5e-01*x^2
       + 4.29497e+09*x^3
       + 4.29497e+09*x^4
       + 2.32831e-10*x^5
       + 2.32831e-10*x^6
       + 6.98492e-10*x^7
       + 6.98492e-10*x^8
       + 1.0e+00*x^9
       + 1.0e+00*x^10
       + 1.0e+00*x^11
       + 1.0e+00
      ;

~~~C

   test31 =
       + 3.0e+00*x
       + 7.5e-01*pow(x,2)
       + 2.147483647e+09*pow(x,3)
       + 2.147483648e+09*pow(x,4)
       + 4.656612875e-10*pow(x,5)
       + 4.656612873e-10*pow(x,6)
       + 1.396983863e-09*pow(x,7)
       + 1.396983862e-09*pow(x,8)
       + 1.0e+00*pow(x,9)
       + 9.999999995e-01*pow(x,10)
       + 9.999999995e-01*pow(x,11)
       + 1.0e+00
      ;

   test32 =
       + 3.0e+00*x
       + 7.5e-01*pow(x,2)
       + 4.294967295e+09*pow(x,3)
       + 4.294967296e+09*pow(x,4)
       + 2.328306437e-10*pow(x,5)
       + 2.328306437e-10*pow(x,6)
       + 6.984919311e-10*pow(x,7)
       + 6.98491931e-10*pow(x,8)
       + 1.0e+00*pow(x,9)
       + 9.999999998e-01*pow(x,10)
       + 9.999999998e-01*pow(x,11)
       + 1.0e+00
      ;

~~~Fortran

      test31 = + 3.0E+00*x
     &  + 7.5E-01*x**2
     &  + 2.147483647E+09*x**3
     &  + 2.147483648E+09*x**4
     &  + 4.656612875E-10*x**5
     &  + 4.656612873E-10*x**6
     &  + 1.396983863E-09*x**7
     &  + 1.396983862E-09*x**8
     &  + 1.0E+00*x**9
     &  + 9.999999995E-01*x**10
     &  + 9.999999995E-01*x**11
     &  + 1.0E+00
     &

      test32 = + 3.0E+00*x
     &  + 7.5E-01*x**2
     &  + 4.294967295E+09*x**3
     &  + 4.294967296E+09*x**4
     &  + 2.328306437E-10*x**5
     &  + 2.328306437E-10*x**6
     &  + 6.984919311E-10*x**7
     &  + 6.98491931E-10*x**8
     &  + 1.0E+00*x**9
     &  + 9.999999998E-01*x**10
     &  + 9.999999998E-01*x**11
     &  + 1.0E+00
     &

~~~Doublefortran

      test31 = + 3.0D+00*x
     &  + 7.5D-01*x**2
     &  + 2.147483647D+09*x**3
     &  + 2.147483648D+09*x**4
     &  + 4.656612875D-10*x**5
     &  + 4.656612873D-10*x**6
     &  + 1.396983863D-09*x**7
     &  + 1.396983862D-09*x**8
     &  + 1.0D+00*x**9
     &  + 9.999999995D-01*x**10
     &  + 9.999999995D-01*x**11
     &  + 1.0D+00
     &

      test32 = + 3.0D+00*x
     &  + 7.5D-01*x**2
     &  + 4.294967295D+09*x**3
     &  + 4.294967296D+09*x**4
     &  + 2.328306437D-10*x**5
     &  + 2.328306437D-10*x**6
     &  + 6.984919311D-10*x**7
     &  + 6.98491931D-10*x**8
     &  + 1.0D+00*x**9
     &  + 9.999999998D-01*x**10
     &  + 9.999999998D-01*x**11
     &  + 1.0D+00
     &

~~~Quadfortran

      test31 = + 3.0Q+00*x
     &  + 7.5Q-01*x**2
     &  + 2.147483647Q+09*x**3
     &  + 2.147483648Q+09*x**4
     &  + 4.656612875Q-10*x**5
     &  + 4.656612873Q-10*x**6
     &  + 1.396983863Q-09*x**7
     &  + 1.396983862Q-09*x**8
     &  + 1.0Q+00*x**9
     &  + 9.999999995Q-01*x**10
     &  + 9.999999995Q-01*x**11
     &  + 1.0Q+00
     &

      test32 = + 3.0Q+00*x
     &  + 7.5Q-01*x**2
     &  + 4.294967295Q+09*x**3
     &  + 4.294967296Q+09*x**4
     &  + 2.328306437Q-10*x**5
     &  + 2.328306437Q-10*x**6
     &  + 6.984919311Q-10*x**7
     &  + 6.98491931Q-10*x**8
     &  + 1.0Q+00*x**9
     &  + 9.999999998Q-01*x**10
     &  + 9.999999998Q-01*x**11
     &  + 1.0Q+00
     &

~~~Fortran90

      test31 = + 3.0E+00*x
     &  + 7.5E-01*x**2
     &  + 2.147483647E+09*x**3
     &  + 2.147483648E+09*x**4
     &  + 4.656612875E-10*x**5
     &  + 4.656612873E-10*x**6
     &  + 1.396983863E-09*x**7
     &  + 1.396983862E-09*x**8
     &  + 1.0E+00*x**9
     &  + 9.999999995E-01*x**10
     &  + 9.999999995E-01*x**11
     &  + 1.0E+00
     &

      test32 = + 3.0E+00*x
     &  + 7.5E-01*x**2
     &  + 4.294967295E+09*x**3
     &  + 4.294967296E+09*x**4
     &  + 2.328306437E-10*x**5
     &  + 2.328306437E-10*x**6
     &  + 6.984919311E-10*x**7
     &  + 6.98491931E-10*x**8
     &  + 1.0E+00*x**9
     &  + 9.999999998E-01*x**10
     &  + 9.999999998E-01*x**11
     &  + 1.0E+00
     &

~~~Fortran90_ki

      test31 = + 3.0E+00_ki*x
     &  + 7.5E-01_ki*x**2
     &  + 2.147483647E+09_ki*x**3
     &  + 2.147483648E+09_ki*x**4
     &  + 4.656612875E-10_ki*x**5
     &  + 4.656612873E-10_ki*x**6
     &  + 1.396983863E-09_ki*x**7
     &  + 1.396983862E-09_ki*x**8
     &  + 1.0E+00_ki*x**9
     &  + 9.999999995E-01_ki*x**10
     &  + 9.999999995E-01_ki*x**11
     &  + 1.0E+00_ki
     &

      test32 = + 3.0E+00_ki*x
     &  + 7.5E-01_ki*x**2
     &  + 4.294967295E+09_ki*x**3
     &  + 4.294967296E+09_ki*x**4
     &  + 2.328306437E-10_ki*x**5
     &  + 2.328306437E-10_ki*x**6
     &  + 6.984919311E-10_ki*x**7
     &  + 6.98491931E-10_ki*x**8
     &  + 1.0E+00_ki*x**9
     &  + 9.999999998E-01_ki*x**10
     &  + 9.999999998E-01_ki*x**11
     &  + 1.0E+00_ki
     &
EOF
*--#] format_and_floats  :
*--#[ startfloat_error :
#Startfloat 100bd,MZV = 10
.end
#pend_if wordsize == 2
runtime_error?("Illegal parameter in #StartFloat: 100bd,MZV = 10")
*--#] startfloat_error :
*--#[ humanstats :
#-
On humanstats;
Symbol x;
Local test1 = (1+x)^499;
Local test2 = (1+x)^500;
Local test3 = (1+x)^1000;
.end
# In 32bit FORM, the "Bytes used" numbers are different
#pend_if wordsize != 4
assert succeeded?
assert stdout =~ exact_pattern("Generated terms =        500  ( <1 K  )")
assert stdout =~ exact_pattern("Terms in output =        500  ( <1 K  )")
assert stdout =~ exact_pattern("Bytes used      =      54420  ( 54 KiB)")
assert stdout =~ exact_pattern("Generated terms =        501  (  1 K  )")
assert stdout =~ exact_pattern("Terms in output =        501  (  1 K  )")
assert stdout =~ exact_pattern("Bytes used      =      54644  ( 55 KiB)")
assert stdout =~ exact_pattern("Generated terms =       1001  (  1 K  )")
assert stdout =~ exact_pattern("Terms in output =       1001  (  1 K  )")
assert stdout =~ exact_pattern("Bytes used      =     199172  (199 KiB)")
*--#] humanstats :
*--#[ Issue49 :
* Add mul_ function for polynomial multiplications
Symbols x,y,z;
#$p = (1+x+y+z)^4;
#$q = $p+1;
#$r = mul_($p,$q);
L r1 = $r;
L r2 = $p^2 + $p;
.sort
Drop;
L Zero = r1 - r2;
P;
.end
assert succeeded?
assert result("Zero") =~ expr("0")
*--#] Issue49 : 
*--#[ Issue72 :
* "Setups: PATHVALUE not yet implemented"
#:incdir foo
#:path
* foo/p1.prc
#call p1()
P;
.end
#:incdir
#:path foo/bar
* foo/bar/p1.prc
#call p1()
P;
.end
#prepare write "foo/p1.prc", "#procedure p1()\nL F=12345;\n#endprocedure\n"
#prepare write "foo/bar/p1.prc", "#procedure p1()\nL G=123456;\n#endprocedure\n"
assert succeeded?
assert result("F") =~ expr("12345")
assert result("G") =~ expr("123456")
*--#] Issue72 :
*--#[ Issue84 :
* Set to match with a vector
V p,p1,...,p6;
CF f,g,h;
L F = f(p1,-p1,p2,-p2);
id,all,f(?a,-p?vector_,?b) = f(?a,p,?b)*g(p);
Print +s;
.end
assert succeeded?
assert result("F") =~ expr("
       + f(p1,p1,p2,-p2)*g(p1)
       + f(p1,-p1,p2,p2)*g(p2)
")
*--#] Issue84 :
*--#[ Issue86_1 :
* Feature request: take/drop n-th argument of list
* [with zero-dimensional tables]
CF f;
S x,n,n1,n2;

* Get [1,1]. nargs >= 1.
Table first(f?(x?,?a));
Fill first = f(x);

* Get [last,last]. nargs >= 1.
Table last(f?(?a,x?));
Fill last = f(x);

* Get [2,last]. nargs >= 1.
Table rest(f?(x?,?a));
Fill rest = f(?a);

* Get [1,last-1]. nargs >= 1.
Table most(f?(?a,x?));
Fill most = f(?a);

* Join two functions.
Table join(f?(?a),f?(?b));
Fill join = f(?a,?b);

* Rotate left by n. nargs >= 1.
Table roll(n?int_,f?(?a));
Fill roll =
  + delta_(n)   * f(?a)
  + thetap_(n)  * roll(n-1,join(rest(f(?a)),first(f(?a))))
  + thetap_(-n) * roll(n+1,join(last(f(?a)),most(f(?a))))
;

* Get [1,n]. 1 <= n <= nargs.
Table firstn(n?pos_,f?(?a));
Table firstnimpl(n?pos0_,f?(?a),f?(x?,?b));
Fill firstn = firstnimpl(n,f,f(?a,dum_));
Fill firstnimpl =
  + delta_(n)  * f(?a)
  + thetap_(n) * firstnimpl(n-1,f(?a,x),f(?b))
;

* Get the n-th argument. 1 <= n <= nargs.
Table take(n?pos_,f?(?a));
Fill take = first(roll(n-1,f(?a)));

* Drop the n-th argument. 1 <= n <= nargs.
Table drop(n?pos_,f?(?a));
Fill drop = roll(1-n,most(roll(n,f(?a))));

* Get [n1,n2]. Negative indices count from the end. 1 <= n1 <= n2 <= nargs.
Table slice(n1?!{0,},n2?!{0,},f?(?a));
Fill slice =
  + thetap_(n1) * thetap_(n2) * firstn(n2-n1+1,roll(n1-1,f(?a)))
  + thetap_(n1) * thetap_(-n2) * slice(n1,nargs_(?a)+n2+1,f(?a))
  + thetap_(-n1) * thetap_(n2) * slice(nargs_(?a)+n1+1,n2,f(?a))
  + thetap_(-n1) * thetap_(-n2) * slice(nargs_(?a)+n1+1,nargs_(?a)+n2+1,f(?a))
;

L F0  = f(1,...,9);
L F1  = first(F0);
L F2  = last(F0);
L F3  = rest(F0);
L F4  = most(F0);
L F5  = roll(0,F0);
L F6  = roll(2,F0);
L F7  = roll(-2,F0);
L F8  = firstn(3,F0);
L F9  = take(3,F0);
L F10 = drop(3,F0);
L F11 = slice(3,3,F0);
L F12 = slice(3,6,F0);
L F13 = slice(3,-4,F0);
L F14 = slice(-7,6,F0);
L F15 = slice(-7,-4,F0);

P;
.end
assert succeeded?
assert result("F0")  =~ expr("f(1,2,3,4,5,6,7,8,9)")
assert result("F1")  =~ expr("f(1)")
assert result("F2")  =~ expr("f(9)")
assert result("F3")  =~ expr("f(2,3,4,5,6,7,8,9)")
assert result("F4")  =~ expr("f(1,2,3,4,5,6,7,8)")
assert result("F5")  =~ expr("f(1,2,3,4,5,6,7,8,9)")
assert result("F6")  =~ expr("f(3,4,5,6,7,8,9,1,2)")
assert result("F7")  =~ expr("f(8,9,1,2,3,4,5,6,7)")
assert result("F8")  =~ expr("f(1,2,3)")
assert result("F9")  =~ expr("f(3)")
assert result("F10") =~ expr("f(1,2,4,5,6,7,8,9)")
assert result("F11") =~ expr("f(3)")
assert result("F12") =~ expr("f(3,4,5,6)")
assert result("F13") =~ expr("f(3,4,5,6)")
assert result("F14") =~ expr("f(3,4,5,6)")
assert result("F15") =~ expr("f(3,4,5,6)")
*--#] Issue86_1 :
*--#[ Issue86_2 :
* [with the Translate statement]
CF f;
L F0  = f(1,2,3,4,5,6,7,8,9);

#do i=1,4
  #do j=1,8
    L F`i'`j' = F0;
  #enddo
#enddo

$n1 = 3;
$n2 = 5;
$n3 = 4;

#procedure Test(F,trans)
  inexpression `F'1;
    transform,f,`trans'(3,5);
  endinexpression;
  inexpression `F'2;
    transform,f,`trans'(3,$n2);
  endinexpression;
  inexpression `F'3;
    transform,f,`trans'(3,last-4);
  endinexpression;
  inexpression `F'4;
    transform,f,`trans'(3,last-$n3);
  endinexpression;
  inexpression `F'5;
    transform,f,`trans'($n1,5);
  endinexpression;
  inexpression `F'6;
    transform,f,`trans'($n1,$n2);
  endinexpression;
  inexpression `F'7;
    transform,f,`trans'($n1,last-4);
  endinexpression;
  inexpression `F'8;
    transform,f,`trans'($n1,last-$n3);
  endinexpression;
#endprocedure

#call Test(F1,dropargs)
#call Test(F2,selectargs)
#call Test(F3,addargs)
#call Test(F4,mulargs)
P;
ModuleOption local, $n1,$n2,$n3;
.end
assert succeeded?
assert result("F0")  =~ expr("f(1,2,3,4,5,6,7,8,9)")
assert result("F11") =~ expr("f(1,2,6,7,8,9)")
assert result("F21") =~ expr("f(3,4,5)")
assert result("F31") =~ expr("f(1,2,12,6,7,8,9)")
assert result("F41") =~ expr("f(1,2,60,6,7,8,9)")

assert result("F12") == result("F11")
assert result("F13") == result("F11")
assert result("F14") == result("F11")
assert result("F15") == result("F11")
assert result("F16") == result("F11")
assert result("F17") == result("F11")
assert result("F18") == result("F11")

assert result("F22") == result("F21")
assert result("F23") == result("F21")
assert result("F24") == result("F21")
assert result("F25") == result("F21")
assert result("F26") == result("F21")
assert result("F27") == result("F21")
assert result("F28") == result("F21")

assert result("F32") == result("F31")
assert result("F33") == result("F31")
assert result("F34") == result("F31")
assert result("F35") == result("F31")
assert result("F36") == result("F31")
assert result("F37") == result("F31")
assert result("F38") == result("F31")

assert result("F42") == result("F41")
assert result("F43") == result("F41")
assert result("F44") == result("F41")
assert result("F45") == result("F41")
assert result("F46") == result("F41")
assert result("F47") == result("F41")
assert result("F48") == result("F41")
*--#] Issue86_2 :
*--#[ Issue87 :
* Feature request: (anti)bracketing w.r.t. a set
s a, b, c, d;
set ab: a, b;
L test = (a + b)*(c + d);
b ab;
print +s;
.end
assert succeeded?
assert result("test") =~ expr("
       + b * (
          + d
          + c
          )
       + a * (
          + d
          + c
          )
")
*--#] Issue87 :
*--#[ Issue135_1 :
* "Assign instructions cannot occur inside statements" without inside statements
L F =
  #do i=1,10
    #$x = `i';
    + `$x'
  #enddo
;
P;
.end
assert succeeded?
assert result("F") =~ expr("55")
*--#] Issue135_1 :
*--#[ Issue135_2 :
S a1,...,a10;
L F =
  #do i = 1,10
    #$x = `i'*a`i'
          +2;
    +`$x'
  #enddo
;
P;
.end
assert succeeded?
assert result("F") =~ expr("
      20 + 10*a10 + 9*a9 + 8*a8 + 7*a7 + 6*a6 + 5*a5 + 4*a4 + 3*a3 + 2*a2 + a1
")
*--#] Issue135_2 :
*--#[ Issue135_3 :
S a1,...,a10,x;
CF f;
CTable sparse,tab(1);

#do i=1,10
  Fill tab(`i') = f(`i'*a`i') + 2;
#enddo

L F =
  #do i = 1,10
    #$tmp = tab(`i');
    #inside $tmp
      id f(x?) = x;
    #endinside
    + (`$tmp')
  #enddo
;
P;
.end
assert succeeded?
assert result("F") =~ expr("
      20 + 10*a10 + 9*a9 + 8*a8 + 7*a7 + 6*a6 + 5*a5 + 4*a4 + 3*a3 + 2*a2 + a1
")
*--#] Issue135_3 :
*--#[ Issue137_1 :
* New command: ArgToExtraSymbol (,ToNumber)
S a,b;
CF f;
L F = f(1) + f(a) + f(b) + f(a+b);
ArgToExtraSymbol f;
P;
.end
assert succeeded?
assert result("F") =~ expr("f(Z4_) + f(Z3_) + f(Z2_) + f(Z1_)")
*--#] Issue137_1 :
*--#[ Issue137_2 :
S a,b;
CF f;
L F = f(1) + f(a) + f(b) + f(a+b);
ArgToExtraSymbol,ToNumber,f;
P;
.end
assert succeeded?
assert result("F") =~ expr("f(1) + f(2) + f(3) + f(4)")
*--#] Issue137_2 :
*--#[ Issue137_3 :
CF f;
S s;
I i;
V v;
* Fast notation.
L F = f(0) + f(1) + f(-1) + f(s) + f(i) + f(v) + f(-v) + f(f);
argtoextrasymbol;
P;
.end
assert succeeded?
assert result("F") =~ expr("
         f(Z8_) + f(Z7_) + f(Z6_) + f(Z5_) + f(Z4_) + f(Z3_) + f(Z2_) + f(Z1_)
")
*--#] Issue137_3 :
*--#[ Issue137_4 :
#:threadbucketsize 10
#:processbucketsize 10
CF f;
Auto S x;

* NOTE: Large N gives another problem with ParFORM (#141).
#define N "500"
L F0 =
  #do i=1,`N'
    + f(1+x`i') * f(1+x{`i'+100}) * f(1+x{`i'+200})
  #enddo
;
.sort
Hide;

L F1 = F0;
.sort

* If all workers fail to share an unique mapping in a consistent way,
* the following code gives a non-zero result or a crash.
argtoextrasymbol;
.sort
argument;
  frompolynomial;
endargument;
.sort

Drop;

L ZERO = F1 - F0;
P;
.end
assert succeeded?
assert result("ZERO") =~ expr("0")
*--#] Issue137_4 :
*--#[ Issue175_1 :
* Loop over currently active expressions #175
L FF = 1;
L [FF|a,b] = 1;
L [FF,[GG]] = 1;
#do e={`activeexprnames_'}
  L `e' = `e' + 1;
#enddo
L N = `numactiveexprs_';
P;
.end
assert succeeded?
assert result("FF") =~ expr("2")
assert result("[FF|a,b]") =~ expr("2")
assert result("[FF,[GG]]") =~ expr("2")
assert result("N") =~ expr("3")
*--#] Issue175_1 :
*--#[ Issue175_2 :
L F1 = 1;
L F2 = 1;
L F3 = 1;

L F1 = 1;  * redefine in the same module!

*.sort  ;* workaround

#message `numactiveexprs_'
#message `activeexprnames_'

#do e={`activeexprnames_'}
  L `e' = `e' + 1;
#enddo

P;
.end
assert succeeded?
assert result("F1") =~ expr("2")
assert result("F2") =~ expr("2")
assert result("F3") =~ expr("2")
*--#] Issue175_2 :
*--#[ Issue175_3 :
L F1 = 1;
L F2 = 1;
L F3 = 1;

.sort

L F1 = 1;  * replace an existing expression!

*.sort  ;* workaround

#message `numactiveexprs_'
#message `activeexprnames_'

#do e={`activeexprnames_'}
  L `e' = `e' + 1;
#enddo

P;
.end
assert succeeded?
assert result("F1") =~ expr("2")
assert result("F2") =~ expr("2")
assert result("F3") =~ expr("2")
*--#] Issue175_3 :
*--#[ Issue175_4 :
CF F1,F2,F3;

L [F1(1,1,1,1)] = F1(1,1,1,1);
L [F2(-1,1,1,1)] = F2(-1,1,1,1);
.sort

* Redefine.
Local [F1(1,1,1,1)] = F1(1,1,1,1);
.sort

#message `numactiveexprs_'
#message `activeexprnames_'

#do e={`activeexprnames_'}
  L `e' = `e' + 1;
#enddo

P;
.end
assert succeeded?
assert result("[F1(1,1,1,1)]") =~ expr("1 + F1(1,1,1,1)")
assert result("[F2(-1,1,1,1)]") =~ expr("1 + F2(-1,1,1,1)")
*--#] Issue175_4 :
*--#[ Issue187 :
* What is the fastest equivalent of Foreach in FORM?

* distrib_ generates combinations in lexicographical order (in the given
* arguments.)

S x1,...,x5;
CF f;
L F = f(x2,x5,x3,x1,x4);
#$counter = 0;
id f(?a$a) = 1;
term;
  multiply distrib_(1,3,f,dummy_,$a);
  $counter = $counter + 1;
  id f(?a) = f($counter,?a);
endterm;
P +s;
ModuleOption noparallel;
.end
assert succeeded?
assert result("F") =~ expr("
       + f(1,x2,x5,x3)
       + f(2,x2,x5,x1)
       + f(3,x2,x5,x4)
       + f(4,x2,x3,x1)
       + f(5,x2,x3,x4)
       + f(6,x2,x1,x4)
       + f(7,x5,x3,x1)
       + f(8,x5,x3,x4)
       + f(9,x5,x1,x4)
       + f(10,x3,x1,x4)
")
*--#] Issue187 : 
*--#[ Issue243_1 :
* #continuedo?
NF f;
L F = 1;
#do i=1,5
  #if `i' == 3
    #continuedo
  #endif
  multiply right, f(`i');
#enddo
chainin f;
P;
.end
assert succeeded?
assert result("F") =~ expr("f(1,2,4,5)")
*--#] Issue243_1 : 
*--#[ Issue243_2 :
NF f;
L F = 1;
#define i "9"
#do i=1,2
  #do i=1,3
    #do i=1,8
      #if `i' == 3
        #continuedo 2
      #endif
      multiply right, f(`i');
    #enddo
    multiply right, f(-`i');
  #enddo
  multiply right, f(-`i');
#enddo
multiply right, f(`i');
chainin f;
P;
.end
assert succeeded?
assert result("F") =~ expr("f(1,2,1,2,1,2,-1,1,2,1,2,1,2,-2,9)")
*--#] Issue243_2 : 
*--#[ Issue243_3 :
NF f;
L F = 1;
#do i=1,3
  #do i=1,2
    #continuedo 0
    multiply right, f(`i');
  #enddo
#enddo
chainin f;
P;
.end
assert succeeded?
assert result("F") =~ expr("f(1,2,1,2,1,2)")
*--#] Issue243_3 : 
*--#[ Issue243_e1 :
#continuedo
.end
assert preprocess_error?("#continuedo without #do")
*--#] Issue243_e1 : 
*--#[ Issue243_e2 :
#do i=1,3
  #continuedo -1
#enddo
.end
assert preprocess_error?("Improper syntax of #continuedo instruction")
*--#] Issue243_e2 : 
*--#[ Issue243_e3 :
#do i=1,3
  #continuedo 1a
#enddo
.end
assert preprocess_error?("Improper syntax of #continuedo instruction")
*--#] Issue243_e3 : 
*--#[ Issue243_e4 :
#do i=1,3
  #continuedo 2
#enddo
.end
assert preprocess_error?("Too many loop levels requested in #continuedo instruction")
*--#] Issue243_e4 : 
*--#[ Issue243_e5 :
#procedure foo
  #continuedo
#endprocedure
#do i=1,3
  #call foo
#enddo
.end
assert preprocess_error?("Trying to jump out of a procedure with a #continuedo instruction")
*--#] Issue243_e5 : 
*--#[ Issue243_e6 :
#procedure foo
  #continuedo 2
#endprocedure
#do i=1,3
  #do j=1,3
    #call foo
  #enddo
#enddo
.end
assert preprocess_error?("Trying to jump out of a procedure with a #continuedo instruction")
*--#] Issue243_e6 : 
*--#[ Issue392_ContinuationLines_1 :
#: ContinuationLines 1
* Setting ContinuationLines to 0 should remove continuation line limit.
auto symbol x;
local ex = (xabcdefg + xhijklmnop)^100;
.sort
format C;
#write <out.c> "%e" ex
.end
assert succeeded?
assert file("out.c") =~ /[_] [+]=  /
*--#] Issue392_ContinuationLines_1 :
*--#[ Issue392_ContinuationLines_0 :
#: ContinuationLines 0
* Setting ContinuationLines to 0 should remove continuation line limit.
auto symbol x;
local ex = (xabcdefg + xhijklmnop)^100;
.sort
format C;
#write <out.c> "%e" ex
.end
assert succeeded?
assert !(file("out.c") =~ /[_] [+]=  /)
*--#] Issue392_ContinuationLines_0 :
*--#[ Sortrealloc_1 :
On sortreallocate;
Symbol x,y;
Local F = (x+y)^10;
.sort
Identify x = - y;
.sort
Print +s;
.end
assert succeeded?
assert result("F") =~ expr("0");
*--#] Sortrealloc_1 :
*--#[ Sortrealloc_2 :
Symbol x,y;
Local F = (x+y)^10;
.sort
#sortreallocate
Identify x = - y;
.sort
Print +s;
.end
assert succeeded?
assert result("F") =~ expr("0");
*--#] Sortrealloc_2 :
*--#[ TempSortDir_unix :
#: TempSortDir bad/path
Local test = 1;
.end
#require unix?
assert runtime_error?
*--#] TempSortDir_unix :
*--#[ TempSortDir_windows :
#: TempSortDir bad_path
Local test = 1;
.end
#require windows?
assert runtime_error?
*--#] TempSortDir_windows :
*--#[ ZeroUnchanged :
#-

#procedure exprinfo
	#message Module `CMODULE_':
	#do e = {`activeexprnames_'}
		#if `ZERO_`e''
			#message zero `e': `ZERO_`e''
		#endif
		#if `UNCHANGED_`e''
			#message unchanged `e': `UNCHANGED_`e''
		#endif
	#enddo
	#if `ZERO_'
		#message All zero: `ZERO_'
	#endif
	#if `UNCHANGED_'
		#message All unchanged: `UNCHANGED_'
	#endif
	#message
#endprocedure


Off stats;

Symbol x,y;

Local test1 = x;
Local test2 = y;
Local test3 = 1;
.sort:1;

#call exprinfo
Identify x = 0;
.sort:2;

#call exprinfo
Identify y = 0;
.sort:3;

#call exprinfo
.sort:4;

#call exprinfo
Multiply 0;
.sort:5;

#message Here, test3 is incorrectly flagged as unchanged:
#call exprinfo
Print;
.end
assert succeeded?
assert result("test1") =~ expr("0")
assert result("test2") =~ expr("0")
assert result("test3") =~ expr("0")
assert stdout =~ exact_pattern(<<'EOF')
~~~Module 2:
~~~
~~~Module 3:
~~~zero test1: 1
~~~unchanged test2: 1
~~~unchanged test3: 1
~~~
~~~Module 4:
~~~zero test1: 1
~~~unchanged test1: 1
~~~zero test2: 1
~~~unchanged test3: 1
~~~
~~~Module 5:
~~~zero test1: 1
~~~unchanged test1: 1
~~~zero test2: 1
~~~unchanged test2: 1
~~~unchanged test3: 1
~~~All unchanged: 1
~~~
~~~Here, test3 is incorrectly flagged as unchanged:
~~~Module 6:
~~~zero test1: 1
~~~unchanged test1: 1
~~~zero test2: 1
~~~unchanged test2: 1
~~~zero test3: 1
~~~unchanged test3: 1
~~~All zero: 1
~~~All unchanged: 1
~~~
EOF
*--#] ZeroUnchanged :
*--#[ tablebase_ro_1 :
Table,sparse,no1fill(1);
Fill no1fill(1) = 1;
Fill no1fill(2) = 2;
Fill no1fill(3) = 3;
TableBase "no1.tbl" create;
TableBase "no1.tbl" addto no1fill;
.end
Table,sparse,no2fill(1);
Fill no2fill(1) = 1;
Fill no2fill(2) = 2;
Fill no2fill(3) = 3;
.sort
TableBase "no1.tbl" open,readonly;
TableBase "no1.tbl" addto no2fill;
.end
assert runtime_error?('Tablebase with the name no1.tbl opened in read only mode')
*--#] tablebase_ro_1 :
*--#[ tablebase_ro_2 :
TableBase "no212.tbl" open, readonly;
.end
assert runtime_error?('Trying to open non-existent TableBase in readonly mode: no212.tbl')
*--#] tablebase_ro_2 :
