#!/usr/bin/env Rscript

require(nullranges)
require(GenomicRanges)

neighbours <- read.delim("../Peaks/mm10/ENCFF519QMV_100kb_neighbours_binned.bed")

peaks <- makeGRangesFromDataFrame(neighbours, keep.extra.columns = T)

set.seed(123)
mgr_bin2 <- matchRanges(focal = peaks[peaks$neighbours == 0],
                   pool = peaks[peaks$neighbour_bin == "1-4"],
                   covar = ~signal, method="stratified")

mgr_bin3 <- matchRanges(focal = peaks[peaks$neighbours == 0],
                       pool = peaks[peaks$neighbour_bin == "5-10"],
                       covar = ~signal, method="stratified")

mgr_bin4 <- matchRanges(focal = peaks[peaks$neighbours == 0],
                        pool = peaks[peaks$neighbour_bin == ">=10"],
                        covar = ~signal, method="stratified")


neighbours2 <- data.frame(chrom=seqnames(mgr_bin2),
                 start=start(mgr_bin2)-1,
                 end=end(mgr_bin2),
                 signal=mgr_bin2$signal,
                 neighbours=mgr_bin2$neighbours,
                 neighbour_bin=mgr_bin2$neighbour_bin,
                 quartile=mgr_bin2$quartile)

neighbours3 <- data.frame(chrom=seqnames(mgr_bin3),
                  start=start(mgr_bin3)-1,
                  end=end(mgr_bin3),
                  signal=mgr_bin3$signal,
                  neighbours=mgr_bin3$neighbours,
                  neighbour_bin=mgr_bin3$neighbour_bin,
                  quartile=mgr_bin3$quartile)

neighbours4 <- data.frame(chrom=seqnames(mgr_bin4),
                  start=start(mgr_bin4)-1,
                  end=end(mgr_bin4),
                  signal=mgr_bin4$signal,
                  neighbours=mgr_bin4$neighbours,
                  neighbour_bin=mgr_bin4$neighbour_bin,
                  quartile=mgr_bin4$quartile)

neighbours_all <- rbind(neighbours2, neighbours3, neighbours4)

write.table(file = "../Peaks/mm10/ENCFF519QMV_100kb_neighbours_binned_nullRanges_matched.bed", x = neighbours_all, row.names = F, quote = F, col.names = T, sep = "\t")
print("Normalised H3K27ac signal values for all bins and saved as ENCFF519QMV_100kb_neighbours_binned_nullRanges_matched.bed")