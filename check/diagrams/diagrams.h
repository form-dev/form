**
* Enable verbose output.
*
*#define FormDiagramsVerbose

**
* Enable cache read and write.
*
*#define FormDiagramsCacheRead
*#define FormDiagramsCacheWrite

**
* Skip cache existence check.
*
*#define FormDiagramsCacheSkipCheck

**
* Specify the cache directory.
*
*#define FormDiagramsCacheDir "CACHE_DIRECTORY_PATH"

**
* Terminate with a non-zero status if any validation check fails.
*
*#define FormDiagramsRaiseError

**
* Override options used by DoComparison().
*
* For example, to generate the cache if it does not exist, one can set it
* via the -D option or the environment variable:
*   FormDiagramsOptionOverrides=cacheread,cachewrite,nocacheskipcheck,raiseerror
*
*#define FormDiagramsOptionOverrides

#ifndef `FormDiagramsCacheDir'
  #define FormDiagramsCacheDir "./.diagrams_cache"
#endif

#ifdef `TESTFILEDIR'
  #redefine FormDiagramsCacheDir "`TESTFILEDIR'/.diagrams_cache"
#endif

#define MaxLegs "9"
#define MaxPropagators "19"

#define CurrentModel ""
#define Bosons ""
#define AntiParticles ""

#define QgrafStyleFile "qgraf.sty"
#define QgrafModelFile "qgraf.mdl"
#define QgrafInputFile "qgraf.dat"
#define QgrafOutputFile "qgraf.out"
#define FeynGraphTemplateFile "feyngraph.jinja"
#define FeynGraphInputFile "feyngraph.toml"
#define FeynGraphOutputFile "diagrams.out"

#define QgrafVersion ""
#define FeynGraphVersion ""

Format nospaces;
Format 255;

* Note that the momentum convention is that all momenta are incoming.
* - Incoming particles are assigned momenta p1, p2, ...
* - Outgoing particles are assigned momenta -q1, -q2, ...
* - Internal particles are assigned momenta k1, k2, ...

S n1,n2,x1,x2;
CF topo,node,counter,coeff,vx,vxs(symmetric),acc,replace;
V p1,...,p`MaxLegs',q1,...,q`MaxLegs',k1,...,k`MaxPropagators',l1,...,l`MaxPropagators';
Set kk:k1,...,k`MaxPropagators';
Set ll:l1,...,l`MaxPropagators';

#OpenDictionary wildmom
  #do i = 1, `MaxPropagators'
    #add k`i': "k`i'?$k`i'"
  #enddo
#CloseDictionary

#do i = 1, `MaxPropagators'
  #$k`i' = 0;
#enddo

Model TEMP;
  Particle f1;
  Particle f2;
EndModel;

*--#[ SetupPhi3Model : SetupPhi3Model()

**
* Prepares the PHI3 model.
*
#procedure SetupPhi3Model()
  #define filename "`QgrafModelFile'"
  #create <`filename'>
  #write <`filename'> "[phi,phi,+]"
  #write <`filename'> "[phi,phi,phi]"
  #close <`filename'>

  Model PHI3;
    Particle phi,1;
    Vertex phi,phi,phi:g;
  EndModel;

  #redefine CurrentModel "PHI3"
  #redefine Bosons "phi"
  #redefine AntiParticles ""
#endprocedure

*--#] SetupPhi3Model : 
*--#[ SetupPhi4Model : SetupPhi4Model()

**
* Prepares the PHI4 model.
*
#procedure SetupPhi4Model()
  #define filename "`QgrafModelFile'"
  #create <`filename'>
  #write <`filename'> "[phi,phi,+]"
  #write <`filename'> "[phi,phi,phi,phi]"
  #close <`filename'>

  Model PHI4;
    Particle phi,1;
    Vertex phi,phi,phi,phi:g^2;
  EndModel;

  #redefine CurrentModel "PHI4"
  #redefine Bosons "phi"
  #redefine AntiParticles ""
#endprocedure

*--#] SetupPhi4Model : 
*--#[ SetupPhi34Model : SetupPhi34Model()

**
* Prepares the PHI34 model.
*
#procedure SetupPhi34Model()
  #define filename "`QgrafModelFile'"
  #create <`filename'>
  #write <`filename'> "[phi,phi,+]"
  #write <`filename'> "[phi,phi,phi]"
  #write <`filename'> "[phi,phi,phi,phi]"
  #close <`filename'>

  Model PHI34;
    Particle phi,1;
    Vertex phi,phi,phi:g;
    Vertex phi,phi,phi,phi:g^2;
  EndModel;

  #redefine CurrentModel "PHI34"
  #redefine Bosons "phi"
  #redefine AntiParticles ""
#endprocedure

*--#] SetupPhi4Model : 
*--#[ SetupQcdModel : SetupQcdModel()

