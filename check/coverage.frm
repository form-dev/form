#ifndef `TEST'
  #message Use -D TEST=XXX
  #terminate
#else
  #include `NAME_' # `TEST'
#endif
.end

*--#[ cov_dollar :
#-
Off stats;
#$Pzero = 2-1-1;
#$Pone = 1;
#$Ptwo = `$Pone'+$Pone+$Pzero+`$Pzero';

#if `$Pone' == `$Ptwo'
	#terminate
#endif
#if (`$Pone' > `$Ptwo') || (`$Pone' >= `$Ptwo')
	#terminate
#endif
#if (`$Ptwo' < `$Pone') || (`$Ptwo' <= `$Pone')
	#terminate
#endif

Symbol x,y;
Local test = (`$Pone'*x+y)^`$Ptwo';
.sort
#$Ptest = test;
$test = test;

ModuleOption,local $test;
Print;
.end
assert succeeded?
*--#] cov_dollar :
*--#[ cov_if :
Symbol x(:100),y,z;
CFunction f,g(symmetric),h;
Vector p,q;
Tensor T,G(symmetric);
Index mu,i1,...,i8;

Set hset: h;

Local test = x * (
	+ z^2
	+ z^3
	+ f(x)
	+ f(y)
	+ f(y)*x
	+ p(mu)
	+ p
	+ p.q
	+ T(p)*z
	+ f(p)
	+ g(p)
	+ h(p)
	+ g(i1,i2)*g(i1,i2)
	+ g(i1,i2)*g(i1,i3)
	+ g(i1,i2,i3)*g(i1,i2,i3)
	+ <g(i1,i2)>*...*<g(i7,i8)>*g(i8,i1)
	+ G(i1,i2)*G(i1,i2)
	+ G(i1,i2)*G(i1,i3)
	+ G(i1,i2,i3)*G(i1,i2,i3)
	+ <G(i1,i2)>*...*<G(i7,i8)>*G(i8,i1)
	);
Local test2 = x;
.sort

#$one = 1;
#$two = 2;
#$pdotq = p.q;

#if ( (maxpowerof(x) > 100) || (minpowerof(x) > -100) )
	Multiply z;
#endif

#if ( termsin(test) == 15 )
	Multiply 2;
#endif

#if ( exists(test3) )
	Multiply 1000;
#endif

#if (isfactorized(test2) == 0)
	If (Expression(test2));
		Identify x = 100;
	EndIf;
#endif

If (Match(f(x?)*x?));
	Identify x = 1;
EndIf;

If (Count(z,1) == 3);
	Identify x = 1;
ElseIf (Count(z,1) == $two);
	Identify x = 2;
EndIf;

If (Count(p+v,1) == 1);
	Identify x = 1;
EndIf;
If (Count(p+d,1) == 1);
	Identify x = 2;
EndIf;
If (Count(p+f,1) == 1);
	Identify x = 3;
EndIf;
If (Count(p+?{f,g},1) == 1);
	Identify x = 4;
EndIf;
If (Count(p+?hset,1) == 1);
	Identify x = 5;
EndIf;
If (Occurs(p.q));
	Multiply 6;
EndIf;
If (Match($pdotq));
	Multiply 6;
EndIf;

If (Occurs(f) || Match(g(p)));
	Multiply 2;
	Identify x = 2;
EndIf;

If ( (Coefficient == MultipleOf(3)) && (Count(z,1) == $one) );
	Multiply z;
EndIf;

If (FindLoop(g, arguments=2, loopsize=2));
	Identify x = 2;
EndIf;
If (FindLoop(g, arguments=3, loopsize=2));
	Identify x = 3;
EndIf;
If (FindLoop(g, arguments=3, loopsize<3, include=i3));
	Multiply 4;
EndIf;
If (FindLoop(g, arguments=2, loopsize=8));
	Multiply 5;
EndIf;

If (FindLoop(G, arguments=2, loopsize=2));
	Identify x = 2;
EndIf;
If (FindLoop(G, arguments=3, loopsize=2));
	Identify x = 3;
EndIf;
If (FindLoop(G, arguments=3, loopsize<3, include=i3));
	Multiply 4;
EndIf;
If (FindLoop(G, arguments=2, loopsize=8));
	Multiply 5;
EndIf;

If ($two);
	Multiply 2;
EndIf;

If (1 >= $two);
	Multiply 1000;
EndIf;

If (1 < 2);
	Multiply 2;
EndIf;
If (1 <= 2);
	Multiply 2;
EndIf;

If (1 > 2);
	Multiply 1000;
EndIf;
If (1 >= 2);
	Multiply 1000;
EndIf;

If (0);
	Multiply 1000;
EndIf;

Print;
.end
assert succeeded?
assert result("test") =~ expr("16*z^2 + 8*z^3 + 576*p.q + 8*p(mu) + 8*p + 16*f(x) + 96*f(y) + 64*f(p) + 64*g(p) + 16*g(i1,i2)^2 + 8*g(i1,i2)*g(i1,i3)*x + 40*g(i1,i2)*g(i1,i8)*g(i2,i3)*g(i3,i4)*g(i4,i5)*g(i5,i6)*g(i6,i7)*g(i7,i8)*x + 96*g(i1,i2,i3)^2 + 40*h(p) + 24*T(p)*z^2 + 96*G(i1,i2,i3)*G(i1,i2,i3) + 16*G(i1,i2)*G(i1,i2) + 8*G(i1,i2)*G(i1,i3)*x + 40*G(i1,i2)*G(i1,i8)*G(i2,i3)*G(i3,i4)*G(i4,i5)*G(i5,i6)*G(i6,i7)*G(i7,i8)*x")
assert result("test2") =~ expr("800")
*--#] cov_if :
*--#[ cov_factorin_ :
CFunction f;
Symbol x1,x2,x3;
Vector p,q;
Index mu;
Local F = 10*x1*p.q*p(mu)*f(x1)*(x1+x2+x3/3);
Local F2 = 10*x1*p.q*p(mu)*f(x1)*(x1+x2+x3/3);
#$f = 10*x1*p.q*p(mu)*f(x1)*(x1+x2+x3/3);
.sort
Drop F2;

Local G = factorin_(F);
Local G2 = factorin_(F2);
Local g = factorin_($f);

Print;
.end
assert succeeded?
assert result("G") =~ expr("10/3*f(x1)*p(mu)*p.q*x1")
assert result("G2") =~ expr("10/3*f(x1)*p(mu)*p.q*x1")
assert result("g") =~ expr("10/3*f(x1)*p(mu)*p.q*x1")
*--#] cov_factorin_ :
*--#[ cov_hideskip :
#: scratchsize 1
#: hidesize 1
Symbol x,y,z;
Local f = (1+x+y+z)^70;
Local g = (1+x+y+z)^70;
.sort
Hide f;
Skip g;
Identify x = 2;
Identify y = 2;
Identify z = 2;
.sort
UnHide f;
Identify x = 1;
Identify y = 1;
Identify z = 1;
Print;
.end
assert succeeded?
assert result("f") =~ expr("1393796574908163946345982392040522594123776")
assert result("g") =~ expr("1393796574908163946345982392040522594123776")
*--#] cov_hideskip :
*--#[ cov_identify_once :
#-
Symbol n,m,x,y;
Vector p,q,r,s;
CFunction f,g;
Set two:2;
#$two = 2;
Local testS =
	+ x*f(1)
	+ x*f(2)
	+ x^2*f(2)
	+ x^2*f(3)
	+ x^-1*f(-1)
	+ x^-1*f(0)
	;
Local testDP =
	+ p.q*f(1)
	+ p.q*f(2)
	+ p.q^2*f(2)
	+ p.q^2*f(3)
	+ p.q^-1*f(-1)
	+ p.q^-1*f(0)
	;

* Arrange so the later patterns could match more than once:
Identify x^n? = x^n * y^n;
Identify p.q^n? = p.q^n * r.s^n;

Identify,once x? = x * g(1);
Identify,once x?^2 = x^2 * g(2);
Identify,once x?^n?two = x^n * g(3);
Identify,once x?^$two = x^$two * g(4);
Identify,once x?^n?!two = x^n * g(5);
Identify,once f(n?)*x?^n? = f(n)*x^n * g(6);
Identify,once f(m?!{n?})*x?^n?!{m?} = f(m)*x^n * g(7);

Identify,once p?.q? = p.q * g(1);
Identify,once p?.q?^2 = p.q^2 * g(2);
Identify,once p?.q?^n?two = p.q^n * g(3);
Identify,once p?.q?^$two = p.q^$two * g(4);
Identify,once p?.q?^n?!two = p.q^n * g(5);
Identify,once f(n?)*p?.q?^n? = f(n)*p.q^n * g(6);
Identify,once f(m?!{n?})*p?.q?^n?!{m?} = f(m)*p.q^n * g(7);
Print;
.end
assert succeeded?
assert result("testS") =~ expr("
      f(-1)*g(5)*g(6)*x^-1*y^-1 + f(0)*g(5)*g(6)*g(7)*x^-1*y^-1 + 2*f(1)*g(1)*
      g(5)*g(6)*x*y + 2*f(2)*g(1)*g(2)*g(3)*g(4)*g(6)*x^2*y^2
");
assert result("testDP") =~ expr("
      f(-1)*g(5)*g(6)*p.q^-1*r.s^-1 + f(0)*g(5)*g(6)*g(7)*p.q^-1*r.s^-1 + f(1)
      *g(1)*g(4)*g(5)*g(6)*g(7)*p.q^2*r.s + f(2)*g(1)*g(2)*g(3)*g(4)*g(5)*g(6)
      *g(7)*p.q^3*r.s^2 + f(2)*g(1)*g(4)*g(5)*g(6)*g(7)*p.q^2*r.s + f(3)*g(1)*
      g(2)*g(3)*g(4)*g(5)*g(6)*g(7)*p.q^3*r.s^2
");
*--#] cov_identify_once :
*--#[ cov_identify_only :
#-
Symbol n,m,x;
Vector p,q;
CFunction f,g;
Vector v;
Index mu,nu;
Set two:2;
#$two = 2;
Local test =
	+ x
	+ x^2
	+ x^-1
	+ x*f(1)
	+ x*f(2)
	+ x^2*f(2)
	+ x^2*f(3)
	+ x^-1*f(-1)
	+ x^-1*f(0)
	;
* Generate some combinations
Identify x^n? = (1+x^n) * (1+p.q^n) * (1 + (mu+nu)*v(mu));
.sort

Identify,only x   = x * g(1);
Identify,only x^2 = x^2 * g(2);
Identify,only x^n?two = x^2 * g(3);
Identify,only x^$two  = x^$two * g(4);
Identify,only x?^2 = x^2 * g(5);
Identify,only x?^n?two  = x^n * g(6);
Identify,only x?^$two   = x^$two * g(7);
Identify,only x?^n?!two = x^n * g(8);
Identify,only f(n?)*x^n?  = f(n)*x^n * g(9);
Identify,only f(n?)*x?^n? = f(n)*x^n * g(10);
Identify,only f(m?!{n?})*x^n?!{m?}  = f(m)*x^n * g(11);
Identify,only f(m?!{n?})*x?^n?!{m?} = f(m)*x^n * g(12);

Identify,only p.q   = p.q * g(13);
Identify,only p.q^2 = p.q^2 * g(14);
Identify,only p.q^n?two = p.q^2 * g(15);
Identify,only p.q^$two  = p.q^$two * g(16);
Identify,only p.q?^2  = p.q^2 * g(17);
Identify,only p?.q?^2 = p.q^2 * g(18);
Identify,only p?.q?^2 = p.q^2 * g(19);
Identify,only p.q?^n?two  = p.q^n * g(20);
Identify,only p.q?^$two   = p.q^$two * g(21);
Identify,only p.q?^n?!two = p.q^n * g(22);
Identify,only f(n?)*p.q^n?   = f(n)*p.q^n * g(23);
Identify,only f(n?)*p.q?^n?  = f(n)*p.q^n * g(24);
Identify,only f(n?)*p?.q?^n? = f(n)*p.q^n * g(25);
Identify,only f(m?!{n?})*p.q^n?!{m?}   = f(m)*p.q^n * g(26);
Identify,only f(m?!{n?})*p.q?^n?!{m?}  = f(m)*p.q^n * g(27);
Identify,only f(m?!{n?})*p?.q?^n?!{m?} = f(m)*p.q^n * g(28);

Identify,only mu?*v?(mu?)*f(n?)*p.q^n?             = mu*v(mu)*f(n)*p.q^n * g(29);
Identify,only mu?*v?(mu?)*f(n?)*p.q?^n?            = mu*v(mu)*f(n)*p.q^n * g(30);
Identify,only mu?*v?(mu?)*f(n?)*p?.q?^n?           = mu*v(mu)*f(n)*p.q^n * g(31);
Identify,only mu?*v?(mu?)*f(m?!{n?})*p.q^n?!{m?}   = mu*v(mu)*f(m)*p.q^n * g(32);
Identify,only mu?*v?(mu?)*f(m?!{n?})*p.q?^n?!{m?}  = mu*v(mu)*f(m)*p.q^n * g(33);
Identify,only mu?*v?(mu?)*f(m?!{n?})*p?.q?^n?!{m?} = mu*v(mu)*f(m)*p.q^n * g(34);

Identify,only nu?!{mu?}*v?(mu?!{nu?})*f(n?)*p.q^n?             = nu*v(mu)*f(n)*p.q^n * g(35);
Identify,only nu?!{mu?}*v?(mu?!{nu?})*f(n?)*p.q?^n?            = nu*v(mu)*f(n)*p.q^n * g(36);
Identify,only nu?!{mu?}*v?(mu?!{nu?})*f(n?)*p?.q?^n?           = nu*v(mu)*f(n)*p.q^n * g(37);
Identify,only nu?!{mu?}*v?(mu?!{nu?})*f(m?!{n?})*p.q^n?!{m?}   = nu*v(mu)*f(m)*p.q^n * g(38);
Identify,only nu?!{mu?}*v?(mu?!{nu?})*f(m?!{n?})*p.q?^n?!{m?}  = nu*v(mu)*f(m)*p.q^n * g(39);
Identify,only nu?!{mu?}*v?(mu?!{nu?})*f(m?!{n?})*p?.q?^n?!{m?} = nu*v(mu)*f(m)*p.q^n * g(40);
Print;
.end
assert succeeded?
assert result("test") =~ expr("
      3 + 3*mu*v(mu) + 3*nu*v(mu) + f(-1)*g(8)*g(9)*g(10)*g(22)*g(23)*g(24)*g(
      25)*p.q^-1*x^-1 + f(-1)*g(8)*g(9)*g(10)*g(22)*g(23)*g(24)*g(25)*g(29)*g(
      30)*g(31)*mu*v(mu)*p.q^-1*x^-1 + f(-1)*g(8)*g(9)*g(10)*g(22)*g(23)*g(24)
      *g(25)*g(35)*g(36)*g(37)*nu*v(mu)*p.q^-1*x^-1 + f(-1)*g(8)*g(9)*g(10)*g(
      26)*x^-1 + f(-1)*g(8)*g(9)*g(10)*g(26)*g(32)*mu*v(mu)*x^-1 + f(-1)*g(8)*
      g(9)*g(10)*g(26)*g(38)*nu*v(mu)*x^-1 + f(-1)*g(11)*g(22)*g(23)*g(24)*g(
      25)*p.q^-1 + f(-1)*g(11)*g(22)*g(23)*g(24)*g(25)*g(29)*g(30)*g(31)*mu*
      v(mu)*p.q^-1 + f(-1)*g(11)*g(22)*g(23)*g(24)*g(25)*g(35)*g(36)*g(37)*nu*
      v(mu)*p.q^-1 + f(-1)*g(11)*g(26) + f(-1)*g(11)*g(26)*g(32)*mu*v(mu) + f(
      -1)*g(11)*g(26)*g(38)*nu*v(mu) + f(0)*g(8)*g(11)*g(12)*g(22)*g(26)*g(27)
      *g(28)*p.q^-1*x^-1 + f(0)*g(8)*g(11)*g(12)*g(22)*g(26)*g(27)*g(28)*g(32)
      *g(33)*g(34)*mu*v(mu)*p.q^-1*x^-1 + f(0)*g(8)*g(11)*g(12)*g(22)*g(26)*g(
      27)*g(28)*g(38)*g(39)*g(40)*nu*v(mu)*p.q^-1*x^-1 + f(0)*g(8)*g(11)*g(12)
      *g(23)*x^-1 + f(0)*g(8)*g(11)*g(12)*g(23)*g(29)*mu*v(mu)*x^-1 + f(0)*g(8
      )*g(11)*g(12)*g(23)*g(35)*nu*v(mu)*x^-1 + f(0)*g(9)*g(22)*g(26)*g(27)*g(
      28)*p.q^-1 + f(0)*g(9)*g(22)*g(26)*g(27)*g(28)*g(32)*g(33)*g(34)*mu*
      v(mu)*p.q^-1 + f(0)*g(9)*g(22)*g(26)*g(27)*g(28)*g(38)*g(39)*g(40)*nu*
      v(mu)*p.q^-1 + f(0)*g(9)*g(23) + f(0)*g(9)*g(23)*g(29)*mu*v(mu) + f(0)*
      g(9)*g(23)*g(35)*nu*v(mu) + f(1)*g(1)*g(8)*g(9)*g(10)*g(13)*g(21)*g(26)*
      g(27)*g(28)*p.q^2*x + f(1)*g(1)*g(8)*g(9)*g(10)*g(13)*g(21)*g(26)*g(27)*
      g(28)*g(32)*g(33)*g(34)*mu*v(mu)*p.q^2*x + f(1)*g(1)*g(8)*g(9)*g(10)*g(
      13)*g(21)*g(26)*g(27)*g(28)*g(38)*g(39)*g(40)*nu*v(mu)*p.q^2*x + f(1)*g(
      1)*g(8)*g(9)*g(10)*g(26)*x + f(1)*g(1)*g(8)*g(9)*g(10)*g(26)*g(32)*mu*
      v(mu)*x + f(1)*g(1)*g(8)*g(9)*g(10)*g(26)*g(38)*nu*v(mu)*x + f(1)*g(11)*
      g(13)*g(21)*g(26)*g(27)*g(28)*p.q^2 + f(1)*g(11)*g(13)*g(21)*g(26)*g(27)
      *g(28)*g(32)*g(33)*g(34)*mu*v(mu)*p.q^2 + f(1)*g(11)*g(13)*g(21)*g(26)*
      g(27)*g(28)*g(38)*g(39)*g(40)*nu*v(mu)*p.q^2 + f(1)*g(11)*g(26) + f(1)*
      g(11)*g(26)*g(32)*mu*v(mu) + f(1)*g(11)*g(26)*g(38)*nu*v(mu) + f(2)*g(1)
      *g(8)*g(11)*g(12)*g(13)*g(21)*g(23)*g(24)*g(25)*p.q^2*x + f(2)*g(1)*g(8)
      *g(11)*g(12)*g(13)*g(21)*g(23)*g(24)*g(25)*g(29)*g(30)*g(31)*mu*v(mu)*
      p.q^2*x + f(2)*g(1)*g(8)*g(11)*g(12)*g(13)*g(21)*g(23)*g(24)*g(25)*g(35)
      *g(36)*g(37)*nu*v(mu)*p.q^2*x + f(2)*g(1)*g(8)*g(11)*g(12)*g(26)*x + f(2
      )*g(1)*g(8)*g(11)*g(12)*g(26)*g(32)*mu*v(mu)*x + f(2)*g(1)*g(8)*g(11)*g(
      12)*g(26)*g(38)*nu*v(mu)*x + f(2)*g(2)*g(3)*g(4)*g(5)*g(6)*g(7)*g(9)*g(
      10)*g(14)*g(15)*g(16)*g(17)*g(18)*g(19)*g(20)*g(23)*g(24)*g(25)*p.q^2*
      x^2 + f(2)*g(2)*g(3)*g(4)*g(5)*g(6)*g(7)*g(9)*g(10)*g(14)*g(15)*g(16)*g(
      17)*g(18)*g(19)*g(20)*g(23)*g(24)*g(25)*g(29)*g(30)*g(31)*mu*v(mu)*p.q^2
      *x^2 + f(2)*g(2)*g(3)*g(4)*g(5)*g(6)*g(7)*g(9)*g(10)*g(14)*g(15)*g(16)*
      g(17)*g(18)*g(19)*g(20)*g(23)*g(24)*g(25)*g(35)*g(36)*g(37)*nu*v(mu)*
      p.q^2*x^2 + f(2)*g(2)*g(3)*g(4)*g(5)*g(6)*g(7)*g(9)*g(10)*g(26)*x^2 + f(
      2)*g(2)*g(3)*g(4)*g(5)*g(6)*g(7)*g(9)*g(10)*g(26)*g(32)*mu*v(mu)*x^2 +
      f(2)*g(2)*g(3)*g(4)*g(5)*g(6)*g(7)*g(9)*g(10)*g(26)*g(38)*nu*v(mu)*x^2
       + f(2)*g(11)*g(13)*g(21)*g(23)*g(24)*g(25)*p.q^2 + f(2)*g(11)*g(13)*g(
      21)*g(23)*g(24)*g(25)*g(29)*g(30)*g(31)*mu*v(mu)*p.q^2 + f(2)*g(11)*g(13
      )*g(21)*g(23)*g(24)*g(25)*g(35)*g(36)*g(37)*nu*v(mu)*p.q^2 + f(2)*g(11)*
      g(14)*g(15)*g(16)*g(17)*g(18)*g(19)*g(20)*g(23)*g(24)*g(25)*p.q^2 + f(2)
      *g(11)*g(14)*g(15)*g(16)*g(17)*g(18)*g(19)*g(20)*g(23)*g(24)*g(25)*g(29)
      *g(30)*g(31)*mu*v(mu)*p.q^2 + f(2)*g(11)*g(14)*g(15)*g(16)*g(17)*g(18)*
      g(19)*g(20)*g(23)*g(24)*g(25)*g(35)*g(36)*g(37)*nu*v(mu)*p.q^2 + 2*f(2)*
      g(11)*g(26) + 2*f(2)*g(11)*g(26)*g(32)*mu*v(mu) + 2*f(2)*g(11)*g(26)*g(
      38)*nu*v(mu) + f(3)*g(2)*g(3)*g(4)*g(5)*g(6)*g(7)*g(11)*g(12)*g(14)*g(15
      )*g(16)*g(17)*g(18)*g(19)*g(20)*g(26)*g(27)*g(28)*p.q^2*x^2 + f(3)*g(2)*
      g(3)*g(4)*g(5)*g(6)*g(7)*g(11)*g(12)*g(14)*g(15)*g(16)*g(17)*g(18)*g(19)
      *g(20)*g(26)*g(27)*g(28)*g(32)*g(33)*g(34)*mu*v(mu)*p.q^2*x^2 + f(3)*g(2
      )*g(3)*g(4)*g(5)*g(6)*g(7)*g(11)*g(12)*g(14)*g(15)*g(16)*g(17)*g(18)*g(
      19)*g(20)*g(26)*g(27)*g(28)*g(38)*g(39)*g(40)*nu*v(mu)*p.q^2*x^2 + f(3)*
      g(2)*g(3)*g(4)*g(5)*g(6)*g(7)*g(11)*g(12)*g(26)*x^2 + f(3)*g(2)*g(3)*g(4
      )*g(5)*g(6)*g(7)*g(11)*g(12)*g(26)*g(32)*mu*v(mu)*x^2 + f(3)*g(2)*g(3)*
      g(4)*g(5)*g(6)*g(7)*g(11)*g(12)*g(26)*g(38)*nu*v(mu)*x^2 + f(3)*g(11)*g(
      14)*g(15)*g(16)*g(17)*g(18)*g(19)*g(20)*g(26)*g(27)*g(28)*p.q^2 + f(3)*
      g(11)*g(14)*g(15)*g(16)*g(17)*g(18)*g(19)*g(20)*g(26)*g(27)*g(28)*g(32)*
      g(33)*g(34)*mu*v(mu)*p.q^2 + f(3)*g(11)*g(14)*g(15)*g(16)*g(17)*g(18)*g(
      19)*g(20)*g(26)*g(27)*g(28)*g(38)*g(39)*g(40)*nu*v(mu)*p.q^2 + f(3)*g(11
      )*g(26) + f(3)*g(11)*g(26)*g(32)*mu*v(mu) + f(3)*g(11)*g(26)*g(38)*nu*
      v(mu) + g(1)*g(8)*x + g(1)*g(8)*mu*v(mu)*x + g(1)*g(8)*nu*v(mu)*x + g(1)
      *g(8)*g(13)*g(21)*p.q^2*x + g(1)*g(8)*g(13)*g(21)*mu*v(mu)*p.q^2*x + g(1
      )*g(8)*g(13)*g(21)*nu*v(mu)*p.q^2*x + g(2)*g(3)*g(4)*g(5)*g(6)*g(7)*x^2
       + g(2)*g(3)*g(4)*g(5)*g(6)*g(7)*mu*v(mu)*x^2 + g(2)*g(3)*g(4)*g(5)*g(6)
      *g(7)*nu*v(mu)*x^2 + g(2)*g(3)*g(4)*g(5)*g(6)*g(7)*g(14)*g(15)*g(16)*g(
      17)*g(18)*g(19)*g(20)*p.q^2*x^2 + g(2)*g(3)*g(4)*g(5)*g(6)*g(7)*g(14)*g(
      15)*g(16)*g(17)*g(18)*g(19)*g(20)*mu*v(mu)*p.q^2*x^2 + g(2)*g(3)*g(4)*g(
      5)*g(6)*g(7)*g(14)*g(15)*g(16)*g(17)*g(18)*g(19)*g(20)*nu*v(mu)*p.q^2*
      x^2 + g(8)*x^-1 + g(8)*mu*v(mu)*x^-1 + g(8)*nu*v(mu)*x^-1 + g(8)*g(22)*
      p.q^-1*x^-1 + g(8)*g(22)*mu*v(mu)*p.q^-1*x^-1 + g(8)*g(22)*nu*v(mu)*
      p.q^-1*x^-1 + g(13)*g(21)*p.q^2 + g(13)*g(21)*mu*v(mu)*p.q^2 + g(13)*g(
      21)*nu*v(mu)*p.q^2 + g(14)*g(15)*g(16)*g(17)*g(18)*g(19)*g(20)*p.q^2 +
      g(14)*g(15)*g(16)*g(17)*g(18)*g(19)*g(20)*mu*v(mu)*p.q^2 + g(14)*g(15)*
      g(16)*g(17)*g(18)*g(19)*g(20)*nu*v(mu)*p.q^2 + g(22)*p.q^-1 + g(22)*mu*
      v(mu)*p.q^-1 + g(22)*nu*v(mu)*p.q^-1
");
*--#] cov_identify_only :
*--#[ cov_saveload :
Symbol x;
Function f;
CFunction g;
Index mu;
Vector p,q;
Tensor T;
Global F = (1+x)^20 + f(1) + g(2) + p.q + p(mu) + T(q) + T(mu) + e_(p,q);
.store
Save test.sav F;
.end
Load test.sav;
Local G = F;
.sort
Delete storage;
Identify x = 1;
Print;
.end
assert succeeded?
assert result("G") =~ expr("1048576 + p.q + p(mu) + e_(p,q) + g(2) + T(q) + T(mu) + f(1)")
*--#] cov_saveload :
*--#[ cov_saveload_err :
Symbol x;
Global F = x;
.store
Save test.sav F;
.end
Load test.sav F1;
.end
assert runtime_error?
assert stdout =~ exact_pattern(<<'EOF')
    Load test.sav F1;
Cannot find expression F1
 F1 not found
EOF
*--#] cov_saveload_err :
*--#[ cov_symm :
* pattern matching of functions with symmtry properties
Indices x1,x2,x3,x4,x5;

CFunction fs(symmetric), fas(antisymmetric), fcs(cyclesymmetric);
Function gs(symmetric), gas(antisymmetric), gcs(cyclesymmetric);
CTensor Ts(symmetric), Tas(antisymmetric), Tcs(cyclesymmetric);
Tensor Us(symmetric), Uas(antisymmetric), Ucs(cyclesymmetric);

Local test =
	+ fs(1,2,3,4,5) + fas(1,2,3,4,5) + fcs(1,2,3,4,5)
	+ gs(1,2,3,4,5) + gas(1,2,3,4,5) + gcs(1,2,3,4,5)
	+ Ts(1,2,3,4,5) + Tas(1,2,3,4,5) + Tcs(1,2,3,4,5)
	+ Us(1,2,3,4,5) + Uas(1,2,3,4,5) + Ucs(1,2,3,4,5)
	;

Identify fs(x1?,x2?,4,3,x5?) = fs;
Identify fas(x1?,x2?,4,3,x5?) = - fas;
Identify fcs(5,1,x3?,x4?,x5?) = fcs;

Identify gs(x1?,x2?,4,3,x5?) = gs;
Identify gas(x1?,x2?,4,3,x5?) = - gas;
Identify gcs(5,1,x3?,x4?,x5?) = gcs;

Identify Ts(x1?,x2?,4,3,x5?) = Ts;
Identify Tas(x1?,x2?,4,3,x5?) = - Tas;
Identify Tcs(5,1,x3?,x4?,x5?) = Tcs;

Identify Us(x1?,x2?,4,3,x5?) = Us;
Identify Uas(x1?,x2?,4,3,x5?) = - Uas;
Identify Ucs(5,1,x3?,x4?,x5?) = Ucs;

Print;
.end
assert succeeded?
assert result("test") =~ expr("fs + fas + fcs + Ts + Tas + Tcs + Us + Uas + Ucs + gs + gas + gcs")
*--#] cov_symm :
*--#[ cov_tablebase_1 :
CTable,sparse f(1);
#do i = 1,10
	Fill f(`i') = `i';
#enddo
.sort
TableBase "test.tbl" create;
TableBase "test.tbl" addto f;
.end
TableBase "test.tbl" open;
Tablebase "test.tbl" load;
.sort
Local test = <f(1)>+...+<f(11)>;
TestUse;
.sort
TableBase "test.tbl" use;
Apply;
Print;
.end
#pend_if mpi?
assert succeeded?
assert result("test") =~ expr("55 + f(11)")
*--#] cov_tablebase_1 :
*--#[ cov_tablebase_2 :
CTable,sparse f(1);
#do i = 1,10
	Fill f(`i') = `i';
#enddo
.sort
TableBase "test2.tbl" create;
TableBase "test2.tbl" addto f;
.end
TableBase "test2.tbl" open;
Tablebase "test2.tbl" enter;
.sort
Local test = <f(1)>+...+<f(11)>;
Apply;
Print;
.end
#pend_if mpi?
assert succeeded?
assert result("test") =~ expr("55 + f(11)")
*--#] cov_tablebase_2 :
*--#[ cov_tablebase_3 :
CTable,sparse f(1);
#do i = 1,10
	Fill f(`i') = `i';
#enddo
.sort
TableBase "test3.tbl" create;
TableBase "test3.tbl" addto f;
.end
TableBase "test3.tbl" open;
Tablebase "test3.tbl" audit;
.end
#pend_if mpi?
assert succeeded?
assert stdout =~ exact_pattern(<<'EOF')
Table,sparse,f(1)
    f(1)
    f(2)
    f(3)
    f(4)
    f(5)
    f(6)
    f(7)
    f(8)
    f(9)
    f(10)
    .end
EOF
*--#] cov_tablebase_3 :
*--#[ cov_transform :
CFunction Z,f,g,h,i;
Symbol inf,x,y,y1,y2,n1,n2;
Set funs: f,g;
#$one = 1;
#$two = 2;

Local test1 = f(1,2,3,4) + g(1,2,3,4) + h(1,2,3,4) + i(1,2,3,4);
Local test2 = f(1,2,3,4);
Local test3 = f(1,2,3,4,5,6,7);
Local test4 = f(1,2,3,4);
Local test5 = f(1,2,3,4) + g(1,2,3,4);
Local test6 = f(1) + f(1,1) + f(1,2) + f(2,1) + f(1,3,2) + f(2,3,1);
Local test7 = test6;
Local test8 =
	+ g(1)*f(1,1,1)
	+ g(2)*f(-1,1,1)
	+ g(3)*f(2,1,1)
	+ g(4)*f(1,-2,1)
	+ g(5)*f(-1,-1,-1)
*	Check against HarmonicSums.m
	- (
		+ g(1)*Z(1, 1, 1, inf)
		- g(2)*Z(-1, -1, 1, inf)
		+ g(3)*Z(2, 1, 1, inf)
		+ g(4)*(-Z(1, -2, -1, inf))
		- g(5)*Z(-1, 1, 1, inf)
	)
	;
Local test9 = test8;

InExpression test1;
	Transform funs addargs($one,last);
	Transform {h,i}, mulargs($one,last);
EndInExpression;

InExpression test2;
	Transform f explode(1,last);
	Identify f(?a) = f(?a)*g(nargs_(?a));
	Identify g(y?$len) = 1;
	Transform f encode(1,last):base=$two;
	Transform f decode(1,$len):base=2, implode(1,last);
EndInExpression;

InExpression test3;
	Transform f permute($one,3,5)($two,6);
EndInExpression;

InExpression test4;
	Transform f reverse($two,last);
EndInExpression;

InExpression test5;
	Transform f cycle($two,last)=+1;
	Transform g cycle(2,last)=-$one;
EndInExpression;

InExpression test6;
	Transform f islyndon(1,last)=(y1,n1);
	Transform f islyndon<(1,last)=(y1,n1);
	Transform f islyndon-(1,last)=(y1,n1);
	Transform f islyndon>(1,last)=(y2,n2);
	Transform f islyndon+(1,last)=(y2,n2);
EndInExpression;

InExpression test7;
	Transform f tolyndon(1,last)=(y1,n1);
	Transform f tolyndon<(1,last)=(y1,n1);
	Transform f tolyndon-(1,last)=(y1,n1);
	Transform f tolyndon>(1,last)=(y2,n2);
	Transform f tolyndon+(1,last)=(y2,n2);
EndInExpression;

InExpression test8;
	Transform f HtoZ(1,last);
	Identify f(?a) = Z(?a,inf);
EndInExpression;

InExpression test9;
	Transform Z ZtoH(1,last-1);
	Identify Z(?a,inf) = f(?a);
EndInExpression;

ModuleOption local $len;
Print;
.end
assert succeeded?
assert result("test1") =~ expr("f(10) + g(10) + h(24) + i(24)")
assert result("test2") =~ expr("f(1,2,3,4)")
assert result("test3") =~ expr("f(3,6,5,4,1,2,7)")
assert result("test4") =~ expr("f(1,4,3,2)")
assert result("test5") =~ expr("f(1,4,2,3) + g(1,3,4,2)")
assert result("test6") =~ expr("f(1)*y1^3*y2^2 + f(1,1)*n1^3*n2^2 + f(1,2)*y1^3*n2^2 + f(1,3,2)*y1^3*n2^2 + f(2,1)*y2^2*n1^3 + f(2,3,1)*n1^3*n2^2")
assert result("test7") =~ expr("f(1)*y1^3*y2^2 + f(1,1)*n1^3*n2^2 + 2*f(2,1)*y1^3*y2^2 + f(3,1,2)*y1^3*y2^2 + f(3,2,1)*y1^3*y2^2")
assert result("test8") =~ expr("0")
assert result("test9") =~ expr("0")
*--#] cov_transform :

*--#[ cov_stmt_tableops :
* covers Fill, PrintTable, ClearTable statements
Symbols x,y;
CTable,sparse tbl(1);
Fill tbl(2) = x^2+y;
Local F = tbl(2);
Print F;
.sort
ClearTable tbl;
Fill tbl(2) = 2*y;
Local G = tbl(2);
Print G;
PrintTable tbl;
.end
assert succeeded?
assert result("G") =~ expr("2*y")
assert nterms("F") == 2
*--#] cov_stmt_tableops :
*--#[ cov_stmt_compress :
* covers Compress on/off and FunPowers (all options) declarations
Symbols x;
Compress on;
CFunction f;
Local F = (x+1)^3;
Print;
.sort
Compress off;
Print;
.sort
FunPowers allfunpowers;
Local G = f(x)^3;
Print G;
.sort
FunPowers nofunpowers;
.end
assert succeeded?
assert result("F") =~ expr("1 + 3*x + 3*x^2 + x^3")
assert result("G") =~ expr("f(x)^3")
*--#] cov_stmt_compress :
*--#[ cov_stmt_unittrace :
* covers UnitTrace statement
Index mu;
Local F = gi_(1)*g_(1,mu)*g_(1,mu);
Trace4,1;
Print F;
.sort
UnitTrace 7;
Local G = gi_(2)*g_(2,mu)*g_(2,mu);
Trace4,2;
Print G;
.end
assert succeeded?
assert result("F") =~ expr("16")
assert result("G") =~ expr("28")
*--#] cov_stmt_unittrace :
*--#[ cov_stmt_ratio :
* covers Ratio statement (partial fractioning with c = b-a)
Symbols a,b,c;
Local F = 1/(a^2*b^2);
Ratio a,b,c;
Print +s F;
.end
assert succeeded?
assert nterms("F") == 4
*--#] cov_stmt_ratio :
*--#[ cov_stmt_chisholm :
* covers Chisholm statement
Index a,b,mu,nu;
Local F = g_(1,a,mu,b)*g_(2,mu)*g_(2,nu)*g_(1,nu);
Chisholm 2;
Print F;
.end
assert succeeded?
*--#] cov_stmt_chisholm :
*--#[ cov_stmt_switch :
* covers Switch/Case/Break/Default/EndSwitch statements
Symbols x;
Local F = x;
.sort
#$num = 2;
Switch $num;
	Case 1;
		Multiply 10;
	Break;
	Case 2;
		Multiply 20;
	Break;
	Default;
		Multiply 99;
EndSwitch;
Print F;
.end
Symbols x;
Local G = x;
.sort
#$num = 5;
Switch $num;
	Case 1;
		Multiply 10;
	Break;
	Case 2;
		Multiply 20;
	Break;
	Default;
		Multiply 99;
EndSwitch;
Print G;
.end
assert succeeded?
assert result("F") =~ expr("20*x")
assert result("G") =~ expr("99*x")
*--#] cov_stmt_switch :
*--#[ cov_stmt_ifelse :
* covers If with dollar comparisons, ElseIf, Else and the one-line If form
Symbols x;
Local F = x;
.sort
#$num = 2;
If ($num == 2);
	Multiply 3;
ElseIf ($num == 1);
	Multiply 11;
Else;
	Multiply 13;
EndIf;
If ($num > 5) Multiply 7;
Print F;
.end
assert succeeded?
assert result("F") =~ expr("3*x")
*--#] cov_stmt_ifelse :
*--#[ cov_stmt_setexit :
* covers SetExitFlag statement (graceful stop; after it the sort is skipped)
Symbols x;
Local F = x;
Print F;
.sort
SetExitFlag;
.end
assert succeeded?
*--#] cov_stmt_setexit :
*--#[ cov_stmt_exit :
* covers Exit statement (abnormal termination)
Symbols x;
Local F = x;
Print F;
Exit "stopping early";
.end
assert runtime_error?
*--#] cov_stmt_exit :
*--#[ cov_stmt_writenwrite :
* covers Write and NWrite format statements with various options
Symbols x;
Write stats;
NWrite statistics;
Write shortstats;
NWrite warnings;
Write allwarnings;
NWrite setup;
Write names;
NWrite allnames;
Write codes;
NWrite highfirst;
Write lowfirst;
NWrite powerfirst;
Write tokens;
Local F = x;
Print F;
.end
assert succeeded?
assert result("F") =~ expr("x")
*--#] cov_stmt_writenwrite :
*--#[ cov_pp_random :
* covers #setrandom and the random_ preprocessor function
#setrandom 8938
#$r = random_(6);
#$s = random_(6);
Symbols x;
Local F = $r*x;
Local G = $s*x;
Print F;
Print G;
.end
assert succeeded?
assert nterms("F") == 1
assert nterms("G") == 1
*--#] cov_pp_random :
*--#[ cov_pp_directives :
* covers #breakdo, #show, #debug and #commentchar
* (with #debug 1 the preprocessor runs in preprocess-only mode)
#debug 1
#show
#commentchar %
% comment via the changed comment character
#do i = 1,5
	#breakdo
#enddo
*--#] cov_pp_directives :
*--#[ cov_pp_appendexchange :
* covers #append/#write/#close and #exchange for expressions and $variables
#append <outappend.txt>
#write <outappend.txt> "new line"
#close <outappend.txt>
S x,y;
Local F = x;
Local G = 2*y;
.sort
#exchange F,G
#$a = 1;
#$b = 2;
#exchange $a,$b
Local H = $a + $b + F;
Print H;
.end
#prepare write "outappend.txt", "old line\n"
assert succeeded?
assert result("H") =~ expr("3 + 2*y")
*--#] cov_pp_appendexchange :
*--#[ cov_opt_format :
* covers the optimization options of the Format statement and
* #optimize/#clearoptimize/#skipextrasymbols/Delete extrasymbols
Symbols a,b,c,d,e;
Local F1 = (a+b+c)*(d+e)*(a+c) + (a+c)*(b+d)*(e+1) + a^2*e - b^3;
Format O1,method=cse;
.sort
#optimize F1
#write "%O"
#clearoptimize
Local F2 = (a+b+c)*(d+e)*(a+c) + (a+c)*(b+d)*(e+1) + a^2*e - b^3;
Format O2,greedyminnum=3,greedymaxperc=2,horner=occurrence,
	hornerdirection=forwardandbackward,stats=on;
.sort
#optimize F2
#write "%O"
#skipextrasymbols
Delete extrasymbols;
#clearoptimize
Local F3 = (a+b+c)*(d+e)*(a+c) + (a+c)*(b+d)*(e+1) + a^2*e - b^3;
Format O3,mctsnumexpand=5,mctsnumkeep=2,mctsnumrepeat=1,mctsconstant=0.5,
	mctsdecaymode=0,mctstimelimit=1;
.sort
#optimize F3
#write "%O"
#clearoptimize
Local F4 = (a+b+c)*(d+e)*(a+c) + (a+c)*(b+d)*(e+1) + a^2*e - b^3;
Format O4,saIter=10,saMinT=1,saMaxT=2,method=csegreedy,greedytimelimit=1,
	timelimit=1,printscheme=off,debugflag=2;
.sort
#optimize F4
#write "%O"
#clearoptimize
.end
assert succeeded?
*--#] cov_opt_format :
*--#[ cov_printoptions :
* covers option syntax and string form of Print/NPrint statements
Symbols x;
#$d = 3;
Local F = (x+1)^2;
Print +s;
.sort
Print -s F;
.sort
Print +ss;
.sort
Print -ss;
.sort
Print +f;
.sort
Print "%$ is the value",$d;
Print -f;
.sort
NPrint;
.end
assert succeeded?
assert result("F") =~ expr("1 + 2*x + x^2")
*--#] cov_printoptions :
*--#[ cov_onoff :
* covers On/Off statements with most option keywords and arguments
On insidefirst;
Off insidefirst;
On propercount;
Off propercount;
On allnames;
Off allnames;
On allwarnings;
Off allwarnings;
On powerfirst;
On lowfirst;
On highfirst;
On setup;
Off setup;
On codes;
Off codes;
On tokens;
Off tokens;
On properorder;
Off properorder;
On nospacesinnumbers;
Off nospacesinnumbers;
On totalsize;
Off totalsize;
On backtrace;
Off backtrace;
On flag,1;
Off flag,1;
On innertest;
Off innertest;
On oldfactarg;
Off oldfactarg;
On memdebugflag;
Off memdebugflag;
On oldgcd;
Off oldgcd;
On oldprfsign;
Off oldprfsign;
On wtimestats;
Off wtimestats;
On sortreallocate;
Off sortreallocate;
On flint;
Off flint;
On humanstats;
Off humanstats;
On humanstatistics;
Off humanstatistics;
On fewerstats;
Off fewerstats;
On fewerstatistics;
Off fewerstatistics;
On processstats;
Off processstats;
On finalstats;
Off finalstats;
On shortstats;
Off shortstats;
On shortstatistics;
Off shortstatistics;
On grccverbose;
Off grccverbose;
On sortverbose;
Off sortverbose;
On indentspace 5;
Off indentspace;
On compress;
Off compress;
On compress gzip 8;
Off compress;
On compress zstd 5;
Off compress;
On statistics;
Off statistics;
.end
assert succeeded?
*--#] cov_onoff :
*--#[ cov_onoff_error :
* error paths of On/Off: unknown option, bad compress argument,
* bad checkpoint interval, and IndentSpace out of range (warning)
On nosuchoption;
.end
On checkpoint 5z;
.end
On compress badthing;
.end
On indentspace 50;
Off indentspace;
.end
assert compile_error?
*--#] cov_onoff_error :
*--#[ cov_factdollar :
* covers FactDollar statement and If with indexed (factorized) $-variables
Symbols x,y;
CFunction f1,f2;
Local F = f1(x^2+2*x*y+y^2)+f1(x^4-y^4);
id f1(x?$x) = f2(x);
FactDollar,$x;
Do $i = 1,$x[0];
	Print "in %t factor %$ is %$",$i,$x[$i];
Enddo;
Print F;
.sort
Local G = $x[0];
Local H = 1;
If ( $x[1] != 0 );
	Print "factor 1 ok";
	Multiply 2;
EndIf;
Print H;
Print G;
.end
# Under threads the module with $-assignments is forced to sequential mode
# (a warning is printed) and the dollar is captured once per thread.
#pend_if threaded?
assert succeeded?
assert nterms("G") == 1
assert result("H") =~ expr("2")
*--#] cov_factdollar :
*--#[ cov_factdollar_error :
* error paths: undefined dollar with factor index in If; too many %$ in Print format
Symbols x;
#$d = 2;
If ( $nosuch[1] == 0 );
	Print "x";
EndIf;
Print "%$ %$",$d;
.end
assert compile_error?
*--#] cov_factdollar_error :
*--#[ cov_modulus :
* covers Modulus statement and its option keywords
Symbols x;
Modulus 7;
Local F = (x+5)^2;
Print F;
.sort
Modulus plusmin,positive,3;
Local G = (x+2)*(x+1);
Print G;
.sort
Modulus nofunctions,coefficientsonly,5;
Local H = (x+1)*(x+4);
Print H;
.sort
Modulus alsodollars,inversetable,nopowers,101;
#$dd = 8*8;
Local I = $dd + 1;
Print I;
.sort
Modulus nodollars,noinversetable,alsopowers,printpowersof(2),13;
Local J = 3*x^2+99;
Print J;
.end
assert succeeded?
assert result("F") =~ expr("4 + 3*x + x^2")
*--#] cov_modulus :
*--#[ cov_traceopts :
* covers Trace4 with option keywords and TraceN
Vectors p,q;
Index mu,nu;
Local F = g_(1,p,mu,q,mu);
Trace4,contract,1;
Print F;
.sort
Local A = g_(1,p,nu,q,nu);
Trace4,nocontract,1;
Print A;
.sort
Local B = g_(1,p,mu,q,mu);
Trace4,notrick,1;
Print B;
.sort
Local C = g_(1,p,mu,q,mu);
Trace4,trick,1;
Print C;
.sort
Local D = g_(1,p,mu,q,mu);
Trace4,nosymmetrize,1;
Print D;
.sort
Local E = g_(1,p,mu,q,mu);
Trace4,symmetrize,1;
Print E;
.sort
Local H = g_(2,p,mu,q,mu);
TraceN 2;
Print H;
.end
assert succeeded?
*--#] cov_traceopts :
*--#[ cov_traceopts_error :
* error paths of Trace4: undefined index, empty argument
Vectors p;
Index mu;
Local F = g_(1,p,mu,mu);
Trace4 notanindex;
Trace4 ;
.end
assert compile_error?
*--#] cov_traceopts_error :
*--#[ cov_createall :
* CreateAll loops and CreateAll paths on graphs of function arguments
Symbols a1,a2,a3;
CFunction f,g,outf;
Local F = f(a1,a2)*f(a2,a3)*f(a3,a1) + f(a1,a2) + f(a1,a3);
CreateAll loops,f,g,type=symbol,ifnoloop=0;
Print F;
.end
Symbols a1,a2,a3;
CFunction f,g,outf;
Local G = f(a1,a2)*f(a2,a3) + f(a1,a2)*f(a3,a2);
CreateAll paths,f,g,outf,type=symbol,ifnopath=0;
Print G;
.end
assert succeeded?
assert nterms("F") == 1
assert result("F") =~ expr("f(a1,a2)*f(a2,a3)*f(a3,a1)*g(a1,a2,a3)")
assert result("G") =~ expr("f(a1,a2)*f(a2,a3)*outf(a2) + f(a1,a2)*f(a3,a2)*outf(a2)")
*--#] cov_createall :
*--#[ cov_replaceloop :
* ReplaceLoop statement and the findloop() condition of If
Index i1,i2,i3,j1,j2,j3;
CFunction fv(Symmetric),ofn;
Local F2 = fv(i1,i2,j1)*fv(i2,i3,j2)*fv(i1,i3,j3);
ReplaceLoop fv,arguments=3,loopsize=3,outfun=ofn,include=i1;
Print F2;
.sort
Local F3 = fv(i1,i2,j1)*fv(i2,i1,j2) + fv(i1,i2,j1);
If ( findloop(fv,arguments=3,loopsize=2) );
	Multiply 3;
EndIf;
Print F3;
.end
assert succeeded?
*--#] cov_replaceloop :
*--#[ cov_mergestuffle :
* Merge/Shuffle/Stuffle statements with once variants
CFunction mf;
Local F3 = mf(1,2)*mf(3,4);
Shuffle mf;
Print F3;
.sort
Local F4 = mf(1,2)*mf(3,4);
Merge mf;
Print F4;
.sort
Local F5 = mf(1,2)*mf(3,4);
Merge,once,mf;
Print F5;
.sort
Stuffle mf+;
Print F3;
.sort
Stuffle,once,mf-;
Print F4;
.sort
Stuffle mf-;
Print F5;
.end
assert succeeded?
*--#] cov_mergestuffle :
*--#[ cov_sumstmt :
* Sum statement with a list of replacement values
CFunction sf;
Index mu,nu;
Local T2 = sf(mu,mu);
Local T3 = sf(mu,nu)*sf(mu,nu);
Sum mu,0,1,2, nu,0,1,2;
Print;
.end
assert succeeded?
assert result("T2") =~ expr("sf(0,0) + sf(1,1) + sf(2,2)")
assert nterms("T3") == 9
*--#] cov_sumstmt :
*--#[ cov_putinside :
* PutInside with bracket information (cf. manual example)
Symbols b1,c1,z;
Function pif;
Local PI = b1 + c1 + (b1+c1)*z;
Bracket b1;
.sort
PutInside pif;
Print;
.end
assert succeeded?
*--#] cov_putinside :
*--#[ cov_factorize :
* Factorize/UnFactorize on a named expression
Symbols x,y;
Local F7 = x^2*y^2 + x*y + 1;
Factorize F7;
Print F7;
.sort
UnFactorize F7;
Print F7;
.end
assert succeeded?
assert nterms("F7") == 3
*--#] cov_factorize :
*--#[ cov_symmetrize_stmt :
* Symmetrize family on (a)symmetric functions
CFunction syf1,syf2,syf3;
Symbol a,b,c;
Local F8 = syf1(b,a)*syf2(b,a) + syf3(b,a,c);
Symmetrize syf1;
AntiSymmetrize syf2;
CycleSymmetrize syf3;
RCycleSymmetrize syf3;
Print F8;
.end
assert succeeded?
*--#] cov_symmetrize_stmt :
*--#[ cov_chisholm_dollar :
* Chisholm with a dollar-variable level and option keywords
Symbols x,z;
CFunction c1;
#$d = 3;
Local F = c1((x+z)^2) + c1(x+z);
Chisholm,symmetrize $d;
Chisholm,nosymmetrize 2;
Print F;
.end
assert succeeded?
*--#] cov_chisholm_dollar :
*--#[ cov_printfiles :
* Print to a file: the +f form and the <channel> form
Symbols q;
Local F9 = q^2;
#write <p9b.txt> "opened";
Print +f, F9;
Print <p9b.txt>, F9;
.sort
Print <p9b.txt>, F9;
Print +f;
.end
assert succeeded?
*--#] cov_printfiles :
*--#[ cov_checkpoint_on :
* On checkpoint with an interval and a run script (deprecated mechanism,
* prints a DeprecationWarning)
On checkpoint 1s,run="true";
Local F10 = 1;
Print;
.end
assert warning?
assert stdout =~ /Deprecation/
*--#] cov_checkpoint_on :
*--#[ cov_external :
* the #external preprocessor block
Symbols x;
#external cat
Local FX = (1+x)^3;
#rmexternal
Print;
.end
assert succeeded?
*--#] cov_external :
*--#[ cov_createrrors :
* error paths for CreateAll/ReplaceLoop/Print/On checkpoint
Symbols x;
CFunction f,g,h;
Local F = 1;
CreateAll cuts,f,g;
Print;
.end
assert compile_error?
assert stdout =~ /Illegal subkey/
*--#] cov_createrrors :
*--#[ cov_preifdollar :
* #if/#elseif/#else/#ifdef/#ifndef with preprocessor dollars
#$d1 = 7;
#if ( $( $d1 == 7 ) )
#write "if branch";
#elseif ( $( $d1 > 7 ) )
#write "elseif branch1";
#else
#write "else branch";
#endif
#if ( $( $d1 != 7 ) )
#write "neg branch";
#elseif ( $( $d1 < 7 ) )
#write "elseif branch2";
#else
#write "else2 branch";
#endif
#ifdef $d1
#write "d1 defined";
#endif
#ifndef nosuchvar
#write "nosuch undefined";
#endif
Local F = 1;
Print;
.end
assert succeeded?
assert stdout =~ /if branch/
assert stdout =~ /else2 branch/
assert stdout =~ /d1 defined/
assert stdout =~ /nosuch undefined/
*--#] cov_preifdollar :
*--#[ cov_prewrite :
* #create/#write/#append/#close/#remove with a channel
#$wv = 3;
#create <c1.txt> "start";
#write <c1.txt> "wv=%$",$wv;
#append <c1.txt> "more";
#close <c1.txt>;
#remove <c1.txt>;
#write "plain %$",$wv;
Local F = 1;
Print;
.end
assert succeeded?
*--#] cov_prewrite :
*--#[ cov_symmetricmatch :
* id-matching for symmetric, cyclic and reversecyclic functions
Symbols x,y,z;
CFunction fsym(Symmetric),fcyc(Cyclic),frc(ReverseCyclic);
Symbol a,b,c,d;
Local M = fsym(b,a)*fsym(a,b) + fcyc(a,b,c)*fcyc(c,a,b)
        + frc(b,a,c)*frc(c,a,b);
id fsym(x?,y?)*fsym(y?,x?) = fsym(x+y,0);
id fcyc(x?,y?,z?)*fcyc(z?,x?,y?) = fcyc(x,y,0);
id frc(x?,y?,z?)*frc(z?,x?,y?) = frc(x,y,0);
Print;
.end
assert succeeded?
assert nterms("M") == 3
*--#] cov_symmetricmatch :
*--#[ cov_factdollar2 :
* FactDollar on a multi-term dollar and error path
Symbols x,y;
Local F = (x+1)*(y+1) + (x-1)*(y-1);
.sort
$e = F;
FactDollar $e;
Print "%$",$e;
.end
# The $-assignment module is forced to sequential mode under threads
# (produces a warning).
#pend_if threaded?
assert succeeded?
*--#] cov_factdollar2 :
*--#[ cov_replaceloop2 :
* ReplaceLoop variants: no include, loopsize<, multiple loops in one term
Index i1,i2,i3,i4,i5,j1,j2,j3,j4,j5,k1;
CFunction fv(Symmetric),ofn;
Local F1 = fv(i1,i2,j1)*fv(i2,i1,j2);
ReplaceLoop fv,arguments=3,loopsize=2,outfun=ofn;
Print F1;
.sort
Local F2 = fv(i1,i2,j1)*fv(i2,i3,j2)*fv(i1,i3,j3)*fv(i4,i5,j5)
         + fv(i1,i2,j1)*fv(i2,i1,j2)*fv(i3,i4,j4)*fv(i4,i3,j5);
ReplaceLoop fv,arguments=3,loopsize<4,outfun=ofn;
Print F2;
.end
assert succeeded?
*--#] cov_replaceloop2 :
*--#[ cov_gettable_err :
* sparse table lookup: unfilled elements stay as table calls
CTable,sparse ttt(1);
Fill ttt(1) = 7;
Local TT = ttt(2) + ttt(1) + ttt(2);
Print;
.end
assert succeeded?
assert result("TT") =~ expr("7 + 2*ttt(2)")
*--#] cov_gettable_err :
*--#[ cov_writeformats :
* #write format specifiers: %d %s %e %E %X %O and %% 
Symbols x;
#define str "abc"
#$dd = 5;
Local F = x;
.sort
#write "A%d B%s";
#write "S:%s",str;
#write "D:%$",$dd;
#write "E:%e",F;
#write "O:%O";
#write "X:%X",F;
Print;
.end
assert succeeded?
assert stdout =~ /S:str/
assert stdout =~ /D:5/
assert stdout =~ /E:x;/
assert stdout =~ /X:/
*--#] cov_writeformats :
*--#[ cov_tryreplace :
* TryReplace swaps a pair of objects (only when it sorts better)
Symbols x,y,z;
Local F = y*z + y*x^2;
TryReplace x,z;
Print;
.sort
Local G = y*z + y*x^2;
TryReplace z,x;
Print G;
Print;
.end
assert succeeded?
assert nterms("F") == 2
assert nterms("G") == 2
*--#] cov_tryreplace :
*--#[ cov_table_err :
* table with a bounded index range, filled and read back
Table ttt(1:3);
Fill ttt(1) = 7;
Fill ttt(2) = 8;
Local TT = ttt(2)*ttt(1);
Print;
.end
assert succeeded?
assert result("TT") == "56"
*--#] cov_table_err :
*--#[ cov_symmetricmatch2 :
* deeper symmetric matching: nested (anti)symmetric arguments, cyclic wildcards
CFunction fs(Symmetric),fa(AntiSymmetric),fc(Cyclic),frc(ReverseCyclic);
Symbols a,b,c,d,x,y,z,q1,q2;
Local F = fa(b,a)*fa(a,c)*fa(c,b) + fs(a,b)*fs(b,a)
        + fs(fa(a,b),fa(c,d))*fs(fa(c,d),fa(a,b));
id fa(x?,y?)*fa(y?,z?) = fa(x,z);
id fs(x?,y?)*fs(y?,x?) = fs(x,y);
Print;
.sort
Local G = fc(a,b,c)*frc(a,b,c) + fc(q1,q2,a)*fc(a,q1,q2);
id fc(x?,y?,z?)*frc(x?,y?,z?) = fc(x,y,z);
id fc(x?,y?,z?)*fc(y?,z?,x?) = fc(1,x,y);
Print G;
Print;
.end
assert succeeded?
*--#] cov_symmetricmatch2 :
*--#[ cov_shapezoo1 :
* metric deltas, epsilon tensors and dotproducts
Vectors p1,p2,p3,p4;
Index i1,i2,i3;
Local ShpE = d_(i1,i2)*d_(i2,i3) + d_(i1,i1) + e_(p1,p2,p3,p4)
        + e_(p1,p1,p3,p4) + p1.p2 + p4.p4;
Print ShpE;
.end
* nested functions, empty and numeric arguments
CFunction f,g,f2;
Symbols a,b,x,y,z;
Local ShpF = f(g(a,b),b) + f() + f(0) + f(f2(a)) + g(a^2-1) + f(x,y,z);
Print ShpF;
.end
assert succeeded?
assert nterms("ShpE") == 5
*--#] cov_shapezoo1 :
*--#[ cov_shapezoo2 :
* Sqrt_, sum_ and denominators
Symbols x,k;
CFunction shpf;
Local ShpA = Sqrt_(x+1) + sum_(k,1,5,shpf(k));
Print ShpA;
.sort
Symbols y;
Local ShpD = 1/(x^2+y) + (x-y)^-2;
Print ShpD;
.end
* bignum coefficients and high powers
Symbols x;
Local ShpB = 12345678901234567890^2 + (x+1)^61;
Print ShpB;
.end
assert succeeded?
*--#] cov_shapezoo2 :
*--#[ cov_wildzoo1 :
* set membership, dynamic sets and exclusions for wildcards
Symbols x,y,w,a,a1,a2,a3,b1,b2,c,nn;
CFunction wzf,wzg;
Set aa: a1,a2,a3;
Local W1 = wzf(a1) + wzf(b1) + wzf(a3);
id wzf(x?aa) = wzg(x);
Print W1;
.sort
Set bb: a1,a2,a3;
Local W2 = wzf(a2) + wzf(c) + wzf(a3);
id wzf(y?bb[nn]) = wzg(nn);
Print W2;
.end
Symbols z,d1,d2;
CFunction h1,h2,h3;
Local W3 = h1(0) + h1(5);
id h1(z?!{0,0}) = h2(z);
Print W3;
.sort
Symbols w,p,q,r,a3;
Local W4 = h3(p,q,a3,r);
id h3(w?{p,q,a3}) = h2(w);
Print W4;
.end
assert succeeded?
assert nterms("W3") == 2
*--#] cov_wildzoo1 :
*--#[ cov_wildzoo2 :
* number and dummy-index wildcards in powers and tensors
Symbols x,x1,n;
CFunction t;
Local P1 = x^3 + x1^2;
id x^n? = t(x,n);
Print P1;
.end
Symbols q1,q2;
CFunction wzf,wzg;
Index i1,i2;
Local P2 = wzf(i1,i2)*wzf(i2,i1);
id wzf(N1_?,N2_?)*wzf(N2_?,N1_?) = wzg(N1_?,N2_?);
Print P2;
.end
assert succeeded?
assert nterms("P1") == 2
*--#] cov_wildzoo2 :
*--#[ cov_idmodifiers :
* Many/Once/Only/Select id modifiers and bare-vector substitution
Symbols x,y;
CFunction f,g,h;
Local IdF = f(x)*f(y);
Many f(x?) = g(x);
Print IdF;
.sort
Local IdG = f(x)*f(y);
Once f(x?) = g(x);
Print IdG;
.sort
Local IdH = f(x)*f(y);
Only f(x?) = h(x);
Print IdH;
.sort
Local IdS = f(x);
Select f(x?) = h(x);
Print IdS;
Print;
.end
Vector p1,p2;
CFunction f;
Local IdV = f(p1,p2);
id p1 = p2;
Print IdV;
.end
assert succeeded?
assert result("IdF") =~ expr("g(x)*g(y)")
*--#] cov_idmodifiers :
*--#[ cov_dollarrhs :
* runtime dollars assigned in one module, used in the next
Symbols x,y;
CFunction f,g;
Local Dr0 = 1;
Print Dr0;
.sort
$d = x^2;
Print "%$",$d;
.sort
Local DrF = $d + f($d);
Print DrF;
Print;
.end
Symbols x,y;
CFunction f,g;
Local DrQ = f(y) + 1;
.sort
$w = f(y) + 1;
id f(x?) = g($w,x);
Print DrQ;
.end
#pend_if threaded?
assert succeeded?
*--#] cov_dollarrhs :
*--#[ cov_errzoo :
* compile-error zoo, one tiny program per message site
Local Err1 = x^((y);
.end
UnrecognizedStatement;
.end
Vector p1;
Symbols q;
Local Err3 = p1[q];
.end
Symbols y1;
CFunction d_;
Local Err4 = d_(y1);
.end
Vector p2,p3;
Local Err5 = p2.5;
.end
AutoDeclare Vector;
Local Err6 = 1;
.end
Local Err7 = ((x);
.end
Symbols aa$b;
Local Err8 = 1;
.end
Vector p4,p5;
Local Err10 = p4.p5^2 + r.s;
.end
Symbols x9;
Print >%s Err10;
.end
Symbols x9;
CFunction FX;
Local Err9 = x9^3;
Factor FX;
.sort
UnFactor FX(???);
.end
#pend_if mpi?
assert compile_error?
*--#] cov_errzoo :
*--#[ cov_errpre :
* preprocessor-error zoo
Symbols x;
Local Ep1 = x;
.sort
#inside Ep1
Local Epx = 2;
#endinside
Print Epx;
.end
#pend_if mpi?
assert preprocess_error?
*--#] cov_errpre :
