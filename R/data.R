
#' Filtered proteomes of Ostreococcus sp. species
#'
#' Data obtained from Pico-PLAZA 3.0. Only the translated sequences of primary
#' transcripts were included, and only genes from chromosomes 1, 2, and 3.
#'
#' @name proteomes
#' @format A list of AAStringSet objects containing 
#' the elements `Olucimarinus`, `Osp_RCC809`, and `Otauri`.
#' @references
#' Van Bel, M., Silvestri, F., Weitz, E. M., Kreft, L., Botzki, A.,
#' Coppens, F., & Vandepoele, K. (2021). PLAZA 5.0: extending the scope
#' and power of comparative and functional genomics in plants.
#' Nucleic acids research.
#' @examples
#' data(proteomes)
#' @usage data(proteomes)
"proteomes"


#' Filtered genome annotation for Ostreococcus sp. species
#'
#' Data obtained from Pico-PLAZA 3.0. Only annotation data for primary
#' transcripts were included, and only genes for chromosomes 1, 2, and 3.
#'
#' @name annotation
#' @format A CompressedGRangesList containing 
#' the elements `Olucimarinus`, `Osp_RCC809`, and `Otauri`.
#' @references
#' Van Bel, M., Silvestri, F., Weitz, E. M., Kreft, L., Botzki, A.,
#' Coppens, F., & Vandepoele, K. (2021). PLAZA 5.0: extending the scope
#' and power of comparative and functional genomics in plants.
#' Nucleic acids research.
#' @examples
#' data(annotation)
#' @usage data(annotation)
"annotation"


#' List of data frames containing BLAST-like tabular output
#'
#' The object was created by running \code{run_diamond} on the protein
#' sequences for the Ostreococcus algae available in the \strong{proteomes}
#' example data. Hits with <50% identity were filtered out. Code to recreate
#' this data is available at the script/ subdirectory.
#' 
#' @name blast_list
#' @format A list of data frames containing the pairwise comparisons between
#' proteomes of Ostreococcus species.
#' @examples 
#' data(blast_list)
#' @usage data(blast_list)
"blast_list"


#' Synteny network of Ostreococcus genomes represented as an edge list
#'
#' The object was created by running \code{infer_syntenet} on the 
#' \strong{blast_list} example data. Code to recreate this data set is 
#' available at the script/ subdirectory.
#' 
#' @name edges
#' @format A data frame containing anchor pairs between two Ostreococcus
#' proteomes.
#' @examples 
#' data(edges)
#' @usage data(edges)
"edges"


#' Synteny network of BUSCO genes for 25 eudicot species
#'
#' Data obtained from Zhao & Schranz, 2019.
#'
#' @name network
#' @format An edgelist (i.e., a 2-column data frame with node 1 in 
#' column 1 and node 2 in column 2).
#' @references
#' Zhao, T., & Schranz, M. E. (2019). Network-based microsynteny analysis 
#' identifies major differences and genomic outliers in mammalian and 
#' angiosperm genomes. Proceedings of the National Academy of 
#' Sciences, 116(6), 2165-2174.
#' @examples
#' data(network)
#' @usage data(network)
"network"


#' Synteny network clusters of BUSCO genes for 25 eudicot species
#' 
#' Data obtained from Zhao & Schranz, 2019.
#'
#' @name clusters
#' @format A 2-column data frame containing the following variables:
#' \describe{
#'   \item{Gene}{Gene ID}
#'   \item{Cluster}{Cluster ID}
#' }
#' @references
#' Zhao, T., & Schranz, M. E. (2019). Network-based microsynteny analysis 
#' identifies major differences and genomic outliers in mammalian and 
#' angiosperm genomes. Proceedings of the National Academy of 
#' Sciences, 116(6), 2165-2174.
#' @examples
#' data(clusters)
#' @usage data(clusters)
"clusters"


#' Microsynteny-based angiosperm phylogeny.
#'
#' Original tree file obtained from Zhao et al., 2021.
#' The tree is an object of class 'phylo', which can be created by reading
#' the tree file with \code{treeio::read.tree()}.
#'
#' @name angiosperm_phylogeny
#' @format An object of class 'phylo'.
#' @references
#' Zhao, T., Zwaenepoel, A., Xue, J. Y., Kao, S. M., Li, Z., 
#' Schranz, M. E., & Van de Peer, Y. (2021). 
#' Whole-genome microsynteny-based phylogeny of angiosperms. 
#' Nature Communications, 12(1), 1-14.
#' @examples
#' data(angiosperm_phylogeny)
#' @usage data(angiosperm_phylogeny)
"angiosperm_phylogeny"


#' Genome annotation of the yeast species S. cerevisiae
#'
#' Data obtained from Ensembl Fungi. Only annotation data for primary
#' transcripts were included.
#' 
#' @name scerevisiae_annot
#' @format A GRangesList as returned by \code{process_input()} containing 
#' the element \strong{Scerevisiae}.
#' @examples
#' data(scerevisiae_annot)
#' @usage data(scerevisiae_annot)
"scerevisiae_annot"


#' Intraspecies DIAMOND output for S. cerevisiae
#'
#' List obtained with \code{run_diamond()}.
#' 
#' @name scerevisiae_diamond
#' @format A list of data frames (length 1) containing the whole paranome of
#' S. cerevisiae resulting from intragenome similarity searches.
#' @examples 
#' data(scerevisiae_diamond)
#' @usage data(scerevisiae_diamond)
"scerevisiae_diamond"