**
* Prepares the QCD model.
*
#procedure SetupQcdModel()
  #define filename "`QgrafModelFile'"
  #create <`filename'>
  #write <`filename'> "[qua,QUA,-]"
  #write <`filename'> "[glu,glu,+]"
  #write <`filename'> "[gho,GHO,-]"
  #write <`filename'> "[QUA,qua,glu]"
  #write <`filename'> "[glu,glu,glu]"
  #write <`filename'> "[glu,glu,glu,glu]"
  #write <`filename'> "[GHO,gho,glu]"
  #close <`filename'>

  Model QCD;
    Particle qua,QUA,-2;
    Particle gho,GHO,-1;
    Particle glu,+3;
    Vertex QUA,qua,glu:g;
    Vertex GHO,gho,glu:g;
    Vertex glu,glu,glu:g;
    Vertex glu,glu,glu,glu:g^2;
  EndModel;

  #redefine CurrentModel "QCD"
  #redefine Bosons "glu"
  #redefine AntiParticles "QUA,GHO"
#endprocedure

*--#] SetupQcdModel : 
*--#[ SetupQcdbModel : SetupQcdbModel()

**
* Prepares the QCD model with the background field.
*
#procedure SetupQcdbModel()
  #define filename "`QgrafModelFile'"
  #create <`filename'>
  #write <`filename'> "[qua,QUA,-]"
  #write <`filename'> "[glu,glu,+]"
  #write <`filename'> "[gho,GHO,-]"
  #write <`filename'> "[back,back,+,external]"
  #write <`filename'> "[QUA,qua,glu]"
  #write <`filename'> "[GHO,gho,glu]"
  #write <`filename'> "[glu,glu,glu]"
  #write <`filename'> "[glu,glu,glu,glu]"
  #write <`filename'> "[QUA,qua,back]"
  #write <`filename'> "[GHO,gho,back]"
  #write <`filename'> "[GHO,gho,back,glu]"
  #write <`filename'> "[back,glu,glu]"
  #write <`filename'> "[back,glu,glu,glu]"
  #close <`filename'>

  Model QCDB;
    Particle qua,QUA,-2;
    Particle gho,GHO,-1;
    Particle glu,+3;
    Particle back,+3,external;
    Vertex QUA,qua,glu:g;
    Vertex GHO,gho,glu:g;
    Vertex glu,glu,glu:g;
    Vertex glu,glu,glu,glu:g^2;
    Vertex QUA,qua,back:g;
    Vertex GHO,gho,back:g;
    Vertex GHO,gho,back,glu:g^2;
    Vertex back,glu,glu:g;
    Vertex back,glu,glu,glu:g^2;
  EndModel;

  #redefine CurrentModel "QCDB"
  #redefine Bosons "glu,back"
  #redefine AntiParticles "QUA,GHO"
#endprocedure

*--#] SetupQcdbModel : 
*--#[ MakeDiagrams : MakeDiagrams(numIn,numOut)

**
* Manipulates diagrams for further manipulation.
*
* Parameters
* ----------
* numIn: positive integer
*   The number of incoming particles.
* numOut: positive integer
*   The number of outgoing particles.
*
* Example Input
* -------------
*  topo_(1)
* *node_(1,1,QUA(-p1))
* *node_(2,1,qua(-q1))
* *node_(3,g,QUA(k2),qua(p1),glu(k1))
* *node_(4,g,QUA(q1),qua(-k2),glu(-k1))
*
*  vx(QUA(-2),qua(1),glu(2))
* *vx(QUA(1),qua(-1),glu(2))
*
* Example Output
* --------------
*  node(QUA(q1),qua(-k2),glu(-k1))
* *node(QUA(k2),qua(p1),glu(k1))
*
#procedure MakeDiagrams(numIn,numOut)
* for diagrams_
  multiply replace_(topo_,dummy_);
  id node_(n1?,n2?,?a) = node_(?a);
  id node_(f1?(p1?)) = 1;
  multiply replace_(node_,node);

