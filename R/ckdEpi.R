#' CKD-EPI
#' @details Calculate estimated glomerular filtration rate (eGFR) by CKD-EPI equation
#' Reference to the equation: Levey AS, Stevens LA, Schmid CH et al. A New Equation to Estimate Glomerular Filtration Rate. Ann Intern Med 2009;150:604–12.
#'
#' @param creatinine Numeric vector. Serum creatinine, could be expressed in "umol/l", "mmol/l" or "mg/dL". Units of measurement should be defined in variable creatinineUnit (if not defined explicitly by user, the default value is "micromol/L").
#' @param age Numeric vector. Age, in years.
#' @param gender Vector
#' @param race Vector. race, specify in case of black patients. The value of variable refers to the parameter label_black.
#' @param creatinineUnit Character string. Units in which serum creatinne is expressed. Could be one of the following: "micromol/l", "mmol/l" or "mg/dl".
#' @return numeric eGFR expressed in ml/min/1.73m<sup>2</sup>.
#' @export
#' @name eGlomerularFiltrationRateCkdEpi
#' @examples
#' estimatedGlomerularFiltrationRateCkdEpi (creatinine = 1.4, age = 60, gender = "Male", race = "White",
#'   creatinineUnit = "mg/dl")
eGlomerularFiltrationRateCkdEpi <- function (
  creatinine,
  age,
  gender,
  race,
  creatinineUnit
) {
  label_black = c ("black")
  labelGenderMale = c ("Male", 1)
  labelGenderFemale = c ("Female", 0)
  creatinine <- ifelse (  creatinineUnit == "mg/dl",
                          creatinine,
                          ifelse(  creatinineUnit == "umol/l",
                                   creatinine / 88.4,
                                   ifelse(  creatinineUnit == "mmol/l",
                                            1000 * creatinine / 88.4, NA)
                                   )
  )
  eGFR <- ifelse( gender %in% labelGenderFemale,
                  ifelse(creatinine <= 0.7,
                          ( (creatinine / 0.7)^(-0.329) ) * (0.993^age),
                          ( (creatinine / 0.7)^(-1.209) ) * (0.993^age)
                  ),
                  ifelse(gender %in% labelGenderMale,
                          ifelse( creatinine <= 0.9,
                                  ( (creatinine / 0.9)^(-0.411) ) * (0.993^age),
                                  ( (creatinine / 0.9)^(-1.209) ) * (0.993^age)
                          ),  NA))


  # apply second set of coefficients for gender and race
  eGFR <- ifelse( race %in% label_black,
                  ifelse( gender %in% labelGenderFemale,
                          eGFR * 166,
                          ifelse( gender %in% labelGenderMale,
                                  eGFR * 163,
                                  NA
                          )
                  ),
                  ifelse( gender %in% labelGenderFemale,
                          eGFR * 144,
                          ifelse( gender %in% labelGenderMale,
                                  eGFR * 141,
                                  NA # if gender value is not corresponding neither to male nor female labels)
                          )
                  )
  )
  return (round(eGFR, 2))
}
