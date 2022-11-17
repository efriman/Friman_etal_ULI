#!/usr/bin/env Rscript

require(GEOquery)

factors = read.table(file = "human_factor_full_QC.txt", sep = "\t", header = T, fill = TRUE)

factors <- factors[factors$Cell_line == "GM12878",]
factors <- factors[(factors$FastQC > 25) & (factors$UniquelyMappedRatio > 0.6) & (factors$PBC > 0.8) & (factors$PeaksFoldChangeAbove10 > 500) & (factors$FRiP > 0.01) & (factors$PeaksUnionDHSRatio > 0.7),]
factors <- factors[complete.cases(factors),]

GEOdata <- lapply(factors$GSMID, getGEO)

factors$Sample <- ""
factors$GSEID <- ""

for (i in 1:length(GEOdata)) {
  factors[factors$GSMID == Meta(GEOdata[[i]])$geo_accession,]$Sample <- Meta(GEOdata[[i]])$title
  factors[factors$GSMID == Meta(GEOdata[[i]])$geo_accession,]$GSEID <- Meta(GEOdata[[i]])$series_id[[1]]
}

write.table(factors, "human_factor_GM12878.txt", quote=FALSE, sep="\t")
