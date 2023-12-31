% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/03_similarity_searches.R
\name{read_diamond}
\alias{read_diamond}
\title{Read DIAMOND/BLAST tables as a list of data frames}
\usage{
read_diamond(diamond_dir = NULL)
}
\arguments{
\item{diamond_dir}{Path to directory containing the tabular output
of DIAMOND or similar programs (e.g., BLAST).}
}
\value{
A list of data frames with the tabular DIAMOND output.
}
\description{
Read DIAMOND/BLAST tables as a list of data frames
}
\examples{
# Path to output directory
diamond_dir <- system.file("extdata", package = "syntenet")

# Read output
l <- read_diamond(diamond_dir)
}
