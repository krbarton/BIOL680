fc = FindFiles('*.t');
S = LoadSpikes(fc);
 
[csc,csc_info] = LoadCSC('R042-2013-08-18-CSC03a.ncs');

neuroplot(S(1:10),csc);