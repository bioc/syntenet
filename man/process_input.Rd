% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/02_data_preprocessing.R
\name{process_input}
\alias{process_input}
\title{Process sequence data}
\usage{
process_input(
  seq = NULL,
  annotation = NULL,
  gene_field = "gene_id",
  filter_annotation = FALSE
)
}
\arguments{
\item{seq}{A list of AAStringSet objects, each list element containing
protein sequences for a given species. This list must have names
(not NULL), and names of each list element must match the names of
list elements in \strong{annotation}.}

\item{annotation}{A GRangesList, CompressedGRangesList, or list of
GRanges with the annotation for the sequences in \strong{seq}. This list must
have names (not NULL), and names of each list element must match the names
of list elements in \strong{seq}.}

\item{gene_field}{Character, name of the column in the GRanges objects
that contains gene IDs. Default: "gene_id".}

\item{filter_annotation}{Logical indicating whether \strong{annotation}
should be filtered to keep only genes that are also in \strong{seq}. This
is particularly useful if users want to remove information on
non-protein coding genes from \strong{annotation}, since such genes are
typically not present in sets of whole-genome protein sequences.
Default: FALSE.}
}
\value{
A list of 2 elements:
\describe{
\item{seq}{The processed list of AAStringSet objects from \strong{seq}.}
\item{annotation}{The processed GRangesList or CompressedGRangesList
object from \strong{annotation}.}
}
}
\description{
Process sequence data
}
\details{
This function processes the input sequences and annotation to:
\enumerate{
\item Remove whitespace and anything after it in sequence names
(i.e., \code{names(seq[[x]])}, which is equivalent to FASTA headers), if
there is any.
\item Add a unique species identifier to sequence names. The species
identifier consists of the first 3-5 strings of the element name.
For instance, if the first element of the \strong{seq} list is named
"Athaliana", each sequence in it will have an identifier "Atha_" added
to the beginning of each gene name (e.g., Atha_AT1G01010).
\item If sequences have an asterisk (*) representing stop codon, remove it.
\item Add a unique species identifier (same as above) to
gene and chromosome names of each element of the \strong{annotation}
GRangesList/CompressedGRangesList.
\item Filter each element of the \strong{annotation}
GRangesList/CompressedGRangesList to keep only seqnames, ranges, and
gene ID.
}
}
\examples{
data(annotation)
data(proteomes)
seq <- proteomes
clean_data <- process_input(seq, annotation)
}