* for QGRAF
* Incoming fields have indices -1, -3, -5, ..., - 2j+1, ...
* Outgoing fields have indices -2, -4, -6, ..., - 2j, ...
* See the manual of QGRAF section 5.1 "The indices".
  #do i = 1, `numIn'
    repeat id vx(?a,f1?(1-2*`i'),?b) = vx(?a,f1(p`i'),?b);
  #enddo
  #do i = 1, `numOut'
    repeat id vx(?a,f1?(-2*`i'),?b) = vx(?a,f1(q`i'),?b);
  #enddo
  repeat id vx(?a,f1?(-1),?b) = vx(?a,f1(p1),?b);
  repeat id vx(?a,f1?(-2),?b) = vx(?a,f1(q1),?b);
  multiply counter(1);
  repeat id vx(?a,f1?(n1?),?b) * vx(?c,f2?(n1?),?d) * counter(n2?)
    = vx(?a,f1(kk[n2]),?b) * vx(?c,f2(-kk[n2]),?d) * counter(n2+1);
  repeat id vx(?a,f1?(n1?),?b,f2?(n1?),?c) * counter(n2?)
    = vx(?a,f1(kk[n2]),?b,f2(-kk[n2]),?c) * counter(n2+1);
  multiply replace_(counter,dummy_);
  multiply replace_(vx,node);

#ifdef `FormDiagramsVerbose'
  P +sss;
#endif
  .sort:mkdiag;
#endprocedure

*--#] MakeDiagrams : 
*--#[ CanonicalizeDiagrams : CanonicalizeDiagrams()

**
* Canonicalizes diagrams.
*
* This procedure attaches a unique topology ID and reassigns
* the loop momenta k1, k2, ... in a canonical way.
*
* Example Input
* -------------
*  node(QUA(q1),qua(-k2),glu(-k1))
* *node(QUA(k2),qua(p1),glu(k1))
*
* Example Output
* --------------
*  topo(1)
* *node(QUA(q1),qua(-k1),glu(k2))
* *node(QUA(k1),qua(p1),glu(-k2))
*
#procedure CanonicalizeDiagrams()
  #define numactiveexprs "`numactiveexprs_'"
  #define activeexprnames "`activeexprnames_'"

* Label each term uniquely.
  #$counter = 0;
  #define i "0"
  #do e = {`activeexprnames',}
    #ifdef `e'
      #redefine i "{`i'+1}"
      #$counter`i' = 0;
      inexpression `e';
        $counter`i' = $counter`i' + 1;
        $counter = $counter`i';
        multiply counter($counter`i');
        goto end;
      endinexpression;
    #endif
  #enddo
  #undefine i
label end;
* Save the current numerical coefficient.
  putinside coeff,xarg_;
  B node;
  ModuleOption maximum, $counter;
  #do i = 1, `numactiveexprs'
    ModuleOption local, $counter`i';
  #enddo
  Moduleoption inparallel;
  .sort:canondiag-1;

* Extract vertex structure into acc(vxs(v1,...)*...).
  Keep Brackets;
  id node(?a) = node(?a) * vxs(?a);
  argument vxs;
    id f1?(p1?) = p1;
  endargument;
  multiply acc(1);
  multiply replace_(vxs,vx);
  id vx(?a) = acc(vxs(?a));
  repeat id acc(x1?) * acc(x2?) = acc(x1 * x2);
  B acc;
  .sort:canondiag-2;

  #do e = {`activeexprnames',}
    #ifdef `e'
      CreateSpectator [`e'.spec], "`e'.`PID_'.spec";
    #endif
  #enddo

  #$numtopo = 0;

  #do loop = 1, 1
*   Find a new topology.
    Keep Brackets;
    #$found = 0;
    if ($found == 0);
      if (match(acc(x1?$x1)));
        $found = 1;
        $numtopo = $numtopo + 1;
        $topo = $x1;
        inside $x1;
          $numv = count_(vxs,1);
        endinside;
      endif;
    endif;
    B acc;
    ModuleOption noparallel;
    .sort:canondiag-3-{`$numtopo'+1};
    #if `$found'
*     Try to match the topology with the current term in all possible ways.
      Keep Brackets;
      #$found = 0;
      $replaced = 0;
      argument acc;
#UseDictionary wildmom($)
        if ((count(vxs,1) == `$numv') && match(`$topo'));
#CloseDictionary
          $found = 1;
          $replaced = 1;
          $t = term_;
          inside $t;
            id all, $topo * replace_(<k1,k1?>,...,<k`MaxPropagators',k`MaxPropagators'?>)
              = $topo * <replace(k1,l1)>*...*<replace(k`MaxPropagators',l`MaxPropagators')>;
            multiply replace_(vxs,dummy_);
            id replace(-k1?vector_,k2?) = replace(k1,-k2);
            chainin replace;
            multiply replace_(<l1,k1>,...,<l`MaxPropagators',k`MaxPropagators'>);
          endinside;
          multiply replace_(vxs,dummy_);
          multiply topo(`$numtopo');
          multiply $t;
        endif;
      endargument;
      if ($replaced);
        id acc(x1?) = x1;
      endif;
      ModuleOption maximum, $found;
      ModuleOption local, $t, $replaced, <$k1>,...,<$k`MaxPropagators'>;
      .sort:canondiag-4-`$numtopo';
      #if `$found'
*       Perform all the generated replacements.
        #redefine loop "0"
        id ifnomatch-> notreplaced, replace(?a) = replace_(?a);
        #do e = {`activeexprnames',}
          #ifdef `e'
            inexpression `e';
              tospectator [`e'.spec];
            endinexpression;
          #endif
        #enddo
label notreplaced;
        B acc;
        .sort:canondiag-5-`$numtopo';
      #endif
    #endif
  #enddo

* Restore expressions from the spectators.
  #do e = {`activeexprnames',}
    #ifdef `e'
      CopySpectator [`e'.copy] = [`e'.spec];
      #exchange `e',[`e'.copy]
    #endif
  #enddo
  .sort:canondiag-6;
  #do e = {`activeexprnames',}
    #ifdef `e'
      Drop [`e'.copy];
      EmptySpectator [`e'.spec];
    #endif
  #enddo

* Drop duplicate terms (keep the first one).
  #define maxunrolling "100"
  #define unrolling
  #define i "0"
  #do k = 1, `$counter'
    #if {`k'+`maxunrolling'-1} <= `$counter'
      #redefine unrolling "`maxunrolling'"
    #else
      #redefine unrolling "{`$counter'-`k'+1}"
    #endif
    #do j = 0, {`unrolling'-1}
      if (match(counter({`k'+`j'})));
        #redefine i "0"
        #do e = {`activeexprnames',}
          #ifdef `e'
            #redefine i "{`i'+1}"
            #$found`i'x`j' = 0;
            inexpression `e';
              if ($found`i'x`j');
                discard;
              else;
                $found`i'x`j' = 1;
                multiply replace_(counter,dummy_);
                tospectator [`e'.spec];
              endif;
            endinexpression;
          #endif
        #enddo
      endif;
    #enddo
    #do i = 1, `numactiveexprs'
      #do j = 0, {`unrolling'-1}
        ModuleOption local, $found`i'x`j';
      #enddo
    #enddo
    ModuleOption inparallel;
    .sort:canondiag-7-`k';
    #redefine k "{`k'+`unrolling'-1}"
  #enddo
  #undefine i
  #if `$counter' == 0
    .sort:canondiag-7;
  #endif

* Restore expressions from the spectators.
  #do e = {`activeexprnames',}
    #ifdef `e'
      CopySpectator [`e'.copy] = [`e'.spec];
      #exchange `e',[`e'.copy]
    #endif
  #enddo
  .sort:canondiag-8;
  #do e = {`activeexprnames',}
    #ifdef `e'
      Drop [`e'.copy];
      RemoveSpectator [`e'.spec];
    #endif
  #enddo

* Restore the coefficient.
  dropcoefficient;
  id coeff(x1?) = x1;

* Reorder identical boson fields at each vertex to align the momenta.
  #do b = {`Bosons',}
    #ifdef `b'
*     Assume that they appear in adjacent positions.
      repeat id node(?a,`b'(?b),`b'(?c),?d) = node(?a,`b'(?b,?c),?d);
      multiply replace_(`b',vxs);
      multiply replace_(vxs,`b');
      repeat id node(?a,`b'(p1?,p2?,?b),?c) = node(?a,`b'(p1),`b'(p2,?b),?c);
    #endif
  #enddo

* Align the loop momenta with the flow of particles.
  #ifdef `AntiParticles'
    #do i = 1, `MaxPropagators'
      if (match(node(?a,f1?{`AntiParticles'}(-k`i'),?b)));
        multiply replace_(k`i',-k`i');
      endif;
    #enddo
  #endif

  .sort:canondiag-9;
#endprocedure

*--#] CanonicalizeDiagrams : 
*--#[ CompareDiagrams : CompareDiagrams(F1,F2,F0)

**
* Compares diagrams in two expressions.
*
* The common diagrams are extracted from F1 and F2, and stored in F0.
* Diagrams must consist of "topo" and "node" functions.
*
* Parameters
* ----------
* F1, F2: expression [in/out]
*   The expressions to be compared. Common diagrams will be removed from
*   these expressions.
* F0: expression [out]
*   The extracted common diagrams.
*
#procedure CompareDiagrams(F1,F2,F0)
  #call CanonicalizeDiagrams()

  B+ topo,node;
  .sort:compdiag-1;
  Keep Brackets;
  L `F0' = 0
  #do t = `F1';
    #$t = `t';
    #inside $t;
      dropcoefficient;
    #endinside;
    #$t1 = `F1'[`$t'];
    #$t2 = `F2'[`$t'];
    #$tt = $t1 - $t2;
    #if termsin($tt) == 0
      + (`t')
    #endif
  #enddo
  ;
  .sort:compdiag-2;
  L `F1' = `F1' - `F0';
  L `F2' = `F2' - `F0';
#ifdef `FormDiagramsVerbose'
  P +sss;
#endif
  .sort:compdiag-3;
#endprocedure

*--#] CompareDiagrams : 
*--#[ DoComparison : DoComparison(other,model,options...)

**
* Performs comparison.
*
* Example
* -------
* #call DoComparison(qgraf,qcd,in=qua,out=qua,loops=1,form_options=ONEPI_,FLOOP_,qgraf_options=onepi,floop)
*
#procedure DoComparison(other,model,?a)
  #define DiagramGenerator "`tolower_(`other')'"
  #switch `DiagramGenerator'
    #case qgraf
      #define DiagramGeneratorName "QGRAF"
      #redefine DiagramGeneratorVersion "`~QgrafVersion'"
      #break
    #case feyngraph
      #define DiagramGeneratorName "FeynGraph"
      #redefine DiagramGeneratorVersion "feyngraph `~FeynGraphVersion'"
      #break
    #default
      #message error: unknown diagram generator: `other'
      #terminate
  #endswitch

  #define in ""
  #define out ""
  #define loops ""
  #define formoptions ""
  #define qgrafoptions ""
  #define feyngraphoptions ""
  #define options ""

  #define next ""
  #do a = {`?a',}
    #ifdef `a'
      #if "`keepleft_(`a',3)'" == "in="
        #redefine next "in"
        #redefine a "`takeleft_(`a',3)'"
      #elseif "`keepleft_(`a',4)'" == "out="
        #redefine next "out"
        #redefine a "`takeleft_(`a',4)'"
      #elseif "`keepleft_(`a',6)'" == "loops="
        #redefine next "loops"
        #redefine a "`takeleft_(`a',6)'"
      #elseif "`keepleft_(`a',13)'" == "form_options="
        #redefine next "formoptions"
        #redefine a "`takeleft_(`a',13)'"
      #elseif "`keepleft_(`a',14)'" == "qgraf_options="
        #redefine next "qgrafoptions"
        #redefine a "`takeleft_(`a',14)'"
      #elseif "`keepleft_(`a',18)'" == "feyngraph_options="
        #redefine next "feyngraphoptions"
        #redefine a "`takeleft_(`a',18)'"
      #elseif "`keepleft_(`a',8)'" == "options="
        #redefine next "options"
        #redefine a "`takeleft_(`a',8)'"
      #endif
      #ifdef `a'
        #ifdef `next'
          #ifdef ``next''
            #redefine `next' "``next'',`a'"
          #else
            #redefine `next' "`a'"
          #endif
        #endif
      #endif
    #endif
  #enddo

  #ifdef `FormDiagramsOptionOverrides'
    #define options "`options',`FormDiagramsOptionOverrides'"
  #endif

  #ifdef `options'
    #do a = {`options',}
      #ifdef `a'
        #switch `tolower_(`a')'
          #case verbose
            #define FormDiagramsVerbose
            #break
          #case noverbose
            #define FormDiagramsVerbose ""
            #break
          #case cacheread
            #define FormDiagramsCacheRead
            #break
          #case nocacheread
            #define FormDiagramsCacheRead ""
            #break
          #case cachewrite
            #define FormDiagramsCacheWrite
            #break
          #case nocachewrite
            #define FormDiagramsCacheWrite ""
            #break
          #case cacheskipcheck
            #define FormDiagramsCacheSkipCheck
            #break
          #case nocacheskipcheck
            #define FormDiagramsCacheSkipCheck ""
            #break
          #case forcecacheread
            #define FormDiagramsCacheRead
            #define FormDiagramsCacheSkipCheck
            #break
          #case raiseerror
            #define FormDiagramsRaiseError
            #break
          #case noraiseerror
            #define FormDiagramsRaiseError ""
            #break
          #default
            #message warning: unknown option: `a'
            #terminate
        #endswitch
      #endif
    #enddo
  #endif

  #define numIn "0"
  #define numOut "0"

  #do a = {`in',}
    #ifdef `a'
      #redefine numIn "{`numIn'+1}"
    #endif
  #enddo

  #do a = {`out',}
    #ifdef `a'
      #redefine numOut "{`numOut'+1}"
    #endif
  #enddo

  #define momenta ""

  #do i = 1, `numIn'
    #redefine momenta "`momenta',p`i'"
  #enddo

  #do i = 1, `numOut'
    #redefine momenta "`momenta',q`i'"
  #enddo

* Construct the cache key.

  #define opt1 "`formoptions'"
  #define opt2 "``DiagramGenerator'options'"
  #define val1 ""
  #define val2 ""
  #do i = 1, 2
    #do a = {`opt`i'',}
      #ifdef `a'
        #if `i' == 1
          #redefine a "`tolower_(`a')'"
          #if "`keepright_(`a',1)'" == "_"
            #redefine a "`takeright_(`a',1)'"
          #endif
        #elseif (`i' == 2) && "`DiagramGenerator'" == "feyngraph"
          #if "`keepright_(`a',12)'" == "self_loops=0"
            #redefine a "`takeright_(`a',12)'selfloops0"
          #elseif "`keepright_(`a',16)'" == "opi_components=1"
            #redefine a "`takeright_(`a',16)'opicomponents1"
          #endif
        #endif
        #redefine val`i' "`val`i''`a'"
      #endif
    #enddo
    #ifdef `val`i''
    #else
      #redefine val`i' "none"
    #endif
  #enddo

  #if "`val1'" == "`val2'"
    #redefine val2 ""
  #endif

  #define cachekey "`DiagramGenerator'_`model'"
  #do b = {in,out,loops,val1,val2}
    #redefine cachekey "`cachekey'_"
    #do a = {``b'',}
      #ifdef `a'
        #redefine cachekey "`cachekey'`a'"
      #endif
    #enddo
    #if "`keepright_(`cachekey',1)'" == "_"
      #redefine cachekey "`takeright_(`cachekey',1)'"
    #endif
  #enddo

* Cache file names.

  #define cachefile "`FormDiagramsCacheDir'/`cachekey'.dat"
  #define cachetmpfile "`cachekey'.dat.`PID_'.tmp"
  #define cachetmpfile2 "`FormDiagramsCacheDir'/`cachekey'.dat2.`PID_'.tmp"

* Set up the model.

  #call Setup`toupper_(`keepleft_(`model',1)')'`takeleft_(`model',1)'Model()

* Generate diagrams.

  #ifdef `formoptions'
    #define optionvalue "0"
    #do a = {`formoptions',}
      #ifdef `a'
        #redefine optionvalue "`optionvalue'+``a''"
      #endif
    #enddo
    #redefine formoptions "`optionvalue'"
  #else
    #redefine formoptions "0"
  #endif

  L F1 = diagrams_(`CurrentModel',{`in'},{`out'},{`momenta'},kk,`loops',`formoptions');
#ifdef `FormDiagramsVerbose'
  P +sss;
#endif
  .sort:gen-diag;
  #$nF1 = termsin_(F1);

* Check if the cache exists.

  #ifdef `FormDiagramsCacheRead'
    #ifdef `FormDiagramsCacheSkipCheck'
      #$cacheexists = 1;
    #else
      #$cacheexists =
        #pipe if [ -f "`cachefile'" ]; then echo 1; else echo 0; fi
      ;
    #endif
  #else
    #$cacheexists = 0;
  #endif

  #if `$cacheexists' == 1
*   If the cache exists, then compare the generated diagrams with the cache,
*   which has already been confirmed to be consistent with the other generator.

    #message Read cache file: `cachefile'

    Skip;

    L F2 =
      #include `cachefile'
    ;
    .sort:load-cache-1;
    #$nF2 = termsin_(F2);
    Drop;
    L oldF1 = F1;
    L oldF2 = F2;
    .sort:load-cache-2;
    Drop;
    L F0 = 0;
    L F1 = oldF1 - oldF2;
    L F2 = - F1;
    .sort:load-cache-3;
  #else
*   Otherwise, we must perform a full comparison.

    #ifdef `FormDiagramsCacheWrite'
*     Output the generated diagrams into a temporary file.
      .sort:save-tmp;
      #write <`cachetmpfile'> "      %+E", F1
      #close <`cachetmpfile'>
    #endif

    Skip;

    L F2 =
      #switch `DiagramGenerator'
        #case qgraf
          #call SetupQgrafFormStyle
          #call RunQgraf(in=`in',out=`out',loops=`loops',options=`qgrafoptions')
          #break
        #case feyngraph
          #call SetupFeynGraphTemplate
          #call RunFeynGraph(in=`in',out=`out',loops=`loops',options=`feyngraphoptions')
          #break
      #endswitch
    ;
#ifdef `FormDiagramsVerbose'
  P +sss;
#endif
    .sort:run-`DiagramGenerator';
    #$nF2 = termsin_(F2);

    #call MakeDiagrams(`numIn',`numOut')
    #call CompareDiagrams(F1,F2,F0)

    #ifdef `FormDiagramsCacheWrite'
*     If the generated diagrams are consistent with those by the other generator
*     then write the cache file.
      #if (`ZERO_F1' == 1) && (`ZERO_F2' == 1)
        #message Write cache file: `cachefile'
        #system mkdir -p "`FormDiagramsCacheDir'"
        #system echo "* Compared with `DiagramGeneratorVersion'" >"`cachetmpfile2'"
        #system echo "* Number of diagrams: FORM: `$nF1', `DiagramGeneratorName': `$nF2'" >>"`cachetmpfile2'"
*       awk filter for normalizing leading spaces.
        #system awk "
          /topo_/ {
            if (NR > 1) print \"\"
            sub(/^  */, \" \")
            printf \"%s\", \$0
            next
          }
          {
            sub(/^  */, \"\")
            printf \"%s\", \$0
          }
          END { print \"\" }
        " "`cachetmpfile'" >>"`cachetmpfile2'"
        #system mv "`cachetmpfile2'" "`cachefile'"
      #endif
      #remove <`cachetmpfile'>
    #endif
  #endif

  #define ok

  #ifdef `TESTCASE'
    #if "`cachekey'" == "`TESTCASE'"
      #message INFO: cachekey matches the test case: `cachekey'
    #else
      #message WARNING: cachekey does not match the test case: `cachekey' vs. `TESTCASE'
      #redefine ok ""
    #endif
  #endif

  #if (`ZERO_F1' == 1) && (`ZERO_F2' == 1)
    #message INFO: Diagrams generated by FORM and `DiagramGeneratorName' match (`$nF1' terms).
  #else
    #if `$nF1' != `$nF2'
      #message ERROR: Diagrams generated by FORM and `DiagramGeneratorName' do not match (`$nF1' terms vs. `$nF2' terms).
    #else
      #message ERROR: Diagrams generated by FORM and `DiagramGeneratorName' do not match.
    #endif
    #redefine ok ""
  #endif

  #ifdef `FormDiagramsRaiseError'
    #ifdef `ok'
    #else
      #terminate
    #endif
  #endif
#endprocedure

*--#] DoComparison : 
*--#[ RunQgraf : RunQgraf(options...)

**
* Runs QGRAF and reads its output.
*
* Example
* -------
* #call SetupQcdModel()
* #call SetupQgrafFormStyle()
* L F =
* #call RunQgraf(in=qua,out=qua,loops=1,options=nosnail)
* ;
*
* Example Output
* --------------
*  F =
*     vx(QUA(-2),qua(1),glu(2))*vx(QUA(1),qua(-1),glu(2));
*
#procedure RunQgraf(?a)
  #define in ""
  #define out ""
  #define loops ""
  #define loopmomentum ""
  #define options ""
  #define next "options"

  #do a = {`?a',}
    #ifdef `a'
      #if "`keepleft_(`a',3)'" == "in="
        #redefine next "in"
        #redefine a "`takeleft_(`a',3)'"
      #elseif "`keepleft_(`a',4)'" == "out="
        #redefine next "out"
        #redefine a "`takeleft_(`a',4)'"
      #elseif "`keepleft_(`a',6)'" == "loops="
        #redefine next "loops"
        #redefine a "`takeleft_(`a',6)'"
      #elseif "`keepleft_(`a',14)'" == "loop_momentum="
        #redefine next "loopmomentum"
        #redefine a "`takeleft_(`a',14)'"
      #elseif "`keepleft_(`a',8)'" == "options="
        #redefine next "options"
        #redefine a "`takeleft_(`a',8)'"
      #endif
      #ifdef `a'
        #ifdef ``next''
          #redefine `next' "``next'',`a'"
        #else
          #redefine `next' "`a'"
        #endif
      #endif
    #endif
  #enddo

  #ifndef `loopmomentum'
    #redefine loopmomentum "k"
  #endif

  #remove <`QgrafOutputFile'>

  #define filename "`QgrafInputFile'"
  #create <`filename'>
  #write <`filename'> "output = \'`QgrafOutputFile'\';"
  #write <`filename'> "style = \'`QgrafStyleFile'\';"
  #write <`filename'> "model = \'`QgrafModelFile'\';"
  #write <`filename'> "in = `in';"
  #write <`filename'> "out = `out';"
  #write <`filename'> "loops = `loops';"
  #write <`filename'> "loop_momentum = `loopmomentum';"
  #write <`filename'> "options = `options';"
  #close <`filename'>

  #system qgraf

#ifdef `FormDiagramsVerbose'
  #system cat `QgrafOutputFile'
#endif
  #include `QgrafOutputFile'
#endprocedure

*--#] RunQgraf : 
*--#[ SetupQgrafFormStyle : SetupQgrafFormStyle()

**
* Prepares the QGRAF style file for FORM.
*
#procedure SetupQgrafFormStyle()
  #define filename "`QgrafStyleFile'"
  #create <`filename'>
  #write <`filename'> "<prologue>"
  #write <`filename'> "*"
  #write <`filename'> "* file generated by <program>"
  #write <`filename'> "*"
  #write <`filename'> "<command_loop><command_line_loop>* <command_data><end><end>*"
  #write <`filename'> "*"
  #write <`filename'> "#redefine QgrafVersion \"<program>\""
  #write <`filename'> "*"
  #write <`filename'> "<diagram>"
  #write <`filename'> "*--#[[ d<diagram_index>:"
  #write <`filename'> "     <sign><symmetry_factor>"
  #write <`filename'> "<vertex_loop>    *vx(<ray_loop><field>(<propagator_index>),<end><back>)"
  #write <`filename'> "<end><back>"
  #write <`filename'> "*--#]] d<diagram_index>: "
  #write <`filename'> "<epilogue>"
  #write <`filename'> "*"
  #write <`filename'> "* end"
  #write <`filename'> "*"
  #write <`filename'> "<exit>"
  #close <`filename'>
#endprocedure

*--#] SetupQgrafFormStyle : 
*--#[ RunFeynGraph : RunFeynGraph(options...)

**
* Runs FeynGraph and reads its output.
*
* Example
* -------
* #call SetupQcdModel()
* #call SetupFeynGraphTemplate()
* L F =
* #call RunFeynGraph(in=qua,out=qua,loops=1,options=self_loops=0)
* ;
*
* Example Output
* --------------
*  F =
*     vx(QUA(-2),qua(3),glu(2))*vx(QUA(3),qua(-1),glu(2));
*
#procedure RunFeynGraph(?a)
  #define in ""
  #define out ""
  #define loops ""
  #define loopmomentum ""
  #define options ""
  #define next "options"

  #do a = {`?a',}
    #ifdef `a'
      #if "`keepleft_(`a',3)'" == "in="
        #redefine next "in"
        #redefine a "`takeleft_(`a',3)'"
      #elseif "`keepleft_(`a',4)'" == "out="
        #redefine next "out"
        #redefine a "`takeleft_(`a',4)'"
      #elseif "`keepleft_(`a',6)'" == "loops="
        #redefine next "loops"
        #redefine a "`takeleft_(`a',6)'"
      #elseif "`keepleft_(`a',14)'" == "loop_momentum="
        #redefine next "loopmomentum"
        #redefine a "`takeleft_(`a',14)'"
      #elseif "`keepleft_(`a',8)'" == "options="
        #redefine next "options"
        #redefine a "`takeleft_(`a',8)'"
      #endif
      #ifdef `a'
        #ifdef ``next''
          #redefine `next' "``next'',`a'"
        #else
          #redefine `next' "`a'"
        #endif
      #endif
    #endif
  #enddo

  #ifndef `loopmomentum'
    #redefine loopmomentum "k"
  #endif

  #remove <`FeynGraphOutputFile'>

  #define filename "`FeynGraphInputFile'"
  #create <`filename'>
  #write <`filename'> "template = \"`FeynGraphTemplateFile'\""
  #write <`filename'> "[process]"
  #write <`filename'> "in = [%"
  #do a = {`in',}
    #ifdef `a'
      #write <`filename'> "\"`a'\", %"
    #endif
  #enddo
  #write <`filename'> "]"
  #write <`filename'> "out = [%"
  #do a = {`out',}
    #ifdef `a'
      #write <`filename'> "\"`a'\", %"
    #endif
  #enddo
  #write <`filename'> "]"
  #write <`filename'> "loops = `loops'"
  #write <`filename'> "model = \"`QgrafModelFile'\""
  #write <`filename'> "momenta = [%"
  #define i "1"
  #do a = {`in',}
    #ifdef `a'
      #write <`filename'> "\"p`i++'\", %"
    #endif
  #enddo
  #redefine i "1"
  #do a = {`out',}
    #ifdef `a'
      #write <`filename'> "\"q`i++'\", %"
    #endif
  #enddo
  #do i = 1, `loops'
    #write <`filename'> "\"k`i'\", %"
  #enddo
  #write <`filename'> "]"
  #write <`filename'> "[filter]"
  #do a = {`options',}
    #ifdef `a'
      #switch `a'
        #case onshell
          #write <`filename'> "`a' = true"
          #break
        #default
          #write <`filename'> "`a'"
      #endswitch
    #endif
  #enddo
  #close <`filename'>

  #system feyngraph `FeynGraphInputFile'
  #pipe echo \#redefine FeynGraphVersion \"$(feyngraph --version)\"

#ifdef `FormDiagramsVerbose'
  #system cat `FeynGraphOutputFile'
#endif
  #include `FeynGraphOutputFile'
#endprocedure

*--#] RunFeynGraph : 
*--#[ SetupFeynGraphTemplate : SetupFeynGraphTemplate()

**
* Prepares the FeynGraph template file for FORM.
*
#procedure SetupFeynGraphTemplate()
  #define filename "`FeynGraphTemplateFile'"
  #create <`filename'>
  #write <`filename'> "{\%- for diag in diagrams -\%}"
  #write <`filename'> "    {\%- set n_in = diag.n_in() -\%}"
  #write <`filename'> "    {\%- set n_ext = diag.n_ext() -\%}"
  #write <`filename'> "*--#[[ d{{ loop.index }}:"
  #write <`filename'> "     {{ \"+\" ~ diag.sign() if diag.sign() >= 0 else diag.sign() -}}"
  #write <`filename'> "     {{ \"/\" ~ diag.symmetry_factor() if diag.symmetry_factor() != 1 else \"\" }}"
  #write <`filename'> "{\%- for vertex in diag.vertices() \%}"
  #write <`filename'> "    *vx("
  #write <`filename'> "{\%- for par in vertex.particles_ordered() -\%}"
  #write <`filename'> "    {\%- set j = vertex.propagators_ordered()[loop.index0].id() -\%}"
  #write <`filename'> "    {\%- if j < n_in -\%}"
  #write <`filename'> "        {\%- set j = - 2 * j - 1 -\%}"
  #write <`filename'> "    {\%- elif j < n_ext -\%}"
  #write <`filename'> "        {\%- set j = - 2 * (j - n_in + 1) -\%}"
  #write <`filename'> "    {\%- endif -\%}"
  #write <`filename'> "    {{ par.name() }}({{ j }})"
  #write <`filename'> "    {\%- if not loop.last -\%},{\%- endif -\%}"
  #write <`filename'> "{\%- endfor -\%}"
  #write <`filename'> ")"
  #write <`filename'> "{\%- endfor \%}"
  #write <`filename'> "*--#]] d{{ loop.index }}: "
  #write <`filename'> "{\% endfor \%}"
  #close <`filename'>
#endprocedure

*--#] SetupFeynGraphTemplate : 
* vim: ft=form et ts=8 sts=2 sw=2 fdm=marker fmr=#[,#] fdc=4
