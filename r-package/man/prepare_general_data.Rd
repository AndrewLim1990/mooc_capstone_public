% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/general_wrangling.R
\name{prepare_general_data}
\alias{prepare_general_data}
\title{Cleans raw demographic data}
\usage{
prepare_general_data(data, language_info, country_info)
}
\arguments{
\item{data}{Data frame containing student demographic information}

\item{language_info}{Data frame containing languages and their associated ISO 
codes}

\item{country_info}{Data frame with countries and their associated languages 
as ISO codes}
}
\value{
Cleaned data frame containing demographic information
}
\description{
Cleans raw demographic data
}
\examples{
prepare_general_data(
  obtain_raw_general_data('psyc1'), 
  language_info(), 
  country_info()
)
}
