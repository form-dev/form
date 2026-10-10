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
*--#[ cov_opt_scheme :
* Scheme option of the Format,Optimize statement (CoOptimizeOption)
Symbols a,b,c,d;
Local F1 = (a+b+c)*(d+a);
Format O1,scheme=(a,b,c,d);
.sort
#optimize F1
#write "%O"
#clearoptimize
Local F2 = (a+b+c)*(d+a);
Format O2,horner=sa,method=greedy,scheme=(a,c,b),printscheme=on;
.sort
#optimize F2
#write "%O"
#clearoptimize
.end
assert succeeded?
*--#] cov_opt_scheme :
*--#[ cov_opt_badopts :
* error branches of the Format,Optimize option parser (CoOptimizeOption)
Symbols x,y;
Local F = x*y;
Format O1,foo=5;
Format O2,horner=wrong,method=wrong,stats=wrong;
.sort
.end
assert compile_error?
*--#] cov_opt_badopts :
*--#[ cov_totensor :
* ToTensor statement (FindAll in pattern.c): vector occurrences in
* dotproducts, contractions and function arguments become tensor arguments
Vectors p;
CTensors t;
Indices i,j;
CFunction g;
Local F = p(i)*p(i)*p(1)*p(j);
ToTensor t,p;
Print F;
.end
assert succeeded?
assert result("F") == "t(1,j,N1_?,N1_?)"
*--#] cov_totensor :
*--#[ cov_totensor2 :
* ToTensor statement: dotproduct conversion and function-argument vectors
Vectors p,q;
CTensors t;
CFunction g;
Indices i,j;
Local F = g(p(i),p(j)) + p(i)*q(i)*q(j);
ToTensor t,p;
Print F;
.end
assert succeeded?
assert result("F") == "t(q)*q(j)+g(p(i),p(j))"
*--#] cov_totensor2 :
*--#[ cov_contentexpr :
* content_/firstterm_ expression functions (GetContent/GetFirstTerm in execute.c)
Symbols x,y;
Local F = (x/3+2/y)^2;
.sort
Local C = content_(F);
Local T = firstterm_(F);
Print C, T;
.end
assert succeeded?
assert result("C") == "1/9*y^-2"
assert result("T") == "4*y^-2"
*--#] cov_contentexpr :
*--#[ cov_contentmerge :
* content_ over the ContentMerge object cases (execute.c): multi-term
* expressions with symbols/dotproducts/indices/vectors/gammas/deltas/
* functions, plus the stored-expression branch of GetContent
Symbols x,y;
Vectors p,q;
Indices i,j;
Functions G;
Local F = 2*x*p.q*i*p*G(j) + 4*x*p.q*i*p*G(j) + 8*x*p.q*i*p*G(j);
Local F2 = 2*g_(1,i)*x + 6*g_(1,i)*x + 14*g_(1,i)*x;
Local F3 = 3*g_(p,q)*x + 6*g_(p,q)*x + 5*g_(p,q)*x;
Local F4 = 3*x^2*y^2 + 6*x*y^3 + 9*y^4;
.sort
Local C = content_(F);
Local C2 = content_(F2);
Local C3 = content_(F3);
Local C4 = content_(F4);
Global G5 = 3*x^2*y^2 + 6*x*y^3 + 9*y^4;
.sort
Print C, C2, C3, C4;
.store
Local D = content_(G5);
Print D;
.end
assert succeeded?
assert result("C") == "14*G(j)*p*i*p.q*x"
assert result("C2") == "22*g_(1,i)*x"
assert result("C3") == "14*g_(p,q)*x"
assert result("C4") == "3*y^2"
assert result("D") == "3*y^2"
*--#] cov_contentmerge :
*--#[ cov_contentmerge2 :
* content_ of dollar expressions: the factors of a $-expression are merged
* by ContentMerge (normal.c CONTENTTERM route), exercising its DOTPRODUCT,
* INDEX, VECTOR, DELTA/GAMMA and negative-power object cases
Symbols a,b,x,y;
Vectors p,q;
Indices i,j;
Functions G;
Local F = 2*x*p.q*i*p*G(j) + 4*x*p.q*i*p*G(j) + 8*x*p.q*i*p*G(j);
#$pd = (x*p.q*i*G(j))*(p.q)*(3+5*x);
#$pe = (g_(1,i)*x)*(g_(p,q))*(2+4*g_(1,i));
#$pf = (p*i*x)*(3+7*p*i);
#$pg = (x^-2)*(x^-2*y^-3+2);
#$ph = (p.q^-2)*(p.q^-2*x+2);
#$pi = (p.q*x^-2)*(2+3*p.q*x^-2);
#$pj = (p.q^-2*x)*(2+3*p.q^-2);
#$pk = (b)*(a^-2+3*b);
#$pl = (x^-2)*(p.q^-2*x^-2+2);
#$cd = content_($pd);
#$ce = content_($pe);
#$cf = content_($pf);
#$cg = content_($pg);
#$ch = content_($ph);
#$ci = content_($pi);
#$cj = content_($pk);
#$ck = content_($pj);
#$cl = content_($pl);
.sort
Local CA = $cd;
Local CB = $ce;
Local CC = $cf;
Local CD = $cg;
Local CE = $ch;
Local CF = $ci;
Local CI = $ck;
Local CJ = $cj;
Local CL = $cl;
Local CM = content_(F);
.sort
Print CA, CB, CC, CD, CE, CF, CI, CJ, CL, CM;
.end
assert succeeded?
assert result("CA") == "G(j)*i*p.q^2*x"
assert result("CB") == "2*g_(p,q)*x"
assert result("CC") == "p*i*x"
assert result("CD") == "x^-4*y^-3"
assert result("CE") == "p.q^-4"
assert result("CF") == "p.q*x^-4"
assert result("CI") == "p.q^-4*x"
assert result("CJ") == "a^-2*b"
assert result("CL") == "p.q^-2*x^-4"
assert result("CM") == "14*G(j)*p*i*p.q*x"
*--#] cov_contentmerge2 :
*--#[ cov_tracengen :
* tracen: recursion (6/8 gammas), n-4 dimension indices, repeated indices
* (TraceNgen in opera.c)
Symbols n;
Symbols [n-4];
Dimension n:[n-4];
Indices ind,m1,m2,m3,m4,m5,m6,m7,m8;
Local F = g_(1,m1,m2,m3,m4,m5,m6);
Local G = g_(1,m1,m2,m3,m4,m5,m6,m7,m8);
Local H = g_(ind,m1,m2,m1,m2);
Local I = g_(ind,m1,m2,m1,m2,m3,m4,m5,m6);
Local J = g_(ind,m1,m2,m3,m1,m2,m3,m4,m5);
Local K = g_(ind,m1,m2,m3,m4,m1,m2,m3,m4);
tracen,1;
tracen,ind;
.sort
* switch to a symbolic dimension without the [n-4] companion: indices
* declared from here on have no nmin4 (TraceNgen else-branches)
Dimension n;
Indices m11,m12,m13,m14,m15;
Local L = g_(1,m11,m12,m13,m11,m12,m13,m14,m15);
Local M = g_(1,m11,m12,m13,m14,m15,m11,m12,m13,m14,m15);
Local N = g_(1,m1,m2,m3,m4,m1);
Local O = g_(1,m1,m1,m2,m3);
tracen,1;
.sort
Local n1 = nterms_(F);
Local n2 = nterms_(G);
Local n3 = nterms_(H);
Local n4 = nterms_(I);
Local n5 = nterms_(J);
Local n6 = nterms_(K);
Local n7 = nterms_(L);
Local n8 = nterms_(M);
Local n9 = nterms_(N);
Local n10 = nterms_(O);
Print n1, n2, n3, n4, n5, n6, n7, n8, n9, n10;
.end
assert succeeded?
assert result("n1") == "15"
assert result("n2") == "105"
assert result("n3") == "2"
assert result("n4") == "6"
assert result("n5") == "3"
assert result("n6") == "4"
assert result("n7") == "3"
assert result("n8") == "5"
assert result("n9") == "0"
assert result("n10") == "1"
*--#] cov_tracengen :
*--#[ cov_bracketpow :
* powers of bracketed expressions (DoOnePow/FindBracket in proces.c/index.c)
Symbols x,y;
Local F = (x+y)*(x+y);
Bracket x;
.sort
Local G = F^2;
Print G;
.end
assert succeeded?
assert result("G") == "y^4+4*x*y^3+6*x^2*y^2+4*x^3*y+x^4"
*--#] cov_bracketpow :
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
*--#[ cov_polyratfun :
* PolyRatFun accumulation
Symbols x,y;
CFunction acc;
PolyRatFun acc;
Local PrFA = 3*x^2*acc(1+y+y^2,1-y) + 2*x^2*acc(1-y+y^2,1+y);
Print PrFA;
.end
* PolyRatFun with Denominators
Symbols a,x,y;
CFunction rat,den;
Local PrFB = 1/(x+y) + 1/(x-y^2);
.sort
PolyRatFun rat;
Denominators den;
id den(a?) = rat(1,a);
Print PrFB;
.end
* PolyRatFun reduction and default mode reset
Symbols x;
CFunction rat;
PolyRatFun rat;
Local PrFC = rat(x^2+1,x-1) + rat(x,x)/x;
Print PrFC;
.sort
PolyRatFun;
Local PrFD = rat(x,x);
Print PrFD;
.end
#pend_if mpi?
assert succeeded?
assert result("PrFA") =~ expr("x^2*acc(-y^3-10*y^2-2*y-5,y^2-1)")
assert nterms("PrFC") == 2
*--#] cov_polyratfun :
*--#[ cov_precondzoo :
* preprocessor dollar conditions and do-loop bounds
#$n = 7;
#if ( $( $n > 5 ) )
Local Q1 = 1;
#endif
#if ( $( $n < 3 ) )
Local Q2 = 1;
#endif
#if ( $( $n == 7 ) )
Local Q3 = 3;
#endif
#$k6 = 21;
#if ( $( $k6 / 3 == 7 ) )
Local Q4 = 2;
#endif
Print Q1,Q3,Q4;
.end
* #do loop with plain and dollar bounds
#$n = 3;
#do p3 = 1,3
Local T`p3' = `p3'+1;
Print T`p3';
.sort
#EndDo
Print T1,T2,T3;
.end
#$n = 3;
#do p4 = 1,`$n'
Local U`p4' = `p4'*2;
Print U`p4';
.sort
#EndDo
Print U1,U3;
.end
assert succeeded?
assert nterms("U3") == 1
*--#] cov_precondzoo :
*--#[ cov_bracketkeep :
* brackets with Keep Brackets across modules
Symbols x;
CFunction f;
Local B1 = f(x)*x^2 + f(x)*x^3;
bracket x;
.sort
Keep Brackets;
Print B1;
.sort
Local B2 = B1;
Print B2;
.end
assert succeeded?
*--#] cov_bracketkeep :
*--#[ cov_optimize :
* optimizer: Horner + CSE with #optimize and #clearoptimize
CFunction f;
Symbols a,b,c;
Local OpH = f(a)+f(b)+(a+b+c)^2;
Local OpG = f(c)+(a+b+c)^3;
Format O2;
Print +f;
.sort
ExtraSymbols,array,w;
#optimize OpG
#write "%O"
#clearoptimize
.sort
#optimize OpH
#write "%O"
.end
* Format Optimize options and mcts Horner
Symbols a,b,c,d;
CFunction f;
Local OpM = (a+b)^2*(c+d)^3 + f((a+b)*(c+d));
.sort
#optimize OpM
#write "%O"
#clearoptimize
.sort
Format Optimize horner=mcts,hornerdirection=backward;
.sort
#optimize OpM
#write "%O"
#clearoptimize
.sort
Format Optimize method=cse;
#optimize OpM
#write "%O"
#clearoptimize
.sort
Format Optimize method=csegreedy;
#optimize OpM
#write "%O"
#clearoptimize
.sort
Format Optimize method=greedy,horner=sa,hornerdirection=forwardandbackward;
#optimize OpM
#write "%O"
#clearoptimize
.end
#pend_if mpi?
assert succeeded?
*--#] cov_optimize :
*--#[ cov_precondmembers :
* $( ) special keywords set_ and multipleof_ inside #if
Symbols a,b,c,z;
Set s3: a,b;
#if $( b == set_(s3) )
Local Pk1 = 1;
#endif
#if $( z == set_(s3) )
Local Pk2 = 2;
#endif
#if $( z != set_(s3) )
Local Pk3 = 3;
#endif
#if $( 6 == multipleof_(2) )
Local Pk4 = 4;
#endif
#if $( 7 == multipleof_(3) )
Local Pk5 = 5;
#endif
Print Pk1,Pk3,Pk4;
.end
assert succeeded?
assert result("Pk1") =~ expr("1")
*--#] cov_precondmembers :

*--#[ cov_inside :
* #inside $var executes statements on the contents of a $ variable
CFunction f;
Local Inx1 = f(3);
.sort
$dd = f(3);
Print "%$",$dd;
.sort
#inside $dd
	Multiply 2;
#endinside
.sort
Local Inx2 = f($dd);
Print Inx2;
.end
#pend_if threaded?
assert succeeded?
assert result("Inx2") =~ expr("f(2*f(3))")
*--#] cov_inside :
*--#[ cov_termsinbracket :
* termsinbracket_() with Keep Brackets machinery
CFunction f,g;
Symbols x,y;
Local Te1 = (f(x)+f(y))*(g(x)+g(y)) + termsinbracket_();
Print;
.sort
Keep Brackets;
Brackets x;
.sort
id f(x?) = termsinbracket_(0)*f(x) + g(x);
Print;
.sort
Local Te2 = termsinbracket_() + x;
Print Te2;
.end
assert succeeded?
*--#] cov_termsinbracket :
*--#[ cov_polyratsave :
* Save/Load of expressions with PolyRatFun (storage round trip)
Off Statistics;
CFunction acc,accinv;
Symbols x,y;
PolyRatFun acc,accinv;
Global F1 = acc(1+x,1) + acc(x,1+2*x);
Print F1;
.sort
.store
Save cov_prf.dat F1;
.end
Off Statistics;
CFunction acc,accinv;
Symbols x,y;
PolyRatFun acc,accinv;
Load cov_prf.dat F1;
Local F5 = F1 + acc(1,x);
Print F5;
.sort
.end
assert succeeded?
assert result("F5") =~ expr("acc(2*x^3 + 4*x^2 + 3*x + 1,2*x^2 + x)")
*--#] cov_polyratsave :
*--#[ cov_idfun :
* id_() intrinsic: crossbreed of replace_ and id statements
CFunction f;
Symbols a,b,c,x,y,u,v,z;
Local Id1 = x^2*id_(x^2,y+z+1,y,u+v,x,z+u)*y*3;
Print Id1;
.sort
Local Id2 = id_(a,3,c,2)*f(a,c);
Print Id2;
.sort
.end
assert succeeded?
assert result("Id1") =~ expr("3*v + 3*v*z + 3*u + 3*u*z + 3*y*v + 3*y*u")
*--#] cov_idfun :
*--#[ cov_trace4 :
* 4-dimensional gamma traces with Trace4 (spin lines 1 and 2)
Vector p1,p2,p3,p4,p5;
Symbols x,e;
Local Tr1 = g_(1,p1,p2,p3,p4);
Local Tr2 = g_(1,p1,p2,p3,p4,p5);
Local Tr3 = g5_(1,p1,p2,p3,p4);
Local Tr4 = g5_(1,p1,p2,p3,p4,p5);
Local Tr5 = g5_(1,p1,p2,p3,p4,p5,p2,p3,p4,p1);
Local Tr6 = g_(1,p1,p2,p3,p4,p5,p2,p3,p4,p1);
Local Tr7 = gi_(1,p1,p2,p3);
Local Tr8 = g_(1,p1,p2,p3,p4)*g5_(2,p1,p2,p3,p4);
Trace4,1;
id p1.p2 = x;
id p1.p1 = 3;
id p2.p2 = 2;
id p3.p3 = 4;
id p4.p4 = 5;
id p5.p5 = 6;
Print;
.sort
Trace4,2;
id x = 7;
Print;
.sort
Trace4,notrick,1;
Trace4,nosymmetrize,1;
Trace4,trick,1;
Print Tr1;
.sort
.end
assert succeeded?
assert result("Tr1") =~ expr("-4*p1.p3*p2.p4 + 4*p1.p4*p2.p3 + 28*p3.p4")
assert result("Tr3") =~ expr("4*e_(p1,p2,p3,p4)")
assert result("Tr2") == "0"
*--#] cov_trace4 :
*--#[ cov_diagrams :
* Feynman diagram generation via diagrams_ (grcc engine), manual: diagrams.tex
Model QCD;
   Particle qua,QUA,  -2;
   Particle gho,GHO,  -1;
   Particle glu,      +3;
   Vertex QUA,qua,glu: g;
   Vertex GHO,gho,glu: g;
   Vertex glu,glu,glu: g;
   Vertex glu,glu,glu,glu: g^2;
EndModel;
Vector q1,q2,q3,q4,q5,q6,q7,q8;
Vector k1,k2,k3,k4,k5,k6,k7,k8;
Set ext : q1,q2,q3,q4,q5,q6,q7,q8;
Set int : k1,k2,k3,k4,k5,k6,k7,k8;
Local gluglu1 = diagrams_(QCD, {glu}, {glu}, int, ext, 1,
    `WithEdges_'+`OnShell_'+`NoTadpole_'+`NoSnail_');
Print gluglu1;
.sort
Local gg2 = diagrams_(QCD, {glu}, {glu}, int, ext, 2, 0);
Local gg2b = diagrams_(QCD, {glu}, {glu}, int, ext, 2,
    `WithBlocks_'+`WithOnePISets_'+`WithoutNodes_');
