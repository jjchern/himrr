library(dplyr, warn.conflicts = FALSE)

# Download Health Insurance Market Rating Reform Data from CMS web --------

xml2::read_html("https://www.cms.gov/CCIIO/Programs-and-Initiatives/Health-Insurance-Market-Reforms/state-rating.html") %>%
        rvest::html_table() -> raw

big_tab = raw[[1]]
ny_vt_fam_tiers = raw[[2]]

head(big_tab)
# Note: X1:X5 are for Individual Market
# Note: X6:X12 are for Small Group Market

# State-specific age curve ------------------------------------------------

url = "https://www.cms.gov/CCIIO/Programs-and-Initiatives/Health-Insurance-Market-Reforms/Downloads/state-specific-age-curve-variations-08-09-2013.pdf"
fil = paste0("data-raw/", basename(url))
if (!file.exists(fil)) download.file(url, fil)

#tabulizer::locate_areas(fil)
ss_age_curve = tabulizer::extract_tables(fil, area = list(c(119.70416, 24.51772, 257.38059, 1207.02619)))

ss_age_curve[[1]] %>%
        as.data.frame(stringsAsFactors = FALSE) %>%
        mutate(
                V1 = stringr::str_replace(V1, "\r", ""),
                V46 = stringr::str_replace(V46, "\r", "")
        ) %>%
        readr::write_csv(tempfile()) %>%
        readr::read_csv(skip = 1) %>%
        rename(default_or_state = `Age (years)`) -> ss_age_curve

fips::fips %>%
        mutate(default_or_state = if_else(
                state %in% c("District of Columbia", "Massachusetts", "Minnesota", "Utah"),
                state,
                "Default"
        )) -> im_other_states

fips::fips %>%
        mutate(default_or_state = if_else(
                state %in% c("District of Columbia", "Massachusetts", "Minnesota", "New Jersey", "Utah"),
                state,
                "Default"
        )) -> sgm_other_states

ss_age_curve %>%
        filter(default_or_state != "New Jersey") %>%
        full_join(im_other_states, by = "default_or_state") %>%
        tidyr::gather(age, age_curve, -state, -fips, -usps, -default_or_state) %>%
        select(state, age, age_curve) %>%
        arrange(state, age) %>%
        group_by(state) %>%
        tidyr::nest(.key = age_curve) -> im_ss_age_curve

ss_age_curve %>%
        full_join(smm_other_states, by = "default_or_state") %>%
        tidyr::gather(age, age_curve, -state, -fips, -usps, -default_or_state) %>%
        select(state, age, age_curve) %>%
        arrange(state, age) %>%
        group_by(state) %>%
        tidyr::nest(.key = age_curve) -> sgm_ss_age_curve

ss_age_curve %>%
        filter(default_or_state == "Default") %>%
        rename(default = default_or_state) %>%
        tidyr::gather(age, age_curve, -default) %>%
        group_by(default) %>%
        tidyr::nest(.key = age_curve) -> default_age_curve

# Clean Individual Market Parameters ---------------------------------------

big_tab %>%
        select(X1:X5) %>% #
        readr::write_csv(tempfile()) %>%
        readr::read_csv(skip = 2) %>%
        rename(
                state                       = State,
                age_rating_ratio            = `Age Rating Ratio`,
                state_establisted_age_curve = `State-Established Age Curve`,
                tobacco_rating_ratio        = `Tobacco Rating Ratio`,
                family_tiers                = `Uniform Family Tiers`
        ) %>%
        mutate(
                age_rating_ratio            = if_else(stringr::str_detect(age_rating_ratio, "\\s"), "3:1", age_rating_ratio),
                state_establisted_age_curve = if_else(stringr::str_detect(state_establisted_age_curve, "\\s"), "No", state_establisted_age_curve),
                tobacco_rating_ratio        = if_else(stringr::str_detect(tobacco_rating_ratio, "\\s"), "1.5:1", tobacco_rating_ratio),
                family_tiers                = if_else(stringr::str_detect(family_tiers, "\\s"), "Uniform", "Special"),
                family_tiers                = if_else(state == "New York", "one adult: 1; two adults: 2; one adult and one or more children: 1.7; two adults and one or more children: 2.85", family_tiers),
                family_tiers                = if_else(state == "Vermont", "one adult: 1; two adults: 2; one adult and one or more children: 1.93; two adults and one or more children: 2.81", family_tiers)
        ) %>%
        full_join(im_ss_age_curve, by = "state") %>%
        select(state, age_rating_ratio, state_establisted_age_curve, age_curve, everything()) -> im


# Clean Small Group Market Parameters -------------------------------------

big_tab %>%
        select(X1, X6:X12) %>%
        readr::write_csv(tempfile()) %>%
        readr::read_csv(skip = 2) %>%
        rename(
                state                       = State,
                age_rating_ratio            = `Age Rating Ratio`,
                state_establisted_age_curve = `State-Established Age Curve`,
                tobacco_rating_ratio        = `Tobacco Rating Ratio`,
                family_tiers                = `Uniform Family Tiers`,
                avg_enrollee_premium        = `Average Enrollee Premiums1`,
                ss_composite_premium_method = `State-Specific Composite Premium Method2`,
                expanded_def_small_employer = `State expanded definition of small employer3`
        ) %>%
        mutate(
                age_rating_ratio            = if_else(stringr::str_detect(age_rating_ratio, "\\s"), "3:1", age_rating_ratio),
                state_establisted_age_curve = if_else(stringr::str_detect(state_establisted_age_curve, "\\s"), "No", state_establisted_age_curve),
                tobacco_rating_ratio        = if_else(stringr::str_detect(tobacco_rating_ratio, "\\s"), "1.5:1", tobacco_rating_ratio),
                family_tiers                = if_else(stringr::str_detect(family_tiers, "\\s"), "Uniform", "Special"),
                family_tiers                = if_else(state == "New York", "one adult: 1; two adults: 2; one adult and one or more children: 1.7; two adults and one or more children: 2.85", family_tiers),
                family_tiers                = if_else(state == "Vermont", "one adult: 1; two adults: 2; one adult and one or more children: 1.93; two adults and one or more children: 2.81", family_tiers),
                avg_enrollee_premium        = if_else(avg_enrollee_premium == "Yes", "Yes", "No"),
                ss_composite_premium_method = if_else(ss_composite_premium_method == "Yes", "Yes", "No"),
                expanded_def_small_employer = if_else(expanded_def_small_employer == "Yes", "Yes", "No")
        ) %>%
        full_join(sgm_ss_age_curve, by = "state") %>%
        select(state, age_rating_ratio, state_establisted_age_curve, age_curve, everything()) -> sgm

# Prepare a federal default df --------------------------------------------

tibble::data_frame(
        age_rating_rato = "3:1",
        age_curve = default_age_curve$age_curve,
        tobacco_rating_ratio = "1.5:1",
        family_tiers = "Uniform (Per Member Rating)",
        avg_enrollee_premium = "Federal default method of two tiers: one tier for all adults and a second tier for all children under 21.",
        composite_premium_method = "No. Federal default is per-member premiums.",
        def_small_employer = "Employer with 1-50 employees. But States have option to expand the definition of small employer to 1-100 employees."
) -> default


# Save the three datasets -------------------------------------------------

devtools::use_data(im, sgm, default, overwrite = TRUE)
