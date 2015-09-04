/* censusDynamics.do v0.00       damiancclarke             yyyy-mm-dd:2015-04-17
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Takes census data to create trends and to examine the dynamic effects of the ar-
senic reform in Antofagasta in 1959/1971.

Currently, this is a 30% sample of the rest of the country, rather than all peo-
ple (see sampler variable)
*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) globals and locals
********************************************************************************
global DAT "~/investigacion/2015/arsenic/data/census"
global OUT "~/investigacion/2015/arsenic/results/dynamics"
global SUM "~/investigacion/2015/arsenic/results/summary"
global LOG "~/investigacion/2015/arsenic/log"

cap mkdir $SUM
log using "$LOG/censusDynamics.txt", text replace

local Y schooling completeUniv* someUniv active employed professional technic
local groups ChileAll ChileNoMig Region2All Region1_4All Region2NoMig Region1_4NoMig
local groups Region2All Region1_4All Region2NoMig Region1_4NoMig



********************************************************************************
*** (2) Use and set-up
********************************************************************************
use "$DAT/census2002_r1_4"
*use "$DAT/census2002"

rename bplclName birth_comuna
gen birthYear = 2002 - age
keep if birthYear >= 1945 & birthYear <= 1975

generat T1 = 0
replace T1 = 1 if  birth_comuna=="antofagasta"|birth_comuna=="mejillones"
replace T1 = 2 if birth_comuna=="tocopilla"|birth_comuna=="maria Elena"|/*
               */ birth_comuna=="calama"

gen ChileAll       = 1                               if T1!=2
gen ChileNoMig     = noMigrator                      if T1!=2
gen Region2All     = regioncode2000==2               if T1!=2
gen Region1_4All   = regioncode2000<=4               if T1!=2
gen Region2NoMig   = regioncode2000==2&noMigrator==1 if T1!=2
gen Region1_4NoMig = regioncode2000<=4&noMigrator==1 if T1!=2
gen Arsenic = T1
replace Arsenic = 0 if birthYear<1959


gen schooling = yrschl if yrschl != 99
gen completeUniversity5= educcl==15 & p26b>=5
gen completeUniversity4= educcl==15 & p26b>=4
gen someUniversity= educcl==15

gen active   = empstat<=2
gen employed = empstat==1

gen professional = occisco<=2 if occisco != 99
gen technician   = occisco==3 if occisco != 99

generat gender = "F" if sex==2
replace gender = "M" if sex==1




********************************************************************************
*** (3) Summary Stats
********************************************************************************
lab var schooling           "Years of Schooling"  
lab var completeUniversity4 "4+ Years of University"
lab var completeUniversity5 "5+ Years of University"
lab var someUniversity      "Some University"
lab var active              "Active on Labor Market"
lab var employed            "Employed"
lab var professional        "Professional Job"
lab var technic             "Technical Job"
lab var birthYear           "Year of Birth"
lab var noMigrator          "Has not Migrated"

#delimit ;
estpost tabstat `Y' birthYear Arsenic noMigrator if Region2All == 1,                              
 statistics(count mean sd min max) columns(statistics);
esttab using "$SUM/sumRegion2.tex", title("Descriptive Statistics (Region II)")
   cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(0)) max(fmt(0))")      
   replace label noobs;

estpost tabstat `Y' birthYear Arsenic noMigrator if Region1_4All == 1,                              
 statistics(count mean sd min max) columns(statistics);
esttab using "$SUM/sumRegion1_4.tex",
   title("Descriptive Statistics (Region I-IV)") replace label noobs
   cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(0)) max(fmt(0))");

/*
estpost tabstat `Y' birthYear Arsenic noMigrator if ChileAll == 1,                              
 statistics(count mean sd min max) columns(statistics);
esttab using "$SUM/sumAll.tex", title("Descriptive Statistics (Chile)") 
   cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(0)) max(fmt(0))")
   replace label noobs;
#delimit cr
*/

generat educLevel = . if educcl == 0
replace educLevel = 1 if educcl >= 1 & educcl <=2
replace educLevel = 2 if educcl >= 3 & educcl <=4
replace educLevel = 3 if educcl >= 5 & educcl <=11
replace educLevel = 4 if educcl >= 12 & educcl <=15

lab def ed 1 "None or Pre-Primary" 2 "Primary" 3 "Secondary" 4 "Tertiary"
lab val educLevel ed
gen number = 1
gen years = p26b
replace years = 4 if educLevel == 3 & p26b>4 
preserve
collapse (sum) number, by(educLevel years)
#delimit ;
graph hbar number, over(years) over(educLevel) nofill
  ytitle("Number of People") scheme(s1mono);
*graph export "$SUM/educationDesc.eps", as(eps) replace;
graph export "$SUM/educationDesc1_4.eps", as(eps) replace;
#delimit cr
restore


********************************************************************************
*** (4) Birth cohort trends
********************************************************************************
local i=1
foreach samp in `groups' {
    cap mkdir "$OUT/`samp'"
    preserve
    keep if `samp'==1

    if `i'==1|`i'==3 local snote "Rest of Region II"
    if `i'==2|`i'==4 local snote "Rest of Regions I-IV"
    collapse `Y', by(birthYear T1)

    lab var schooling           "Years of Schooling"  
    lab var completeUniversity4 "4+ Years of University"
    lab var completeUniversity5 "5+ Years of University"
    lab var someUniversity      "Some University"
    lab var active              "Active on Labor Market"
    lab var employed            "Employed"
    lab var professional        "Professional Job"
    lab var technic             "Technical Job"
    
    foreach outcome of varlist `Y' {
        dis "Graphing `outcome'"
        #delimit ;
        twoway connected `outcome' birthYear if T1==1, lpattern(dash) ||
               connected `outcome' birthYear if T1==0, scheme(s1mono)
        legend(label(1 "Antofagasta/Mejillones") label(2 "`snote'"))
        xtitle("Birth Year") xlabel(1945[5]1975, angle(55)) xline(1958 1971);
        graph export "$OUT/`samp'/Trend_`outcome'.eps", replace as(eps);
        #delimit cr
    }
    restore

    cap mkdir "$OUT/`samp'/gender"
    preserve
    keep if `samp'==1
    collapse `Y', by(birthYear T1 gender)

    foreach g in F M {
        foreach y of varlist `Y' {
            dis "Graphing `outcome'"
            #delimit ;
            twoway connected `y' birthYear if T1==1&gend=="`g'", lpattern(dash)
                || connected `y' birthYear if T1==0&gend=="`g'", scheme(s1mono)
            legend(lab(1 "Antofagasta/Mejillones") lab(2 "`samp'"))
            xtitle("Birth Year") xlabel(1945[5]1975, angle(55)) xline(1958 1971);
            graph export "$OUT/`samp'/gender/Trend_`y'_`g'.eps", replace as(eps);
            #delimit cr
        }
    }
    restore
    local ++i
}


********************************************************************************
*** (X) Clear
********************************************************************************
log close
