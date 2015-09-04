# formatTabs.py v0.00            damiancclarke             yyyy-mm-dd:2015-09-03
#---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
#
# Formats tables exported from Stata for inclusion in LaTeX.  
# 
# Running is: python formatTabs.py
#

import re
import os

#==============================================================================
#== (0) File names 
#==============================================================================
RES = '/home/damiancclarke/investigacion/2015/arsenic/results/regression/' 
TAB = '/home/damiancclarke/investigacion/2015/arsenic/tables/'


mc    = '\\multicolumn{9}{l}{\\textbf{'
tlist = ['Region2', 'Region1_4', 'femaleRegion2', 'femaleRegion1_4', 
         'maleRegion2', 'maleRegion1_4']
names = ['residents of region II', 'residents of regions I-IV',
         'female residents of region II', 'female residents of regions I-IV',
         'male residents of region II', 'male residents of regions I-IV']

#==============================================================================
#== (1) Sum Stats table
#==============================================================================
tab   = open(TAB+'sumStats.tex', 'w')


tab.write('\\begin{table}[htbp] \\begin{center}\n'
'\\caption{Descriptive Statistics}\n'
'\\begin{tabular}{lccccc} \\toprule \n'
'& Observations & Mean & Std.\\ Dev. & Min. & Max \\\\ \\midrule \n'
'\\textbf{Panel A: Regions I-IV}&&&&&\\\\')

stats = open(RES+'../summary/sumRegion1_4.tex', 'r').readlines()
for i,line in enumerate(stats):
    if i>=9 and i<=19:
        tab.write(line)

tab.write('\\midrule \n \\textbf{Panel A: Region II}&&&&&\\\\')
stats = open(RES+'../summary/sumRegion2.tex', 'r').readlines()
for i,line in enumerate(stats):
    if i>=9 and i<=19:
        tab.write(line)

tab.write('\\bottomrule \\multicolumn{5}{p{10cm}}{\\begin{footnotesize}'
'\\textsc{Notes:} Add Notes.'
'\\end{footnotesize}} \n'
'\\end{tabular}\\end{center}\\end{table}')

tab.close()
#==============================================================================
#== (2) Arsenic tables
#==============================================================================
j = 0
for tt in tlist:
    tab = open(TAB+"arsenic" + tt + '.tex', 'w')

    tab.write('\\begin{landscape}\\begin{table}[htbp]\\begin{center}\n'
    '\\caption{Arsenic and Long Run Outcomes ('+names[j]+')}\n'
    '\\begin{tabular}{l*{8}{c}}\n \\toprule \n '
    '&(1)&(2)&(3)&(4)&(5)&(6)&(7)&(8)\\\\ \n '
    '&Years of&Four Year&Five Year&Enroled in&Active&Employed&Professional&Technical'
    '\\\\ \n &Education&University&University&University&&&Career&Career \\\\'
    '\\midrule \n'
    '\\multicolumn{9}{l}{\\textbf{Panel A: Fixed Effects, All}} \\\\ \n')

    results = open(RES+tt+'AllFE.tex', 'r').readlines()
    for i,line in enumerate(results):
        if i>=8 and i<=11:
            line = line.replace('\\midrule','&&&&&&&&\\\\')
            tab.write(line)

    tab.write(mc+'Panel B: Fixed Effects and trends, All}} \\\\ \n')
    results = open(RES+tt+'AllTrend.tex', 'r').readlines()
    for i,line in enumerate(results):
        if i>=8 and i<=11:
            line = line.replace('\\midrule','&&&&&&&&\\\\')
            tab.write(line)

    tab.write(mc+'Panel C: Fixed Effects, Non-Migrators}} \\\\ \n')
    results = open(RES+tt+'NoMigFE.tex', 'r').readlines()
    for i,line in enumerate(results):
        if i>=8 and i<=11:
            line = line.replace('\\midrule','&&&&&&&&\\\\')
            tab.write(line)

    tab.write(mc+'Panel D: Fixed Effects and trends, Non-Migrators}} \\\\ \n')
    results = open(RES+tt+'NoMigTrend.tex', 'r').readlines()
    for i,line in enumerate(results):
        if i>=8 and i<=11:
            line = line.replace('\\midrule','&&&&&&&&\\\\')
            tab.write(line)

    tab.write('\\bottomrule \n \\multicolumn{9}{p{17.4cm}}{'
              '\\begin{footnotesize} \\textsc{Notes:} Sample consists of all '
              +names[j] +' born between 1952 and 1968 (aged between 34 and 50'
              ' at the time of the census). Birth comuna and year fixed effects'
              ' are always included. Standard errors allow for arbitrary '
              'correlations within each comuna and birth cohort.'
              '\\end{footnotesize}}\\end{tabular}\\end{center}\n'
              '\\end{table}\\end{landscape}') 
    j = j+1
    tab.close()
