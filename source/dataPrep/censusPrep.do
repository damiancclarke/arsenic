/* censusPrep.do v0.00           damiancclarke             yyyy-mm-dd:2015-01-24
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes raw census data from 2002, names variables, labels variables co-
nsistently, and produces an output file. This includes comuna names, names of c-
omuna of birth, job type, and so forth.

Note that all merges here are complete, and the total censal population (15,116,
435) is accounted for.  Variable naming and setup is exactly as defined in IPUMS
harmonisation.  Further details are available at:
https://international.ipums.org/international-action/variables/group

contact: mailto:damian.clarke@economics.ox.ac.uk

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) Globals and locals
********************************************************************************
global DAT "~/database/Censo/CENSO_2002/CENSO2002"
global OUT "~/investigacion/2014/ParentalInvestments/data/census"
global LOG "~/investigacion/2014/ParentalInvestments/log"
global GEO "~/investigacion/2014/ParentalInvestments/data/Geo"


cap mkdir $OUT
log using "$LOG/censusPrep.txt", text replace

local indiv 1
local house 0

********************************************************************************
*** (2) Open file, merge comuna names
********************************************************************************
use "$DAT/persona.dta"
rename portafolio Portafolios
merge m:1 Portafolios using "$DAT/Portafolios"
drop if _merge==2
drop _merge

merge m:1 Comuna using "$DAT/Comunas"
drop _merge

gen x="x"
egen serial=concat(Portafolios x vn x hn)
bys serial: gen persons=_N
gen year = 2002

****************************************************************************
*** (3) Create birth comuna data
****************************************************************************
rename Comuna municl
rename nombre municlName
rename p22b   Comuna

merge m:1 Comuna using "$DAT/Comunas"

gen birthComunaKnown = _merge==3
replace birthComunaKnown= 2 if p22a == 2&_merge==1
replace birthComunaKnown= 3 if p22a == 3
replace birthComunaKnown= 9 if p22a == 9

gen bplclComuna = Comuna if _merge==3
drop _merge
rename nombre bplclName

replace bplclComuna = 96 if p22a == 3
replace bplclComuna = 98 if p22a == 9
replace bplclComuna = 97 if bplclComuna == .

if `indiv'==1 {
    ****************************************************************************
    *** (4) Name other variables
    ****************************************************************************
    rename pn pernum
    rename p34 chborn
    rename p35 chsurv
    rename p19 age
    rename p18 sex
    rename p21 ethncl
    rename p22c yrimm


    gen relate = p17==1
    replace relate = 2 if p17==2|p17==3
    replace relate = 3 if p17==4|p17==5
    replace relate = 4 if p17>5&p17<=13
    replace relate = 5 if p17>13

    gen marst = p27==0|p27==3
    replace marst = 2 if p27==1|p27==2
    replace marst = 3 if p27==4|p27==5
    replace marst = 4 if p27==6

    gen consens = p27==2

    gen nativity = 1 if p22a==1|p22a==2
    replace nativity=2 if p22a==3
    replace nativity=9 if p22a==9

    gen bplctry = Comuna if nativity!=1
    replace bplctry = 23040 if nativity==1

    gen yrsimm = 2002-yrimm if yrimm!=0&yrimm!=9999
    replace yrsimm=97 if yrsimm>97&yrsimm!=.
    replace yrsimm=98 if yrimm==9999
    replace yrsimm=99 if yrimm==0

    gen relig=p28==9
    replace relig=0 if p28==0
    replace relig=4 if p28==4
    replace relig=5 if p28==5
    replace relig=6 if p28==1|p28==2
    replace relig=7 if p28==3|p28==7|p28==8

    gen indig=ethncl<=8
    replace indig=2 if indig==0

    gen lit=p25==2
    replace lit=2 if p25==1

    gen edattan = .
    replace edattan = 0 if p26a==0
    replace edattan = 1 if p26a==1|p26a==2
    replace edattan = 1 if p26a==4&p26b<6
    replace edattan = 1 if p26a==3&p26b<6
    replace edattan = 2 if p26a==4&p26b>=6
    replace edattan = 2 if p26a==3&p26b>=6
    replace edattan = 2 if p26a>4&p26a<=11&p26b<4
    replace edattan = 3 if p26a>4&p26a<=11&p26b>=4
    replace edattan = 3 if p26a>11&p26b<5
    replace edattan = 4 if p26a>11&p26b>=5

    gen yrschl = .
    replace yrschl = 0 if p26a==1|p26a==2
    replace yrschl = p26b if p26a==3|p26a==4
    replace yrschl = 8 + p26b if p26a>4&p26a<=11
    replace yrschl = 12 if yrschl>12&yrschl!=.
    replace yrschl = 12 + p26b if p26a>11
    replace yrschl = 18 if yrschl>18&yrschl!=.
    replace yrschl = 99 if p26a==0

    rename p26a educcl

    gen empstat = .
    replace empstat = 0 if p29==0
    replace empstat = 1 if p29==1|p29==2|p29==4
    replace empstat = 2 if p29==3|p29==5
    replace empstat = 3 if p29>5&p29<=10

    gen occisco = .
    replace occisco = 1 if p31==11|p31==12|p31==13
    replace occisco = 2 if p31>20&p31<30 
    replace occisco = 3 if p31>30&p31<40
    replace occisco = 4 if p31>40&p31<50
    replace occisco = 5 if p31==51|p31==52
    replace occisco = 6 if p31==61|p31==62
    replace occisco = 7 if p31>70&p31<80
    replace occisco = 8 if p31>80&p31<90
    replace occisco = 9 if p31>90&p31<100
    replace occisco = 10 if p31 == 1
    replace occisco = 99 if p31 == 0

    rename p31 occ

    gen indgen = .
    replace indgen = 0 if p32==0
    replace indgen = 10 if p32>0&p32<=10
    replace indgen = 20 if p32>10&p32<=20
    replace indgen = 30 if p32>20&p32<=40
    replace indgen = 40 if p32>40&p32<=45
    replace indgen = 50 if p32==45
    replace indgen = 60 if p32>50&p32<=55
    replace indgen = 70 if p32==55
    replace indgen = 80 if p32>60&p32<=65
    replace indgen = 90 if p32>64&p32<=69
    replace indgen = 100 if p32==75
    replace indgen = 111 if p32==70|p32==74
    replace indgen = 112 if p32==80
    replace indgen = 113 if p32==85
    replace indgen = 114 if p32==71|p32==72|p32==73|(p32>=90&p32<=93)
    replace indgen = 120 if p32==95
    replace indgen = 999 if p32==99

    rename p32 ind

    gen classwk = .
    replace classwk = 0 if p30==0
    replace classwk = 1 if p30==3
    replace classwk = 2 if p30==1|p30==2|p30==4
    replace classwk = 3 if p30==5

    gen geo1b_cl=round(municl/1000)

    gen oldreg = round(p24b/1000)
    gen mgrate5 = .
    replace mgrate5 = 0 if p24a==0
    replace mgrate5 = 11 if p24a==1
    replace mgrate5 = 12 if p24a==2&oldreg==geo1b_cl
    replace mgrate5 = 20 if p24a==2&oldreg!=geo1b_cl
    replace mgrate5 = 30 if p24a==33
    replace mgrate5 = 99 if p24a==9

    gen mgctry2 = p24b if p24a==3
    replace mgctry2 = 0 if mgctry==.

    gen migcl2 = p24b if mgrate5==11|mgrate5==12|mgrate5==20
    replace migcl2 = 999 if mgrate5==0
    replace migcl2 = 998 if mgrate5==99
    replace migcl2 = 996 if mgrate5==30

    gen disemp = 1 if p29==9
    replace disemp = 2 if p29!=9&p29!=0
    replace disemp = 9 if p29==0

    gen disblnd=(p20_1-2)*-1
    gen disdeaf=(p20_2-2)*-1
    gen dismute=(p20_3-2)*-1
    gen dismntl=(p20_4-2)*-1
    gen disable = p20_6 + 1

    tab p23a
    tab p24a
    gen livesHere  = p23a==1
    gen livedHere  = p24a==1
    gen noMigrator = livesHere==1 & livedHere==1
    
    #delimit ;
    lab def sex   1 "Male" 2 "Female";
    lab def rel   1 "Head" 2 "Spouse/partner" 3 "Child" 4 "Other Relative" 5
    "Non-relative";
    lab def civ   1 "Single/never married" 2 "Married/in union" 3
    "Separated/divorced/spouse absent" 4 "Widowed";
    lab def nat   1 "Native-born" 2 "Foreign-born" 9 "Unknown";
    lab def rlg   0 "not in universe" 1 "No religion" 4 "Jewish" 5 "Muslim" 6
    "Christian" 7 "Other";
    lab def idg   1 "Yes" 2 "No";
    lab def lit   0 "not in universe" 1 "No (illiterate)" 2 "Yes (literate)";
    lab def edu   0 "Not un universe" 1 "Less than primary completed" 2
    "Primary completed" 3 "Secondary completed" 4
    "University completed";
    lab def emp   0 "Not un universe" 1 "Employed" 2 "Unemployed" 3 "Inactive";
    lab def occ   0 "Not un universe" 1 "Legislators, senior officials and managers"
    2 "Professionals" 3 "Technicians and associate professionals" 4 
    "Clarks" 5 "Service workers and shop and market sales" 6
    "Skilled agricultural and fishery workers" 7
    "Crafts and related trades workers" 8
    "Plant and machine operators and assemblers" 9
    "Elementary occupations" 10 "Armed forces" 99
    "NIU (not in universe)";
    lab def ind 0 "NIU (not in universe)" 10 "Agriculture, fishing, and forestry"
    20 "Mining" 30 "Manufacturing" 40 "Electricity, gas and water" 50
    "Construction" 60 "Wholesale and retail trade" 70
    "Hotels and restaurants" 80 "Transportation and communications" 90
    "Financial services and insurance" 100
    "Public administration and defense" 111
    "Real estate and business services" 112 "Education" 113
    "Health and social work" 114 "Other services" 120
    "Private household services" 999 "Response unkown";
    lab def wrk 0 "NIU (not in universe)" 1 "Self-employed" 2 "Wage/salary worker"
    3 "Unpaid worker";
    lab def mig 0 "NIU (not in universe)" 11 "Same major, same minor admini unit"
    12 "Same major, different minor admin unit" 20
    "Different major admin unit" 30 "Abroad" 99 "Unknown/missing";
    lab def dsb 1 "Disabled" 2 "Not Disabled" 9 "NIU (not in universe)";
    #delimit cr

    ****************************************************************************
    *** (5) Label
    ****************************************************************************
    lab values sex      sex
    lab values relate   rel
    lab values nativity nat
    lab values relig    rlg
    lab values indig    idg
    lab values lit      lit
    lab values edattan  edu
    lab values empstat  emp
    lab values occisco  occ
    lab values indgen   ind
    lab values disemp   dsb
    lab values disblnd  dsb
    lab values disdeaf  dsb
    lab values dismute  dsb
    lab values dismntl  dsb
    lab values disable  dsb


    lab var serial      "Household serial number"
    lab var persons     "Number of persons in household"
    lab var pernum      "Person number"
    lab var relate      "relation to household head"
    lab var sex         "Gender (1=male, 2=female)"
    lab var age         "Age in years (0-108)"
    lab var marst       "Marital status"
    lab var consens     "Consensual union"
    lab var nativity    "Nativity status"
    lab var bplctry     "Country of birth"
    lab var chborn      "Children ever born"
    lab var chsurv      "Children surviving"
    lab var bplclComuna "Code of birth comuna"
    lab var bplclName   "Name of birth comuna"
    lab var ethncl      "Ethnicity, Chile"
    lab var yrimm       "Year of immigration"
    lab var yrsimm      "Years since immigrated"
    lab var relig       "Religion"
    lab var indig       "Member of an indigenous group (1=yes, 2=no)"
    lab var lit         "Litearcy (1=no, 2=yes)"
    lab var edattan     "Educational attainment, international recode"
    lab var yrschl      "Years of schooling (99 is not in universe)"
    lab var educcl      "Educational attainment, Chile"
    lab var empstat     "Employment status"
    lab var occisco     "Occupation, ISCO general"
    lab var occ         "Occupation, unrecoded"
    lab var indgen      "Industry, general recode"
    lab var classwk     "Class of worker"
    lab var municl      "Municipality, Chile 1982-2002"
    lab var municlName  "Municipality, Chile 1982-2002 (name)"
    lab var geo1b_cl    "Region of CHile (1 to 15)"
    lab var mgrate      "Migration status, 5 years"
    lab var mgctry2     "Country of residence 5 years ago"
    lab var migcl2      "Comuna of residence 5 years ago"
    lab var disable     "Disability status"
    lab var disemp      "Employment disability"
    lab var disblnd     "Blind or vision-impaired"
    lab var disdeaf     "Deaf or hearing-impaired"
    lab var dismute     "Mute"
    lab var dismntl     "Mental disability"
    lab var livesHere   "Person still lives in comuna of birth"
    lab var livedHere   "Person lived in comuna of birth 5 years ago"
    lab var noMigrator  "Person lives in birth comuna and lived here 5 yrs ago"
    
    ****************************************************************************
    *** (6) Merge into old comuna names
    ****************************************************************************
    replace bplclComuna = 5802 if bplclComuna == 5505
    replace bplclComuna = 5803 if bplclComuna == 5507
    replace bplclComuna = 5801 if bplclComuna == 5106
    replace bplclComuna = 5804 if bplclComuna == 5108

    gen id=bplclComuna
    merge m:1 id using "$GEO/oldComunas"
    drop _merge

    ****************************************************************************
    *** (7) Save
    ****************************************************************************
    drop vn hn Portafolios p17 p27 Comuna birthComunaKnown p28 p30 p23a p23b  /*
    */ p20_* p22a p23* p24* p25 p28 p29 p30 p33* p36* x oldreg

    lab dat "Chile 2002 Census, all people.  Cleaned and coded (Damian Clarke)"
    save "$OUT/census2002", replace
    keep if regioncode2000<=4
    lab dat "Chile 2002 Census, region 1-4.  Cleaned and coded (Damian Clarke)"
    save "$OUT/census2002_r1_4", replace
}

