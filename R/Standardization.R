#' @export
#' @param nameFromListOfMeasurements one name of the measurement from list
#' @param siValue value to convert to US value
#' @return data.frame with 4 columns: nameFromListOfMeasurements, siValue, siUnit, usValue, usUnit
#' @title Convert SI unit value to US unit value
#' @description Function converts SI values to US
convertSiToUs <- function(nameFromListOfMeasurements, siValue) {r <-  data.table(getConv())[Measurement == nameFromListOfMeasurements, ][, res :=  round(siValue / Conversion, 2)]
   return(data.frame(nameFromListOfMeasurements = nameFromListOfMeasurements, siValue = siValue, siUnit = r[['SIUnit']], usValue  = r[['res']], usUnit = r[['ConventionalUnit']] ))
}
#' @export
#' @param nameFromListOfMeasurements one name of the measurement from list
#' @param usValue value to convert to SI value
#' @return data.frame with 4 columns: nameFromListOfMeasurements, siValue, siUnit, usValue, usUnit
#' @title Convert US unit value to SI unit value
#' @description Function converts US values to SI
convertUsToSi <- function(nameFromListOfMeasurements, usValue) {r <- data.table(getConv())[Measurement == nameFromListOfMeasurements, ][, res :=  round(usValue * Conversion, 2)]
  return(data.frame(nameFromListOfMeasurements = nameFromListOfMeasurements, siValue = r[['res']], siUnit = r[['SIUnit']], usValue  = usValue, usUnit = r[['ConventionalUnit']]))
}


