* Compares the diagram generator with others.
*
* When run outside the testsuite, this file must be on the include path.
* For example, run:
*   form -D TEST=XXX -I check check/diagrams.frm
*
#ifndef `TEST'
  #message Use -D TEST=XXX
  #terminate
#else
  #include `NAME_' # `TEST'
#endif
.end

*--#[ feyngraph_qcd_3_none :
#include- diagrams/diagrams.h
#call DoComparison(feyngraph,qcd,in=,out=,loops=3,form_options=,feyngraph_options=,options=forcecacheread)
.end
assert succeeded?
assert nterms("F1", 0) == 74;
assert nterms("F1") == 0;
assert nterms("F2") == 0;
*--#] feyngraph_qcd_3_none : 
*--#[ feyngraph_qcd_3_onepi_opicomponents1 :
#include- diagrams/diagrams.h
#call DoComparison(feyngraph,qcd,in=,out=,loops=3,form_options=ONEPI_,feyngraph_options=opi_components=1,options=forcecacheread)
.end
assert succeeded?
assert nterms("F1", 0) == 19;
assert nterms("F1") == 0;
assert nterms("F2") == 0;
*--#] feyngraph_qcd_3_onepi_opicomponents1 : 
*--#[ qgraf_qcd_qua_qua_3_none :
#include- diagrams/diagrams.h
#call DoComparison(qgraf,qcd,in=qua,out=qua,loops=3,form_options=,qgraf_options=,options=forcecacheread)
.end
# Too many subexpressions for the 32-bit version.
#require wordsize >= 4
assert succeeded?
assert nterms("F1", 0) == 1001;
assert nterms("F1") == 0;
assert nterms("F2") == 0;
*--#] qgraf_qcd_qua_qua_3_none : 
*--#[ qgraf_qcd_glu_glu_3_none :
#include- diagrams/diagrams.h
#call DoComparison(qgraf,qcd,in=glu,out=glu,loops=3,form_options=,qgraf_options=,options=forcecacheread)
.end
# Too many subexpressions for the 32-bit version.
#require wordsize >= 4
assert succeeded?
assert nterms("F1", 0) == 2829;
assert nterms("F1") == 0;
assert nterms("F2") == 0;
*--#] qgraf_qcd_glu_glu_3_none : 
*--#[ qgraf_qcd_qua_qua_3_onepifloop :
#include- diagrams/diagrams.h
#call DoComparison(qgraf,qcd,in=qua,out=qua,loops=3,form_options=ONEPI_,FLOOP_,qgraf_options=onepi,floop,options=forcecacheread)
.end
# The option does not fit into a 16-bit WORD.
#require wordsize >= 4
assert succeeded?
assert nterms("F1", 0) == 89;
assert nterms("F1") == 0;
assert nterms("F2") == 0;
*--#] qgraf_qcd_qua_qua_3_onepifloop : 
*--#[ qgraf_qcd_glu_glu_3_onepifloop :
#include- diagrams/diagrams.h
#call DoComparison(qgraf,qcd,in=glu,out=glu,loops=3,form_options=ONEPI_,FLOOP_,qgraf_options=onepi,floop,options=forcecacheread)
.end
# The option does not fit into a 16-bit WORD.
#require wordsize >= 4
assert succeeded?
assert nterms("F1", 0) == 222;
assert nterms("F1") == 0;
assert nterms("F2") == 0;
*--#] qgraf_qcd_glu_glu_3_onepifloop : 
*--#[ qgraf_qcd_qua_quaglu_3_onepifloop :
#include- diagrams/diagrams.h
#call DoComparison(qgraf,qcd,in=qua,out=qua,glu,loops=3,form_options=ONEPI_,FLOOP_,qgraf_options=onepi,floop,options=forcecacheread)
.end
# The option does not fit into a 16-bit WORD.
#require wordsize >= 4
assert succeeded?
assert nterms("F1", 0) == 664;
assert nterms("F1") == 0;
assert nterms("F2") == 0;
*--#] qgraf_qcd_qua_quaglu_3_onepifloop : 
*--#[ qgraf_qcd_quaQUA_gluglu_2_onepifloop :
#include- diagrams/diagrams.h
#call DoComparison(qgraf,qcd,in=qua,QUA,out=glu,glu,loops=2,form_options=ONEPI_,FLOOP_,qgraf_options=onepi,floop,options=forcecacheread)
.end
# The option does not fit into a 16-bit WORD.
#require wordsize >= 4
assert succeeded?
assert nterms("F1", 0) == 211;
assert nterms("F1") == 0;
assert nterms("F2") == 0;
*--#] qgraf_qcd_quaQUA_gluglu_2_onepifloop : 
