Data acquisition
================

# Data in data/

## annotation.rda

Here, we will get the annotation for the *Ostreococcus sp.* algae
species from Pico-PLAZA 3.0 and filter them to include only chromosomes
1, 2, and 3 for these species for package size issues.

``` r
library(GenomicRanges)
links <- c(
    Olucimarinus = "ftp://ftp.psb.ugent.be/pub/plaza/plaza_pico_03/GFF/olu/annotation.selected_transcript.all_features.olu.gff3.gz",
    OspRCC809 = "ftp://ftp.psb.ugent.be/pub/plaza/plaza_pico_03/GFF/orcc809/annotation.selected_transcript.all_features.orcc809.gff3.gz"
)

annotation <- lapply(links, rtracklayer::import)
annotation <- lapply(annotation, function(x) {
    a <- x[x$type == "gene", ]
    a$Parent <- NULL
    a$name <- NULL
    a$phase <- NULL
    a$score <- NULL
    a$source <- NULL
    a$pid <- NULL
    if("chr_1" %in% seqnames(a)) {
        a <- keepSeqlevels(a, c("chr_1", "chr_2", "chr_3"),
                           pruning.mode = "coarse")
    } else {
        a <- keepSeqlevels(a, c("Chr_1", "Chr_2", "Chr_3"),
                           pruning.mode = "coarse")
    }
    return(a)
})
annotation <- GenomicRanges::GRangesList(annotation)

usethis::use_data(
    annotation, compress = "xz", overwrite = TRUE
)
```

## proteomes.rda

The protein sequences of the *Ostreococcus sp.* algae species (from
primary transcripts only) were obtained from Pico-PLAZA 3.0 and stored
in a list of AAStringSet objects. As above, only chromosomes 1, 2, and 3
were kept.

``` r
links <- c(
    Olucimarinus = "ftp://ftp.psb.ugent.be/pub/plaza/plaza_pico_03/Fasta/proteome.selected_transcript.olu.fasta.gz",
    OspRCC809 = "ftp://ftp.psb.ugent.be/pub/plaza/plaza_pico_03/Fasta/proteome.selected_transcript.orcc809.fasta.gz"
)

filt_genes <- unlist(lapply(annotation, function(x) return(x$gene_id)))

proteomes <- lapply(links, function(x) {
    seq <- Biostrings::readAAStringSet(x)
    names(seq) <- gsub("\\.[0-9] .*", "", names(seq))
    seq <- seq[names(seq) %in% filt_genes]
    return(seq)
})

usethis::use_data(
    proteomes, compress = "xz", overwrite = TRUE
)

# For some reason, the dramatic reduction in gene number does not affect
# much the size of the proteomes.rda file. Let's solve it by exporting 
# each sequence to a file, reading them, and saving again.
library(Biostrings)
data("proteomes")
dir <- tempdir()
seq1 <- proteomes$Olucimarinus
seq2 <- proteomes$OspRCC809

# Save .fa.gz files to tempdir
writeXStringSet(seq1, filepath = file.path(dir, "seq1.fa"), compress = "gzip")
writeXStringSet(seq2, filepath = file.path(dir, "seq2.fa"), compress = "gzip")

# Read files as AAStringSet objetcs and save them to a list
aa1 <- readAAStringSet(file.path(dir, "seq1.fa"))
aa2 <- readAAStringSet(file.path(dir, "seq2.fa"))
proteomes <- list(Olucimarinus = aa1, OspRCC809 = aa2)

usethis::use_data(
    proteomes, compress = "xz", overwrite = TRUE
)
```

## blast_list.rda

This object contains the blast list inferred from the example data, and
it is used in the vignette.

``` r
# Load data
data(proteomes)
data(annotation)

# Process data
pdata <- process_input(proteomes, annotation)

# Get blast list
blast_list <- run_diamond(seq = pdata$seq)
blast_list <- lapply(blast_list, function(x) return(x[x$perc_identity >= 50, ]))

# Save object
usethis::use_data(blast_list, compress = "xz", overwrite = TRUE)
```

## network.rda

