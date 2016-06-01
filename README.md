
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

States can request a standard lower than the federal standard. For example, DC, MA, NY, and UT have their own age curve for both individual and small group markets, and NJ has specific age curve for small group market.

Source
------

-   [Market Rating Reforms, State Specific Rating Variations, CCIIO; Updated February 26, 2016.](https://www.cms.gov/CCIIO/Programs-and-Initiatives/Health-Insurance-Market-Reforms/state-rating.html)

Installation
============

``` r
# install.packages("devtools")
devtools::install_github("jjchern/himrr")
```

Usage
=====

`himrr`'s Three Tibbles
-----------------------

`himrr` includes three datasets:

-   `himrr::default` for federal default,
-   `himrr::im` for state-specific rating variations in individual market, and
-   `himrr::sgm` for state-specific rating variations in small group market.

``` r
library(dplyr, warn.conflicts = FALSE)
himrr::default
#> Source: local data frame [1 x 7]
#> 
#>   age_rating_rato       age_curve tobacco_rating_ratio
#>             <chr>          <list>                <chr>
#> 1             3:1 <tbl_df [45,2]>                1.5:1
#> Variables not shown: family_tiers <chr>, avg_enrollee_premium <chr>,
#>   composite_premium_method <chr>, def_small_employer <chr>.
himrr::im
#> Source: local data frame [51 x 6]
#> 
#>                   state age_rating_ratio state_establisted_age_curve
#>                   <chr>            <chr>                       <chr>
#> 1               Alabama              3:1                          No
#> 2                Alaska              3:1                          No
#> 3               Arizona              3:1                          No
#> 4              Arkansas              3:1                          No
#> 5            California              3:1                          No
#> 6              Colorado              3:1                          No
#> 7           Connecticut              3:1                          No
#> 8              Delaware              3:1                          No
#> 9  District of Columbia              3:1                         Yes
#> 10              Florida              3:1                          No
#> ..                  ...              ...                         ...
#> Variables not shown: age_curve <list>, tobacco_rating_ratio <chr>,
#>   family_tiers <chr>.
himrr::sgm
#> Source: local data frame [51 x 9]
#> 
#>                   state age_rating_ratio state_establisted_age_curve
#>                   <chr>            <chr>                       <chr>
#> 1               Alabama              3:1                          No
#> 2                Alaska              3:1                          No
#> 3               Arizona              3:1                          No
#> 4              Arkansas              3:1                          No
#> 5            California              3:1                          No
#> 6              Colorado              3:1                          No
#> 7           Connecticut              3:1                          No
#> 8              Delaware              3:1                          No
#> 9  District of Columbia              3:1                         Yes
#> 10              Florida              3:1                          No
#> ..                  ...              ...                         ...
#> Variables not shown: age_curve <list>, tobacco_rating_ratio <chr>,
#>   family_tiers <chr>, avg_enrollee_premium <chr>,
#>   ss_composite_premium_method <chr>, expanded_def_small_employer <chr>.
```

State Specific Age Curves for Individual Market
-----------------------------------------------

``` r
himrr::im %>% 
        select(state, age_curve) %>% 
        tidyr::unnest() 
#> Source: local data frame [2,295 x 3]
#> 
#>      state   age age_curve
#>      <chr> <chr>     <dbl>
#> 1  Alabama  0-20     0.635
#> 2  Alabama    21     1.000
#> 3  Alabama    22     1.000
#> 4  Alabama    23     1.000
#> 5  Alabama    24     1.000
#> 6  Alabama    25     1.004
#> 7  Alabama    26     1.024
#> 8  Alabama    27     1.048
#> 9  Alabama    28     1.087
#> 10 Alabama    29     1.119
#> ..     ...   ...       ...
```

State Specific Family Tiers For Individual Market
-------------------------------------------------

``` r
himrr::im %>% 
        select(state, family_tiers) %>% 
        mutate(state = if_else(family_tiers == "Uniform", "Other States", state)) %>% 
        distinct() %>% 
        knitr::kable()
```

| state        | family\_tiers                                                                                                    |
|:-------------|:-----------------------------------------------------------------------------------------------------------------|
| Other States | Uniform                                                                                                          |
| New York     | one adult: 1; two adults: 2; one adult and one or more children: 1.7; two adults and one or more children: 2.85  |
| Vermont      | one adult: 1; two adults: 2; one adult and one or more children: 1.93; two adults and one or more children: 2.81 |

Reference
=========

-   [KFF - Health Insurance & Managed Care](http://kff.org/state-category/health-insurance-managed-care/)
-   [The Affordable Care Act: Rating Factor Limitations](http://coventryhealthcare.com/web/groups/public/@cvty_corporate_chc/documents/webcontent/c084481.pdf)
