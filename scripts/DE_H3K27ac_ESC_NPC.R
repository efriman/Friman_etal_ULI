#!/usr/bin/env Rscript

setwd("/path/")
library(edgeR)
library(limma)
library(Glimma)
require(GenomicRanges)
require(ggplot2)
require(dplyr)
require(reshape2)
require(tidyr)
require(circlize)

#Differential expression using TMM normalization with edgeR and limma/voom of a HOMER annotatePeaks.pl data frame loaded with load_HOMER
DE_HOMER_RNA <- function(data, samples_table, design) {
  #Load data
  edgeR <- DGEList(data[,7:ncol(data)])
  edgeR$samples <- cbind(edgeR$samples, samples_table)
  #Normalize
  edgeR <- calcNormFactors(edgeR, method = "TMM")
  #Make design matrix
  design_matrix <- model.matrix(design)
  for (i in 1:length(as.character(attributes(terms(design))$term.labels))) {
    colnames(design_matrix) <- gsub(as.character(attributes(
      terms(design))$term.labels)[i], 
      "", 
      colnames(design_matrix))
  }
  contrast_matrix <- makeContrasts(contrast = contrast1, 
                                   levels = colnames(design_matrix))
  contrast_matrix[which(rownames(contrast_matrix) == contrast2)] <- -1
  #Differential expression with limma/voom
  voom <- voom(edgeR, design_matrix, plot = FALSE)
  vfit <- lmFit(voom, design_matrix)
  vfit <- contrasts.fit(vfit, contrasts=contrast_matrix)
  efit <- eBayes(vfit)
  #Extract all entries
  all <- topTreat(efit, coef = 1, n = Inf)
  all_regions <- data[which(rownames(data) %in% rownames(all)), 1:6]
  all_regions <- cbind(all_regions, all[match(rownames(all_regions), rownames(all)),], 
                       cpm(edgeR, normalized.lib.sizes=TRUE))
  return(all_regions)
}

#Function to extract right part of string
right = function(text, num_char) {
  substr(text, nchar(text) - (num_char-1), nchar(text))
}

#Generate sample info table
samples_table <- data.frame(Name = c(
  "ESC_Rep1",
  "ESC_Rep2",
  "NPC_Rep1",
  "NPC_Rep2"))

samples_table$Replicate <- as.factor(right(as.character(samples_table$Name),1))
samples_table$Sample <- as.factor(substr(samples_table$Name, 1, nchar(as.character(samples_table$Name))-5))

#Load annotatePeaks.pl file
annotation <- read.delim(file = "annotation_H3K27ac_ESC_NPC.txt")[,c(-1,-7:-15,-17:-19)]
colnames(annotation)[7:ncol(annotation)] <- as.character(samples_table$Name)

#Perform differential expression analysis for 2TS22C SOX2OFF 26h ATAC-seq data
contrast1 = "NPC"
contrast2 = "ESC"

Sample <- droplevels(samples_table$Sample)
Replicate <- make.names(samples_table$Replicate)

NPCvsESC_H3K27ac <- DE_HOMER_RNA(data = annotation, 
                           samples_table = samples_table, 
                           design = ~0+Sample)


write.table(file = "H3K27ac_DE_NPC_higher_mm10.bed", x = NPCvsESC_H3K27ac[(NPCvsESC_H3K27ac$adj.P.Val < 0.05) & (NPCvsESC_H3K27ac$logFC > 0),c("Chr", "Start", "End")], row.names = F, quote = F, col.names = F, sep = "\t")

write.table(file = "H3K27ac_DE_ESC_higher_mm10.bed", x = NPCvsESC_H3K27ac[(NPCvsESC_H3K27ac$adj.P.Val < 0.05) & (NPCvsESC_H3K27ac$logFC < 0),c("Chr", "Start", "End")], row.names = F, quote = F, col.names = F, sep = "\t")