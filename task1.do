
* an example do-file
sysuse auto
generate gp100m = 100/mpg
label var gp100m "Gallons per 100 miles"
regress gp100m weight foreing

* practice1
use http://www.stata-press.com/data/r13/census5
tabulate region
summarize marriage_rate divorce_rate median_age if state!="Nevada"

* a sample analysis job
version 13
use http://www.stata-press.com/data/r13/census5
/* obtain the summary statistics: */
tabulate region
summarize marriage_rate divorce_rate median_age if state!="Nevada"

* a sample analysis job
version 13
use http://www.stata-press.com/data/r13/census5
tabulate region /* obtain summary statistics */
summarize marriage_rate divorce_rate median_age if state!="Nevada"

* argument practice
args dsname
use ‘dsname’
tabulate region
summarize marriage_rate divorce_rate

* Read in cd4.raw data and create stata data set
log using cd4-readin , replace
set memory 40m
infile time cd4 age packs drugs sexpart cesd id using cd4
gen timedays = round(time*365.25,1)
compress
label var id "subject ID"
label var time "years since seroconversion"
label var timedays "days since seroconversion"
label var cd4 "CD4 Count"
label var age "age (yrs) relative to arbitrary origin"
label var packs "packs of cigarettes smoked per day"
label var drugs "recreational drug use yes/no"
label var sexpart "number of sexual partners"
label var cesd "depression score relative to arbitrary origin"
save cd4 , replace
clear
log close 

*trajectory.do file for Stata 6.0
clear
use cd4
egen newid=group(id)
sum newid
drop id
ren newid id
egen cd4mean = mean(cd4), by(id)
list id cd4 cd4mean in 1/10
sort id
quietly by id: replace cd4mean=. if (_n > 1)
egen rnk=rank(cd4mean)
local i = 1
while `i' <= 7{
gen sub`i' =(rnk == `i'*25)
sort id timedays
quietly by id: replace sub`i'=sub`i'[1]
gen cd4l`i' = cd4 if (sub`i')
 drop sub`i'
 local i=`i'+1
}
ksm cd4 timedays, lowess gen(cd4smth) nograph
graph cd4 cd4l1-cd4l7 cd4smth timedays, c(.LLLLLLL.) s(.iiiiiiio)
pen(233333334) xlab ylab