********************************************************************************
*** (8) Add household characteristisc
********************************************************************************
if `house'==1 {
    keep vn hn pn Portafolios bplclComuna

    replace bplclComuna = 5802 if bplclComuna == 5505
    replace bplclComuna = 5803 if bplclComuna == 5507
    replace bplclComuna = 5801 if bplclComuna == 5106
    replace bplclComuna = 5804 if bplclComuna == 5108

    gen id=bplclComuna
    merge m:1 id using "$GEO/oldComunas"
    drop _merge

    
    rename vn VN_Renumerado
    rename hn HN
    rename Portafolios Portafolio
    merge m:1 Portafolio VN_R using "$DAT/Viviendas"
    drop if _merge==2
    drop V2 V4* V5 V6 V7 V8 V9 V10A V11 _merge
    replace V1=8 if V1>8
    rename V1 houseType
    rename V3 ownership
    drop VN
    rename VN_Renumerado VN

    
    lab def house 1 "House" 2 "Apartment" 3 "Rooms in house" 4 "mediagua" /*
    */5 "rancho/chuza" 6 "ruca" 7 "Mobile home" 8 "Other" 
    lab def owner 0 "N/A" 1 "Owner (paid off)" 2 "Owner (paying)" 3 "Renter" /*
    */ 4 "Given for work/service" 5 "Free"
    lab values houseType house
    lab values ownership owner
    
    
    merge m:1 Portafolio VN HN using "$DAT/Hogares"
    drop _merge

    gen television   = H15_1==1|H15_2==1 if H15_1!=0
    gen videocamera  = H15_3==1 if H15_3!=0
    gen cableTV      = H15_4==1 if H15_4!=0
    gen computer     = H15_15==1 if H15_15!=0
    gen washMachine  = H15_6==1 if H15_6!=0
    gen clothesDrier = H15_7==1 if H15_7!=0
    gen refrigerator = H15_8==1 if H15_8!=0
    gen freezer      = H15_9==1 if H15_9!=0
    gen microwave    = H15_10==1 if H15_10!=0
    gen internet     = H15_11==1 if H15_11!=0
    gen bicycle      = H16_1==1 if H16_1!=0
    gen motorbike    = H16_2==1 if H16_2!=0
    gen van          = H16_3==1 if H16_3!=0
    gen car          = H16_4==1 if H16_4!=0
    gen truck        = H16_5==1 if H16_5!=0
    gen boat         = H16_6==1 if H16_6!=0

    rename CSE_DECI goodsDecile

    lab var television   "Television in individual's household"
    lab var videocamera  "Videocamera in individual's household" 
    lab var cableTV      "Cable TV in individual's household" 
    lab var computer     "Computer in individual's household" 
    lab var washMachine  "Washing machine in individual's household" 
    lab var clothesDrier "Clothes Dryer in individual's household" 
    lab var refrigerator "Refrigerator in individual's household"
    lab var freezer      "Freezer in individual's household"
    lab var microwave    "Microwave in individual's household"
    lab var internet     "Internet in individual's household"
    lab var bicycle      "Bicycle accessible by individual"
    lab var motorbike    "Motorbile accessible by individual"
    lab var van          "Van (automobile) accessible by individual"
    lab var car          "Car accessible by individual"
    lab var truck        "Truck/jeep accessible by individual"
    lab var boat         "Boat accessible by individual"
    lab var goodsDecile  "Decile assigned to individual based on goods in home"

    drop H1* TH TM TP
    lab dat "Chile 2002 Census, household goods.  Cleaned and coded (D. Clarke)"
    save "$OUT/census2002_goods", replace

    ****************************************************************************
    *** (9) Subset
    ****************************************************************************
    keep if regioncode2000<=4
    gen x="x"
    egen serial=concat(Portafolio x VN x HN)
    rename pn pernum
    drop x
    merge 1:1 serial pernum using "$OUT/census2002_north"
    drop _merge
    
    save "$OUT/census2002_goods_r1_4", replace
}


********************************************************************************
*** (X) Close
********************************************************************************
log close
