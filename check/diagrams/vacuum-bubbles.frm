* Compares the diagram generator with others.
*
* When run outside the testsuite, this file must be on the include path.
* For example, run:
*   form -D TEST=XXX -I check/diagrams vacuum-bubbles.frm
*
#ifndef `TEST'
  #message Use -D TEST=XXX
  #terminate
#else
  #include `NAME_' # `TEST'
#endif
.end

*--#[ feyngraph_phi3_2_none :
#include- diagrams.h
#call DoComparison(feyngraph,phi3,in=,out=,loops=2,form_options=,feyngraph_options=,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 2
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_phi3_2_none : 
*--#[ feyngraph_phi3_2_onepi_opicomponents1 :
#include- diagrams.h
#call DoComparison(feyngraph,phi3,in=,out=,loops=2,form_options=ONEPI_,feyngraph_options=opi_components=1,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 1
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_phi3_2_onepi_opicomponents1 : 
*--#[ feyngraph_phi3_3_none :
#include- diagrams.h
#call DoComparison(feyngraph,phi3,in=,out=,loops=3,form_options=,feyngraph_options=,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 5
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_phi3_3_none : 
*--#[ feyngraph_phi3_3_onepi_opicomponents1 :
#include- diagrams.h
#call DoComparison(feyngraph,phi3,in=,out=,loops=3,form_options=ONEPI_,feyngraph_options=opi_components=1,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 2
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_phi3_3_onepi_opicomponents1 : 
*--#[ feyngraph_phi3_4_none :
#include- diagrams.h
#call DoComparison(feyngraph,phi3,in=,out=,loops=4,form_options=,feyngraph_options=,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 17
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_phi3_4_none : 
*--#[ feyngraph_phi3_4_onepi_opicomponents1 :
#include- diagrams.h
#call DoComparison(feyngraph,phi3,in=,out=,loops=4,form_options=ONEPI_,feyngraph_options=opi_components=1,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 5
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_phi3_4_onepi_opicomponents1 : 
*--#[ feyngraph_phi3_5_none :
#include- diagrams.h
#call DoComparison(feyngraph,phi3,in=,out=,loops=5,form_options=,feyngraph_options=,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 71
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_phi3_5_none : 
*--#[ feyngraph_phi3_5_onepi_opicomponents1 :
#include- diagrams.h
#call DoComparison(feyngraph,phi3,in=,out=,loops=5,form_options=ONEPI_,feyngraph_options=opi_components=1,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 16
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_phi3_5_onepi_opicomponents1 : 
*--#[ feyngraph_phi4_2_none :
#include- diagrams.h
#call DoComparison(feyngraph,phi4,in=,out=,loops=2,form_options=,feyngraph_options=,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 1
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_phi4_2_none : 
*--#[ feyngraph_phi4_2_onepi_opicomponents1 :
#include- diagrams.h
#call DoComparison(feyngraph,phi4,in=,out=,loops=2,form_options=ONEPI_,feyngraph_options=opi_components=1,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 1
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_phi4_2_onepi_opicomponents1 : 
*--#[ feyngraph_phi4_3_none :
#include- diagrams.h
#call DoComparison(feyngraph,phi4,in=,out=,loops=3,form_options=,feyngraph_options=,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 2
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_phi4_3_none : 
*--#[ feyngraph_phi4_3_onepi_opicomponents1 :
#include- diagrams.h
#call DoComparison(feyngraph,phi4,in=,out=,loops=3,form_options=ONEPI_,feyngraph_options=opi_components=1,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 2
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_phi4_3_onepi_opicomponents1 : 
*--#[ feyngraph_phi4_4_none :
#include- diagrams.h
#call DoComparison(feyngraph,phi4,in=,out=,loops=4,form_options=,feyngraph_options=,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 4
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_phi4_4_none : 
*--#[ feyngraph_phi4_4_onepi_opicomponents1 :
#include- diagrams.h
#call DoComparison(feyngraph,phi4,in=,out=,loops=4,form_options=ONEPI_,feyngraph_options=opi_components=1,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 4
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_phi4_4_onepi_opicomponents1 : 
*--#[ feyngraph_phi4_5_none :
#include- diagrams.h
#call DoComparison(feyngraph,phi4,in=,out=,loops=5,form_options=,feyngraph_options=,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 10
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_phi4_5_none : 
*--#[ feyngraph_phi4_5_onepi_opicomponents1 :
#include- diagrams.h
#call DoComparison(feyngraph,phi4,in=,out=,loops=5,form_options=ONEPI_,feyngraph_options=opi_components=1,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 10
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_phi4_5_onepi_opicomponents1 : 
*--#[ feyngraph_qcd_2_none :
#include- diagrams.h
#call DoComparison(feyngraph,qcd,in=,out=,loops=2,form_options=,feyngraph_options=,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 10
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_qcd_2_none : 
*--#[ feyngraph_qcd_2_onepi_opicomponents1 :
#include- diagrams.h
#call DoComparison(feyngraph,qcd,in=,out=,loops=2,form_options=ONEPI_,feyngraph_options=opi_components=1,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 4
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_qcd_2_onepi_opicomponents1 : 
*--#[ feyngraph_qcd_3_none :
#include- diagrams.h
#call DoComparison(feyngraph,qcd,in=,out=,loops=3,form_options=,feyngraph_options=,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 74
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_qcd_3_none : 
*--#[ feyngraph_qcd_3_onepi_opicomponents1 :
#include- diagrams.h
#call DoComparison(feyngraph,qcd,in=,out=,loops=3,form_options=ONEPI_,feyngraph_options=opi_components=1,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 19
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_qcd_3_onepi_opicomponents1 : 
*--#[ feyngraph_qcd_4_none :
#include- diagrams.h
#call DoComparison(feyngraph,qcd,in=,out=,loops=4,form_options=,feyngraph_options=,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 787
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_qcd_4_none : 
*--#[ feyngraph_qcd_4_onepi_opicomponents1 :
#include- diagrams.h
#call DoComparison(feyngraph,qcd,in=,out=,loops=4,form_options=ONEPI_,feyngraph_options=opi_components=1,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 118
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_qcd_4_onepi_opicomponents1 : 
*--#[ feyngraph_qcd_5_none :
#include- diagrams.h
#call DoComparison(feyngraph,qcd,in=,out=,loops=5,form_options=,feyngraph_options=,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 12034
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_qcd_5_none : 
*--#[ feyngraph_qcd_5_onepi_opicomponents1 :
#include- diagrams.h
#call DoComparison(feyngraph,qcd,in=,out=,loops=5,form_options=ONEPI_,feyngraph_options=opi_components=1,options=cacheread,cachewrite)
.end
assert succeeded?
assert nterms("F1", 0) == 1194
assert nterms("F1") == 0
assert nterms("F2") == 0
*--#] feyngraph_qcd_5_onepi_opicomponents1 : 
