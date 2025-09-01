
// 1. Import & basic checks

import delimited "/Users/ducthanh/Desktop/patents_litigation_case/litigation_master_cleaned_data.csv"
describe
count

// 2. Dates & Core Variables
 
* If dates are strings like 2020-05-17, convert to Stata dates
gen filed_date  = date(date_filed,  "YMD")
gen closed_date = date(date_closed, "YMD")
format filed_date closed_date %td

* Duration (prefer the SQL-calculated one; backstop if missing/odd)
capture confirm variable case_duration_days
gen duration = case_duration_days if !missing(case_duration_days)
replace duration = closed_date - filed_date if missing(duration) & !missing(filed_date, closed_date)

* Clean impossible/negative durations
drop if duration < 0
label var duration "Case duration in days"

* Outcome dummies
encode inferred_outcome, gen(outcome_code)
gen settlement = (inferred_outcome=="Settlement")
gen judgment   = (inferred_outcome=="Judgment")
gen dismissed  = (inferred_outcome=="Dismissed")
gen ongoing    = (inferred_outcome=="Ongoing/Other")

* Court factor (encode string → numeric)
encode court_code, gen(court)
label var court "Court (encoded)"

// 3. Complexity features & sanity summaries

* Case complexity proxies
egen parties_total = rowtotal(n_plaintiffs n_defendants n_counter_plaintiffs n_counter_defendants n_third_parties)
gen ln_attorneys   = ln(n_attorneys + 1)
gen ln_parties     = ln(parties_total + 1)
gen ln_duration    = ln(duration + 1)

* Quick descriptive tables for the report appendix
tab inferred_outcome
tab court if _N<., sort
summ duration n_plaintiffs n_defendants n_attorneys parties_total

// 4. Descriptive Visuals

* Outcome share
graph pie, over(inferred_outcome) title("Share of outcomes")
graph export "outputs/outcome_share.png", replace

* Duration by outcome
graph box duration, over(inferred_outcome) title("Duration by outcome")
graph export "outputs/duration_by_outcome.png", replace

// 5. Model 1 - Probability of settlement (Logit)

* Baseline logit: does complexity affect settlement?
logit settlement n_plaintiffs n_defendants n_attorneys i.court, vce(cluster court)
est store L1

* Add richer complexity and outcomes for robustness
logit settlement ln_parties ln_attorneys i.court, vce(cluster court)
est store L2

* Marginal effects (business translation of coefficients)
margins, at(n_defendants=(1 3 5 10)) post
est store M1

* Export nice tables
capture which esttab
if _rc ssc install estout, replace
esttab L1 L2 using "outputs/settlement_models.rtf", replace b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) compress

// 6. Model 2 — How long do cases take?
* Exclude ongoing cases if they have no closure; keep only positive durations
keep if duration>0

reg ln_duration ln_parties ln_attorneys i.outcome_code i.court, vce(cluster court)
est store D1

* Interpretation helper: percent change per additional party
lincom ln_parties, eform
esttab D1 using "outputs/duration_model.rtf", replace 
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) compress


// 7. Model 3 — Time-to-settlement (Survival analysis)

* Failure = settlement event; censored otherwise (judgment/dismissed/ongoing)
stset duration, failure(settlement)

* Kaplan–Meier curves by simple complexity buckets
xtile parties_terc = parties_total, n(3)
label define terc 1 "Low" 2 "Mid" 3 "High"
label values parties_terc terc

sts graph, by(parties_terc) ci title("Time-to-settlement by complexity (KM)")
graph export "outputs/km_parties.png", replace

* Cox proportional hazards with court FE (strata as alternative)
stcox ln_parties ln_attorneys i.court, vce(cluster court)
est store S1

* PH assumption check (global and by covariate)
estat phtest, detail

// 8. Court benchmarking (performance & mix)

* Court-level KPIs for dashboarding
collapse (count) cases=case_row_id (mean) mean_duration=duration /// 
         (mean) settle_rate=settlement, by(court_code)
sort cases
export delimited using "outputs/court_benchmarks.csv", replace

/// 9. Export 

* One-page model summary
esttab L1 L2 D1 S1 using "outputs/model_summary.docx", ///
      replace title("Litigation Models Summary") b(%9.3f) se(%9.3f) ///
      star(* 0.10 ** 0.05 *** 0.01) compress


