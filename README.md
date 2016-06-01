
<!-- README.md is generated from README.Rmd. Please edit that file -->
About
=====

`himrr` is an R data package for policy parameters specified by ACA's **H**ealth **I**nsurance **M**arket **R**ating **R**eform.

Premiums in Health Insurance Marketplace are regulated under the Affordable Care Act (ACA). Specifically, [45 CFR 147.102 - Fair health insurance premiums](https://www.law.cornell.edu/cfr/text/45/147.102) provides a federal default of

1.  Age rating ratios of 3:1,
2.  Federally established age curve,
3.  Tobacco rating ratios of no more than 1.5:1,
4.  Two tiers: one tier for all adults and a second tier for all children under 21, and
5.  Per member rating.

States can request a standard lower than the federal standard.

`himrr` includes three datasets for federal defualt, state-specific rating variations in individual market, and state-specific rating variations in small group market.

Source
------

-   [Market Rating Reforms, State Specific Rating Variations, CCIIO; Updated February 26, 2016.](https://www.cms.gov/CCIIO/Programs-and-Initiatives/Health-Insurance-Market-Reforms/state-rating.html)

Installation
============

``` r
# install.packages("devtools")
devtools::install_github("jjchern/himrr")
```
