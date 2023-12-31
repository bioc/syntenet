% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/syntenet-package.R
\docType{package}
\name{syntenet-package}
\alias{syntenet}
\alias{syntenet-package}
\title{syntenet: Inference And Analysis Of Synteny Networks}
\description{
\if{html}{\figure{logo.png}{options: style='float: right' alt='logo' width='120'}}

syntenet can be used to infer synteny networks from whole-genome protein sequences and analyze them. Anchor pairs are detected with the MCScanX algorithm, which was ported to this package with the Rcpp framework for R and C++ integration. Anchor pairs from synteny analyses are treated as an undirected unweighted graph (i.e., a synteny network), and users can perform: i. network clustering; ii. phylogenomic profiling (by identifying which species contain which clusters) and; iii. microsynteny-based phylogeny reconstruction with maximum likelihood.
}
\seealso{
Useful links:
\itemize{
  \item \url{https://github.com/almeidasilvaf/syntenet}
  \item Report bugs at \url{https://support.bioconductor.org/t/syntenet}
}

}
\author{
\strong{Maintainer}: Fabrício Almeida-Silva \email{fabricio_almeidasilva@hotmail.com} (\href{https://orcid.org/0000-0002-5314-2964}{ORCID})

Authors:
\itemize{
  \item Tao Zhao \email{tao.zhao@nwafu.edu.cn} (\href{https://orcid.org/0000-0001-7302-6445}{ORCID})
  \item Kristian K Ullrich \email{ullrich@evolbio.mpg.de} (\href{https://orcid.org/0000-0003-4308-9626}{ORCID})
  \item Yves Van de Peer \email{yves.vandepeer@psb.vib-ugent.be} (\href{https://orcid.org/0000-0003-4327-3730}{ORCID})
}

}
\keyword{internal}