Local gg2t = diagrams_(QCD, {glu,glu}, {glu}, int, ext, 2, `TopologiesOnly_');
Local vac = diagrams_(QCD, {}, {}, int, ext, 2, `Floop_');
Print gg2;
.sort
Print gg2b;
.sort
Print gg2t;
.sort
Print vac;
.sort
.end
Model PHI3;
   Particle phi, +1;
   Vertex phi,phi,phi: g;
EndModel;
On GrccVerbose;
Vector q1,q2,k1,k2;
Set ext : q1,q2;
Set int : k1,k2;
Local t1 = diagrams_(PHI3, {phi}, {phi}, int, ext, 1, `TopologiesOnly_');
Local gg = diagrams_(PHI3, {phi}, {phi}, int, ext, g^2, 0);
Print t1;
.sort
Off GrccVerbose;
Print gg;
.sort
.end
assert succeeded?
assert nterms("gluglu1") == 3
assert nterms("gg2") == 127
assert nterms("gg2b") == 65
assert nterms("gg2t") == 217
assert nterms("vac") == 5
assert result("gluglu1") =~ /node_\(3,g,QUA\(-q1\),qua\(-q2\),glu\(k1\)/
assert result("vac") =~ /topo_/
assert nterms("t1") == 2
assert nterms("gg") == 2
assert result("t1") =~ /topo_\(2\)/
*--#] cov_diagrams :
*--#[ cov_modstmts :
* module-level statements: insidefirst, propercount, notinparallel, nhide,
* nfactorize (CoInsideFirst, CoProperCount, CoNotInParallel, CoNoHide,
* CoNFactorize + DoFactorize without-factor mode)
S x;
CFunction f;
InsideFirst off;
ProperCount off;
NotInParallel;
NHide;
Local F = f(x)^2;
id f(x?) = x^2;
id x^2 = 4;
Factorize F;
NFactorize F;
Print F;
.sort
S c;
Local G = (x+1)^5*c + x^3*c;
Factorize G;
NFactorize G;
Print "%t";
.sort
Print G;
.end
assert succeeded?
assert result("F") == "16"
*--#] cov_modstmts :
*--#[ cov_dolconv :
* dollar->long/index conversions: #do loop with dollar bound (DolToLong),
* trace with dollar spin line + index dollar (DolToIndex), sizeof/termsin
* preprocessor conditions on dollar variables
* dollar loop bounds force sequential modules -> pending under threads
#pend_if threaded?
S a; Vector p1,p2;
CFunction e;
Local w0 = 1;
$d = 2;
.sort
#do i = 1,$d
Local u`i' = e(a)^`i';
#enddo
Local T = g_(1,p1,p2);
$n = 1;
Trace4,$n;
.sort
Print +s T;
Print u1,u2;
.end
S x;
Local q = x;
$xs = 2*x+1;
.sort
#if ( sizeof($xs) > 2 && termsin($xs) == 2 )
Local q2 = 1;
#endif
Print q2;
.end
assert succeeded?
assert nterms("u1") == 1 && nterms("u2") == 1
assert result("u1") == "e(a)"
assert nterms("q2") == 1
*--#] cov_dolconv :
*--#[ cov_loadzoo :
* Save/Load round trip with >INFILEINDEX expressions (index buffer
* overflow -> SeekFile/ReadSaveIndex reload path), the silent-load
* option, and the illegal-option error path
Auto S x;
#do i = 1,15
Global g`i' = x^`i' + `i';
#enddo
.store
Save cov1a.dat;
.end
Load cov1a.dat;
Local T = g1+g5+g13;
.sort
Print T;
.end
Load,-s,cov1a.dat;
Local U = g2+g14;
.sort
Print U;
.end
Load,-x,cov1a.dat;
.end
assert nterms("T") == 4
assert result("T") =~ expr("19 + x + x^5 + x^13")
assert nterms("U") == 3
assert result("U") =~ /x\^14/
assert runtime_error?
assert stdout =~ /Illegal option in Load statement/
*--#] cov_loadzoo :
*--#[ cov_dolwild :
* wildcard-argument list capture ?ww$x (DOLWILDARGS dollars) plus
* termsin/sizeof preprocessor branches on wildargs and empty dollars
#pend_if threaded?
S a,b,c;
CFunction g,h;
Local E = g(a,b,c);
$z = 0;
id g(?ww$x) = h($x);
.sort
#if ( termsin($x) == 3 )
Local W3 = a;
#endif
#if ( sizeof($x) > 2 )
Local W2 = b;
#endif
#if ( termsin($z) == 0 )
Local Z1 = c;
#endif
Local E2 = g(5);
id g(?wv$x2) = h($x2);
.sort
#if ( termsin($x2) == 1 && sizeof($x2) >= 1 )
Local W1 = a;
#endif
Print E,E2,W3,W2,Z1,W1;
.end
assert nterms("W3") == 1 && nterms("W2") == 1 && nterms("Z1") == 1
assert nterms("W1") == 1
assert result("E2") == "h(5)"
assert nterms("E") == 1
*--#] cov_dolwild :
*--#[ cov_exprprop :
* re-declaration of existing expressions (Local/Global/Factorized
* property changes, DoExpr else branch) and the invalid-name error path
S x;
Local F = x^2;
LocalFactorized G = 2*(x+1)*(x+2);
.sort
Global F;
Local F;
GlobalFactorized G;
LocalFactorized G;
.sort
Print F,G;
.end
S x;
Local H = x;
.sort
Global Nosuch;
.end
assert nterms("F") == 1
assert result("F") == "x^2"
assert nterms("G") == 5
assert runtime_error?
assert stdout =~ /Nosuch is not a valid expression/
*--#] cov_exprprop :
*--#[ cov_bernoulli :
* builtin Bernoulli number function bernoulli_(n) (BERNOULLIFUNCTION
* normalisation path, reken.c Bernoulli())
Auto S x;
Local B = bernoulli_(0)+bernoulli_(1)+bernoulli_(2)+bernoulli_(6)-bernoulli_(7);
Print B;
.end
assert nterms("B") == 1
assert result("B") == "47881/30240"
*--#] cov_bernoulli :
*--#[ cov_polygcd :
* PolyRatFun with multi-term numerator and denominator (gcd via
* GCDfunction3 multi-term branch -> TakeSymbolContent/GCDclean) and
* products of PolyRatFun functions (MULfunc)
Symbol x,y;
CFunction rat;
PolyRatFun rat;
Local E = rat((x^2+3*x+2)*(x^3-1),(x^2+3*x+2)*(x^3+x^2));
Local Pr2 = rat((x^2+y^2)*(x^2-y^2),(x^2+y^2)*(x^4+x*y^2+x^2*y));
Local G = rat((x-y)*(x+y)^2,(x-y)*(x+y));
.sort
Print E,Pr2,G;
.end
assert result("E") == "rat(x^3-1,x^3+x^2)"
assert result("Pr2") == "rat(x^2-y^2,x^4+x^2*y+x*y^2)"
assert result("G") == "rat(x+y,1)"
*--#] cov_polygcd :
*--#[ cov_mescerr :
* illegal name in declaration statement (MesCerr)
Symbol 1x;
.end
assert compile_error?
assert stdout =~ /Illegal name/
*--#] cov_mescerr :
*--#[ cov_mescomp :
* illegal character in the Load expression list (MesComp)
S x;
Global g = x;
.store
Save m3.dat;
.end
Load m3.dat,g+2;
.end
assert runtime_error?
assert stdout =~ /Illegal character/
*--#] cov_mescomp :
*--#[ cov_mescomp2 :
* illegal character in the Save expression list (MesComp)
S x;
Global h = x;
.store
Save m2.dat,h+1;
.end
assert runtime_error?
assert stdout =~ /Illegal character/
*--#] cov_mescomp2 :
*--#[ cov_extcomm2 :
* #fromexternal into dollar and preprocessor variables with maxlength,
* from without listing, and the no-channel error path
#pend_if threaded?
Symbols x,a,b;
#external "n" cat -u
#toexternal "(a+b)^2\n\n"
#prompt
#fromexternal+ "$d2" 7
Local T = $d2;
#toexternal "(a+b)^3\n\n"
#fromexternal- "rsp"
#message rsp=`rsp'
#rmexternal `n'
Print T;
.end
assert result("T") == "b^2+2*a*b+a^2"
assert stdout =~ /rsp=\(a\+b\)\^3/
*--#] cov_extcomm2 :
*--#[ cov_extnochannel :
* #fromexternal with the external channel not set (DoFromExternal error path)
Symbols x;
#fromexternal "v"
.end
assert runtime_error?
assert stdout =~ /No current external channel/
*--#] cov_extnochannel :
*--#[ cov_dict :
* preprocessor dictionaries: #opendictionary/#add/#usedictionary + output
* (DoPreOpenDictionary/DoPreAddDictionary/WriteLists->WriteDictionary)
On names;
Symbols x1,mu,N;
CFunction f;
#OpenDictionary dic
  #add x1: "x_1"
  #add mu: "\mu"
  #add f: "\ln"
#CloseDictionary
Local F = x1*mu*f(x1)+N;
#usedictionary dic
Print +s;
.sort
Print F;
.end
assert succeeded?
assert nterms("F") == 2
assert stdout =~ /Contents of dictionary dic/
assert stdout =~ /x_1/
assert stdout =~ /\\ln/
*--#] cov_dict :
*--#[ cov_declmisc :
* NTensors/CTensors/NFunctions/Commuting/Indexes declarations, ProcessBucketSize,
* GFactorized and the NHide/NUnHide/NFactorize/NUnFactorize specification statements
NTensors t1,t2;
CTensors c1;
NFunctions nf1;
Commuting cf1;
Indexes i,j;
Symbols x,y;
ProcessBucketSize 100;
GFactorized GF = (x+1)*(x+2);
Local F = t1(i,j)*nf1(x)*cf1(y);
.sort
NHide GF;
NUnHide;
NFactorize GF;
NUnFactorize GF;
.sort
Print GF;
.end
assert succeeded?
assert nterms("F") == 1
assert result("GF") == "(1+x)*(2+x)"
*--#] cov_declmisc :
*--#[ cov_metric :
* the metric statement is inactive and only issues a message
Symbols x,y;
Metric m;
Local F = x+y;
.sort
Print F;
.end
assert compile_error? "does not do anything yet"
*--#] cov_metric :
*--#[ cov_cycsym :
* CycleSymmetrize and RCycleSymmetrize canonicalize function arguments
CFunction f,g,h;
Symbols x,y,z;
Local F = f(2,1)+f(1,2)+g(2,1)+g(1,2);
.sort
CycleSymmetrize f;
RCycleSymmetrize g;
Identify f(?a) = h(?a);
Identify g(?a) = h(?a);
.sort
Print F;
.end
assert succeeded?
assert result("F") == "4*h(1,2)"
*--#] cov_cycsym :
*--#[ cov_ifmatch :
* ifmatch/ifnomatch shorthand with labels and the IdNew/IdOld statements
#pend_if threaded?
Symbols x,y;
CFunction f,g;
Local F = f(x)+g(x)+f(1)+g(y);
.sort
ifmatch-> gotit f(x?$a) = f($a);
goto done;
Label gotit;
Label done;
IdNew f(?a) = f(?a);
IdOld g(?a) = g(?a);
.sort
Print F;
.end
assert succeeded?
assert result("F") == "f(x)+f(1)+g(x)+g(y)"
*--#] cov_ifmatch :
*--#[ cov_spectator :
* the full spectator cycle: CreateSpectator, ToSpectator, CopySpectator,
* EmptySpectator, RemoveSpectator
Symbols x,y;
CreateSpectator S1,"s1.spec";
Local F = x+y;
Local H = x*3;
.sort
Drop F;
ToSpectator S1;
.sort
CopySpectator NewE = S1;
.sort
EmptySpectator S1;
RemoveSpectator S1;
.sort
Print NewE;
.end
assert succeeded?
assert result("NewE") == "3*x"
*--#] cov_spectator :
*--#[ cov_globalmod :
* the .global module terminator keeps declarations alive across a .sort
Symbols x,y;
Local F = x+y;
.sort
Symbols z;
.global
Local G = z+F;
.sort
Print G;
.end
assert succeeded?
assert result("G") == "z+y+x"
*--#] cov_globalmod :
*--#[ cov_globalmod_err :
* non-global expressions are removed by a .store after .global
Symbols x,y;
Local F = x+y;
.global
.store
Symbols z;
Local G = z+F;
.end
assert compile_error? "Undeclared variable F"
*--#] cov_globalmod_err :
*--#[ cov_polyratexp :
* PolyRatFun with the expand option (relative)
Symbol x,ep;
CFunction rat;
PolyRatFun rat(expand,x,2,relative);
Local F = rat(x^3+1,x^5+x^2);
Print F;
.end
assert succeeded?
assert result("F") == "rat(x^-2)"
*--#] cov_polyratexp :
*--#[ cov_polyratexp2 :
* PolyRatFun with the expand option (fixed) including a power of a ratio
Symbol x,ep;
CFunction rat;
PolyRatFun rat(expand,x,2,fixed);
Local F = rat(x^3+1,x^5+x^2);
Local G = rat(x^2-1,x^4-1)^2;
Print F;
Print G;
.end
assert succeeded?
assert result("F") == "rat(x^-2)"
assert result("G") == "rat(1-2*x^2)"
*--#] cov_polyratexp2 :
*--#[ cov_polyratdiv :
* PolyRatFun with the finddivergence option
Symbol x,ep;
CFunction rat;
PolyRatFun rat(finddivergence,ep);
Local F = rat(x^3+1,x^5+x^2);
Print F;
.end
assert succeeded?
assert result("F") == "rat(1,1)"
*--#] cov_polyratdiv :
*--#[ cov_polyratexp_err :
* ExpandRat error path when the PolyRatFun is not expandable in the variable
Symbol x,ep;
CFunction rat;
PolyRatFun rat(expand,x,3,fixed);
Local F = rat(ep+x^2+x^3*ep^2, x+x^2*ep);
.sort
Print F;
.end
assert runtime_error? "incorrect variable inside"
*--#] cov_polyratexp_err :
*--#[ cov_abrackets :
* ABrackets with AntiPutInside and PutInside
Symbols x,y;
CFunction f,g;
Local F = f(x,y)*g(x,y)+f(y,x);
.sort
APutInside g,x;
PutInside g;
ABrackets f;
.sort
Print F;
.end
assert succeeded?
assert result("F") == "g(g(f(x,y)*g(x,y)))+g(g(f(y,x)))"
*--#] cov_abrackets :
*--#[ cov_polygcd3 :
* multiterm GCD inside PolyRatFun normalization (GCDfunction3)
Symbol x,ep;
CFunction rat;
PolyRatFun rat;
Local F = rat(x^2-1, x^3-1);
Local G = rat(x^2+2*x*ep+ep^2, x+ep);
Print F;
Print G;
.end
assert succeeded?
assert result("F") == "rat(x+1,x^2+x+1)"
assert result("G") == "rat(x+ep,1)"
*--#] cov_polygcd3 :
*--#[ cov_fmatchcy :
* pattern matching on cyclic functions (FunMatchCy): rotation machinery
CFunction f(cyclic),g;
Symbols n,m;
Local F = f(1,2,3)+f(4,5,6);
.sort
Identify f(n?,3,m?) = g(n,m);
Identify f(?a,3) = g(?a);
Identify f(?a,6) = g(?a);
.sort
Print F;
.end
assert succeeded?
assert result("F") == "g(2,1)+g(4,5)"
*--#] cov_fmatchcy :
*--#[ cov_fmatchcy2 :
* pattern matching on reverse-cyclic functions (FunMatchCy)
CFunction f(rcyclic),g;
Symbols n,m;
Local F = f(1,2,3)+f(4,5,6);
.sort
Identify f(n?,3,m?) = g(n,m);
Identify f(?a,3) = g(?a);
Identify f(?a,6) = g(?a);
.sort
Print F;
.end
assert succeeded?
assert result("F") == "g(1,2)+g(4,5)"
*--#] cov_fmatchcy2 :
*--#[ cov_fmatchsy :
* pattern matching on symmetric functions (FunMatchSy)
CFunction h(symmetric),k;
Symbols n,m;
Local G = h(1,2,3)+h(4,5,6);
.sort
Identify h(n?,3,m?) = k(n,m);
Identify h(1,n?,m?) = k(n,m);
.sort
Print G;
.end
assert succeeded?
assert result("G") == "h(4,5,6)+k(2,1)"
*--#] cov_fmatchsy :
*--#[ cov_select :
* Select statement with sets (SUBSELECT idoption; TestSelect in pattern.c)
* The substitution survives only on terms containing no element of the
* listed sets; terms with a set element are restored.
Symbols x,y,z,w,m,n;
Vectors p,q,r,p2;
Indices i,j,k2;
Tensor t1;
Functions f,g,f2,f3,f4,f5,f6,f7,f8,g2,f;
#$x = 5;
Set Ssym: x,y;
Set Svec: p,q;
Set Sidx: i,j;
Set Sfun: f,g;
Local F = x*z + w*z + p(i)*z + p.q*z + f(z)*w + g(z)*w;
.sort
Select Ssym, Svec, Sidx, Sfun, z = n;
.sort
Local G = w*p(i) + w*r(i) + w*p.q + w*d_(i,j) + w*f(z) + w*g_(1,i) + w*x
+ w*f2(z) + w*f3(p) + w*f4(-p) + w*f5(i) + w*f6(g2(z)) + w*f7(n)
+ w*r(k2) + w*r.p2 + w*f3(r) + w*f5(k2) + w*t1(-p) + w*t1(k2)
+ w*f7(g2) + w*f7($x) + w*i;
Select Ssym, Svec, Sidx, Sfun, w = m;
.sort
Print F;
Print G;
.end
assert succeeded?
assert result("F") =~ expr("m*n + x*z + p.q*z + p(i)*z + f(z)*w + g(z)*w")
assert result("G") =~ expr("x*w + p.q*w + r.p2*m + p(i)*w + r(i)*w + r(k2)*m + i*w + d_(i,j)*w - t1(p)*w + t1(k2)*m + g_(1,i)*w + f(z)*w + f2(z)*m + f3(p)*w + f3(r)*m + f4(-p)*w + f5(i)*w + f5(k2)*m + f6(g2(z))*m + f7(n)*m + f7(5)*m + f7(g2)*m")
*--#] cov_select :
*--#[ cov_polyfun :
* PolyFun statement: the polyfun argument is the coefficient of the term.
* Equal terms are merged by adding their polyfun arguments (AddArgs in
* sort.c) for all argument types: bare functions (commuting and not),
* symbols, short and long numbers, and with a modulus active.
Symbols x,y;
Function g2;
CFunction h2,acc;
PolyFun acc;
Local F1 = x^2*acc(g2) + x^2*acc(g2);
Local F2 = x^2*acc(g2) + x^2*acc(h2);
Local F2b = x^2*acc(h2) + x^2*acc(g2);
Local F3 = x^2*acc(g2) + x^2*acc(y);
Local F4 = x^2*acc(g2) + x^2*acc(3);
Local F5 = x^2*acc(y) + x^2*acc(g2);
Local F6 = x^2*acc(y) + x^2*acc(-3);
Local F6b = x^2*acc(-3) + x^2*acc(y);
Local F7 = x^2*acc(3) + x^2*acc(g2);
Local F8 = x^2*acc(3) + x^2*acc(-3);
Local F9 = x^2*acc(3) + x^2*acc(-5);
Local F11 = x^2*acc(g2) + x^2*acc(x^2);
Local F12 = x^2*acc(x^2) + x^2*acc(y);
Local F13 = x^2*acc(x^2) + x^2*acc(3);
Local F14 = x^2*acc(x^2) + x^2*acc(g2);
Local F15 = x^2*acc(1000000000) + x^2*acc(1000000000);
Local F17 = x^2*acc(-1000000000) + x^2*acc(-1000000000);
Local F18 = x^2*acc(2000000000) + x^2*acc(2000000000);
Local F19 = x^2*acc(-2000000000) + x^2*acc(-2000000000);
.sort
Print;
.sort
Modulus 1000000000000007;
Local FN = x^2*acc(2000000000) + x^2*acc(2000000000);
Print FN;
.end
assert succeeded?
assert result("F1") =~ expr("x^2*acc(2*g2)")
assert result("F2") =~ expr("x^2*acc(g2 + h2)")
assert result("F2b") =~ expr("x^2*acc(g2 + h2)")
assert result("F3") =~ expr("x^2*acc(y + g2)")
assert result("F4") =~ expr("x^2*acc(3 + g2)")
assert result("F5") =~ expr("x^2*acc(y + g2)")
assert result("F6") =~ expr("x^2*acc(-3 + y)")
assert result("F6b") =~ expr("x^2*acc(-3 + y)")
assert result("F7") =~ expr("x^2*acc(3 + g2)")
assert result("F8") == "0"
assert result("F9") =~ expr("x^2*acc(-2)")
assert result("F11") =~ expr("x^2*acc(x^2 + g2)")
assert result("F12") =~ expr("x^2*acc(y + x^2)")
assert result("F13") =~ expr("x^2*acc(3 + x^2)")
assert result("F14") =~ expr("x^2*acc(x^2 + g2)")
assert result("F15") =~ expr("x^2*acc(2000000000)")
assert result("F17") =~ expr("x^2*acc(-2000000000)")
assert result("F18") =~ expr("x^2*acc(4000000000)")
assert result("F19") =~ expr("x^2*acc(-4000000000)")
assert result("FN") =~ expr("x^2*acc(4000000000)")
*--#] cov_polyfun :
*--#[ cov_findall :
* Vector substitution, id <vector> = <vector>, and the simultaneous
* substitution of consecutive id/also statements (FindAll in pattern.c,
* the SUBVECTOR case of DoSubst/DoIfSubst). Vectors are replaced in
* indexed vector objects (p(i)), dot products (p.q, p.p) and chains of
* them; also-chains replace all chain members in a single pass.
Vectors p,q,r,s;
Indices i,j;
Symbols x;
Local A = p(i) + x*p.q;
id p = s;
Print A;
.sort
Local B = x*p.q + p.p;
id p = s;
Print B;
.sort
Local C = p(i)*p(j)*q(i);
id p = s;
Print C;
.sort
Local D = p(i)*q(j)*r(i);
id p = q;
Print D;
.sort
Local E = p.q + p(i);
id p = q;
also q = r;
Print E;
.sort
Local F = p(i)*q(j)*p(j);
id p = q;
also q = r;
Print F;
.end
assert succeeded?
assert result("A") =~ expr("q.s*x + s(i)")
assert result("B") =~ expr("q.s*x + s.s")
assert result("C") =~ expr("s(j)*q.s")
assert result("D") =~ expr("q(j)*q.r")
assert result("E") =~ expr("q.r + q(i)")
assert result("F") =~ expr("q(i)*q.r")
*--#] cov_findall :
*--#[ cov_tensdollar :
* Dollar variables in tensor-function arguments (InFunction in proces.c):
* a $-reference inside a tensor argument is stored as a FUNNYDOLLAR
* placeholder and replaced by the dollar's current value when the term is
* generated. The value can come from a wildcard binding: a number
* (DOLNUMBER), zero (DOLZERO) or a wildarg list (DOLWILDARGS). With
* Modulus and the alsofunctions option, function arguments are reduced
* modulo the modulus while the dollars are substituted.
Symbols x,a;
Indices i,j,k;
Tensor t1;
CFunction f,g;
Modulus 7, alsofunctions;
Local T1 = f(2)*g(0)*t1(i,j);
id f(x?$d1) = 1;
id g(x?$d2) = 1;
id t1(?a$d3) = 1;
$z = t1($d1,j);
$z0 = t1($d2,j);
$zw = t1($d3);
Print T1;
Print " z1=%$;", $z;
Print " z2=%$;", $z0;
Print " z3=%$;", $zw;
.end
# Under threads the $-assignments force sequential mode and the
# wildcard-bound dollars are captured per thread.
#pend_if threaded?
assert succeeded?
assert result("T1") =~ expr("1")
assert result("z1") =~ expr("t1(2,j)")
assert result("z2") =~ expr("0")
assert result("z3") =~ expr("t1(i,j)")
*--#] cov_tensdollar :
*--#[ cov_tensdollar2 :
* A dollar bound to a symbol has the wrong type for a tensor-function
* argument substitution: InFunction reports the error and the program
* terminates at run time.
Symbols x;
Indices i,j;
Tensor t1;
CFunction f;
Local T = f(x);
id f(x?$d4) = 1;
$z = t1($d4,j);
.end
# Under threads the $-assignments force sequential mode and the
# wildcard-bound dollars are captured per thread.
#pend_if threaded?
assert runtime_error?
*--#] cov_tensdollar2 :
*--#[ cov_tensdollar3 :
* A wildcard-bound dollar that never got a value is undefined in a tensor
* substitution (InFunction reports the error and the program terminates).
Symbols x;
Indices i,j;
Tensor t1;
CFunction f;
Local T = t1(i,j);
id f(x?$d5) = 1;
$z = t1($d5,j);
.end
# Under threads the $-assignments force sequential mode and the
# wildcard-bound dollars are captured per thread.
#pend_if threaded?
assert runtime_error?
*--#] cov_tensdollar3 :

*--#[ cov_reset :
* The .store module terminator: saves the state, globalizes all
* declarations and then empties the memory (PopVariables -> ResetVariables
* in names.c) so that the following modules start from scratch.
Symbols a;
Vectors v;
Indices i;
CFunction f;
Table,sparse t(1);
AutoDeclare Symbol az;
Set vecs: v;
Fill t(1) = 5;
Local E = t(1) + f(a) + v(i) + az;
.sort
Print E;
.store
Symbols b;
CFunction g;
Local G = g(b);
.sort
Print G;
* The .clear terminator frees everything, including tables (ResetVariables
* with par = 2 in names.c).
.clear
.end
assert succeeded?
assert result("E") =~ expr("5 + az + v(i) + f(a)")
assert result("G") =~ expr("g(b)")
*--#] cov_reset :
*--#[ cov_rootsunity :
* Roots of unity (Symbols w#3, w2#-4) and their normalization in
* Normalize (normal.c): powers are reduced modulo the root order, and
* for an even order (w2#-4) half the order evaluates to -1. The sig_
* numerical function of a root of unity contributes the root itself to
* the term's symbol-power table.
Symbols w#3,w2#-4,x;
Local N1 = w^4;
Local N2 = w^-1;
Local N3 = w2^2;
Local N4 = w2^6;
Local F = sig_(w)*x;
Local G = sig_(w)*sig_(w);
Local H = sig_(w*w2);
Local I = sig_(w^2);
Local J = sig_(x+w);
Local K = sig_(w2)*sig_(w2);
Local P3 = sig_(w)^3;
Print N1, N2, N3, N4, F, G, H, I, J, K, P3;
.end
assert succeeded?
assert result("N1") =~ expr("w")
assert result("N2") =~ expr("w^2")
assert result("N3") =~ expr("-1")
assert result("N4") =~ expr("-1")
assert result("F") =~ expr("w*x")
assert result("G") =~ expr("w^2")
assert result("H") =~ expr("w*w2")
assert result("I") =~ expr("w^2")
assert result("J") =~ expr("sig_(x + w)")
assert result("K") =~ expr("-1")
assert result("P3") =~ expr("1")
*--#] cov_rootsunity :
*--#[ cov_modfunc :
* The mod_ and mod2_ numerical functions in Normalize (normal.c):
* short/short arguments, a single argument, and long-number arguments
* with a short or a long modulus.
Symbols x;
Local Q1 = mod_(5,3);
Local Q2 = mod2_(5,3);
Local Q3 = mod_(2,3);
Local Q4 = mod2_(2,3);
Local Q5 = mod_(-2,3);
Local Q6 = mod2_(-2,3);
Local Q7 = mod_(0,3);
Local Q8 = mod_(5);
Local Q9 = mod_(0);
Local Q10 = mod_(21474836470,3);
Local Q11 = mod2_(21474836470,3);
Local Q12 = mod_(-21474836470,3);
Local Q13 = mod2_(-21474836470,3);
Local R1 = mod_(5,21474836470);
Local R2 = mod2_(5,21474836470);
Local R5 = mod_(123456789012345,21474836470);
Local R6 = mod2_(-5,21474836470);
Local R9 = mod2_(21474836469,21474836470);
Print Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13;
Print R1, R2, R5, R6, R9;
.end
assert succeeded?
assert result("Q1") =~ expr("2")
assert result("Q2") =~ expr("-1")
assert result("Q3") =~ expr("2")
assert result("Q4") =~ expr("-1")
assert result("Q5") =~ expr("1")
assert result("Q6") =~ expr("1")
assert result("Q7") =~ expr("0")
assert result("Q8") =~ expr("5")
assert result("Q9") =~ expr("0")
assert result("Q10") =~ expr("1")
assert result("Q11") =~ expr("1")
assert result("Q12") =~ expr("2")
assert result("Q13") =~ expr("-1")
assert result("R1") =~ expr("5")
assert result("R2") =~ expr("5")
assert result("R5") =~ expr("19428982785")
assert result("R6") =~ expr("-5")
assert result("R9") =~ expr("-1")
*--#] cov_modfunc :
*--#[ cov_makerational :
* makerational_(a,m) finds a fraction f1/f2, both less than sqrt(m),
* with f1/f2 = a mod m (manual: reconstruct fractions after modular
* calculus). Under the modulus the fraction reproduces a; degenerate
* calls go through the general MakeLongRational path in Normalize
* (normal.c). The dollar keeps the unreduced fraction.
#$m = prime_(1);
Local P4 = makerational_(12345678,$m);
Local A = makerational_(2,3)*makerational_(5,7);
$r = makerational_(12345678,$m);
Print P4;
.sort
Modulus `$m';
Print P4, A;
Print " r=%$;", $r;
.end
# Under threads the $ assignments force sequential mode.
#pend_if threaded?
assert succeeded?
assert result("P4") =~ expr("12345678")
assert result("A") =~ expr("2147483586")
assert result("r") =~ expr("9719/38790")
*--#] cov_makerational :
*--#[ cov_wildsub :
* WildFill (wildcard.c) on the replacement of argument wildcards: when
* a wildcard bound to a symbol or subexpression is used as the power of
* a dot product in the replacement, an EXPONENT function is built with
* the bound value inside.
Symbol a,x,y;
Vector p,q,r,s,t;
CFunction f,h;
Local T1 = f(x);
Local T2 = f(p.q);
Local T3 = f(q.s*r.t);
Local T4 = f(x,p.q);
Print T1, T2, T3, T4;
.sort
id f(a?) = h(1)*(p.q^a);
Print T1, T2, T3, T4;
.sort
id f(a?,p?.q?) = h(3)*(p.q^a);
Print T1, T2, T3, T4;
.end
assert succeeded?
assert result("T1") =~ expr("(p.q)^(x)*h(1)")
assert result("T2") =~ expr("(p.q)^(p.q)*h(1)")
assert result("T3") =~ expr("(p.q)^(q.s*r.t)*h(1)")
assert result("T4") =~ expr("(p.q)^(x)*h(3)")
*--#] cov_wildsub :
*--#[ cov_cycargwild :
* Cyclic functions with multiple argument-list wildcards (FunMatchCy
* Case 3): splitting the arguments between ?a and ?b, and the repeated
* name multiplicity machinery of ?a ?a.  Both occurrences of ?a must
* match the same argument list, so f(1,1,1) and f(1,1,2) do not match
* in the ?a ?a module (the later f(x?,?a,?b) rule does match them).
CFunction f(cyclic),g,h;
Tensor t(cyclic);
Symbols x;
Local A = f(1,2,3);
Local B = f(1,2,3,4);
.sort
id f(?a,?b) = g(?a)*h(?b);
.sort
Local C = f(1,1);
Local D = f(1,1,1);
Local E = f(1,1,2);
.sort
id f(?a,?a) = h(?a);
.sort
Local F = f(1,x,2,3);
Local G = t(1,1);
.sort
id f(x?,?a,?b) = g(?a)*h(?b);
id t(?a,?a) = g(2);
.sort
Print A, B, C, D, E, F, G;
.end
assert succeeded?
assert result("A") =~ expr("g*h(1,2,3)")
assert result("B") =~ expr("g*h(1,2,3,4)")
assert result("C") =~ expr("h(1)")
assert result("D") =~ expr("g*h(1,1)")
assert result("E") =~ expr("g*h(1,1)")
assert result("F") =~ expr("g*h(1,x,2)")
assert result("G") =~ expr("g(2)")
*--#] cov_cycargwild :
*--#[ cov_ifdolindex :
* Runtime if-statement with a DOLINDEX dollar (a dollar assigned an
* index).  DoIfStatement rejects such dollars because their index
* number is always >= AM.OffsetIndex, giving "$... is of wrong type".
Indices i;
Symbols s;
Local T = s;
$d = i;
$e = 0;
.sort
if ( $d > 0 ) $e = 1;
Print " e=%$;", $e;
.end
assert runtime_error?
*--#] cov_ifdolindex :
*--#[ cov_ifdolwildargs :
* Runtime if-statement with a dollar bound to an argument wildcard
* (?a$d, type DOLWILDARGS).  Such bindings always start with a zero
* count word, which DoIfStatement cannot compare numerically: the
* DOLWILDARGS check passes and the DOLARGUMENT case reports
* "$... is of wrong type".
CFunction f,g,h;
Symbols s;
Local T = f(2,3);
$e = 0;
.sort
id f(?a$d) = h(?a);
if ( $d == 2 ) $e = 1;
Print " e=%$;", $e;
.end
assert runtime_error?
*--#] cov_ifdolwildargs :
*--#[ cov_bracketindex :
* Bracket index lookups that fall between two indexed brackets force
* FindBracket to scan the stored terms forward (index.c 188-266).
* The bracket w does not occur in F, so the result is zero.
Symbols a,b,c,w,x;
Local F = a*x^2+b*x+c;
B+ x;
.sort
Local D = F[w]*F[x];
Print D;
.end
assert succeeded?
assert result("D") == "0"
*--#] cov_bracketindex :
*--#[ cov_bracketindex_nocompress :
* Same as cov_bracketindex, but with Compress off the stored terms are
* uncompressed, so FindBracket scans take the no-compression branches.
Symbols a,b,c,w,x;
Compress off;
Local F = a*x^2+b*x+c;
B+ x;
.sort
Local D = F[w]*F[x];
Print D;
.end
assert succeeded?
assert result("D") == "0"
*--#] cov_bracketindex_nocompress :
*--#[ cov_oncevecwild :
* once-statement patterns with a vector wildcard inside a dotproduct
* (p.q?): FindOnce walks the dotproduct lists and binds the wildcard
* vector to the term's second vector. The second pattern has two
* dotproducts and matches nothing; it exercises the failure paths.
Vectors a,b,p,q,r;
Symbols y;
Local T = p.q + p.p + q.q;
.sort
once p.q? = 2*y;
once p.q?*a.b = 2*y;
Print T;
.end
assert succeeded?
assert result("T") =~ expr("4*y + q.q")
*--#] cov_oncevecwild :
*--#[ cov_tablebase_use :
* tablebase cycle with named load/use: the load and use statements take
* a table name, and a second use statement finds the elements already
* loaded (ELEMENTLOADED path in CoTBuse).
CTable,sparse f(1);
#do i = 1,10
	Fill f(`i') = `i';
#enddo
.sort
TableBase "test4.tbl" create;
TableBase "test4.tbl" addto f;
.end
TableBase "test4.tbl" open;
Tablebase "test4.tbl" load f;
.sort
Local test = f(3)*f(20);
TestUse f;
.sort
TableBase "test4.tbl" use f;
TableBase "test4.tbl" use f;
Apply;
Print;
.end
#pend_if mpi?
assert succeeded?
assert result("test") =~ expr("3*f(20)")
*--#] cov_tablebase_use :
*--#[ cov_tablebase_useerr :
* error path of the tablebase use statement: no open tablebase
TableBase "nouse.tbl" use;
.end
#pend_if mpi?
assert compile_error?('No open tablebase with the name nouse.tbl')
*--#] cov_tablebase_useerr :
*--#[ cov_tablebase_useerr2 :
* error path of the tablebase use statement: argument is not a table
CTable,sparse g(1);
Fill g(1) = 5;
.sort
TableBase "test5.tbl" create;
TableBase "test5.tbl" addto g;
Symbol z;
TableBase "test5.tbl" use z;
.end
#pend_if mpi?
assert compile_error?('z should be a previously declared table')
*--#] cov_tablebase_useerr2 :
*--#[ cov_tablebase_useerr3 :
* error path of the tablebase use statement: table is not sparse
CTable,sparse g(1);
Fill g(1) = 5;
.sort
TableBase "test7.tbl" create;
TableBase "test7.tbl" addto g;
Table n(2);
TableBase "test7.tbl" use n;
.end
#pend_if mpi?
assert compile_error?('n should be a sparse table')
*--#] cov_tablebase_useerr3 :
*--#[ cov_tablebase_noload :
* using a tablebase table that has not been loaded (FindTableTree fails)
CTable,sparse f(1);
Fill f(1) = 5;
.sort
TableBase "test6.tbl" create;
TableBase "test6.tbl" addto f;
.end
TableBase "test6.tbl" open;
TableBase "test6.tbl" use f;
.end
#pend_if mpi?
assert runtime_error?('has not been loaded properly')
*--#] cov_tablebase_noload :

*---[ Saturation campaign batch: transforms, stuffle, preprocessor ]---

*--#[ cov_stuffle_root :
* Stuffle merge on products of root-of-unity symbols (Symbol w#n)
Symbol w1#3, w2#5, w3#-3;
CFunction z;
Local F1 = z(w1)*z(w2);
Local F2 = z(1,2)*z(w1);
Local F3 = z(w1/2)*z(2);
Local F4 = z(w1)*z(w3)*z(2);
Stuffle z+;
Print;
.end
assert succeeded?
assert result("F1") =~ expr("z(2*w1*w2)+z(w1,w2)+z(w2,w1)")
assert result("F2") =~ expr("z(2*w1,2)+z(w1,1,2)+z(1,3*w1)+z(1,w1,2)+z(1,2,w1)")
assert result("F3") =~ expr("z(2)*z(1/2*w1)")
assert nterms("F4") == 13
*--#] cov_stuffle_root :

*--#[ cov_transform_specs :
* transform statement on a tensor with a mix of index/vector/number args
Index mu,nu;
Vector p;
Tensor t;
Local test = t(mu,nu,p,3,5);
Transform t encode(1,last):base=10;
Transform t decode(1,last):base=10;
Transform t replace(1,last)=(3,4);
Transform t implode(1,last);
Transform t explode(1,last);
Transform t permute(1,3);
Transform t reverse(1,last);
Transform t dedup(1,last);
Transform t cycle(2,4)=+1;
Print;
.end
assert result("test") =~ expr("t(5,nu,4,mu,p)")
*--#] cov_transform_specs :

*--#[ cov_transform_rangefar :
* transform ranges pointing beyond the available arguments
CFunction f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11;
Symbol x;
Local test = f1(1,2)+f2(1,2)+f3(1,2)+f4(1,2)+f5(1,x)+f6(1,2)
 +f7(1,2)+f8(1,x,2)+f9(1,2)+f10(1,x)+f11(1,x);
Transform f1 encode(3,7):base=10;
Transform f2 decode(3,7):base=10;
Transform f3 implode(3,7);
Transform f4 explode(3,7);
Transform f5 replace(3,7)=(xarg_,0);
Transform f6 permute(3,4,5);
Transform f7 reverse(3,7);
Transform f8 dedup(3,7);
Transform f9 cycle(3,7)=+1;
Transform f10 addargs(3,7);
Transform f11 mulargs(3,7);
Print;
.end
assert result("test") =~
 expr("f1(1,2)+f2(1,2)+f3(1,2)+f4(1,2)+f5(1,x)+f6(1,2)+f7(1,2)+f8(1,x,2)+f9(1,2)+f10(1,x)+f11(1,x)")
*--#] cov_transform_rangefar :

*--#[ cov_transform_replace :
* replace with xarg_ wildcards, pairs of arguments and multi-pair lists
CFunction f1,f2,f3;
Symbol a,b,x,y;
Local test = f1(1,y+2) + f2(2,3,a) + f3(3,x);
Transform f1 replace(1,last)=(xarg_,2*xarg_+1);
Transform f2 replace(1,last)=(2,y,3,x);
Transform f3 replace(1,2)=(3,4,xarg_,0);
Print;
.end
assert result("test") =~ expr("f1(3,5+2*y)+f2(y,x,a)+f3(4,0)")
*--#] cov_transform_replace :

*--#[ cov_transform_bigout :
* encode results that do not fit in one word; negative and zero digits
CFunction f1,f2,f3,f4;
Local test = f1(8,8,8,8) + f2(-1,2) + f3(0,1,1)
 + f4(0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
 ,1,1,1,1,1,1,1,1,1,1);
Transform f1 encode(1,last):base=8191;
Transform f2 encode(1,last):base=10;
Transform f3 encode(1,last):base=10;
Transform f4 encode(1,last):base=2;
Print;
.end
assert result("test") =~
 expr("f1(4396972900352)+f2(8)+f3(11)+f4(35184372088831)")
*--#] cov_transform_bigout :

*--#[ cov_transform_dollarbase :
* encode/decode with a dollar-valued base ($ assigned in the same module)
#pend_if threaded?
CFunction f1,f2,f3;
Local test = f1(1,2,1,0,1) + f2(1,2,1,0,1) + f3(13);
$b = 3;
Transform f1 encode(1,last):base=$b;
Transform f2 decode(1,5):base=$b;
Transform f3 decode(1,5):base=$b;
Print;
.end
assert result("test") =~
 expr("f1(145)+f2(0,0,0,0,1,2,1,0,1)+f3(0,0,1,1,1)")
*--#] cov_transform_dollarbase :

*--#[ cov_dollarbase_err :
* encode with a dollar base that has no acceptable number value
#pend_if threaded?
CFunction f;
Local test = f(1,2,1);
$b = 1;
Transform f encode(1,last):base=$b;
Print;
.end
assert runtime_error?('does not have a number value > 1')
*--#] cov_dollarbase_err :

*--#[ cov_transform_single :
* transform on single-element and tight ranges
CFunction f1,f2,f3,f4;
Local test = f1(7) + f2(2,7,9) + f3(13) + f4(1,2,3,4);
Transform f1 encode(1,1):base=10;
Transform f2 encode(2,2):base=10;
Transform f3 decode(1,1):base=10;
Transform f4 reverse(2,3);
Print;
.end
assert result("test") =~
 expr("f1(7)+f2(2,7,9)+f3(13)+f4(1,3,2,4)")
*--#] cov_transform_single :

*--#[ cov_argstage :
* ArgImplode/SplitArg with ranges and zero arguments
CFunction f1,f2;
Symbol x,y;
Local test = f1(<x^5>,...,<x^1>) + f2(1,0,1,0);
ArgImplode f2;
SplitArg f1;
Print;
.end
assert result("test") =~ expr("f1(x^5,x^4,x^3,x^2,x)+f2(1,2,0)")
*--#] cov_argstage :

*--#[ cov_setextattr :
* preprocessor statement for external command attributes
#setexternalattr shell=noshell,kill=9,killall=false
Symbol x;
Local E = x;
Print;
.end
assert succeeded?
assert result("E") =~ expr("x")
*--#] cov_setextattr :

*--#[ cov_pifarith :
* a parenthesised multiplication inside #if is rejected by the preprocessor
Symbol x;
#if ( ( (2+3)*(4-1) ) == 15 )
Local E = x;
#endif
Local test = x;
Print;
.end
assert preprocess_error?('illegal operator')
*--#] cov_pifarith :

*--#[ cov_pifarith_false :
* simple arithmetic #if conditions evaluate silently to false
Symbol x;
#if ( ( 3*4+2 - 4 ) == 10 )
Local E1 = x;
#endif
#if ( ( -7 + 2 ) == -5 )
Local E2 = x;
#endif
Local test = E1+E2;
Print;
.end
assert compile_error?('Undeclared variable E1')
*--#] cov_pifarith_false :

*--#[ cov_replace_bad :
* replace pair list with a dangling comma
CFunction f;
Symbol a;
Local test = f(1,2);
Transform f replace(1,last)=(3,);
Print;
.end
assert compile_error?('Illegal position for closing parenthesis')
*--#] cov_replace_bad :

*--#[ cov_transform_badopt :
* unknown transformation name inside a Transform statement
CFunction f;
Local test = f(1,2);
Transform f bogusopt(1,last);
Print;
.end
assert compile_error?('Unknown transformation inside a Transform statement')
*--#] cov_transform_badopt :

*--#[ cov_transform_lyndonerr :
* islyndon does not accept a range without an = list
CFunction f;
Symbol y;
Local test = f(1,2,3);
Transform f islyndon(1,last);
Print;
.end
assert compile_error?('should be followed by')
*--#] cov_transform_lyndonerr :

*--#[ cov_tensor_adderr :
* addargs on a tensor is illegal
Index mu;
Tensor t;
Local test = t(mu,1,2);
Transform t addargs(1,last);
Print;
.end
assert runtime_error?('Illegal attempt to add arguments of a tensor')
*--#] cov_tensor_adderr :

*--#[ cov_tensor_mulerr :
* mulargs on a tensor is illegal
Index mu;
Tensor t;
Local test = t(mu,1,2);
Transform t mulargs(1,last);
Print;
.end
assert runtime_error?('Illegal attempt to multiply arguments of a tensor')
*--#] cov_tensor_mulerr :

*--#[ cov_replace_nopairs :
* replace without an = pair list
CFunction f;
Local test = f(1,2);
Transform f replace(1,last);
Print;
.end
assert compile_error?('should be followed by an = sign')
*--#] cov_replace_nopairs :

*--#[ cov_transform_baseone :
* encode/decode base must be at least two
CFunction f;
Local test = f(1,2);
Transform f encode(1,last):base=1;
Print;
.end
assert compile_error?('Illegal value for base')
*--#] cov_transform_baseone :

*---[ Saturation campaign batch 2: LLM-authored probes (wildcards, brackets, #write) ]---

*--#[ cov_wildargtomatch :
* ?a wildcards comparing whole argument lists between two functions
CFunction f,g,h;
Symbol x,y,z;
Local t = f(g(x),g(x)) + f(g(x),g(y)) + f(h(x,y),h(x,y)) + f(h(x,y),h(x,z))
 + f(h(x),h(x,y));
id f(g(?a),g(?a)) = 1;
id f(h(?a),h(?a)) = 1;
Print;
.end
assert result("t") =~
 expr("2+f(g(x),g(y))+f(h(x),h(x,y))+f(h(x,y),h(x,z))")
*--#] cov_wildargtomatch :

*--#[ cov_bracketsetvec :
* Bracket with a set of vectors
Vector v,p;
CFunction f;
Set vs: v, p;
Local e = v(1)*f(2);
Bracket vs;
Print;
.end
assert succeeded?
*--#] cov_bracketsetvec :

*--#[ cov_wildsetnum :
* Set statement referencing not-yet-declared names
Set even: 2,4,6;
Set sb: a,b;
Symbol x,y,a,b;
CFunction f,g;
Local t = f(2,4) + f(2,3);
id f(x?even_,x?even_) = 1;
Print +s;
.end
assert compile_error?('has not been declared')
*--#] cov_wildsetnum :

*--#[ cov_bracketdeltaerr :
* Bracket on the delta function g_ is illegal
CFunction f;
Local e = g_(1,2)*f(3);
Bracket g_(1,2);
Print;
.end
assert compile_error?('Illegal separator: Bracket')
*--#] cov_bracketdeltaerr :

*--#[ cov_wildbracerr :
* id on an undeclared function
Symbol a,x;
Local F = (a+1)*f((a+1)^2);
Keep Brackets;
id f(?a) = g(?a);
Print +s;
.end
assert compile_error?('Undeclared variable')
*--#] cov_wildbracerr :

*--#[ cov_wildbrac :
* wildcard id applied while brackets are kept
Symbol a,x;
CFunction f,g;
Keep Brackets;
Local F = (a+1)*f((a+1)^2);
id f(?a) = g(?a);
Print +s;
.end
assert succeeded?
*--#] cov_wildbrac :

*--#[ cov_wch_width :
* #write number formats with explicit field widths
Symbol x;
Local e = x;
#write "n=%5d, k=%12d end\n" 42 7
#write "m=%1d end\n" 9
Print;
.end
assert succeeded?
assert result("e") =~ expr("x")
*--#] cov_wch_width :

*--#[ cov_wch_plusnum :
* the - flag is not a legal #write format modifier
Symbol x;
Local e = x;
#write "n=%-4d end\n" 7
Print;
.end
assert preprocess_error?('Illegal control sequence')
*--#] cov_wch_plusnum :

*--#[ cov_wch_dollar :
* #write of a preprocessor dollar value
#$s = 123456789012345;
#write "val=%$ end\n" $s
Symbol x;
Local e = x;
Print;
.end
assert succeeded?
assert result("e") =~ expr("x")
*--#] cov_wch_dollar :

*--#[ cov_wch_undol :
* #write %$ of an undefined dollar
#write "a=%$ end\n" $nosuchdollar1
Symbol x;
Local e = x;
Print;
.end
assert preprocess_error?('has not been defined')
*--#] cov_wch_undol :

*--#[ cov_wch_dolerr :
* #write %$ with a non-dollar argument
#write "a=%$ end\n" 5
Symbol x;
Local e = x;
Print;
.end
assert preprocess_error?('$-variable expected')
*--#] cov_wch_dolerr :

*--#[ cov_wch_noclose :
* unterminated #write format string
#write "unterminated format string
Symbol x;
Local e = x;
Print;
.end
assert warning?('end instruction generated')
*--#] cov_wch_noclose :

*--#[ cov_wch_illch :
* illegal characters after a $-variable in #write
Symbol x;
#$s = 3;
#write "a=%$ end\n" $s+
Local e = x;
Print;
.end
assert preprocess_error?('illegal characters after $-variable')
*--#] cov_wch_illch :

*--#[ cov_funcncerr :
* illegal symmetry specification in a Functions declaration
Functions f,g,nc(nocom);
Symbol x;
Local t = f(x)*g(x);
Print;
.end
assert compile_error?('Illegal specification for symme')
*--#] cov_funcncerr :

*--#[ cov_polyraterr :
* PolyRatFun on a function that is not a regular commutative function
Symbols x;
PolyRatFun rat;
Local t = rat(x^2+1,x^3-2);
Print +s;
.end
assert compile_error?('should be a regular commuting')
*--#] cov_polyraterr :

*--#[ cov_dotseterr :
* dot product with an illegal second element
Vector p,q;
CFunction f;
Local e = p.f(3);
Print;
.end
assert compile_error?('Illegal second element in dotpr')
*--#] cov_dotseterr :

*--#[ cov_onfortran :
* On fortran after statement code in the same module
Symbol x;
Local e = x;
On fortran;
Print;
.end
assert compile_error?('Declaration out of order')
*--#] cov_onfortran :

*---[ Saturation campaign batch 3: FactArg and if/match statement paths ]---

*--#[ cov_factarg_num :
* FactArg on argument 1 of a function
Symbol x,y;
Function f;
Local test = f((x+y)^2,(x-y)^2);
FactArg 1,f;
Print;
.end
assert succeeded?
assert result("test") =~ expr("f(y+x,y+x,y-x,y-x)")
*--#] cov_factarg_num :

*--#[ cov_factarg_delta :
* FactArg moving a delta factor out of function arguments
Symbol x,y;
Vector p,q;
Function f;
Local test = f(x*d_(p,q) + y*d_(p,q));
FactArg f;
Print;
.end
assert succeeded?
assert result("test") =~ expr("f(y+x,p.q)")
*--#] cov_factarg_delta :

*--#[ cov_factarg_idx :
* FactArg on function arguments carrying indices terminates
Symbol x,y;
Index i,j;
Function f;
Local test = f(x*i + y*i);
FactArg f;
Print;
.end
assert runtime_error?
*--#] cov_factarg_idx :

*--#[ cov_factarg_negpow :
* FactArg combining negative powers inside function arguments
Symbol x,y;
Function f;
Local test = f(1/x + 2/x);
FactArg f;
Print;
.end
assert succeeded?
assert result("test") =~ expr("f(3,x^-1)")
*--#] cov_factarg_negpow :

*--#[ cov_factarg_tensor :
* FactArg moving tensor elements out of function arguments
Symbol x,y;
Index i;
Tensor t1;
Function f;
Local test = f(t1(i)*x + t1(i)*y);
FactArg f;
Print;
.end
assert succeeded?
assert result("test") =~ expr("f(y+x,t1(i))")
*--#] cov_factarg_tensor :

*--#[ cov_ifdivnum :
* integer division in an if condition evaluates to 1
Local a = 0;
if ( 3/2 ) id x = 1;
Print a, x;
.end
assert runtime_error?('is not the name of an active expression')
*--#] cov_ifdivnum :

*--#[ cov_matchcond_undec :
* match() inside if with an undeclared variable
CFunction f;
Local t = f(x);
if ( match(f(x?)) > 0 ) id x = 2;
Print t;
.end
assert compile_error?('Undeclared variable')
*--#] cov_matchcond_undec :

*--#[ cov_barelse :
* else statement with undeclared variable in the condition
Local t = 5;
if ( count(x,1) > 0 ) id x = 1;
else id t = 2;
endif;
Print t;
.end
assert compile_error?('No extra text allowed')
*--#] cov_barelse :

*--#[ cov_factdollar_err :
* Factorize on a dollar variable is illegal
Symbol a,b;
Factorize $f1;
$f1 = (a+b)*(a+c);
.sort
Print $f1;
.end
assert compile_error?('Illegal object in (N)Factorize statement')
*--#] cov_factdollar_err :

*--#[ cov_lowfirst_modfact :
* unrecognized LowFirst statement plus large modulus with Factorize
Symbol a,b;
LowFirst;
Modulus 10000000000000;
Factorize $m2;
$m2 = (a+b)^2;
.sort
Print $m2;
.end
assert compile_error?('Unrecognized statement LowFirst')
assert compile_error?('Illegal object in (N)Factorize statement')
*--#] cov_lowfirst_modfact :

*---[ Saturation campaign batch 4: DoTail child flags, FillExpression, preproc exists/isnumber ]---

*--#[ cov_dootail_ok :
* FORM child processes with silent command-line flags
#system cd $TESTFILEDIR && printf ".end\n" > $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM -c $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM -l $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM -M $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM -W $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM -d foo=bar $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM -d bar $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM -L -C $TESTTMPDIR/l1.log $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM -f -C $TESTTMPDIR/l2.log $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM -F -C $TESTTMPDIR/l3.log $TESTTMPDIR/dt.frm
Symbol oks;
Local ok = 1;
Print;
.end
assert succeeded?
*--#] cov_dootail_ok :

*--#[ cov_dootail_paths :
* FORM child processes with path-related command-line flags
#system cd $TESTFILEDIR && printf ".end\n" > $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM -t $TESTTMPDIR $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM -T $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM -s /dev/null $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM -i x $TESTTMPDIR/dt.frm 2>/dev/null
#system cd $TESTFILEDIR && $FORM -I $TESTTMPDIR $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM -I=$TESTTMPDIR $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM -C=$TESTTMPDIR/l4.log $TESTTMPDIR/dt.frm
Symbol oks;
Local ok = 1;
Print;
.end
assert succeeded?
*--#] cov_dootail_paths :

*--#[ cov_dootail_err :
* a failing child FORM process makes the #system statement terminate
#system cd $TESTFILEDIR && printf ".end\n" > $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM $TESTTMPDIR/nosuchfile.frm
Symbol oks;
Local ok = 1;
Print;
.end
assert runtime_error?
*--#] cov_dootail_err :

*--#[ cov_dootail_pipe :
* the -pipe flag without preset external channels
#system cd $TESTFILEDIR && printf ".end\n" > $TESTTMPDIR/dt.frm
#system cd $TESTFILEDIR && $FORM -pipe $TESTTMPDIR/dt.frm < /dev/null
Symbol oks;
Local ok = 1;
Print;
.end
assert succeeded?
*--#] cov_dootail_pipe :

*--#[ cov_exists_dollar :
* preprocessor exists() on dollars and file names
$x = 5;
#if ( exists($x) )
  #message "dollar exists"
#else
  #message "dollar missing"
#endif
#if ( exists($nosuchdollar) )
  #message "oops"
#else
  #message "undefined dollar absent"
#endif
#if ( exists("no_such_file_here_xyz") )
  #message "oops"
#else
  #message "file absent"
#endif
Symbol a;
Local f = a;
Print;
.end
assert compile_error?('Declaration out of order')
*--#] cov_exists_dollar :

*--#[ cov_isnum_cond :
* isnumber() on a non-dollar argument inside #if
Symbol a,b;
Local num = 5;
Local poly = a^2 + 1;
#if ( isnumber(num) )
  #message "num is a number"
#else
  #message "num not a number"
#endif
#if ( isnumber(poly) )
  #message "oops"
#else
  #message "poly not a number"
#endif
Print;
.end
assert preprocess_error?('Unmatched parentheses')
*--#] cov_isnum_cond :

*--#[ cov_fill_expr :
* FillExpression from an expression bracketed in its cell symbols
Symbol x,y;
Table t(0:2,0:2);
Local e = (x*y)*(1 + x + y);
Bracket x,y;
.sort
FillExpression t = e(x,y);
Local out = t(1,1) + t(2,1) + t(1,2);
Print out;
.end
assert succeeded?
assert result("out") =~ expr("3")
*--#] cov_fill_expr :

*--#[ cov_fill_exprfun :
* FillExpression from an expression bracketed in a function
CFunction f;
Table u(0:2,0:2);
Local e2 = f(1,1)+f(2,1)+f(1,2)*3;
Bracket f;
.sort
FillExpression u = e2(f);
Local out2 = u(1,1) + u(2,1) + u(1,2);
Print out2;
.end
assert succeeded?
assert result("out2") =~ expr("5")
*--#] cov_fill_exprfun :

*--#[ cov_trunc_include :
* nonexistent include file under truncated output lines
#truncate 16
#include "no_such_file_with_a_very_long_name_for_overflow_test.frm"
Symbol x;
Local t = x;
Print;
.end
assert preprocess_error?('Improper syntax for file')
assert preprocess_error?('Unrecognized preprocessor')
*--#] cov_trunc_include :

*--#[ cov_tablebase_load :
* Load on a TableBase without a file name
TableBase tb;
Load tb;
.end
assert compile_error?('Proper syntax: TableBase')
*--#] cov_tablebase_load :

*--#[ cov_plusminus :
* unary plus/minus expressions in if conditions
Symbol x;
Local b = 0;
if ( +1 ) id x = 1;
if ( -1 ) id x = 2;
Print b;
.end
assert succeeded?
assert result("b") =~ expr("0")
*--#] cov_plusminus :
*--#[ cov_takearg_index :
* target: TakeArgContent INDEX branch, argument.c:2863-2903
* probe: clean
* target: TakeArgContent INDEX branch, argument.c:2863-2903
Symbol x,y;
Index i,j;
Function f;
Local test = f(x*i + y*i);
FactArg f;
Print +s;
.end
assert runtime_error?
*--#] cov_takearg_index :

*--#[ cov_bracketsetvec_2 :
* set of vectors in bracket: bset INDEX branch (execute.c 1445-1489)
* probe: clean
* set of vectors in bracket: bset INDEX branch (execute.c 1445-1489)
Vector v,p;
CFunction f;
Set vs: v, p;
Local e = v(1)*f(2);
Bracket vs;
Print;
.end
assert succeeded?
assert result("e") =~ expr("+ v(1) * ( f(2) )")
*--#] cov_bracketsetvec_2 :

*--#[ cov_thr_bucketsize :
* farm probe 0032_thr_bucketsize_11 (+9 lines)
* probe: clean
On threads;
Symbol x,y,z;
ProcessBucketSize 1;
ThreadBucketSize 1;
Local f = (x+y+z)^18;
.sort
Print;
.end
assert succeeded?
assert result("f") =~ expr("z^18 + 18*y*z^17 + 153*y^2*z^16 + 816*y^3*z^15 + 3060*y^4*z^14 + 8568*
y^5*z^13 + 18564*y^6*z^12 + 31824*y^7*z^11 + 43758*y^8*z^10 + 48620*y^9*
z^9 + 43758*y^10*z^8 + 31824*y^11*z^7 + 18564*y^12*z^6 + 8568*y^13*z^5
+ 3060*y^14*z^4 + 816*y^15*z^3 + 153*y^16*z^2 + 18*y^17*z + y^18 + 18*x
*z^17 + 306*x*y*z^16 + 2448*x*y^2*z^15 + 12240*x*y^3*z^14 + 42840*x*y^4*
z^13 + 111384*x*y^5*z^12 + 222768*x*y^6*z^11 + 350064*x*y^7*z^10 +
437580*x*y^8*z^9 + 437580*x*y^9*z^8 + 350064*x*y^10*z^7 + 222768*x*y^11*
z^6 + 111384*x*y^12*z^5 + 42840*x*y^13*z^4 + 12240*x*y^14*z^3 + 2448*x*
y^15*z^2 + 306*x*y^16*z + 18*x*y^17 + 153*x^2*z^16 + 2448*x^2*y*z^15 +
18360*x^2*y^2*z^14 + 85680*x^2*y^3*z^13 + 278460*x^2*y^4*z^12 + 668304*
x^2*y^5*z^11 + 1225224*x^2*y^6*z^10 + 1750320*x^2*y^7*z^9 + 1969110*x^2*
y^8*z^8 + 1750320*x^2*y^9*z^7 + 1225224*x^2*y^10*z^6 + 668304*x^2*y^11*
z^5 + 278460*x^2*y^12*z^4 + 85680*x^2*y^13*z^3 + 18360*x^2*y^14*z^2 +
2448*x^2*y^15*z + 153*x^2*y^16 + 816*x^3*z^15 + 12240*x^3*y*z^14 + 85680
*x^3*y^2*z^13 + 371280*x^3*y^3*z^12 + 1113840*x^3*y^4*z^11 + 2450448*x^3
*y^5*z^10 + 4084080*x^3*y^6*z^9 + 5250960*x^3*y^7*z^8 + 5250960*x^3*y^8*
z^7 + 4084080*x^3*y^9*z^6 + 2450448*x^3*y^10*z^5 + 1113840*x^3*y^11*z^4
+ 371280*x^3*y^12*z^3 + 85680*x^3*y^13*z^2 + 12240*x^3*y^14*z + 816*x^3
*y^15 + 3060*x^4*z^14 + 42840*x^4*y*z^13 + 278460*x^4*y^2*z^12 + 1113840
*x^4*y^3*z^11 + 3063060*x^4*y^4*z^10 + 6126120*x^4*y^5*z^9 + 9189180*x^4
*y^6*z^8 + 10501920*x^4*y^7*z^7 + 9189180*x^4*y^8*z^6 + 6126120*x^4*y^9*
z^5 + 3063060*x^4*y^10*z^4 + 1113840*x^4*y^11*z^3 + 278460*x^4*y^12*z^2
+ 42840*x^4*y^13*z + 3060*x^4*y^14 + 8568*x^5*z^13 + 111384*x^5*y*z^12
+ 668304*x^5*y^2*z^11 + 2450448*x^5*y^3*z^10 + 6126120*x^5*y^4*z^9 +
11027016*x^5*y^5*z^8 + 14702688*x^5*y^6*z^7 + 14702688*x^5*y^7*z^6 +
11027016*x^5*y^8*z^5 + 6126120*x^5*y^9*z^4 + 2450448*x^5*y^10*z^3 +
668304*x^5*y^11*z^2 + 111384*x^5*y^12*z + 8568*x^5*y^13 + 18564*x^6*z^12
+ 222768*x^6*y*z^11 + 1225224*x^6*y^2*z^10 + 4084080*x^6*y^3*z^9 +
9189180*x^6*y^4*z^8 + 14702688*x^6*y^5*z^7 + 17153136*x^6*y^6*z^6 +
14702688*x^6*y^7*z^5 + 9189180*x^6*y^8*z^4 + 4084080*x^6*y^9*z^3 +
1225224*x^6*y^10*z^2 + 222768*x^6*y^11*z + 18564*x^6*y^12 + 31824*x^7*
z^11 + 350064*x^7*y*z^10 + 1750320*x^7*y^2*z^9 + 5250960*x^7*y^3*z^8 +
10501920*x^7*y^4*z^7 + 14702688*x^7*y^5*z^6 + 14702688*x^7*y^6*z^5 +
10501920*x^7*y^7*z^4 + 5250960*x^7*y^8*z^3 + 1750320*x^7*y^9*z^2 +
350064*x^7*y^10*z + 31824*x^7*y^11 + 43758*x^8*z^10 + 437580*x^8*y*z^9
+ 1969110*x^8*y^2*z^8 + 5250960*x^8*y^3*z^7 + 9189180*x^8*y^4*z^6 +
11027016*x^8*y^5*z^5 + 9189180*x^8*y^6*z^4 + 5250960*x^8*y^7*z^3 +
1969110*x^8*y^8*z^2 + 437580*x^8*y^9*z + 43758*x^8*y^10 + 48620*x^9*z^9
+ 437580*x^9*y*z^8 + 1750320*x^9*y^2*z^7 + 4084080*x^9*y^3*z^6 +
6126120*x^9*y^4*z^5 + 6126120*x^9*y^5*z^4 + 4084080*x^9*y^6*z^3 +
1750320*x^9*y^7*z^2 + 437580*x^9*y^8*z + 48620*x^9*y^9 + 43758*x^10*z^8
+ 350064*x^10*y*z^7 + 1225224*x^10*y^2*z^6 + 2450448*x^10*y^3*z^5 +
3063060*x^10*y^4*z^4 + 2450448*x^10*y^5*z^3 + 1225224*x^10*y^6*z^2 +
350064*x^10*y^7*z + 43758*x^10*y^8 + 31824*x^11*z^7 + 222768*x^11*y*z^6
+ 668304*x^11*y^2*z^5 + 1113840*x^11*y^3*z^4 + 1113840*x^11*y^4*z^3 +
668304*x^11*y^5*z^2 + 222768*x^11*y^6*z + 31824*x^11*y^7 + 18564*x^12*
z^6 + 111384*x^12*y*z^5 + 278460*x^12*y^2*z^4 + 371280*x^12*y^3*z^3 +
278460*x^12*y^4*z^2 + 111384*x^12*y^5*z + 18564*x^12*y^6 + 8568*x^13*z^5
+ 42840*x^13*y*z^4 + 85680*x^13*y^2*z^3 + 85680*x^13*y^3*z^2 + 42840*
x^13*y^4*z + 8568*x^13*y^5 + 3060*x^14*z^4 + 12240*x^14*y*z^3 + 18360*
x^14*y^2*z^2 + 12240*x^14*y^3*z + 3060*x^14*y^4 + 816*x^15*z^3 + 2448*
x^15*y*z^2 + 2448*x^15*y^2*z + 816*x^15*y^3 + 153*x^16*z^2 + 306*x^16*y*
z + 153*x^16*y^2 + 18*x^17*z + 18*x^17*y + x^18")
*--#] cov_thr_bucketsize :

*--#[ cov_powden :
* exponent wildcards matching negative powers via denominators
* probe: clean
* exponent wildcards matching negative powers via denominators
Symbol x,y;
CFunction f;
Local t1 = 1/x^3;
id x^n_ = f(n_);
Local t2 = x^2/y^-4;
id x^n_*y^n_ = f(n_);
Local t3 = 1/(x^3*y^3);
id x^n_*y^n_ = f(n_);
Print +s;
.end
assert compile_error?('Undeclared variable n_')
*--#] cov_powden :

*--#[ cov_fill_warn :
* bracket with out-of-range power should be skipped with a warning
* probe: clean
* bracket with out-of-range power should be skipped with a warning
Symbol x,y;
Table t(0:2,0:2);
Local e = (x^5*y)*(1 + x*y);
Keep Brackets;
.sort
FillExpression t = e(x,y);
Local out = t(1,1);
Print out;
.end
assert compile_error?('Specification out of')
*--#] cov_fill_warn :

*--#[ cov_ifelse :
* farm probe 0012_ifelse_4 (+5 lines)
* probe: clean
Symbol x;
Local t = 5;
if ( count(x,1) > 0 ) id x = 1;
else id t = 2;
endif;
Print t;
.end
Local u = 7;
if ( 0 ) id u = 1;
else id u = 2;
endif;
Print u;
.end
assert compile_error?('No extra text')
*--#] cov_ifelse :

*--#[ cov_wildsym :
* target: findpat.c FindOnce wildcard symbol with wildcard power, SYMTOSYM + OnceL4a (508-560, 534-537, 528-531)
* probe: clean
* target: findpat.c FindOnce wildcard symbol with wildcard power, SYMTOSYM + OnceL4a (508-560, 534-537, 528-531)
Symbol x,y;
CFunction f;
Local a = x^3;
id, once, n1?^n2? = f(n1?,n2?);
Print;
Local b = x^(-3)*y^2;
id, once, n1?^n2?*n3?^n2? = f(n1?,n3?);
Print;
Local c = x^3*y^(-2);
id, once, n1?^n2?*n3?^n2? = f(n1?,n3?);
Print;
Local d = x^3*y^5;
id, once, n1?^n2?*n1?^n2? = f(n1?);
Print;
.end
assert compile_error?('Undeclared variable n1')
*--#] cov_wildsym :

*--#[ cov_dotail_flags :
* Runs the coverage-instrumented binary as a child to exercise DoTail
* probe: clean
* Runs the coverage-instrumented binary as a child to exercise DoTail
* option cases: c l L f F h W M and d (with and without '=')
#system cd $TESTFILEDIR && echo .end > $TESTTMPDIR/cvf1.frm; $FORM -c $TESTTMPDIR/cvf1.frm; $FORM -l $TESTTMPDIR/cvf1.frm; $FORM -L -C $TESTTMPDIR/cvlog1.frm $TESTTMPDIR/cvf1.frm; $FORM -f -C $TESTTMPDIR/cvlog2.frm $TESTTMPDIR/cvf1.frm; $FORM -F -C $TESTTMPDIR/cvlog3.frm $TESTTMPDIR/cvf1.frm; $FORM -h -W -M $TESTTMPDIR/cvf1.frm; true
#system cd $TESTFILEDIR && $FORM -d foo=bar $TESTTMPDIR/cvf1.frm; $FORM -d bar $TESTTMPDIR/cvf1.frm; true
Symbol ok;
Local ok = 1;
Print;
.end
assert compile_error?('name of expression')
*--#] cov_dotail_flags :

*--#[ cov_typedwild :
* typed wildcards in function arguments
* probe: clean
* typed wildcards in function arguments
Symbols a,b;
CFunction f,g,h;
Local t1 = f(a,3,b);
id f(x_,n?y_,x_) = h(x_,y_);
Local t2 = f(a,b);
id f(p?s_) = g(p?s_);
Local t3 = f(3);
id f(n?y_) = g(y_);
Print +s;
.end
assert compile_error?('Undeclared variable x_')
*--#] cov_typedwild :

*--#[ cov_dotail_illegal :
* DoTail illegal options: -Z, bare -i, -Q, and '/'-prefix branch of line 303
* probe: clean
* DoTail illegal options: -Z, bare -i, -Q, and '/'-prefix branch of line 303
* expected child message fragment: Illegal option in call of FORM
#system cd $TESTFILEDIR && echo .end > $TESTTMPDIR/cvf6.frm; $FORM -Z $TESTTMPDIR/cvf6.frm; $FORM -i $TESTTMPDIR/cvf6.frm; $FORM -Q $TESTTMPDIR/cvf6.frm; $FORM /zz $TESTTMPDIR/cvf6.frm; true
Symbol ok;
Local ok = 1;
Print;
.end
assert compile_error?('name of expression')
*--#] cov_dotail_illegal :

*--#[ cov_08_genericarg :
* named wildcard plus generic ? argument filler on a symmetric
* probe: clean
* named wildcard plus generic ? argument filler on a symmetric
* function; hits the funnycount (ARGWILD) handling.
Symbol a,b,c,x;
CFunction f,g;
Symmetric f;
Local test = f(c,b,a);
id f(x?,?) = g(x);
Print;
.end
assert compile_error?('Unrecognized statement S')
*--#] cov_08_genericarg :

*--#[ cov_dotail_pipe :
* DoTail -pipe option; child hits initPresetExternalChannels error path
* probe: clean
* DoTail -pipe option; child hits initPresetExternalChannels error path
* expected child message fragment: Error initializing preset external channels
#system cd $TESTFILEDIR && echo .end > $TESTTMPDIR/cvf4.frm; $FORM -pipe $TESTTMPDIR/cvf4.frm < /dev/null; true
Symbol ok;
Local ok = 1;
Print;
.end
assert compile_error?('name of expression')
*--#] cov_dotail_pipe :

*--#[ cov_dotail_bare :
* DoTail with argc<1: goto printversion path (version banner, lines 297-300, 559-568)
* probe: clean
* DoTail with argc<1: goto printversion path (version banner, lines 297-300, 559-568)
#system cd $TESTFILEDIR && $FORM < /dev/null; true
Symbol ok;
Local ok = 1;
Print;
.end
assert compile_error?('name of expression')
*--#] cov_dotail_bare :

*--#[ cov_setnocomma :
* expected: should be followed by a comma
* probe: error
* expected: should be followed by a comma
CFunction f;
Transform,{f};
.end
assert compile_error?('f}: A set')
*--#] cov_setnocomma :

*--#[ cov_ifcomp :
* target: if.c NOT/subexpression fast path, OR short-circuit, nested parens
* runtime $-variables force sequential mode under threads
* probe: clean
* target: if.c NOT/subexpression fast path, OR short-circuit, nested parens
Symbol x,y,z;
$a = 1;
Local t = 3*x*y;
If ( ! Occurrence(z) ) Multiply 2; EndIf;
If ( $a > 0 || Coefficient(y) > 2 ) Multiply 3; EndIf;
If ( ( Count(x,1,0) || Count(y,1,0) ) && Occurrence(x) ) Multiply 5; EndIf;
Print;
.end
#pend_if threaded?
assert compile_error?('Definition out of')
*--#] cov_ifcomp :

*--#[ cov_dol_big :
* farm probe 0066_dol_big_5 (+8 lines)
* runtime $-variables force sequential mode under threads
* probe: clean
Symbol x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12;
CFunction f;
Local test = x1*x2*x3*x4*x5*x6*x7*x8*x9*x10*x11*x12;
$x = x1*x2*x3*x4*x5*x6*x7*x8*x9*x10*x11*x12;
id $x = f(1,2,3,4,5,6,7,8,9);
Print;
.end
#pend_if threaded?
assert succeeded?
assert result("test") =~ expr("f(1,2,3,4,5,6,7,8,9)")
*--#] cov_dol_big :

*--#[ cov_takearg_index_2 :
* target: TakeArgContent INDEX branch, argument.c:2863-2903
* probe: clean
* target: TakeArgContent INDEX branch, argument.c:2863-2903
Symbol x,y;
Index i,j;
Function f;
Local test = f(x*i + y*i);
FactArg f;
Print +s;
.end
assert runtime_error?
*--#] cov_takearg_index_2 :

*--#[ cov_replmism :
* expected: Replace
* probe: error
* expected: Replace
CFunction f;
Set funcs: f;
Local test = f(1,2,3);
Transform,funcs,replace(1,2)=(2);
Print;
.end
assert succeeded?
assert result("test") =~ expr("f(1,0,3)")
*--#] cov_replmism :

*--#[ cov_do_oneexpr :
* #do over an existing expression name (ONEEXPRESSION loop type)
* probe: clean
* #do over an existing expression name (ONEEXPRESSION loop type)
Symbol x;
Local F = 3;
.sort
#do i = F
#message loop over expression done
#enddo
.end
assert succeeded?
*--#] cov_do_oneexpr :

*--#[ cov_pipe_echo2 :
* channel output forming a full statement (output-consumption path)
* probe: clean
* channel output forming a full statement (output-consumption path)
#pipe "echo" "Local t = 1;"
Print;
.end
assert succeeded?
assert result("t") =~ expr("1")
*--#] cov_pipe_echo2 :

*--#[ cov_mod_noinv :
* expected: Inverse in modulus arithmetic doesn't exist
* probe: error
* expected: Inverse in modulus arithmetic doesn't exist
Modulus 6;
Local test = 1/2;
Print;
.end
assert succeeded?
assert result("test") =~ expr("0")
*--#] cov_mod_noinv :

*--#[ cov_idall_sym_err :
* expected: id,all can only be used with (products of) functions and/or tensors
* probe: error
* expected: id,all can only be used with (products of) functions and/or tensors
Symbol x,y;
Local test = x;
id, all, x = y;
.end
assert runtime_error?
*--#] cov_idall_sym_err :

*--#[ cov_mod_divz :
* expected: Division by zero in modulus arithmetic
* probe: error
* expected: Division by zero in modulus arithmetic
Modulus 7;
Local test = 1/7;
Print;
.end
assert runtime_error?
*--#] cov_mod_divz :

*--#[ cov_do_dollar1_ok :
* dollar variable as the FIRST parameter of #do (success path)
* runtime $-variables force sequential mode under threads
* probe: clean
* dollar variable as the FIRST parameter of #do (success path)
Symbol x;
$a = 3;
.sort
#do i = $a, 5
#message i = `i'
#enddo
.end
#pend_if threaded?
assert preprocess_error?('$a does not')
*--#] cov_do_dollar1_ok :

*--#[ cov_to_inside :
* farm probe 0058_to_inside_7 (+6 lines)
* probe: clean
CFunction f;
Symbol q,qb;
Local topo = f(1,2,3,4);
ToDiagram topo: f(1,2,3,4): q,qb,q,qb;
NumberofDiagrams;
NextDiagram;
if ( InsideDiagram(f(1,2)) ) Print;
IdenticaltoDiagram topo;
Print;
.end
assert compile_error?('Unrecognized statement ToDia')
*--#] cov_to_inside :

*--#[ cov_dotail_pipe_2 :
* DoTail -pipe option; child hits initPresetExternalChannels error path
* probe: clean
* DoTail -pipe option; child hits initPresetExternalChannels error path
* expected child message fragment: Error initializing preset external channels
#system cd $TESTFILEDIR && echo .end > $TESTTMPDIR/cvf4.frm; $FORM -pipe $TESTTMPDIR/cvf4.frm < /dev/null; true
Symbol ok;
Local ok = 1;
Print;
.end
assert compile_error?('name of expression')
*--#] cov_dotail_pipe_2 :

*--#[ cov_rev_irrend :
* unterminated string in reversed include hits tools.c 926 -> 871-874 irrend
* probe: error
* unterminated string in reversed include hits tools.c 926 -> 871-874 irrend
* expected: Irregular end of reverse include file.
Symbol z;
Local keep = 1;
#create revg
Local y1 = 1;
Print "unterminated
Local y2 = 2;
#endcreate
#reverseinclude revg
Print;
.end
assert preprocess_error?('Proper syntax is:')
*--#] cov_rev_irrend :

*--#[ cov_insideopen :
* expected: endinside statement(s) missing
* probe: error
* expected: endinside statement(s) missing
Symbol x;
Local f = x^2;
Inside f;
.end
assert compile_error?('Illegal object in')
*--#] cov_insideopen :

*--#[ cov_ifopen2 :
* expected: endif statement(s) missing
* runtime $-variables force sequential mode under threads
* probe: error
* expected: endif statement(s) missing
$a = 1;
If ($a > 0);
.end
#pend_if threaded?
assert runtime_error?
*--#] cov_ifopen2 :

*--#[ cov_rev_string :
* quoted string with ; and backslash inside reversed include: tools.c 919-926
* probe: clean
* quoted string with ; and backslash inside reversed include: tools.c 919-926
#create revf
Local x1 = 1;
Print "a;b\\c";
Local x2 = 2;
#endcreate
#reverseinclude revf
Print;
.end
assert preprocess_error?('Proper syntax is:')
*--#] cov_rev_string :

*--#[ cov_takearg_index_3 :
* target: TakeArgContent INDEX branch, argument.c:2863-2903
* probe: clean
* target: TakeArgContent INDEX branch, argument.c:2863-2903
Symbol x,y;
Index i,j;
Function f;
Local test = f(x*i + y*i);
FactArg f;
Print +s;
.end
assert runtime_error?
*--#] cov_takearg_index_3 :

*--#[ cov_replmism_2 :
* expected: Replace
* probe: error
* expected: Replace
CFunction f;
Set funcs: f;
Local test = f(1,2,3);
Transform,funcs,replace(1,2)=(2);
Print;
.end
assert succeeded?
assert result("test") =~ expr("f(1,0,3)")
*--#] cov_replmism_2 :

*--#[ cov_cyc_zero :
* farm probe 0045_cyc_zero_11 (+7 lines)
* probe: clean
Function h(cyclic);
Symbol s;
Local test = h;
id h = s;
Print;
.end
assert succeeded?
assert result("test") =~ expr("s")
*--#] cov_cyc_zero :

*--#[ cov_dotail_pipe_3 :
* DoTail -pipe option; child hits initPresetExternalChannels error path
* probe: clean
* DoTail -pipe option; child hits initPresetExternalChannels error path
* expected child message fragment: Error initializing preset external channels
#system cd $TESTFILEDIR && echo .end > $TESTTMPDIR/cvf4.frm; $FORM -pipe $TESTTMPDIR/cvf4.frm < /dev/null; true
Symbol ok;
Local ok = 1;
Print;
.end
assert compile_error?('name of expression')
*--#] cov_dotail_pipe_3 :

*--#[ cov_gamma2 :
* expected: gamma with two arguments and momentum form
* probe: clean
* expected: gamma with two arguments and momentum form
Vector p;
Symbol x;
Local F = gi_(1,2)*g5_(p)*x;
if ( match(gi_(1,2)) ) Print "m1";
if ( match(g5_(p)) ) Print "m2";
Print F;
.end
assert succeeded?
assert result("F") =~ expr("g_(p,5_)*g_(1,2)*x")
*--#] cov_gamma2 :

*--#[ cov_anti_fun :
* farm probe 0038_anti_fun_32 (+8 lines)
* probe: clean
Functions f,g,h;
Symbol x,y;
Local F = f(x)*g(y)*h(x+y)*x;
AntiBracket f;
.sort
Print;
.end
assert succeeded?
assert result("F") =~ expr("f(x)*g(y)*h(y + x)*x")
*--#] cov_anti_fun :

*--#[ cov_mod_frac :
* farm probe 0006_mod_frac_14 (+27 lines)
* probe: clean
Local test = mod_(1/1234567890123456789012345678901234567890,97);
Print;
.end
assert succeeded?
assert result("test") =~ expr("52")
*--#] cov_mod_frac :

*--#[ cov_takearg_index_4 :
* target: TakeArgContent INDEX branch, argument.c:2863-2903
* probe: clean
* target: TakeArgContent INDEX branch, argument.c:2863-2903
Symbol x,y;
Index i,j;
Function f;
Local test = f(x*i + y*i);
FactArg f;
Print +s;
.end
assert runtime_error?
*--#] cov_takearg_index_4 :

*--#[ cov_max_small_big :
* farm probe 0006_max_small_big_17 (+10 lines)
* probe: clean
Local test = max_(5,1234567890123456789012345678901234567890);
Print;
.end
assert succeeded?
assert result("test") =~ expr("1234567890123456789012345678901234567890")
*--#] cov_max_small_big :

*--#[ cov_replmism_3 :
* expected: Replace
* probe: error
* expected: Replace
CFunction f;
Set funcs: f;
Local test = f(1,2,3);
Transform,funcs,replace(1,2)=(2);
Print;
.end
assert succeeded?
assert result("test") =~ expr("f(1,0,3)")
*--#] cov_replmism_3 :

*--#[ cov_indexpat :
* expected: vector-with-index pattern -> INDEX branch in FindAll
* probe: clean
* expected: vector-with-index pattern -> INDEX branch in FindAll
Index i,j;
Vector p,q;
Local F = p(i)*q(j);
if ( match(p(i)) ) Print "matched";
Print F;
.end
assert succeeded?
assert result("F") =~ expr("p(i)*q(j)")
*--#] cov_indexpat :

*--#[ cov_anti_funset :
* farm probe 0038_anti_funset_33 (+11 lines)
* probe: clean
Functions f1,f2,g;
Symbol x;
Set fs: f1, f2;
Local F = f1(x)*g(x)*f2(x)*x;
AntiBracket fs;
.sort
Print;
.end
assert succeeded?
assert result("F") =~ expr("f1(x)*g(x)*f2(x)*x")
*--#] cov_anti_funset :

*--#[ cov_flagok :
* valid flag(...) condition, big compile run 4510-4543
* probe: clean
* valid flag(...) condition, big compile run 4510-4543
CFunction f;
Local F = f(1);
if ( flag(1,2) ) Print;
.end
assert succeeded?
assert result("F") =~ expr("f(1)")
*--#] cov_flagok :

*--#[ cov_brk_vecset :
* farm probe 0038_brk_vecset_37 (+18 lines)
* probe: clean
Vectors p1,p2,q1,q2;
Set vs: p1, p2;
Local F = p1.p2*q1.q2;
Bracket vs;
.sort
Print;
.end
assert succeeded?
assert result("F") =~ expr("p1.p2*q1.q2")
*--#] cov_brk_vecset :

*--#[ cov_expok :
* valid expression(...) condition, compile run 4546-4591
* probe: clean
* valid expression(...) condition, compile run 4546-4591
Symbol x;
Local F = x;
if ( expression(F) == 0 ) Print;
.end
assert succeeded?
assert result("F") =~ expr("x")
*--#] cov_expok :

*--#[ cov_isfactok :
* valid isfactorized(...) condition, compile run 4595-4639
* probe: clean
* valid isfactorized(...) condition, compile run 4595-4639
Symbol x;
Local F = x;
if ( isfactorized(F) ) Print;
.end
assert succeeded?
assert result("F") =~ expr("x")
*--#] cov_isfactok :

*--#[ cov_1102_dfill_neg :
* d_ on RHS with wildcard-filled argument, negative power (DENOMINATOR path)
* probe: clean
* d_ on RHS with wildcard-filled argument, negative power (DENOMINATOR path)
Symbol x,y;
CFunction f,g;
Local test = f(g(x));
id f(y?) = d_(-2,f(y));
Print;
.end
assert compile_error?('Illegal object in')
*--#] cov_1102_dfill_neg :

*--#[ cov_dotail_pipe_4 :
* DoTail -pipe option; child hits initPresetExternalChannels error path
* probe: clean
* DoTail -pipe option; child hits initPresetExternalChannels error path
* expected child message fragment: Error initializing preset external channels
#system cd $TESTFILEDIR && echo .end > $TESTTMPDIR/cvf4.frm; $FORM -pipe $TESTTMPDIR/cvf4.frm < /dev/null; true
Symbol ok;
Local ok = 1;
Print;
.end
assert compile_error?('name of expression')
*--#] cov_dotail_pipe_4 :

*--#[ cov_brk_argwild :
* farm probe 0038_brk_argwild_35 (+7 lines)
* probe: clean
Symbol x,y;
Functions f,g;
Local F = f(x,y)*g(x)*y;
Bracket f(1?,...);
.sort
Print;
.end
assert compile_error?('Improper operators for')
*--#] cov_brk_argwild :

*--#[ cov_pr_pctd :
* expected: !!!Wrong object in Print statement!!!
* probe: error
* expected: !!!Wrong object in Print statement!!!
* expression object paired with numeric specifier should set specialerror
Symbol x;
Local F = x;
Print "%d",F;
.end
assert compile_error?('Illegal object in')
*--#] cov_pr_pctd :

*--#[ cov_brk_delta :
* farm probe 0038_brk_delta_36 (+5 lines)
* probe: clean
Symbol i,j;
Local F = d_(i,j)*x*d_(i,i);
Bracket d_;
.sort
Print;
.end
assert compile_error?('Undeclared variable x')
*--#] cov_brk_delta :

*--#[ cov_fac150 :
* factorized expression with many brackets: ISFACTORIZED enlargement branch (index.c 409-410)
* probe: clean
* factorized expression with many brackets: ISFACTORIZED enlargement branch (index.c 409-410)
AutoDeclare Symbol s;
Local test = (s1+s2+s3+s4+s5+s6+s7+s8+s9+s10+s11+s12+s13+s14+s15+s16+s17+s18+s19+s20+s21+s22+s23+s24+s25+s26+s27+s28+s29+s30+s31+s32+s33+s34+s35+s36+s37+s38+s39+s40+s41+s42+s43+s44+s45+s46+s47+s48+s49+s50+s51+s52+s53+s54+s55+s56+s57+s58+s59+s60+s61+s62+s63+s64+s65+s66+s67+s68+s69+s70+s71+s72+s73+s74+s75+s76+s77+s78+s79+s80+s81+s82+s83+s84+s85+s86+s87+s88+s89+s90+s91+s92+s93+s94+s95+s96+s97+s98+s99+s100+s101+s102+s103+s104+s105+s106+s107+s108+s109+s110+s111+s112+s113+s114+s115+s116+s117+s118+s119+s120+s121+s122+s123+s124+s125+s126+s127+s128+s129+s130+s131+s132+s133+s134+s135+s136+s137+s138+s139+s140+s141+s142+s143+s144+s145+s146+s147+s148+s149+s150)^2;
Bracket;
Factorize test;
.sort
Print;
.end
assert succeeded?
assert result("test") =~ expr("( s150 + s149 + s148 + s147 + s146 + s145 + s144 + s143 + s142 + s141
+ s140 + s139 + s138 + s137 + s136 + s135 + s134 + s133 + s132 +
s131 + s130 + s129 + s128 + s127 + s126 + s125 + s124 + s123 + s122
+ s121 + s120 + s119 + s118 + s117 + s116 + s115 + s114 + s113 +
s112 + s111 + s110 + s109 + s108 + s107 + s106 + s105 + s104 + s103
+ s102 + s101 + s100 + s99 + s98 + s97 + s96 + s95 + s94 + s93 + s92
+ s91 + s90 + s89 + s88 + s87 + s86 + s85 + s84 + s83 + s82 + s81 +
s80 + s79 + s78 + s77 + s76 + s75 + s74 + s73 + s72 + s71 + s70 + s69
+ s68 + s67 + s66 + s65 + s64 + s63 + s62 + s61 + s60 + s59 + s58 +
s57 + s56 + s55 + s54 + s53 + s52 + s51 + s50 + s49 + s48 + s47 + s46
+ s45 + s44 + s43 + s42 + s41 + s40 + s39 + s38 + s37 + s36 + s35 +
s34 + s33 + s32 + s31 + s30 + s29 + s28 + s27 + s26 + s25 + s24 + s23
+ s22 + s21 + s20 + s19 + s18 + s17 + s16 + s15 + s14 + s13 + s12 +
s11 + s10 + s9 + s8 + s7 + s6 + s5 + s4 + s3 + s2 + s1 )
* ( s150 + s149 + s148 + s147 + s146 + s145 + s144 + s143 + s142 + s141
+ s140 + s139 + s138 + s137 + s136 + s135 + s134 + s133 + s132 +
s131 + s130 + s129 + s128 + s127 + s126 + s125 + s124 + s123 + s122
+ s121 + s120 + s119 + s118 + s117 + s116 + s115 + s114 + s113 +
s112 + s111 + s110 + s109 + s108 + s107 + s106 + s105 + s104 + s103
+ s102 + s101 + s100 + s99 + s98 + s97 + s96 + s95 + s94 + s93 + s92
+ s91 + s90 + s89 + s88 + s87 + s86 + s85 + s84 + s83 + s82 + s81 +
s80 + s79 + s78 + s77 + s76 + s75 + s74 + s73 + s72 + s71 + s70 + s69
+ s68 + s67 + s66 + s65 + s64 + s63 + s62 + s61 + s60 + s59 + s58 +
s57 + s56 + s55 + s54 + s53 + s52 + s51 + s50 + s49 + s48 + s47 + s46
+ s45 + s44 + s43 + s42 + s41 + s40 + s39 + s38 + s37 + s36 + s35 +
s34 + s33 + s32 + s31 + s30 + s29 + s28 + s27 + s26 + s25 + s24 + s23
+ s22 + s21 + s20 + s19 + s18 + s17 + s16 + s15 + s14 + s13 + s12 +
s11 + s10 + s9 + s8 + s7 + s6 + s5 + s4 + s3 + s2 + s1 )")
*--#] cov_fac150 :

*--#[ cov_factdol_negpow :
* Factorized dollar with negative power (power < 0 path)
* runtime $-variables force sequential mode under threads
* probe: clean
* Factorized dollar with negative power (power < 0 path)
Symbol x;
Local F = (x+1)*(x-1);
.sort
$dd = F;
.sort
FactDollar,$dd;
.sort
Local G = $dd^-1;
.sort
Print;
.end
#pend_if threaded?
assert succeeded?
assert result("F") =~ expr("- 1 + x^2")
assert result("G") =~ expr("1/( - 1 + x^2)")
*--#] cov_factdol_negpow :

*--#[ cov_bigtablefill :
* long fill expression may push table into tree/boomlijst storage
* probe: clean
* long fill expression may push table into tree/boomlijst storage
Symbol x;
Table t(1:4);
.sort
Fill t(1) = (x+1)^10;
.sort
Fill t(2) = (x+2)^12;
.sort
Local u = t(1)+t(2);
.sort
Print;
.clear
.sort
Local v = 2;
Print;
.end
assert succeeded?
assert result("v") =~ expr("2")
*--#] cov_bigtablefill :

*--#[ cov_clearall :
* farm probe 0065_clearall_0 (+10 lines)
* probe: clean
Symbol x,y;
Vector v;
Index i;
CFunction f;
Set s: x,y;
Table tb(1:2,1:2);
.sort
Fill tb(1,1) = 5;
.sort
Local t = f(x)*v(i) + tb(1,1);
.sort
Print;
.clear
.sort
Local u = 1;
Print;
.end
assert succeeded?
assert result("u") =~ expr("1")
*--#] cov_clearall :

*--#[ cov_mixtyp :
* wildcard bound as function arg, reused as power wildcard -> type clash
* probe: clean
* wildcard bound as function arg, reused as power wildcard -> type clash
* at CheckWild (lines 482-484)
Symbol x,n;
Functions f;
Local test = f(3)*x^-3;
id f(n?)*x^-n? = 1;
Print;
.end
assert succeeded?
assert result("test") =~ expr("1")
*--#] cov_mixtyp :

*--#[ cov_vecmiss :
* vector present in one term only: scratch-vector path
* probe: clean
* vector present in one term only: scratch-vector path
Vector p,q,r;
Index i,j,k;
CFunction g;
Symbol x,y;
Local a = g(p(i),q(j))*x + g(q(j))*y;
.sort
Local b = factorin_(a);
Print b;
.sort
Print;
.end
assert succeeded?
assert result("a") =~ expr("g(p(i),q(j))*x + g(q(j))*y")
assert result("b") =~ expr("1")
*--#] cov_vecmiss :

*--#[ cov_bigexp :
* large expansion inside Substitute; attempts workspace check path 654-658
* probe: clean
* large expansion inside Substitute; attempts workspace check path 654-658
Symbol x,y;
CFunction f;
Local test = f(x);
id f(x?) = (y+1)^50000;
.end
assert runtime_error?
*--#] cov_bigexp :

*--#[ cov_wc_symwild_all :
* farm probe 0019_wc_symwild_all_37 (+14 lines)
* probe: clean
Symbol a,b,x;
CFunction f;
Local t = a^2*b^3;
id x? = f(x);
Print;
.end
assert succeeded?
assert result("t") =~ expr("f(a)^2*b^3")
*--#] cov_wc_symwild_all :

*--#[ cov_grepeat2 :
* farm probe 0039_grepeat2_61 (+36 lines)
* probe: clean
Index mu,nu;
Local test = g_(1,2)*g_(3,4);
repeat id g_(mu?,nu?)*g_(mu,nu) = 1;
Print test;
.end
assert succeeded?
assert result("test") =~ expr("g_(1,2)*g_(3,4)")
*--#] cov_grepeat2 :

*--#[ cov_mkrat_basic :
* target: notation.c NormPolyTerm via MakeRational_ normalization
* probe: clean
* target: notation.c NormPolyTerm via MakeRational_ normalization
Symbol x;
Local test = MakeRational_((x+1)^2,x+1);
Print;
.end
assert succeeded?
assert result("test") =~ expr("0/0")
*--#] cov_mkrat_basic :

*--#[ cov_autoclear :
* farm probe 0065_autoclear_2 (+18 lines)
* probe: clean
AutoDeclare Symbol s;
AutoDeclare Vector v;
AutoDeclare Index i;
AutoDeclare Function f;
.sort
Local t = f1(i1)*v(i1) + s2^2;
.sort
Print;
.clear
.sort
Local u = 1;
Print;
.end
assert succeeded?
assert result("u") =~ expr("1")
*--#] cov_autoclear :

*--#[ cov_mkrat_pow2 :
* attempts MakeLongRational failure (1026-1034) via huge common power of two
* probe: clean
* attempts MakeLongRational failure (1026-1034) via huge common power of two
Local test = MakeRational_(3*2^320,5*2^320);
Print;
.end
assert warning?('fraction could not')
assert result("test") =~ expr("640796110776273024718506511850865634380811356706995830984112482346665917\\
7341921650068886260809728")
*--#] cov_mkrat_pow2 :

*--#[ cov_pfortran :
* farm probe 0079_pfortran_8 (+10 lines)
* probe: clean
Format PFortran;
Symbol x,y,z;
Local test = (x+y+z)^2*(x+2*y);
Bracket x;
Print test;
.end
assert succeeded?
*--#] cov_pfortran :

*--#[ cov_gwild1 :
* farm probe 0039_gwild1_56 (+8 lines)
* probe: clean
Index mu;
Local test = g_(1);
id g_(mu?) = g_(mu,5);
Print test;
.end
assert succeeded?
assert result("test") =~ expr("g_(1,5)")
*--#] cov_gwild1 :

*--#[ cov_c_bracket :
* farm probe 0079_c_bracket_2 (+6 lines)
* probe: clean
Format C;
Symbol x,y,z;
Local test = (x+y+z)^2*(x+2*y);
Bracket x;
Print test;
.end
assert succeeded?
assert result("test") =~ expr("+ x * ( pow(z,2) + 6*y*z + 5*pow(y,2) )")
*--#] cov_c_bracket :

*--#[ cov_s2_argtoobig :
* expected: Sorted function argument too long
* probe: error
* expected: Sorted function argument too long
Symbol x;
Function f;
Local t = f;
#do i = 1,9000
    id,once f(?a) = f(?a,x);
#enddo
Print;
.end
assert runtime_error?
*--#] cov_s2_argtoobig :

*--#[ cov_biggcd :
* kGCD > kLCM: long GCD numerator (10^30,10^12), short LCM denominator (15)
* probe: clean
* kGCD > kLCM: long GCD numerator (10^30,10^12), short LCM denominator (15)
Symbol x;
Local a = 1000000000000000000000000000000*x/3 + 1000000000000*x^2/5;
.sort
Local b = factorin_(a);
Print b;
.sort
Print;
.end
assert succeeded?
assert result("a") =~ expr("1000000000000000000000000000000/3*x + 200000000000*x^2")
assert result("b") =~ expr("200000000000/3*x")
*--#] cov_biggcd :

*--#[ cov_dotswap :
* vector wildcard dot product matching swapped order (lines 749-757)
* probe: clean
* vector wildcard dot product matching swapped order (lines 749-757)
Vector p,q;
Local test = q.p + p.p;
id p?.q = 1;
Print;
.end
assert succeeded?
assert result("test") =~ expr("1 + p.p")
*--#] cov_dotswap :

*--#[ cov_gslide :
* farm probe 0039_gslide_59 (+7 lines)
* probe: clean
Index mu;
Local test = g_(1,2,3);
id g_(mu?,1) = g_(mu,9);
Print test;
.end
assert succeeded?
assert result("test") =~ expr("g_(1,2,3)")
*--#] cov_gslide :

*--#[ cov_mkrat_exprarg :
* attempts expression argument (non-SNUMBER, non-general) -> normal.c 1009-1013
* probe: clean
* attempts expression argument (non-SNUMBER, non-general) -> normal.c 1009-1013
Symbol x;
Local F = x;
.sort
Local test = MakeRational_(3,F);
Print;
.end
assert succeeded?
assert result("F") =~ expr("x")
assert result("test") =~ expr("makerational_(3,x)")
*--#] cov_mkrat_exprarg :

*--#[ cov_biglcm :
* kLCM > kGCD: short GCD numerator, long LCM denominator
* probe: clean
* kLCM > kGCD: short GCD numerator, long LCM denominator
Symbol x;
Local a = x/3 + x^2/1000000000000000000000000000000;
.sort
Local b = factorin_(a);
Print b;
.sort
Print;
.end
assert succeeded?
assert result("a") =~ expr("1/3*x + 1/1000000000000000000000000000000*x^2")
assert result("b") =~ expr("1/3000000000000000000000000000000*x")
*--#] cov_biglcm :

*--#[ cov_pgenidx :
* farm probe 0022_pgenidx_9 (+31 lines)
* probe: clean
Vectors p;
Indices i;
Symbol x;
Local t = p(i);
id p(i?) = x;
Print;
.end
assert succeeded?
assert result("t") =~ expr("x")
*--#] cov_pgenidx :

*--#[ cov_min_zerobig :
* targets normal.c 1897-1899 (zero via loadnew2) and 1914-1916 (n_llnum[0]==0, big subexpr arg, loadnew1)
* probe: clean
* targets normal.c 1897-1899 (zero via loadnew2) and 1914-1916 (n_llnum[0]==0, big subexpr arg, loadnew1)
Symbol x;
Local test = min_(0,-(3^100));
Print;
.end
assert succeeded?
assert result("test") =~ expr("- 515377520732011331036461129765621272702107522001")
*--#] cov_min_zerobig :

*--#[ cov_gcd_expr :
* targets ratio.c 886-897 (CreateExpression path over expression terms)
* probe: clean
* targets ratio.c 886-897 (CreateExpression path over expression terms)
Symbol x;
Local e = 1+6;
Local test = gcd_(e,x);
Print;
.end
assert succeeded?
assert result("e") =~ expr("7")
assert result("test") =~ expr("1")
*--#] cov_gcd_expr :

*--#[ cov_s6_absmix :
* farm probe 0005_s6_absmix_11 (+17 lines)
* probe: clean
Symbol x;
Local test = abs_(i_*x);
Print;
.end
assert succeeded?
assert result("test") =~ expr("abs_(i_*x)")
*--#] cov_s6_absmix :

*--#[ cov_autofunctable :
* table declared on an auto-declared function name; may error if
* probe: clean
* table declared on an auto-declared function name; may error if
* FORM refuses Table on an existing auto function - either way useful
.global
Symbol g;
.sort
AutoDeclare Function f;
.sort
Local t = f1(1);
.sort
Table f1(1:2);
.sort
Fill f1(1) = 4;
.sort
Print;
.clear
.sort
Local u = g;
Print;
.end
assert runtime_error?('Table now decl')
*--#] cov_autofunctable :

*--#[ cov_ab_vector_eps :
* farm probe 0040_ab_vector_eps_17 (+8 lines)
* probe: clean
Vector p,q,r;
Index i;
Local F = e_(p,q)*e_(r,q);
Bracket p;
.sort
AntiBracket, r;
.sort
Print;
.end
assert succeeded?
assert result("F") =~ expr("- e_(p,q)*e_(q,r)")
*--#] cov_ab_vector_eps :

*--#[ cov_gcd_numneg :
* targets ratio.c GCDfunction 704-711 (both args negative, sign=-1)
* probe: clean
* targets ratio.c GCDfunction 704-711 (both args negative, sign=-1)
Local test = gcd_(-12,-18,-24);
Print;
.end
assert succeeded?
assert result("test") =~ expr("- 6")
*--#] cov_gcd_numneg :

*--#[ cov_hideg_chain :
* exercises redefinition replace-chain over hidden global/local expressions
* probe: clean
* exercises redefinition replace-chain over hidden global/local expressions
Symbol x,y;
Global f = x;
Local g = y;
.sort
Hide f;
Hide g;
.sort
Global f = x+1;
Local g = y+1;
.sort
Print;
.end
assert succeeded?
assert result("f") =~ expr("1 + x")
assert result("g") =~ expr("1 + y")
*--#] cov_hideg_chain :

*--#[ cov_binom_big :
* target: notation.c NormPolyTerm LNUMBER/Mully (166-171) via big-number poly arithmetic
* probe: clean
* target: notation.c NormPolyTerm LNUMBER/Mully (166-171) via big-number poly arithmetic
Local test = Binom_(300,150);
Print;
.end
assert succeeded?
assert result("test") =~ expr("937597027728274527931937544390640848792326557000813589204723527129751700\\
21839591675861424")
*--#] cov_binom_big :

*--#[ cov_fbracket_plain :
* FIRSTBRACKET variant: unbracketed single-term expression (1062-1064, 1078)
* probe: clean
* FIRSTBRACKET variant: unbracketed single-term expression (1062-1064, 1078)
Symbol x;
Local F = x;
.sort
Local test = firstbracket_(F);
Print;
.end
assert succeeded?
assert result("F") =~ expr("x")
assert result("test") =~ expr("1")
*--#] cov_fbracket_plain :

*--#[ cov_gcd_minvec :
* targets ratio.c 693-694 (MINVECTOR promotion) and 765-767 output
* probe: clean
* targets ratio.c 693-694 (MINVECTOR promotion) and 765-767 output
Vector p;
Local test = gcd_(-p,p);
Print;
.end
assert succeeded?
assert result("test") =~ expr("p")
*--#] cov_gcd_minvec :

*--#[ cov_norm_divzero :
* expected: Division by zero during normalization
* probe: error
* expected: Division by zero during normalization
* target: normal.c 4215-4219 NormInf
Symbol a;
Local test = 1/(a-a);
Print;
.end
assert runtime_error?
*--#] cov_norm_divzero :

*--#[ cov_expr_args :
* expression definition with prototype arguments of all four types
* probe: clean
* expression definition with prototype arguments of all four types
Symbol x;
Index i;
Vector p;
Function g;
Local f(x,i,p,g)=x;
.sort
Print;
.end
assert succeeded?
assert result("f(x,i,p,g)") =~ expr("x")
*--#] cov_expr_args :

*--#[ cov_goog_0000_funny_vector_self :
* farm probe goog_0000_funny_vector_self_8 (+6 lines)
* probe: clean
Vector v;
Local F = v(v);
Print;
.end
assert succeeded?
assert result("F") =~ expr("v.v")
*--#] cov_goog_0000_funny_vector_self :

*--#[ cov_arg_powdiff :
* farm probe 0013_arg_powdiff_24 (+5 lines)
* probe: clean
Symbol x;
CFunction f;
Local s = f(x^5,x^2,3*x^3);
Argument f, x^2;
  id x = x/2;
EndArgument;
Print;
.end
assert compile_error?('x is not')
*--#] cov_arg_powdiff :

*--#[ cov_dolzero :
* farm probe 0099_dolzero_10 (+5 lines)
* runtime $-variables force sequential mode under threads
* probe: clean
Symbol x,y;
CFunction f;
$a = x*y;
$b = 3;
$c = (x - x);
$d = 0;
.sort
Local t = $a + $b + $c + $d;
Print;
.end
#pend_if threaded?
assert runtime_error?
*--#] cov_dolzero :

*--#[ cov_dolidx :
* farm probe 0099_dolidx_11 (+6 lines)
* runtime $-variables force sequential mode under threads
* probe: clean
Index i;
CFunction f,g;
$a = i;
.sort
Local t = f($a);
Print;
.end
#pend_if threaded?
assert runtime_error?
*--#] cov_dolidx :

*--#[ cov_isfact_notexpr :
* expected: is not an expression
* probe: error
* expected: is not an expression
Symbol q,x;
Local t = x;
If ( isfactorized(q) ) Id x = 1;
.end
assert compile_error?('q is not')
*--#] cov_isfact_notexpr :

*--#[ cov_fact_dollar :
* farm probe 0096_fact_dollar_6 (+10 lines)
* runtime $-variables force sequential mode under threads
* probe: clean
Symbol x;
Local t = 1;
$a = factor_(x^2-1);
id t = t*$a;
Print t;
.end
#pend_if threaded?
assert compile_error?('Illegal use of')
*--#] cov_fact_dollar :

*--#[ cov_copy_alt :
* farm probe 0066_copy_alt_10 (+6 lines)
* probe: clean
Set sortsize 200;
Set scratchsize 200;
Symbol a1,a2,a3,a4,a5;
Local F = (a1+a2+a3+a4+a5)^5;
Local G = 1;
.sort
.copy F,G;
.sort
Print G;
.end
assert preprocess_error?('Unrecognized module terminat')
*--#] cov_copy_alt :

*--#[ cov_seteq_syntax :
* farm probe 0066_seteq_syntax_15 (+10 lines)
* probe: clean
Set sortsize = 200;
Set scratchsize = 200;
Symbol a1,a2,a3;
Local F = (a1+a2+a3)^5;
Local G = 1;
.sort
.copy F to G;
.sort
Print G;
.end
assert preprocess_error?('Unrecognized module term')
*--#] cov_seteq_syntax :

*--#[ cov_divzero :
* expected: Division by zero
* probe: error
* expected: Division by zero
CFunction f;
Local F = f(1);
if ( 4/0 > 0 ) Print;
.end
assert compile_error?('Division by zero!')
*--#] cov_divzero :

*--#[ cov_dol_numfac_bad :
* expected: Problems with argument of NumFactors_
* runtime $-variables force sequential mode under threads
* probe: error
* expected: Problems with argument of NumFactors_
Symbol x;
Local test = x;
$a = test;
Local t = NumFactors_($a,x);
Print;
.end
#pend_if threaded?
assert compile_error?('Definition out of')
*--#] cov_dol_numfac_bad :

*--#[ cov_dotail_pipe_5 :
* DoTail -pipe option; child hits initPresetExternalChannels error path
* probe: clean
* DoTail -pipe option; child hits initPresetExternalChannels error path
* expected child message fragment: Error initializing preset external channels
#system cd $TESTFILEDIR && echo .end > $TESTTMPDIR/cvf4.frm; $FORM -pipe $TESTTMPDIR/cvf4.frm < /dev/null; true
Symbol ok;
Local ok = 1;
Print;
.end
assert compile_error?('name of expression')
*--#] cov_dotail_pipe_5 :

*--#[ cov_divok :
* farm probe 0058_divok_11 (+8 lines)
* probe: clean
Symbol x;
Local t = x;
If ( count(x) == 6/2 ) Id x = 1;
Print;
.end
Symbol x;
Local t = x;
If ( count(x) == 1/2 ) Id x = 1;
Print;
.end
Symbol x;
Local t = x;
If ( 6/2 == 3 ) Id x = 1;
Print;
.end
assert compile_error?('Illegal sequence: f,(count,x)')
*--#] cov_divok :

*--#[ cov_dot_set :
* expected: Illegally formed dotproduct
* probe: error
* expected: Illegally formed dotproduct
Vectors p,q;
Set v: q;
Local t = p.v;
Print;
.end
assert compile_error?('Set without argument')
*--#] cov_dot_set :

*--#[ cov_goog_0000_dimension_out_of_range :
* expected: Dimension_ out of range
* probe: error
* expected: Dimension_ out of range
Index mu = -1000000;
Local F = d_(mu, mu);
Print;
.end
assert compile_error?('Illegal di')
*--#] cov_goog_0000_dimension_out_of_range :

*--#[ cov_goog_0000_root_unity_overflow :
* expected: Power overflow during normalization
* probe: error
* expected: Power overflow during normalization
Symbol x(5);
Local F = x^30000 * x^30000 * x^30000;
Print;
.end
assert compile_error?('Undeclared va')
*--#] cov_goog_0000_root_unity_overflow :

*--#[ cov_pipe_from_stream :
* target: alternative #fromexternal syntax (no filename); also hits do_run_cmd first
* probe: error
* target: alternative #fromexternal syntax (no filename); also hits do_run_cmd first
* expected: Cannot open
#pipe 1, /bin/echo "Local z = 9;"
#fromexternal 1
#closeexternal 1
.end
assert runtime_error?
*--#] cov_pipe_from_stream :

*--#[ cov_factorize_sub :
* Factorize with subexpression option (best attempt at exact syntax)
* probe: clean
* Factorize with subexpression option (best attempt at exact syntax)
Symbol a,b,c;
Local test = (a+b)*(a+b+c);
Factorize test, sub;
.sort
Print;
.end
assert succeeded?
assert result("test") =~ expr("( c + b + a )
* ( b + a )")
*--#] cov_factorize_sub :

*--#[ cov_mod101_same_mod :
* farm probe 0191_mod101_same_mod_3 (+27 lines)
* probe: clean
Symbol x;
Modulus 101;
Local f = x^7+x^2+1;
Local g = x^6+x+1;
Factorize f;
Factorize g;
Print;
.end
assert succeeded?
assert result("f") =~ expr("( 1 + x + x^2 )
* ( 1 + 100*x + x^2 + 100*x^4 + x^5 )")
assert result("g") =~ expr("( 54 + 65*x + 73*x^2 + 38*x^3 + x^4 )
* ( 58 + 63*x + x^2 )")
*--#] cov_mod101_same_mod :

*--#[ cov_clearall_2 :
* farm probe 0065_clearall_0 (+5 lines)
* probe: clean
Symbol x,y;
Vector v;
Index i;
CFunction f;
Set s: x,y;
Table tb(1:2,1:2);
.sort
Fill tb(1,1) = 5;
.sort
Local t = f(x)*v(i) + tb(1,1);
.sort
Print;
.clear
.sort
Local u = 1;
Print;
.end
assert succeeded?
assert result("u") =~ expr("1")
*--#] cov_clearall_2 :

*--#[ cov_bigexp_2 :
* large expansion inside Substitute; attempts workspace check path 654-658
* probe: clean
* large expansion inside Substitute; attempts workspace check path 654-658
Symbol x,y;
CFunction f;
Local test = f(x);
id f(x?) = (y+1)^50000;
.end
assert runtime_error?
*--#] cov_bigexp_2 :

*--#[ cov_sort1_properorder :
* guess: On properorder sets AC.properorderflag (sort.c:2765-2773 CompArg loop)
* probe: clean
* guess: On properorder sets AC.properorderflag (sort.c:2765-2773 CompArg loop)
CFunction f,g;
Symbol x,y;
On properorder;
Local t = f(x+y)*g(x) + f(x)*g(x+y) + f(y)*g(y^2);
.sort
Print;
.end
assert succeeded?
assert result("t") =~ expr("f(y + x)*g(x) + f(x)*g(y + x) + f(y)*g(y^2)")
*--#] cov_sort1_properorder :

*--#[ cov_mkrat_bignum :
* hits normal.c 963-978 (big arg1), 984-990, 1014-1023 (DivLong), 1035-1043
* probe: clean
* hits normal.c 963-978 (big arg1), 984-990, 1014-1023 (DivLong), 1035-1043
Local test = MakeRational_(123456789012345678901234567890,5);
Print;
.end
assert succeeded?
assert result("test") =~ expr("0/0")
*--#] cov_mkrat_bignum :

*--#[ cov_nsdollar :
* dollar variable assignment inside namespace (ConstructName '$' case)
* runtime $-variables force sequential mode under threads
* probe: clean
* dollar variable assignment inside namespace (ConstructName '$' case)
#namespace nsdollar
Symbol q;
Local F = q;
$dd = F + 1;
Print F;
#endnamespace
.end
#pend_if threaded?
assert succeeded?
assert result("F") =~ expr("q")
*--#] cov_nsdollar :

*--#[ cov_ddrep6 :
* farm probe 0118_ddrep6_5 (+13 lines)
* probe: clean
Vector p1,p2,p3;
Local test = dd_(p1,p1,p2,p2,p3,p3);
Print;
.end
assert succeeded?
assert result("test") =~ expr("p1.p1*p2.p2*p3.p3 + 2*p1.p1*p2.p3^2 + 8*p1.p2*p1.p3*p2.p3 + 2*p1.p2^2*
p3.p3 + 2*p1.p3^2*p2.p2")
*--#] cov_ddrep6 :

*--#[ cov_rev_raw :
* farm probe 0160_rev_raw_9 (+33 lines)
* probe: clean
Symbol a,b,c;
Function f;
Local F = f(reverse_(a,b,c));
Print;
.end
assert succeeded?
assert result("F") =~ expr("f(c,b,a)")
*--#] cov_rev_raw :

*--#[ cov_sym_fixzero :
* note: should emit Warning "Restriction to zero arguments removed"
* probe: clean
* note: should emit Warning "Restriction to zero arguments removed"
Symbol x;
CFunction f;
Local test = f(1,2);
Symmetrize f:0;
Print;
.end
assert warning?('Restriction to ze')
assert result("test") =~ expr("f(1,2)")
*--#] cov_sym_fixzero :

*--#[ cov_sym_groups :
* farm probe 0124_sym_groups_2 (+21 lines)
* probe: clean
Symbol x;
CFunction f;
Local test = f(1,2,3,4);
Symmetrize f(1,2),(3,4);
Print;
.end
assert succeeded?
assert result("test") =~ expr("f(1,2,3,4)")
*--#] cov_sym_groups :

*--#[ cov_dim_ok :
* target: names.c:1481-1502 dimension field {d=...}
* probe: clean
* target: names.c:1481-1502 dimension field {d=...}
Function f{d=4};
Local test = f(1,2);
Print;
.end
assert succeeded?
assert result("test") =~ expr("f(1,2)")
*--#] cov_dim_ok :

*--#[ cov_rr_msg :
* expansion inside #message (output capture variant)
* probe: clean
* expansion inside #message (output capture variant)
#message `RANDOM_(lin,0.5,0.5)'
Symbol x;
Local t = 1;
Print;
.end
assert succeeded?
assert result("t") =~ expr("1")
*--#] cov_rr_msg :

*--#[ cov_ddsort :
* farm probe 0118_ddsort_2 (+6 lines)
* probe: clean
Vector p1,p2,p3,p4;
Local test = dd_(p3,p1,p4,p2);
Print;
.end
assert succeeded?
assert result("test") =~ expr("p1.p2*p3.p4 + p1.p3*p2.p4 + p1.p4*p2.p3")
*--#] cov_ddsort :

*--#[ cov_rat_small :
* target: reken.c GcdLong small-arg branch (lines 2457-2462, na==1 case line 2459)
* probe: clean
* target: reken.c GcdLong small-arg branch (lines 2457-2462, na==1 case line 2459)
Local r = MakeRational_(3,5);
Local s = MakeRational_(-8,6);
Local t = MakeRational_(7,7);
Local u = MakeRational_(1000003,1000003);
Print r,s,t,u;
.end
assert warning?('fraction could not')
assert result("r") =~ expr("- 2")
assert result("s") =~ expr("- 2")
assert result("t") =~ expr("7")
assert result("u") =~ expr("1000003")
*--#] cov_rat_small :

*--#[ cov_sort1_powtype_c :
* alternative guess: On powerfirst;
* probe: clean
* alternative guess: On powerfirst;
Symbol x,y;
On powerfirst;
Local t = x + x*y + x^2*y + x*y^3 + y^2 + x^2;
.sort
Print;
.end
assert succeeded?
assert result("t") =~ expr("x*y^3 + x^2*y + x^2 + x*y + y^2 + x")
*--#] cov_sort1_powtype_c :

*--#[ cov_revinc_ok :
* hits tools.c:354 (REVERSEFILESTREAM + ReverseStatements)
* probe: clean
* hits tools.c:354 (REVERSEFILESTREAM + ReverseStatements)
#system cd $TESTFILEDIR && { printf "Local ra = 1;\nLocal rb = 2;\n" > rev.inc; } 2>/dev/null
#reverseinclude rev.inc
Print;
.end
assert succeeded?
assert result("rb") =~ expr("2")
assert result("ra") =~ expr("1")
*--#] cov_revinc_ok :

*--#[ cov_rev_raw0 :
* farm probe 0160_rev_raw0_10 (+5 lines)
* probe: clean
Function f;
Local F = f(reverse_);
Print;
.end
assert succeeded?
assert result("F") =~ expr("f")
*--#] cov_rev_raw0 :

*--#[ cov_unhide_global :
* farm probe 0173_unhide_global_6 (+7 lines)
* probe: clean
Symbol x;
Global f = x;
.sort
Hide f;
.sort
UnHide f;
.sort
Print f;
.end
assert succeeded?
assert result("f") =~ expr("x")
*--#] cov_unhide_global :

*--#[ cov_set_ordered :
* farm probe 0193_set_ordered_4 (+20 lines)
* probe: clean
Symbol a,b;
Set v(ordered): a,b;
Local t = a*b;
Print;
.end
assert succeeded?
assert result("t") =~ expr("a*b")
*--#] cov_set_ordered :

*--#[ cov_dimfield :
* dimension field {d=...} on a symbol declaration
* probe: clean
* dimension field {d=...} on a symbol declaration
Symbol x{d=4};
Local t = x;
Print;
.end
assert succeeded?
assert result("t") =~ expr("x")
*--#] cov_dimfield :

*--#[ cov_fmt_float :
* Format Float with no arg (OutNumberType=10) and too-small precision
* probe: clean
* Format Float with no arg (OutNumberType=10) and too-small precision
* (compcomm.c 329-344, warning ... float format value corrected to 3)
Symbol x;
Local t = x;
Format Float;
Format Float,1;
Print;
.end
assert compile_error?('... float format')
*--#] cov_fmt_float :

*--#[ cov_ddempty :
* farm probe 0118_ddempty_7 (+11 lines)
* probe: clean
Local test = dd_();
Print;
.end
assert succeeded?
assert result("test") =~ expr("1")
*--#] cov_ddempty :

*--#[ cov_intohide_global :
* farm probe 0173_intohide_global_8 (+7 lines)
* probe: clean
Symbol x;
Global f = x;
.sort
IntoHide f;
.sort
.end
assert succeeded?
*--#] cov_intohide_global :

*--#[ cov_pbtbl_sflag :
* farm probe 0195_pbtbl_sflag_2 (+14 lines)
* probe: clean
Table t(1:3,1:2);
Fill t(1,1)=1, t(3,2)=2;
PrintTable +s t;
Print;
.end
assert compile_error?('Illegal character at')
*--#] cov_pbtbl_sflag :

*--#[ cov_expr_notexpr :
* expected: is not an expression
* probe: error
* expected: is not an expression
Symbol q,x;
Local t = x;
If ( expression(q) ) Id x = 1;
.end
assert compile_error?('q is not')
*--#] cov_expr_notexpr :

*--#[ cov_pbtbl_sfcomma :
* farm probe 0195_pbtbl_sfcomma_3 (+7 lines)
* probe: clean
Table t(1:2);
Fill t(1,1)=1;
PrintTable +s,+f t;
Print;
.end
assert compile_error?('Incorrect number of')
*--#] cov_pbtbl_sfcomma :

*--#[ cov_pbtbl_flagjunk :
* expected: Illegal + option in PrintTable statement
* probe: error
* expected: Illegal + option in PrintTable statement
Table t(1:2);
Fill t(1,1)=1;
PrintTable +fzz t;
.end
assert compile_error?('Incorrect number of')
*--#] cov_pbtbl_flagjunk :

*--#[ cov_pbtbl_fileout :
* farm probe 0195_pbtbl_fileout_5 (+7 lines)
* probe: clean
Table t(1:2);
Fill t(1,1)=1;
PrintTable t > tbl_out.txt;
Print;
.end
assert compile_error?('Incorrect number of')
*--#] cov_pbtbl_fileout :

*--#[ cov_modcoeff :
* farm probe 0186_modcoeff_3 (+10 lines)
* probe: clean
Symbol x;
Function f;
Modulus 7,coefficientsonly;
Local t = f(x+1)+x^9;
Print t;
Modulus;
.end
assert compile_error?('Declaration out of')
*--#] cov_modcoeff :

*--#[ cov_star :
* star-table fill, syntax variant A: negative count in declaration
* probe: clean
* star-table fill, syntax variant A: negative count in declaration
Table t(-(3),1:10);
Fill t(1,5)=25;
Fill t(2,3,4)=12;
Fill t(3,1,2,3)=9;
Local z = 1;
Print z;
.end
assert compile_error?('Illegal character at')
*--#] cov_star :

*--#[ cov_seteq_syntax_2 :
* farm probe 0066_seteq_syntax_15 (+10 lines)
* probe: clean
Set sortsize = 200;
Set scratchsize = 200;
Symbol a1,a2,a3;
Local F = (a1+a2+a3)^5;
Local G = 1;
.sort
.copy F to G;
.sort
Print G;
.end
assert preprocess_error?('Unrecognized module term')
*--#] cov_seteq_syntax_2 :

*--#[ cov_topol_onlyfunc :
* farm probe 0167_topol_onlyfunc_1 (+27 lines)
* probe: clean
Symbol x;
CFunction f,g,h;
ToPolynomial onlyfunctions f,g;
Local t = f(x) + g(x) + h(x);
Print;
.end
assert compile_error?('Definition out of')
*--#] cov_topol_onlyfunc :

*--#[ cov_dotail_pipe_6 :
* DoTail -pipe option; child hits initPresetExternalChannels error path
* probe: clean
* DoTail -pipe option; child hits initPresetExternalChannels error path
* expected child message fragment: Error initializing preset external channels
#system cd $TESTFILEDIR && echo .end > $TESTTMPDIR/cvf4.frm; $FORM -pipe $TESTTMPDIR/cvf4.frm < /dev/null; true
Symbol ok;
Local ok = 1;
Print;
.end
assert compile_error?('name of expression')
*--#] cov_dotail_pipe_6 :

*--#[ cov_cnt_doterr :
* expected: Illegal use of . after
* probe: error
* expected: Illegal use of . after
* dot after a symbol in count: compcomm.c 4094-4105
Symbol x,y;
Local test = x^2;
If ( count(x.y,1,1) ) Print "yes";
Print;
.end
assert compile_error?('Illegal use of')
*--#] cov_cnt_doterr :

*--#[ cov_set_dim :
* farm probe 0193_set_dim_7 (+16 lines)
* probe: clean
Symbol a,b;
Set v{d=3}: a,b;
Local t = a*b;
Print;
.end
assert compile_error?('Dimension check failed')
*--#] cov_set_dim :

*--#[ cov_cnt_notvec :
* expected: Not a vector in dotproduct
* probe: error
* expected: Not a vector in dotproduct
* vector.symboldot in count: compcomm.c 4088-4091
Vector p;
Symbol y;
Local test = p;
If ( count(p.y,1,1) ) Print "yes";
Print;
.end
assert compile_error?('Not a vector')
*--#] cov_cnt_notvec :

*--#[ cov_dol_factor_dynindex :
* farm probe 0172_dol_factor_dynindex_5 (+12 lines)
* runtime $-variables force sequential mode under threads
* probe: clean
Symbol x;
$n = 1;
$x = 5*x;
Factorize $x;
$y = 0;
If ($x[$n] > 3) $y = 1;
Print $y;
.end
#pend_if threaded?
assert compile_error?('Illegal object in')
*--#] cov_dol_factor_dynindex :

*--#[ cov_cnt_dot :
* hits dotproduct count path: compcomm.c 4080-4092, 4131-4135, Sgetnum
* probe: clean
* hits dotproduct count path: compcomm.c 4080-4092, 4131-4135, Sgetnum
Vector p,q;
Local test = p.q;
If ( count(p.q,1,1) ) Print "yes";
Print;
.end
assert compile_error?('Illegal name: unt,p.q,1,1')
*--#] cov_cnt_dot :

*--#[ cov_cnt_vecparen :
* expected: specifier for vector
* probe: error
* expected: specifier for vector
* vector followed by ) in count: compcomm.c 4194-4200
Vector p;
Local test = p;
If ( count(p) ) Print "yes";
Print;
.end
assert compile_error?('Illegal specifier for')
*--#] cov_cnt_vecparen :

*--#[ cov_fmt_oopt :
* expected: Illegal optimization specification in format statement
* probe: error
* expected: Illegal optimization specification in format statement
* trailing option after O<num> -> CoOptimizeOption (compcomm.c 227),
* then out-of-range level -> switch default (compcomm.c 222-225)
Symbol x;
Local t = x;
Format O2,compress;
Format O9;
Print;
.end
assert compile_error?('Correct use in')
*--#] cov_fmt_oopt :

*--#[ cov_fmt_ls :
* linesize corrections and junk trailing field (compcomm.c 272-291)
* probe: clean
* linesize corrections and junk trailing field (compcomm.c 272-291)
* warnings expected: Too small value for linesize corrected to 39,
* Illegal value for linesize: 0, Illegal linesize field in format statement
Symbol x;
Local t = x;
Format 10;
Format 0;
Format 72abc;
Print;
.end
assert compile_error?('Illegal value for')
*--#] cov_fmt_ls :

*--#[ cov_fmt_cmode :
* Format C<num> -> CMODE/Cnumpows (compcomm.c 415-422), then bad
* probe: clean
* Format C<num> -> CMODE/Cnumpows (compcomm.c 415-422), then bad
* suffix -> goto Unknown (compcomm.c 419, 424)
Symbol x;
Local t = x;
Format C3;
Format C3x;
Print;
.end
assert compile_error?('Unknown option: C3x')
*--#] cov_fmt_cmode :

*--#[ cov_dol_def_bt_err :
* expected: Illegal factor number for dollar variable
* runtime $-variables force sequential mode under threads
* probe: error
* expected: Illegal factor number for dollar variable
* tools.c:403-404 via backtick substitution
Symbol x,y,z;
$n = 3;
#define m `$n[]'
.end
#pend_if threaded?
assert preprocess_error?('Illegal factor number')
*--#] cov_dol_def_bt_err :

*--#[ cov_azur_0001_0003_dolnumber_simple :
* farm probe azur_0001_0003_dolnumber_simple_2 (+5 lines)
* probe: clean
Symbol a;
Local F = a*$1^2;
Print;
.end
assert runtime_error?
*--#] cov_azur_0001_0003_dolnumber_simple :

*--#[ cov_rr_lin_big :
* hits %3f/%2f/%1f and big "%e" branches (reken.c:3995-3996,4005-4007)
* probe: clean
* hits %3f/%2f/%1f and big "%e" branches (reken.c:3995-3996,4005-4007)
#define v1`RANDOM_(lin,500,500)'
#define v2`RANDOM_(lin,5000,5000)'
#define v3`RANDOM_(lin,50000,50000)'
#define v4`RANDOM_(lin,2000000,2000000)'
Symbol x;
Local t = 1;
Print;
.end
assert preprocess_error?('Illegal string for')
*--#] cov_rr_lin_big :

*--#[ cov_revinc_end :
* expected: reverseinclude
* probe: error
* expected: reverseinclude
* tries ReverseStatements failure -> tools.c:355-356
#system cd $TESTFILEDIR && { printf ".end\n" > revend.inc; } 2>/dev/null
#reverseinclude revend.inc
Print;
.end
assert succeeded?
*--#] cov_revinc_end :

*--#[ cov_enddo_missing :
* expected: enddo statement(s) missing
* probe: error
* expected: enddo statement(s) missing
Symbol i;
Do i = 1,3;
.end
assert compile_error?('do loop parameter')
*--#] cov_enddo_missing :

*--#[ cov_cplx_bad :
* expected: Illegal specification for complexity of f
* probe: error
* expected: Illegal specification for complexity of f
Function f#q;
.end
assert compile_error?('Illegal specification for')
*--#] cov_cplx_bad :

*--#[ cov_nsuse :
* guess at #use directive to expose namespace names outside
* probe: clean
* guess at #use directive to expose namespace names outside
#namespace nsuse
#define w 4
#endnamespace
#use nsuse
#message `w'
#end
.end
assert preprocess_error?('Illegal string for')
*--#] cov_nsuse :

*--#[ cov_extchan_open :
* farm probe 0187_extchan_open_0 (+7 lines)
* probe: clean
#externalchannel "echo x = 17"
#fromexternal x
#show x
.end
assert preprocess_error?('Unrecognized preprocessor')
*--#] cov_extchan_open :

*--#[ cov_err_nonpoly :
* expected: not a polynomial
* probe: error
* expected: not a polynomial
Symbol x,y;
CFunction f;
Local F = f(1)*(x+y+1)*(x+2*y+2);
Factorize F;
Print;
.end
assert succeeded?
assert result("F") =~ expr("( 1 + y + x )
* ( 2 + 2*y + x )
* ( f(1) )")
*--#] cov_err_nonpoly :

*--#[ cov_mv_highdeg :
* high degrees in each variable -> ideal-adic Newton iteration loop
* probe: clean
* high degrees in each variable -> ideal-adic Newton iteration loop
Symbol x,y;
Local F = (x+y^2+1)*(x*y+x+y^3+2)*(2*x+y^2+y+3);
Factorize F;
Print;
.end
assert succeeded?
assert result("F") =~ expr("( 1 + y^2 + x )
* ( 2 + y^3 + x + x*y )
* ( 3 + y + y^2 + 2*x )")
*--#] cov_mv_highdeg :

*--#[ cov_clearall_3 :
* farm probe 0065_clearall_0 (+5 lines)
* probe: clean
Symbol x,y;
Vector v;
Index i;
CFunction f;
Set s: x,y;
Table tb(1:2,1:2);
.sort
Fill tb(1,1) = 5;
.sort
Local t = f(x)*v(i) + tb(1,1);
.sort
Print;
.clear
.sort
Local u = 1;
Print;
.end
assert succeeded?
assert result("u") =~ expr("1")
*--#] cov_clearall_3 :

*--#[ cov_bigexp_3 :
* large expansion inside Substitute; attempts workspace check path 654-658
* probe: clean
* large expansion inside Substitute; attempts workspace check path 654-658
Symbol x,y;
CFunction f;
Local test = f(x);
id f(x?) = (y+1)^50000;
.end
assert runtime_error?
*--#] cov_bigexp_3 :

*--#[ cov_putinside_multi :
* farm probe 0216_putinside_multi_3 (+18 lines)
* probe: clean
Vector p;
Symbol x,y;
Function f;
Local t = f(x,y,p) + f(p.p);
PutInside f, x, y, p, p.p, d_;
Print;
.end
assert succeeded?
assert result("t") =~ expr("f(p.p)*f(1) + f(x,y,p)*f(1)")
*--#] cov_putinside_multi :

*--#[ cov_r02_rand_big :
* random_ with very large n (long-number paste path)
* random_ with very large n (long-number paste path)
#setrandom 89
Local F = random_(1000000000000000000000000);
.sort
Print F;
.end
assert succeeded?
assert result("F") =~ expr("864792395326970427174710")
*--#] cov_r02_rand_big :

*--#[ cov_nsdollar_2 :
* dollar variable assignment inside namespace (ConstructName '$' case)
* runtime $-variables force sequential mode under threads
* probe: clean
* dollar variable assignment inside namespace (ConstructName '$' case)
#namespace nsdollar
Symbol q;
Local F = q;
$dd = F + 1;
Print F;
#endnamespace
.end
#pend_if threaded?
assert succeeded?
assert result("F") =~ expr("q")
*--#] cov_nsdollar_2 :

*--#[ cov_sum_dollarloop :
* farm probe 0209_sum_dollarloop_2 (+18 lines)
* runtime $-variables force sequential mode under threads
* probe: clean
CFunction f;
Index i,j;
Local e = f(i,j);
$a = 1;
$b = 2;
Sum i,$a,$b;
Print;
.end
#pend_if threaded?
assert runtime_error?
*--#] cov_sum_dollarloop :

*--#[ cov_commute_tensor :
* tensor functions under CommuteInSet: raw-word compare branch
* probe: clean
* tensor functions under CommuteInSet: raw-word compare branch
Tensor t1,t2;
Vector p,q;
CommuteInSet {t1,t2},{t1,t2};
Local test = t1(p,q)*t2(p);
id t1(p?) = t2(p);
Print;
.end
assert compile_error?('t1 is not')
*--#] cov_commute_tensor :

*--#[ cov_deepnest :
* three levels of nested dollar factors
* runtime $-variables force sequential mode under threads
* probe: clean
* three levels of nested dollar factors
Symbol x;
$i = 5;
$j = 2;
$k = 3;
Local test = x;
if ( $i[$j[$k[2]]] > 0 ) id x = 1;
Print test;
.end
#pend_if threaded?
assert compile_error?('Definition out of')
*--#] cov_deepnest :

*--#[ cov_r10_setmember :
* dollar set-membership test (dollar.c IsSetMember)
* runtime $-variables force sequential mode under threads
* dollar set-membership test (dollar.c IsSetMember)
Symbols a,b,x;
$r1 = a in {a,b};
$r2 = x in {a,b};
Local T1 = $r1;
Local T2 = $r2;
.sort
Print T1;
Print T2;
.end
#pend_if threaded?
assert compile_error?('Illegal position for')
*--#] cov_r10_setmember :

*--#[ cov_seteq_syntax_3 :
* farm probe 0066_seteq_syntax_15 (+10 lines)
* probe: clean
Set sortsize = 200;
Set scratchsize = 200;
Symbol a1,a2,a3;
Local F = (a1+a2+a3)^5;
Local G = 1;
.sort
.copy F to G;
.sort
Print G;
.end
assert preprocess_error?('Unrecognized module term')
*--#] cov_seteq_syntax_3 :

*--#[ cov_bigfactor :
* expected: Value in dollar factor too large
* runtime $-variables force sequential mode under threads
* probe: error
* expected: Value in dollar factor too large
Symbol x;
$i = 1;
Local test = x;
if ( $i[99999999999999999999] > 0 ) id x = 1;
Print test;
.end
#pend_if threaded?
assert compile_error?('Definition out of')
*--#] cov_bigfactor :

*--#[ cov_dotail_pipe_7 :
* DoTail -pipe option; child hits initPresetExternalChannels error path
* probe: clean
* DoTail -pipe option; child hits initPresetExternalChannels error path
* expected child message fragment: Error initializing preset external channels
#system cd $TESTFILEDIR && echo .end > $TESTTMPDIR/cvf4.frm; $FORM -pipe $TESTTMPDIR/cvf4.frm < /dev/null; true
Symbol ok;
Local ok = 1;
Print;
.end
assert compile_error?('name of expression')
*--#] cov_dotail_pipe_7 :

*--#[ cov_pre_incr :
* farm probe 0244_pre_incr_7 (+9 lines)
* probe: clean
#do idx = 1,3
    #message value `idx++'
#enddo
.end
assert succeeded?
*--#] cov_pre_incr :

*--#[ cov_pre_showinput_ :
* farm probe 0244_pre_showinput__2 (+5 lines)
* probe: clean
#message showinput = `SHOWINPUT_'
.end
assert succeeded?
*--#] cov_pre_showinput_ :

*--#[ cov_pre_time_ :
* farm probe 0244_pre_time__0 (+13 lines)
* probe: clean
#message running time = `time_'
.end
assert succeeded?
*--#] cov_pre_time_ :

*--#[ cov_0902_remove_inside_module :
* farm probe 0232_0902_remove_inside_module_10 (+5 lines)
* probe: clean
Symbol x,y;
CFunction f;
#add dm:1,2,3;
Local t = f(x,y);
.sort
#remove dm;
Print t;
.end
assert preprocess_error?('there is no')
*--#] cov_0902_remove_inside_module :

*--#[ cov_nsuse_2 :
* guess at #use directive to expose namespace names outside
* probe: clean
* guess at #use directive to expose namespace names outside
#namespace nsuse
#define w 4
#endnamespace
#use nsuse
#message `w'
#end
.end
assert preprocess_error?('Illegal string for')
*--#] cov_nsuse_2 :

*--#[ cov_fact_basic :
* farm probe 0079_fact_basic_12 (+12 lines)
* probe: clean
Symbol x,y;
Local e = (1+x)*(2+x*y);
Factorize e;
Print;
.end
assert succeeded?
assert result("e") =~ expr("( 1 + x )
* ( 2 + x*y )")
*--#] cov_fact_basic :

*--#[ cov_modulus_2 :
* farm probe 0133_modulus_10 (+66 lines)
* probe: clean
Function f;
Modulus 7;
Symbol a,b,x;
Local test = f(x*a + x*b);
FactArg f;
Print;
.end
assert succeeded?
assert result("test") =~ expr("f(x,b + a)")
*--#] cov_modulus_2 :

*--#[ cov_fact_pownegsym :
* farm probe 0079_fact_pownegsym_15 (+6 lines)
* probe: clean
Symbol x,y,n;
Local e = y^-n*x;
Factorize e;
Print;
.end
assert succeeded?
assert result("e") =~ expr("( (y)^( - n) )
* ( x )")
*--#] cov_fact_pownegsym :

*--#[ cov_factarg_frac :
* nontrivial denominator: den.is_one() false branch
* probe: clean
* nontrivial denominator: den.is_one() false branch
Symbol x,y;
CFunction f;
Local test = f((x^2-1)/3);
FactArg f;
Print;
.end
assert succeeded?
assert result("test") =~ expr("f(1/3, - 1 + x,1 + x)")
*--#] cov_factarg_frac :

*--#[ cov_fort_brk :
* farm probe 0089_fort_brk_23 (+8 lines)
* probe: clean
Symbol x,y,z;
Format Fortran;
Format O1;
Local F = (x+y+z)^6 + (x-y-z)^4;
Bracket x,y;
Print F;
.end
assert succeeded?
*--#] cov_fort_brk :

*--#[ cov_powset :
* farm probe 0025_powset_15 (+6 lines)
* probe: clean
Symbol x,a,b,n;
Set s: a,b;
CFunction f,g;
Local t = f(x^a) + f(x^b) + f(x^3);
id f(x^n?s) = g(x^n);
Print;
.end
assert succeeded?
assert result("t") =~ expr("f(x^3) + f((x)^(a)) + f((x)^(b))")
*--#] cov_powset :

*--#[ cov_fun_multi :
* farm probe 0133_fun_multi_6 (+5 lines)
* probe: clean
Function f,g,h;
Symbol a,b,x,y;
Local test = f(g(x)*h(y)*a + g(x)*h(y)*b);
FactArg f;
Print;
.end
assert succeeded?
assert result("test") =~ expr("f(b + a,g(x),h(y))")
*--#] cov_fun_multi :

*--#[ cov_factorsym :
* speculative: FACTORSYMBOL/HAAKJE/fromindex branch (sort.c 2462-2465) via nested subexpressions
* probe: clean
* speculative: FACTORSYMBOL/HAAKJE/fromindex branch (sort.c 2462-2465) via nested subexpressions
Symbol x,y;
CFunction gcf;
PolyFun gcf;
Local test = (gcf(x+1)+x^2)*(gcf(x+1)-x^2);
Print;
.end
assert succeeded?
assert result("test") =~ expr("x^4*gcf(-1) + gcf(1 + 2*x + x^2)")
*--#] cov_factorsym :

*--#[ cov_bigexp_4 :
* large expansion inside Substitute; attempts workspace check path 654-658
* probe: clean
* large expansion inside Substitute; attempts workspace check path 654-658
Symbol x,y;
CFunction f;
Local test = f(x);
id f(x?) = (y+1)^50000;
.end
assert runtime_error?
*--#] cov_bigexp_4 :

*--#[ cov_trace_rep22 :
* repeated indices: factor/multiplicity branch (opera.c 1714-1733)
* probe: clean
* repeated indices: factor/multiplicity branch (opera.c 1714-1733)
Vector p1,p2;
Local F = g_(1,p1,p2,p1,p2);
trace4,1;
Print;
.end
assert succeeded?
assert result("F") =~ expr("- 4*p1.p1*p2.p2 + 8*p1.p2^2")
*--#] cov_trace_rep22 :

*--#[ cov_gcd_exprvec :
* target: ratio.c lines 762-763 and 797-805 (vector/index firstshort at output)
* probe: clean
* target: ratio.c lines 762-763 and 797-805 (vector/index firstshort at output)
Vector p,q;
Symbol x;
Local e1 = p^2;
Local test = gcd_(e1,p);
Print;
.end
assert succeeded?
assert result("e1") =~ expr("p*p")
assert result("test") =~ expr("p")
*--#] cov_gcd_exprvec :

*--#[ cov_rat_zero_one :
* farm probe 0156_rat_zero_one_22 (+5 lines)
* probe: clean
Symbol x,y;
Local t = MakeRational_(0, x^2*y);
Local u = MakeRational_(1, x*y^-1);
Print t;
Print u;
.end
assert succeeded?
assert result("t") =~ expr("0")
assert result("u") =~ expr("makerational_(1,x*y^-1)")
*--#] cov_rat_zero_one :

*--#[ cov_dth_onearg :
* target: normal.c DoTheta 4359-4364, single general argument paths
* probe: clean
* target: normal.c DoTheta 4359-4364, single general argument paths
Symbol x,y;
Local t1 = theta_(x);
Local t2 = theta_(x+y);
Print;
.end
assert succeeded?
assert result("t1") =~ expr("theta_(x)")
assert result("t2") =~ expr("theta_(y + x)")
*--#] cov_dth_onearg :

*--#[ cov_tr_pairs :
* farm probe 0180_tr_pairs_5 (+6 lines)
* probe: clean
Symbol x,y;
CFunction f,g;
Local test = x + f(1);
TryReplace x, y, f, g;
Print;
.end
assert succeeded?
assert result("test") =~ expr("y + f(1)")
*--#] cov_tr_pairs :

*--#[ cov_nsdollar_3 :
* dollar variable assignment inside namespace (ConstructName '$' case)
* runtime $-variables force sequential mode under threads
* probe: clean
* dollar variable assignment inside namespace (ConstructName '$' case)
#namespace nsdollar
Symbol q;
Local F = q;
$dd = F + 1;
Print F;
#endnamespace
.end
#pend_if threaded?
assert succeeded?
assert result("F") =~ expr("q")
*--#] cov_nsdollar_3 :

*--#[ cov_dth_moreterms :
* target: normal.c DoTheta 4409-4410, first arg has more terms (tb >= stopb)
* probe: clean
* target: normal.c DoTheta 4409-4410, first arg has more terms (tb >= stopb)
Symbol x,y;
Local test = theta_(x+y,x);
Print;
.end
assert succeeded?
assert result("test") =~ expr("1")
*--#] cov_dth_moreterms :

*--#[ cov_fun_miss :
* farm probe 0133_fun_miss_5 (+5 lines)
* probe: clean
Function f,g;
Symbol a,b,x,y;
Local test = f(g(x)*a + g(y)*b);
FactArg f;
Print;
.end
assert runtime_error?
*--#] cov_fun_miss :

*--#[ cov_tr_index :
* farm probe 0180_tr_index_2 (+5 lines)
* probe: clean
Index i,j;
CFunction f;
Local test = f(i);
TryReplace i, j;
Print;
.end
assert succeeded?
assert result("test") =~ expr("f(i)")
*--#] cov_tr_index :

*--#[ cov_tr_minvec :
* farm probe 0180_tr_minvec_4 (+12 lines)
* probe: clean
Vector p,q;
CFunction f;
Local test = f(p);
TryReplace p, -q;
Print;
.end
assert succeeded?
assert result("test") =~ expr("f(p)")
*--#] cov_tr_minvec :

*--#[ cov_abs_negnum :
* farm probe 0004_abs_negnum_8 (+5 lines)
* probe: clean
Local test = abs_(-5);
Print;
.end
assert succeeded?
assert result("test") =~ expr("5")
*--#] cov_abs_negnum :

*--#[ cov_4221_zz_paren :
* expected: 0^0 during normalization of term
* probe: error
* expected: 0^0 during normalization of term
Local test = (0)^(1-1);
Print;
.end
assert runtime_error?
*--#] cov_4221_zz_paren :

*--#[ cov_popts :
* Print with +s, +ss and +sss option chains
* probe: clean
* Print with +s, +ss and +sss option chains
Symbol x,y;
Local t = x*y;
Print +s t;
Print +ss t;
Print +sss t;
.end
assert succeeded?
assert result("t") =~ expr("+
x
*y")
*--#] cov_popts :

*--#[ cov_missing_endwhile :
* expected: endwhile statement(s) missing
* probe: error
* expected: endwhile statement(s) missing
Symbol x;
Local t = x;
While ( x > 0 );
  id x = x - 1;
.end
assert compile_error?('Unrecognized word: x')
*--#] cov_missing_endwhile :

*--#[ cov_polyrat_with_polyfun_notexact :
* farm probe 0169_polyrat_with_polyfun_notexact_20 (+7 lines)
* probe: clean
Symbol a,b;
PolyFun f;
PolyRatFun rat;
Local test = f(a^2+1)/f(a);
Print;
.end
assert compile_error?('f should be')
*--#] cov_polyrat_with_polyfun_notexact :

*--#[ cov_vecnotset2 :
* farm probe 0026_vecnotset2_34 (+6 lines)
* probe: clean
Vector p;
Function g;
Set s: 1,2,3;
Symbol x;
Local t = p(1)+p(2);
id p(x?{!s}) = g(x);
Print;
.end
assert compile_error?('Illegal object in')
*--#] cov_vecnotset2 :

*--#[ cov_setflag_wild :
* farm probe 0019_setflag_wild_51 (+7 lines)
* probe: clean
AutoDeclare Symbol a;
CFunction f,g;
Local t = f(1,a);
id f(x?,{1,a}) = g(x);
Print;
.end
assert compile_error?('Undeclared variable x')
*--#] cov_setflag_wild :

*--#[ cov_apply_deep :
* target: tables.c 2101-2110 nested recursion, stilltogo != maxtogo path
* probe: clean
* target: tables.c 2101-2110 nested recursion, stilltogo != maxtogo path
Symbol x,y;
CFunction g,h;
Local templ = g(x?);
Local target = g(h(1+x)+y);
Apply templ to target;
Print;
.end
assert compile_error?('Illegal character at')
*--#] cov_apply_deep :

*--#[ cov_argtoarg_tensor_err :
* expected: Illegal substitution of argument field in tensor
* probe: error
* expected: Illegal substitution of argument field in tensor
AutoDeclare Symbol x,y,a;
Vector p;
CFunction f;
Local t = f(x,y);
id f(?a?) = p(a);
Print;
.end
assert compile_error?('Illegal type of')
*--#] cov_argtoarg_tensor_err :

*--#[ cov_tryreplace_stmt :
* farm probe 0199_tryreplace_stmt_23 (+10 lines)
* probe: clean
Symbols x,y;
CFunctions f,g;
Local test = f(x)*g(f(x)) + f(2);
TryReplace, f(x?) = g(x?);
Print;
.end
assert compile_error?('Illegal object in')
*--#] cov_tryreplace_stmt :

*--#[ cov_fact_factdollar :
* farm probe 0079_fact_factdollar_19 (+9 lines)
* probe: clean
Symbol x,y;
Local e = (1+x)*(1+y);
Factorize e;
FactDollar $d,e;
Print;
.end
assert compile_error?('Statement out of')
*--#] cov_fact_factdollar :

*--#[ cov_seteq_syntax_4 :
* farm probe 0066_seteq_syntax_15 (+10 lines)
* probe: clean
Set sortsize = 200;
Set scratchsize = 200;
Symbol a1,a2,a3;
Local F = (a1+a2+a3)^5;
Local G = 1;
.sort
.copy F to G;
.sort
Print G;
.end
assert preprocess_error?('Unrecognized module term')
*--#] cov_seteq_syntax_4 :

*--#[ cov_dotail_pipe_8 :
* DoTail -pipe option; child hits initPresetExternalChannels error path
* probe: clean
* DoTail -pipe option; child hits initPresetExternalChannels error path
* expected child message fragment: Error initializing preset external channels
#system cd $TESTFILEDIR && echo .end > $TESTTMPDIR/cvf4.frm; $FORM -pipe $TESTTMPDIR/cvf4.frm < /dev/null; true
Symbol ok;
Local ok = 1;
Print;
.end
assert compile_error?('name of expression')
*--#] cov_dotail_pipe_8 :

*--#[ cov_symm_tensor_TF :
* target: tensor function branch via TensorFunction declaration (syntax variant)
* probe: clean
* target: tensor function branch via TensorFunction declaration (syntax variant)
Index i,j,k;
TensorFunction t;
Symmetrize t,t;
Local test = t(j,i) + t(k,i,j) + t(j,j,i);
Print;
.end
assert compile_error?('Unrecognized statement')
*--#] cov_symm_tensor_TF :

*--#[ cov_4221_zz_funarg :
* expected: 0^0 during normalization of term
* probe: error
* expected: 0^0 during normalization of term
Symbol x;
CFunction g;
Local test = g(x)*(0^0);
Print;
.end
assert compile_error?('Encountered 0^0 during')
*--#] cov_4221_zz_funarg :

*--#[ cov_tr_set :
* expected: Illegal object type in TryReplace: v
* probe: error
* expected: Illegal object type in TryReplace: v
Symbol x;
Set v: x;
Local test = x;
TryReplace v, x;
Print;
.end
assert compile_error?('Illegal object type')
*--#] cov_tr_set :

*--#[ cov_ext_doloop :
* guess: external channel used from inside a preprocessor loop
* probe: clean
* guess: external channel used from inside a preprocessor loop
#setexternal cat
#do i = 1,3
    #toexternal item `i'
#enddo
#removeexternal
Symbol x;
Local t = x;
Print;
.end
assert preprocess_error?('setexternal: number expect')
*--#] cov_ext_doloop :

*--#[ cov_redef_esc :
* farm probe 0188_redef_esc_21 (+7 lines)
* probe: clean
#define x "1"
#redefine x "a\+b"
#write "value = `x'"
.end
assert succeeded?
*--#] cov_redef_esc :

*--#[ cov_mdl_stmt_endmodel :
* expected: Unknown statement
* probe: error
* expected: Unknown statement
Model qed;
Particle e spin 2;
Particle a spin 3 vector;
Vertex e,e,a coupling ee;
EndModel;
.end
assert compile_error?('A vertex statement')
*--#] cov_mdl_stmt_endmodel :

*--#[ cov_on_innertest :
* expected: Unrecognized option in ON statement
* probe: error
* expected: Unrecognized option in ON statement
On innertest xyz;
On innertest;
.end
assert succeeded?
*--#] cov_on_innertest :


*--#[ cov_dedup_badrange :
* expected: error from ReadRange inside dedup (transform.c:487-488)
* probe: error
* expected: error from ReadRange inside dedup (transform.c:487-488)
CFunction f;
Transform f dedup(qq);
.end
assert compile_error?('Illegal keyword inside')
*--#] cov_dedup_badrange :

*--#[ cov_nsuse_3 :
* guess at #use directive to expose namespace names outside
* probe: clean
* guess at #use directive to expose namespace names outside
#namespace nsuse
#define w 4
#endnamespace
#use nsuse
#message `w'
#end
.end
assert preprocess_error?('Illegal string for')
*--#] cov_nsuse_3 :

