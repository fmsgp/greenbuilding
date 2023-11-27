//# Household water consumption 

**Panel A: household
use resid_clean.dta, clear

keep if HIP!=1 //removing HIP buildings
keep if status_alt!=2 //remove buildings that are built as green
drop if year_complete<1981 | year_complete>2011 //selecting buildings that are completed between 1981 and 2010

cap drop lnwat
gen lnwat=ln(wat+1)

cap drop wat_ext
summ wat, det
gen wat_ext=1 if wat>r(p99) | wat<r(p1)

*Table S1 Panel A column (2)
reghdfe lnwat 1.green#1.post if pcat==1, absorb(i.hid time) cluster(pcode) compact poolsize(5)

*Table 1 Panel A column (1) 
drop if wat_ext==1
reghdfe lnwat 1.green#1.post if pcat==1, absorb(i.hid time) cluster(pcode) compact poolsize(5)

*Figure3(a)
cap drop N
bysort hid (time): gen N=_N 
cap drop renter
gen renter=(N<=48)

reghdfe lnwat 1.post#i.renter if pcat==1, absorb(hid time) cluster(pcode) compact poolsize(5)

coefplot, drop(_cons) recast(scatter, ps(p1)) ciopts(recast(rbarm) color(%40) lw(0) barwidth(3) ) vertical ytitle("Log of consumption") ylabel(-0.1(0.05)0.1,format(%5.2f)) yline(0, lp(dash) lc(black)) omitted  coeflabels(1.post#0.renter="Home owner" 1.post#1.renter="Renter" ) base xtitle("Home ownership")

*Figure3(b)
gen ann=(time>685)
reghdfe lnwat 1.post 1.ann#0.green#1.pcat 1.ann#1.green#1.post#1.pcat, absorb(hid time) cluster(pcode) compact poolsize(5)
coefplot, drop(1.post _cons) recast(scatter, ps(p1)) ciopts(recast(rbarm) color(%40) lw(0) barwidth(3) ) vertical ytitle("Log of consumption") ylabel(-0.1(0.05)0.1,format(%5.2f)) yline(0, lp(dash) lc(black)) omitted coeflabels(1.ann#0.green#1.pcat="Non-green" 1.ann#1.green#1.post#1.pcat="Green")

*Figure 4(a)
drop if pcat!=1
reghdfe lnwat 1.green#1.post#i.award, absorb(hid time) cluster(pcode) compact poolsize(5)
eststo wathh_award
coefplot wathh_award, /// 
drop (1.green#1.post#0.award 1.green#1.post#1.award _cons) recast(scatter, ps(p1)) ciopts(recast(rbarm) pstyle(p1) color(%40) lw(0) barwidth(3) ) vertical ytitle("Log of monthly water consumption") ylabel(-0.1(0.05)0.1,format(%5.2f)) yline(0, lp(dash) lc(black)) omitted ///
coeflabels(1.green#1.post#2.award="Gold" 1.green#1.post#3.award="Gold Plus" 1.green#1.post#4.award="Platinum") legend(off) base xtitle("Award")

*Figure S1(a)
cap drop agec
gen agec=1 if year_complete<1990
replace agec=2 if year_complete>=1990 & year_complete<=2001
replace agec=3 if year_complete>2001


reghdfe lnwat 1.green#1.post#i.ptype, absorb(hid time) cluster(pcode) compact poolsize(5)
eststo wathh_ptype

reghdfe lnwat 1.green#1.post#i.agec, absorb(hid time) cluster(pcode) compact poolsize(5)
eststo wathh_agec

coefplot (wathh_ptype, keep(*#3.ptype *#4.ptype)) (`v'wathh_agec, keep(*#2.agec *#3.agec)), /// 
recast(scatter, ps(p1)) ciopts(recast(rbarm) color(%40) lw(0) barwidth(3) ) vertical ytitle("Log of consumption") ylabel(-0.1(0.05)0.1,format(%5.2f)) yline(0, lp(dash) lc(black)) omitted coeflabels(1.green#1.post#2.ptype="3-room" 1.green#1.post#3.ptype="4-room" 1.green#1.post#4.ptype="5-room+" 1.green#1.post#2.agec="1990-2000" 1.green#1.post#3.agec="After 2001") legend(off) base groups(*.ptype="{bf:Flat type}" *.agec="{bf:Building age}")

*Figure S1(b)
cap drop cn
bysort hid (year): gen cn=_n
cap drop m_wat
bysort hid: egen m_wat=mean(wat)
cap drop qt
egen qt=xtile(m_wat), nq(4)
cap drop cut
bysort hid: egen cut=mean(qt)
replace cut=0 if cut==.

reghdfe lnwat 1.green#1.post#i.cut, absorb(hid time) cluster(pcode) compact poolsize(5)
eststo wathh_wd
coefplot  wathh_wd, drop(1.green#1.post#0.cut _cons) /// 
recast(scatter, ps(p1)) ciopts(recast(rbarm) color(%40) lw(0) barwidth(3) ) vertical ytitle("Log of consumption") ylabel(-0.1(0.05)0.1,format(%5.2f)) yline(0, lp(dash) lc(black)) omitted coeflabels(*#1.cut="Q1"  *#2.cut="Q2" *#3.cut="Q3" *#4.cut="Q4") legend(off) base xtitle("Water demand")

*Figure S1(c)
cap drop floor_cat
gen floor_cat=1 if floor<=5
replace floor_cat=2 if floor>5 & floor<=10
replace floor_cat=3 if floor>10 & floor<=15
replace floor_cat=4 if floor>15
label def level 1 "low" 2 "mid" 3 "high" 4 "very high"
label values floor_cat leve

reghdfe lnwat 1.green#1.post#i.floor_cat, absorb(hid time) cluster(pcode) compact poolsize(5)

eststo wathh_floor
coefplot  wathh_floor, drop( _cons) /// 
recast(scatter, ps(p1)) ciopts(recast(rbarm) color(%40) lw(0) barwidth(3) ) vertical ytitle("Log of consumption") ylabel(-0.1(0.05)0.1,format(%5.2f)) yline(0, lp(dash) lc(black)) omitted coeflabels(1.green#1.post#1.floor_cat="low" 1.green#1.post#2.floor_cat="mid" 1.green#1.post#3.floor_cat="high" 1.green#1.post#4.floor_cat="very high") legend(off) base xtitle("Floor")


*Figure S1(d)
reghdfe lnwat 1.green#1.post#i.cert_year, absorb(hid time) cluster(pcode) compact poolsize(5)
eststo wathh_certyear
coefplot wathh_certyear, /// 
drop (1.green#1.post#0.cert_year 1.green#1.post#2011.cert_year _cons 1.green#1.post#2010.cert_year _cons) recast(scatter, ps(p1)) ciopts(recast(rbarm) pstyle(p1) color(%40) lw(0) barwidth(3) ) vertical ytitle("Log of monthly water consumption") ylabel(-0.1(0.05)0.1,format(%5.2f)) yline(0, lp(dash) lc(black)) omitted ///
coeflabels(1.green#1.post#2012.cert_year="2012" 1.green#1.post#2014.cert_year="2014" 1.green#1.post#2015.cert_year="2015" 1.green#1.post#2016.cert_year="2016" 1.green#1.post#2017.cert_year="2017") legend(off) base xtitle("Year of certification")
graph save wathh_certyear.gph, replace
graph export wathh_certyear.png, replace

*Table 1 Panel A column (2) 
cap drop amwat
bysort hid year: egen amwat=mean(wat)
cap drop cn
bysort hid year: gen cn=_n
keep if cn==1
cap drop lnamwat
gen lnamwat=ln(amwat+1)
csdid lnamwat, ivar(hid) time(year) gvar(cert_year) vce(cluster pcode)

csdid lnamwat, ivar(hid) time(year) gvar(cert_year) vce(cluster pcode)
estimates save csdid_wat, replace
cap drop cs_base
gen cs_base=e(sample)

*Figure 2(a)
estat event, window(-3 5)
/*
import excel csdidhh_wat_event.xlsx, sheet("Sheet1") firstrow clear

mkmat estimate min95 max95, matrix(plot)
matrix rownames plot= "T-3" "T-2" "T-1" "T0" "T+1"  "T+2" "T+3" "T+4" "T+5"

coefplot   matrix(plot[,1]), ci((plot[,2] plot[,3])) ylabel(-0.1(0.05)0.1,format(%5.2f)) vertical omitted recast(scatter, ps(p1)) ciopts(recast(rbarm) color(%40) lw(0) barwidth(3) ) ytitle("Log of consumption") yline(0) legend(off)

*/


*Table 1 Panel A column (3) 
gen cs_base=e(sample)
reghdfe lnamwat 1.green#1.post if cs_base==1, absorb(i.hid time) cluster(pcode) compact poolsize(5)

//# Robustness checks for household water consumption 
use resid_clean.dta, clear

keep if HIP!=1 //removing HIP buildings
cap drop lnwat
gen lnwat=ln(wat+1)

cap drop wat_ext
summ wat, det
gen wat_ext=1 if wat>r(p99) | wat<r(p1)
drop if wat_ext==1

*Table S1 Panel A column (5) 
reghdfe lnwat 1.green#1.post if pcat==1 & year_complete>=1981 & year_complete<2011, absorb(i.hid time) cluster(pcode) compact poolsize(5)

drop if year_complete<1981 | year_complete>2011
keep if status_alt!=2
*Table S1 Panel A column (3) 
reghdfe lnwat 1.green#1.post if pcat==1, absorb(i.hid time) cluster(pcode) compact poolsize(5)

*Table S1 Panel A column (4) 
cap drop N
bysort hid: gen N=_N
tab N
reghdfe lnwat 1.green#1.post if pcat==1 & N==120, absorb(i.hid time) cluster(pcode) compact poolsize(5)

*Table S1 Panel A column (6) 
cap drop loc
gen loc=floor(pcode/1000)
cap drop temp
bysort loc: egen temp=mean(green)
cap drop sr_loc
gen sr_loc=(temp>0)
reghdfe lnwat 1.green#1.post if pcat==1 & sr_loc==1, absorb(i.hid time) cluster(pcode) compact poolsize(5)

*Table S1 Panel A column (7) 
reghdfe lnwat 1.green#1.post lntemp lnrain if pcat==1, absorb(i.hid time) cluster(pcode) compact poolsize(5)

//# Common area water consumption
use reside_common, clear

**Panel B: common area
keep if HIP!=1 
keep if status_alt!=2
drop if year_complete<1981 | year_complete>=2011

cap drop ext
summ wat, det
gen ext=1 if wat>r(p95) | wat<r(p5)

*Table S1 Panel B column (2) 
reghdfe lnwat 1.green#1.post, absorb(pcode time) cluster(pcode) compact poolsize(5)

*Table 1 Panel B column (1)
drop if ext==1
reghdfe lnwat 1.green#1.post, absorb(pcode time) cluster(pcode) compact poolsize(5)

*Figure 4(b)
reghdfe lnwat 1.green#1.post#i.award, absorb(pcode time) cluster(pcode) compact poolsize(5)
eststo watcommon_award
coefplot  watcommon_award, /// 
drop (1.green#1.post#0.award 1.green#1.post#1.award _cons) recast(scatter, ps(p1)) ciopts(recast(rbarm) pstyle(p1) color(%40) lw(0) barwidth(3) ) vertical ytitle("Log of consumption") ylabel(-1(0.5)1,format(%5.2f)) yline(0, lp(dash) lc(black)) omitted ///
coeflabels(1.green#1.post#2.award="Gold" 1.green#1.post#3.award="Gold Plus" 1.green#1.post#4.award="Platinum") legend(off) base xtitle("Award")


*Table 1 Panel B column (2) 
cap drop amwat
bysort hid year: egen amwat=mean(wat)
cap drop cn
bysort hid year: gen cn=_n
keep if cn==1
cap drop lnamwat
gen lnamwat=ln(amwat+1)
csdid lnamwat, ivar(hid) time(year) gvar(cert_year) vce(cluster pcode) 
gen sc=e(sample)

*Figure 2(b)
estat event, window(-4 4)
/*
import excel csdid_commonevent.xlsx, sheet("Sheet1") firstrow clear

mkmat estimate min95 max95, matrix(plot)
matrix rownames plot= "T-4" "T-3" "T-2"  "T-1" "T0" "T+1"  "T+2" "T+3" "T+4"

coefplot   matrix(plot[,1]), ci((plot[,2] plot[,3])) ylabel(-0.5(0.25)0.5,format(%5.2f)) vertical omitted recast(scatter, ps(p1)) ciopts(recast(rbarm) color(%40) lw(0) barwidth(3) ) ytitle("Log of consumption") yline(0) legend(off)

*/

*Table 1 Panel B column (3) 
reghdfe lnamwat 1.green#1.post if sc==1, absorb(pcode year) cluster(pcode) compact poolsize(5)

//# Robustness checks for common area water consumption 
use reside_common, clear

keep if HIP!=1 //removing HIP buildings
cap drop lnwat
gen lnwat=ln(wat+1)

cap drop ext
summ wat, det
gen ext=1 if wat>r(p95) | wat<r(p5)
drop if ext==1

*Table S1 Panel B column (5) 
reghdfe lnwat 1.green#1.post if pcat==1 & year_complete>=1981 & year_complete<2011, absorb(pcode time) cluster(pcode) compact poolsize(5)

drop if year_complete<1981 | year_complete>2011
keep if status_alt!=2
*Table S1 Panel B column (3) 
reghdfe lnwat 1.green#1.post if pcat==1, absorb(pcode time) cluster(pcode) compact poolsize(5)

*Table S1 Panel B column (4) 
cap drop N
bysort hid: gen N=_N
tab N
reghdfe lnwat 1.green#1.post if pcat==1 & N==120, absorb(pcode time) cluster(pcode) compact poolsize(5)

*Table S1 Panel B column (6) 
cap drop loc
gen loc=floor(pcode/1000)
cap drop temp
bysort loc: egen temp=mean(green)
cap drop sr_loc
gen sr_loc=(temp>0)
reghdfe lnwat 1.green#1.post if pcat==1 & sr_loc==1, absorb(pcode time) cluster(pcode) compact poolsize(5)

*Table S1 Panel B column (7) 
reghdfe lnwat 1.green#1.post lntemp lnrain if pcat==1, absorb(pcode time) cluster(pcode) compact poolsize(5)

//# Including HIP sample
use resid_clean.dta, clear

keep if status_alt!=2 //remove buildings that are built as green
drop if year_complete<1981 | year_complete>2011 //selecting buildings that are completed between 1981 and 2010

cap drop lnwat
gen lnwat=ln(wat+1)

cap drop wat_ext
summ wat, det
gen wat_ext=1 if wat>r(p99) | wat<r(p1)

*Table 2 column (1)
reghdfe lnwat i.post_HIP#1.post if wat_ext!=1, absorb(i.hid time) cluster(pcode) compact poolsize(5)


*Table 2 column (2)
cap drop cn
bysort pcode ptype time: gen cn=_n
keep if cn==1

cap drop gid
egen gid=group(pcode ptype)
cap drop lnelec
gen lnelec=ln(elec_bp+1)

cap drop elec_ext
summ elec_bp, det
gen elec_ext=1 if elec_bp>r(p99) | elec_bp<r(p1)

reghdfe lnelec i.post_HIP#1.post if elec_ext!=1, absorb(i.gid time) cluster(pcode) compact poolsize(5)

//# Electricity and block-flat type level data

use resid_clean, clear

keep if HIP!=1 
keep if status_alt!=2
drop if year_complete<1981 | year_complete>2011
drop if cert_year<=year_complete & cert_year!=0

cap drop wat_bp
bysort pcode ptype time: egen wat_bp=mean(wat)

cap drop elec_bp
bysort pcode ptype time: egen elec_bp=mean(elec_hh)

cap drop cn
bysort pcode ptype time: gen cn=_n

keep if cn==1

cap drop gid
egen gid=group(pcode ptype)
cap drop lnwat
gen lnwat=ln(wat_bp+1)
cap drop lnelec
gen lnelec=ln(elec_bp+1)

cap drop elec_ext
cap drop wat_ext
summ elec_bp, det
gen elec_ext=1 if elec_bp>r(p99) | elec_bp<r(p1)
summ wat_bp, det
gen wat_ext=1 if wat_bp>r(p99) | wat_bp<r(p1)

*Table S3 column (2)
reghdfe lnwat 1.green#1.post, absorb(gid time) cluster(pcode) compact poolsize(5)

*Table S2 Panel A column (1)
drop if wat_ext==1 | elec_ext==1
reghdfe lnwat 1.green#1.post, absorb(gid time) cluster(pcode) compact poolsize(5)
*Table S2 Panel A column (2)
reghdfe lnelec 1.green#1.post, absorb(gid time) cluster(pcode) compact poolsize(5)

*Figure S2(a)
cap drop agec
gen agec=1 if year_complete<1990
replace agec=2 if year_complete>=1990 & year_complete<=2001
replace agec=3 if year_complete>2001


reghdfe lnelec 1.green#1.post#i.ptype, absorb(gid time) cluster(pcode) compact poolsize(5)
eststo elec_ptype

reghdfe lnelec 1.green#1.post#i.agec, absorb(gid time) cluster(pcode) compact poolsize(5)
eststo elec_agec

coefplot (elec_ptype, keep(*#3.ptype *#4.ptype)) (elec_agec, keep(*#2.agec *#3.agec)), /// 
recast(scatter, ps(p1)) ciopts(recast(rbarm) color(%40) lw(0) barwidth(3) ) vertical ytitle("Log of consumption") ylabel(-0.1(0.05)0.1,format(%5.2f)) yline(0, lp(dash) lc(black)) omitted coeflabels(1.green#1.post#2.ptype="3-room" 1.green#1.post#3.ptype="4-room" 1.green#1.post#4.ptype="5-room+" 1.green#1.post#2.agec="1990-2000" 1.green#1.post#3.agec="After 2001") legend(off) base groups(*.ptype="{bf:Flat type}" *.agec="{bf:Building age}")

*Figure S2(b)
cap drop cn
bysort gid (year): gen cn=_n
cap drop m_elec
bysort gid: egen m_elec=mean(elec_bp)
cap drop qt
egen qt=xtile(m_elec), by(ptype) nq(4)
cap drop cut
bysort gid: egen cut=mean(qt)
replace cut=0 if cut==.

reghdfe lnelec 1.green#1.post#i.cut, absorb(gid time) cluster(pcode) compact poolsize(5)
eststo elec_wd
coefplot  elec_wd, drop(1.green#1.post#0.cut _cons) /// 
recast(scatter, ps(p1)) ciopts(recast(rbarm) color(%40) lw(0) barwidth(3) ) vertical ytitle("Log of consumption") ylabel(-0.1(0.05)0.1,format(%5.2f)) yline(0, lp(dash) lc(black)) omitted coeflabels(*#1.cut="Q1"  *#2.cut="Q2" *#3.cut="Q3" *#4.cut="Q4") legend(off) base xtitle("Electricity demand")

*Figure S2(c)
reghdfe lnelec 1.green#1.post#i.award, absorb(gid time) cluster(pcode) compact poolsize(5)
eststo elec_award
coefplot elec_award, /// 
drop (1.green#1.post#0.award 1.green#1.post#1.award _cons) recast(scatter, ps(p1)) ciopts(recast(rbarm) pstyle(p1) color(%40) lw(0) barwidth(3) ) vertical ytitle("Log of monthly water consumption") ylabel(-0.1(0.05)0.1,format(%5.2f)) yline(0, lp(dash) lc(black)) omitted ///
coeflabels(1.green#1.post#2.award="Gold" 1.green#1.post#3.award="Gold Plus" 1.green#1.post#4.award="Platinum") legend(off) base xtitle("Award")

*Figure S2(d)
reghdfe lnelec 1.green#1.post#i.cert_year, absorb(gid time) cluster(pcode) compact poolsize(5)
eststo elec_certyear
coefplot elec_certyear, /// 
drop (1.green#1.post#0.cert_year 1.green#1.post#2011.cert_year _cons 1.green#1.post#2010.cert_year _cons) recast(scatter, ps(p1)) ciopts(recast(rbarm) pstyle(p1) color(%40) lw(0) barwidth(3) ) vertical ytitle("Log of monthly water consumption") ylabel(-0.1(0.05)0.1,format(%5.2f)) yline(0, lp(dash) lc(black)) omitted ///
coeflabels(1.green#1.post#2012.cert_year="2012" 1.green#1.post#2014.cert_year="2014" 1.green#1.post#2015.cert_year="2015" 1.green#1.post#2016.cert_year="2016" 1.green#1.post#2017.cert_year="2017") legend(off) base xtitle("Year of certification")

*Table S2 column (2)
cap drop amelec
bysort gid year: egen amelec=mean(elec_bp)
cap drop amwat
bysort gid year: egen amwat=mean(wat_bp)
cap drop cn
bysort gid year: gen cn=_n

keep if cn==1
cap drop lnamelec
gen lnamelec=ln(amelec+1)
cap drop lnamwat
gen lnamwat=ln(amwat+1)

csdid lnamwat, ivar(gid) time(year) gvar(cert_year) vce(cluster gid) notyet
estat simple

csdid lnamelec, ivar(gid) time(year) gvar(cert_year) vce(cluster pcode) noyet
estat simple
gen csdid_elecbpy=e(sample)

*Figure S3
estat event, window(-3 5)
/*
import excel csdidhh_elec_event.xlsx, sheet("Sheet1") firstrow clear

mkmat estimate min95 max95, matrix(plot)
matrix rownames plot= "T-3" "T-2" "T-1" "T0" "T+1"  "T+2" "T+3" "T+4" "T+5"

coefplot   matrix(plot[,1]), ci((plot[,2] plot[,3])) ylabel(-0.1(0.05)0.1,format(%5.2f)) vertical omitted recast(scatter, ps(p1)) ciopts(recast(rbarm) color(%40) lw(0) barwidth(3) ) ytitle("Log of consumption") yline(0) legend(off)

*/

*Table S2 column (3)
reghdfe lnamwat 1.green#1.post if csdid_elecbpy==1, absorb(gid year) cluster(pcode) compact poolsize(5)
reghdfe lnamelec 1.green#1.post if csdid_elecbpy==1, absorb(gid year) cluster(pcode) compact poolsize(5)

//# Robustness checks for electricity
use resid_clean.dta, clear

keep if HIP!=1 
drop if cert_year<=year_complete & cert_year!=0

cap drop wat_bp
bysort pcode ptype time: egen wat_bp=mean(wat)

cap drop elec_bp
bysort pcode ptype time: egen elec_bp=mean(elec_hh)

cap drop cn
bysort pcode ptype time: gen cn=_n

keep if cn==1

cap drop gid
egen gid=group(pcode ptype)
cap drop lnwat
gen lnwat=ln(wat_bp+1)
cap drop lnelec
gen lnelec=ln(elec_bp+1)

cap drop elec_ext
cap drop wat_ext
summ elec_bp, det
gen elec_ext=1 if elec_bp>r(p99) | elec_bp<r(p1)
summ wat_bp, det
gen wat_ext=1 if wat_bp>r(p99) | wat_bp<r(p1)

drop if wat_ext==1 | elec_ext==1

*Table S1 Panel A column (5) 
reghdfe lnwat 1.green#1.post if pcat==1 & year_complete>=1981 & year_complete<2011, absorb(i.hid time) cluster(pcode) compact poolsize(5)

drop if year_complete<1981 | year_complete>2011
keep if status_alt!=2
*Table S1 Panel A column (3) 
reghdfe lnwat 1.green#1.post if pcat==1, absorb(i.hid time) cluster(pcode) compact poolsize(5)

*Table S1 Panel A column (4) 
cap drop N
bysort hid: gen N=_N
tab N
reghdfe lnwat 1.green#1.post if pcat==1 & N==120, absorb(i.hid time) cluster(pcode) compact poolsize(5)

*Table S1 Panel A column (6) 
cap drop loc
gen loc=floor(pcode/1000)
cap drop temp
bysort loc: egen temp=mean(green)
cap drop sr_loc
gen sr_loc=(temp>0)
reghdfe lnwat 1.green#1.post if pcat==1 & sr_loc==1, absorb(i.hid time) cluster(pcode) compact poolsize(5)

*Table S1 Panel A column (7) 
reghdfe lnwat 1.green#1.post lntemp lnrain if pcat==1, absorb(i.hid time) cluster(pcode) compact poolsize(5)

//# Existing commercial buildings: 
use commercial_clean.dta, clear

drop if status==2
bysort accountID (time): gen N=_N
bysort accountID (time): gen cn=_n

keep if N==120
gen lnwat=ln(wat+1)

cap drop ext
summ wat, det
gen ext5=1 if wat>r(p95) | wat<r(p5)
*Table S4 column (1)
reghdfe lnwat 1.green#1.post#i.section if ext5!=1 , absorb(accountID time) cluster(accountID)

cap drop mwat
bysort accountID year: egen mwat=mean(wat)
cap drop cn
bysort accountID year: gen cn=_n
cap drop lnmwat
gen lnmwat=ln(mwat+1)
keep if cn==1

*Table S4 column (2)

csdid lnmwat, ivar(accountID) time(year) gvar(cert_year) vce(cluster accountID) 
estat simple
gen sc=e(sample)

*Figure S4 
estat event, window(-3 5)
/*
import excel csdidenr_event.xlsx, sheet("Sheet1") firstrow clear

mkmat estimate min95 max95, matrix(plot)
matrix rownames plot= "T-3" "T-2" "T-1" "T0" "T+1"  "T+2" "T+3" "T+4" "T+5"

coefplot   matrix(plot[,1]), ci((plot[,2] plot[,3])) ylabel(-0.2(0.1)0.2,format(%5.2f)) vertical omitted recast(scatter, ps(p1)) ciopts(recast(rbarm) color(%40) lw(0) barwidth(3) ) ytitle("Log of consumption") yline(0) legend(off)

*/

*Table S4 column (3)
reghdfe lnmwat 1.green#1.post sc==1, absorb(accountID year) cluster(accountID) 


//# New residential buildings
use resid_clean.dta, clear

keep if HIP!=1 
keep if status_alt!=1
drop if cert_year>=year_complete & cert_year!=0
drop if pcat==2
drop if year_complete<2010

gen district=floor(pcode/10000)
cap drop floor_cat
gen floor_cat=1 if floor<=5
replace floor_cat=2 if floor>5 & floor<=10
replace floor_cat=3 if floor>10 & floor<=15
replace floor_cat=4 if floor>15
label def level 1 "low" 2 "mid" 3 "high" 4 "very high"
label values floor_cat leve

cap drop wat_ext
summ wat, det
gen wat_ext=1 if wat>r(p99) | wat<r(p1)

gen lnwat=ln(wat+1)

bysort pcode: egen maxfloor=max(floor)
gen topfloor=(maxfloor==floor)

*Table S5 column(1)
reghdfe lnwat 1.green dist_mrt if wat_ext!=1, absorb(i.time i.year_complete i.ptype i.floor_cat i.district i.topfloor) cluster(pcode) compact poolsize(5)
gen sam=e(sample)

cap drop elec_bp
bysort pcode ptype time: egen elec_bp=mean(elec_hh)
cap drop cn
bysort pcode ptype time: gen cn=_n
keep if cn==1

cap drop gid
egen gid=group(pcode ptype)
cap drop lnelec
gen lnelec=ln(elec_bp+1)

cap drop elec_ext
summ elec_bp, det
gen elec_ext=1 if elec_bp>r(p99) | elec_bp<r(p1)

*Table S5 column(2)
reghdfe lnelec 1.green dist_mrt if wat_ext!=1 & elec_ext!=1, absorb(i.time i.year_complete i.ptype i.floor_cat i.district i.topfloor) cluster(pcode) compact poolsize(5)