The synteny network for BUSCO genes was downloaded from [this Dataverse
repository](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/BDMA7A),
which is associated with the paper [Network-based microsynteny analysis
identifies major differences and genomic outliers in mammalian and
angiosperm genomes](https://doi.org/10.1073/pnas.1801757116). The
dataset was filtered to only include the following species:

- *Vigna radiata*
- *Vigna angularis*
- *Phaseolus vulgaris*
- *Glycine max*
- *Cajanus cajan*
- *Trifolium pratense*
- *Medicago truncatula*
- *Arachis duranensis*
- *Lotus japonicus*
- *Lupinus angustifolius*
- *Cicer arietinum*
- *Prunus mume*
- *Prunus persica*
- *Pyrus x bretschneideri*
- *Malus domestica*
- *Rubus occidentalis*
- *Fragaris vesca*
- *Morus notabilis*
- *Ziziphus jujuba*
- *Jatropha curcas*
- *Manihot esculenta*
- *Ricinus communis*
- *Linum usitatissimum*
- *Populus trichocarpa*

``` r
#----Download file--------------------------------------------------------------
net_file <- file.path(tempdir(), "busco_network.txt.gz")
download.file("https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/BDMA7A/7JWAFI", destfile = net_file)

#----Read file and filter it----------------------------------------------------
busco_network <- readr::read_delim(net_file, show_col_types = FALSE, 
                           col_names = FALSE, delim = " ")

species <- unique(substr(c(busco_network$X1, busco_network$X2), 1, 5))
species <- unique(gsub("_.*", "", species))
species <- sort(unique(gsub("[0-9]*$", "", species)))

selected_species <- c(
    "vra", "van", "pvu", "gma", "cca", "tpr", "mtr", "adu", "lja",
    "Lang", "car", # Fabaceae
    "pmu", "ppe", "pbr", "mdo", "roc", "fve",
    "Mnot", "Zjuj", "hlu", 
    "jcu", "mes", "rco", "lus", "ptr"
)
s_patt <- paste0("^", selected_species)
s_patt <- paste0(s_patt, collapse = "|")

# Filtered network
busco_network <- busco_network[grepl(s_patt, busco_network$X1), ]
busco_network <- busco_network[grepl(s_patt, busco_network$X2), ]

# Clean names (i.e., separate species IDs by _)
not_underscore <- unique(substr(c(busco_network$X1, busco_network$X2), 1, 5))
not_underscore <- not_underscore[!grepl("_", not_underscore)]

busco_network$X1 <- gsub("Lang", "Lang_", busco_network$X1)
busco_network$X2 <- gsub("Lang", "Lang_", busco_network$X2)

busco_network$X1 <- gsub("Mnot", "Mnot_", busco_network$X1)
busco_network$X2 <- gsub("Mnot", "Mnot_", busco_network$X2)

busco_network$X1 <- gsub("Zjuj", "Zjuj_", busco_network$X1)
busco_network$X2 <- gsub("Zjuj", "Zjuj_", busco_network$X2)

network <- busco_network
network <- as.data.frame(network)
names(network) <- c("node1", "node2")

usethis::use_data(network, compress = "xz", overwrite = TRUE)
```

## edges.rda

``` r
# Load data
data(proteomes)
data(annotation)
data(blast_list)

# Process input data
pdata <- process_input(proteomes, annotation)

# Infer network
edges <- infer_syntenet(blast_list, pdata$annotation)

usethis::use_data(edges, compress = "xz")
```

## clusters.rda

The synteny network clusters for BUSCO genes were downloaded from [this
Dataverse
repository](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/BDMA7A),
which is associated with the paper [Network-based microsynteny analysis
identifies major differences and genomic outliers in mammalian and
angiosperm genomes](https://doi.org/10.1073/pnas.1801757116). The
dataset was filtered to only include the species mentioned above.

``` r
#----Download file--------------------------------------------------------------
cfile <- file.path(tempdir(), "clusters.txt.gz")
download.file("https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/BDMA7A/THEQD7", destfile = cfile)

#----Read file and filter it----------------------------------------------------
clusters <- readr::read_tsv(cfile, show_col_types = FALSE)
clusters <- clusters[grepl(s_patt, clusters$names), ]
names(clusters) <- c("Gene", "Cluster")

clusters$Gene <- gsub("Lang", "Lang_", clusters$Gene)
clusters$Gene <- gsub("Mnot", "Mnot_", clusters$Gene)
clusters$Gene <- gsub("Zjuj", "Zjuj_", clusters$Gene)

clusters <- as.data.frame(clusters)
usethis::use_data(clusters, compress = "xz", overwrite = TRUE)
```

## angiosperm_phylogeny.rda

Phylogenomic profiles for the whole genome of 123 angiosperm species
were downloaded from [this Dataverse
repository](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/7ZZWIH),
which is associated with the publication [Whole-genome
microsynteny-based phylogeny of
angiosperms](https://doi.org/10.1038/s41467-021-23665-0).

``` r
download.file(
    url = "https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/7ZZWIH/HFZBGE",
    destfile = file.path(tempdir(), "profiles.tar.gz"))

system2("tar", args = c("-zxvf", file))

#----Load file------------------------------------------------------------------
prof <- read.table("123genome_profiled_allsize", header = TRUE, sep = " ",
                   row.names = 1)
unlink("123genome_profiled_allsize")

#----Binarize and transpose profiles--------------------------------------------
transposed_profiles <- binarize_and_transpose(prof)

#----Infer microsynteny-based phylogeny-----------------------------------------
# Using Amborella trichopoda as an outgroup
phylo <- infer_microsynteny_phylogeny(transposed_profiles, outgroup = "atr")

angiosperm_phylogeny <- treeio::read.tree(phylo[10])

# Replace abbreviations with species names
angiosperm_phylogeny$tip.label
angiosperm_phylogeny$tip.label <- stringr::str_replace_all(
    angiosperm_phylogeny$tip.label, 
    c("^pmu" = "Prunus mume",
      "^ppe" = "Prunus persica",
      "^pbr" = "Pyrus x bretschneideri",
      "^Mald" = "Malus domestica",
      "^Rchi" = "Rosa chinensis",
      "^fve" = "Fragaria vesca",
      "^roc" = "Rubus occidentalis",
      "^Dryd" = "Dryas drummondii",
      "^Pand" = "Parasponia andersonii",
      "^Tori" = "Trema orientale",
      "^Mnot" = "Morus notabilis",
      "^Zjuj" = "Ziziphus jujuba",
      "^cme" = "Cucumis melo",
      "^csa" = "Cucumis sativus",
      "^cla" = "Citrullus lanatus",
      "^Cuma" = "Cucurbita maxima",
      "^Begf" = "Begonia fuchsioides",
      "^Datg" = "Datisca glomerata",
      "^van" = "Vigna angularis",
      "^vra" = "Vigna radiata",
      "^pvu" = "Phaseolus vulgaris",
      "^gma" = "Glycine max",
      "^cca" = "Cajanus cajan",
      "^mtr" = "Medicago truncatula",
      "^tpr" = "Trifolium pratense",
      "^car" = "Cicer arietinum",
      "^lja" = "Lotus japonicus",
      "^Lang" = "Lupinus angustifolius",
      "^Anan" = "Ammopiptanthus nanus",
      "^adu" = "Arachis duranensis",
      "^Cgla" = "Casuarina pendula",
      "^Bpen" = "Betula pendula",
      "^Cill" = "Carya illinoinensis",
      "^Qrob" = "Quercus robur",
      "^bnp" = "Brassica napus",
      "^bol" = "Brassica oleracea",
      "^bra" = "Brassica rapa",
      "^spa" = "Schrenkiella parvula",
      "^tsa" = "Thellungiella salsuginea",
      "^thh" = "Thellungiella halophila",
      "^ath" = "Arabidopsis thaliana",
      "^Alyr" = "Arabidopsis lyrata",
      "^Csat" = "Camelina sativa",
      "^cru" = "Capsella rubella",
      "^Bost" = "Boechera stricta",
      "^Lmey" = "Lepidium meyenii",
      "^Alp" = "Arabis alpina",
      "^aar" = "Aethionema arabicum",
      "^tha" = "Tarenaya hassleriana",
      "^cgy" = "Cleome gynandra",
      "^cpa" = "Carica papaya",
      "^Ghir" = "Gossypium hirsutum",
      "^Goba" = "Gossypium barbadense",
      "^gra" = "Gossypium raimondii",
      "^Dzib" = "Durio zibethinus",
      "^tca" = "Theobroma cacao",
      "^csi" = "Citrus sinensis",
      "^Cmax" = "Citrus maxima",
      "^Xsor" = "Xanthoceras sorbifolium",
      "^rco" = "Ricinus communis",
      "^mes" = "Manihot esculenta",
      "^ptr" = "Populus trichocarpa",
      "^lus" = "Linum usitatissimum",
      "^Pgra" = "Punica granatum",
      "^egr" = "Eucalyptus grandis",
      "^Cach" = "Capsicum chinense",
      "^Caba" = "Capsicum baccatum",
      "^can" = "Capsicum annuum",
      "^sly" = "Solanum lycopersicum",
      "^spe" = "Solanum pennellii",
      "^stu" = "Solanum tuberosum",
      "^pax" = "Petunia axillaris",
      "^Cuca" = "Cuscuta campestris",
      "^Inil" = "Ipomoea nil",
      "^coc" = "Coffea canephora",
      "^mgu" = "Mimulus guttatus",
      "^sin" = "Sesamum indicum",
      "^Oeur" = "Olea europaea",
      "^HanX" = "Helianthus annuus",
      "^Lsat" = "Lactuca sativa",
      "^dca" = "Daucus carota",
      "^Aeri" = "Actinidia eriantha",
      "^ach" = "Actinidia chinensis",
      "^bvu" = "Beta vulgaris",
      "^Cqui" = "Chenopodium quinoa",
      "^Ahyp" = "Amaranthus hypochondriacus",
      "^Kalf" = "Kalanchoe fedtschenkoi",
      "^Mole" = "Malania oleifera",
      "^vvi" = "Vitis vinifera",
      "^nnu" = "Nelumbo nucifera",
      "^Mcor" = "Macleaya cordata",
      "^Psom" = "Papaver somniferum",
      "^Aqco" = "Aquilegia coerulea",
      "^Sevi" = "Setaria viridis",
      "^sit" = "Setaria italica",
      "^Ecru" = "Echinochloa crus-galli",
      "^Sacc" = "Saccharum officinarum",
      "^sbi" = "Sorghum bicolor",
      "^Zmay" = "Zea mays",
      "^oth" = "Oropetium thomaeum",
      "^osa" = "Oryza sativa",
      "^ogl" = "Oryza glaberrima",
      "^oru" = "Oryza rufipogon",
      "^Opun" = "Oryza punctata",
      "^lpe" = "Leersia perrieri",
      "^HORV" = "Hordeum vulgare",
      "^Trdc" = "Triticum turgidum",
      "^bdi" = "Brachypodium distachyon",
      "^aco" = "Ananas comosus",
      "^mac" = "Musa acuminata",
      "^Pdac" = "Phoenix dactylifera",
      "^egu" = "Elaeis guineensis",
      "^Ashe" = "Apostasia shenzhenica",
      "^peq" = "Phalaenopsis equestris",
      "^Aoff" = "Asparagus officinalis",
      "^Xvis" = "Xerophyta viscosa",
      "^zom" = "Zostera marina",
      "^spo" = "Spirodela polyrhiza",
      "^CKAN" = "Cinnamomum kanehirae",
      "^Peam" = "Persea americana",
      "^Lchi" = "Liriodendron chinense",
      "^Nymp" = "Nymphaea colorata",
      "^atr" = "Amborella trichopoda"
      )
)


usethis::use_data(angiosperm_phylogeny, compress = "xz", overwrite = TRUE)
```

## scerevisiae_annot.rda + scerevisiae_diamond.rda

These files contain a processed annotation list (as returned by
`process_input()`) and a list of intragenome DIAMOND comparisons.

``` r
library(doubletrouble)

# Load data from {doubletrouble}
data("yeast_annot")
data("yeast_seq")
data("diamond_intra")

pdata <- process_input(yeast_seq, yeast_annot)

# Create objects
scerevisiae_annot <- pdata$annotation[1]
scerevisiae_diamond <- list(
    Scerevisiae_Scerevisiae = diamond_intra$Scerevisiae_Scerevisiae |>
        dplyr::filter(evalue <= 1e-10)
)

# Save objects
usethis::use_data(scerevisiae_annot, compress = "xz")
usethis::use_data(scerevisiae_diamond, compress = "xz", overwrite = TRUE)
```

# Data in inst/extdata

## Scerevisiae.collinearity

This file contains the intragenome synteny blocks for *S. cerevisiae*.

``` r
# Load data
data(scerevisiae_annot)
data(scerevisiae_diamond)

# Detect intragenome synteny
intra_syn <- intraspecies_synteny(
    scerevisiae_diamond, scerevisiae_annot
)

# Move file to inst/extdata
fs::file_move(
    path = intra_syn,
    new_path = here::here("inst", "extdata")
)

data(proteomes)
data(annotation)
processed <- process_input(proteomes, annotation) 
if(diamond_is_installed()) {
    blast_list <- run_diamond(processed$seq, ... = "--sensitive")
}

net <- infer_syntenet(blast_list, processed$annotation)

# Move file
olu_col <- file.path(tempdir(), "intraspecies_synteny", "Olu.collinearity")
out <- here::here("inst", "extdata")

fs::file_move(path = olu_col, new_path = out)
```

## sequences/

This directory contains FASTA files that correspond to a subset of the
sequences in the example data set `proteomes`.

``` r
data(proteomes)

# Create a list of vector with IDs of genes to subset - here, first 100 genes
genes_subset <- lapply(proteomes, function(x) names(x)[1:100]) 

# Path to sequences/ directory
seq_dir <- here::here("inst", "extdata", "sequences")

# Export sequences as FASTA files
Biostrings::writeXStringSet(
    proteomes$Olucimarinus[genes_subset$Olucimarinus], 
    filepath = file.path(seq_dir, "Olucimarinus.fa.gz"),
    compress = TRUE
)

Biostrings::writeXStringSet(
    proteomes$OspRCC809[genes_subset$OspRCC809], 
    filepath = file.path(seq_dir, "OspRCC809.fa.gz"), 
    compress = TRUE
)
```

## annotation/

This directory contains GFF3 files that correspond to a subset of the
ranges in the example data set `annotation`.

``` r
data(annotation)

# Path to annotation/ directory
annot_dir <- here::here("inst", "extdata", "annotation")

# Export ranges as GFF3 files
rtracklayer::export(
    annotation$Olucimarinus[annotation$Olucimarinus$gene_id %in% 
                                genes_subset$Olucimarinus, ], 
    con = file.path(annot_dir, "Olucimarinus.gff3.gz")
)
rtracklayer::export(
    annotation$OspRCC809[annotation$OspRCC809$gene_id %in%
                             genes_subset$OspRCC809, ], 
    con = file.path(annot_dir, "OspRCC809.gff3.gz")
)
```

## RefSeq_parsing_example/

This directory contains a subset of 10 genes from the *Alosa alosa*
genome (FASTA and GFF3 files) to demonstrate how to parse RefSeq data.

Gene annotation (GFF3) and whole-genome protein sequences (FASTA) were
downloaded from [NCBI’s Data
Hub](https://www.ncbi.nlm.nih.gov/data-hub/taxonomy/278164/) and
processed using the code below.

- *Aalosa.gff3.gz*

``` bash
# Bash

head -n 474 genomic.gff | awk '$3 == "gene" || $3 == "CDS" || $1 ~ /^#/' > Aalosa.gff3
gzip Aalosa.gff3
```

- *Aalosa.fa*

``` r
# Read files
ranges <- rtracklayer::import(here::here(
    "inst", "extdata", "RefSeq_parsing_example", "Aalosa.gff3.gz"
))

sequence <- Biostrings::readAAStringSet(
    "~/Downloads/protein.faa"
)

# Get proteins to extract from FASTA file
proteins <- unique(ranges[ranges$type == "CDS"]$Name)

# Subset sequences
pmatch <- paste0(proteins, collapse = "|")
final_seqs <- sequence[grep(pmatch, names(sequence))]

# Write to file
Biostrings::writeXStringSet(
    final_seqs,
    file = here::here(
        "inst", "extdata", "RefSeq_parsing_example", "Aalosa.fa.gz"
    ),
    compress = TRUE
)
```
