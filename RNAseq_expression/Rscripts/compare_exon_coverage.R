library(ggplot2)
library(ggridges)
library(tidyr)
library(dplyr)
setwd("~/projects/P_capsici_genome/RNAseq_expression")
exoncovtable <- read.csv("results/allfeatureCountsExons/gsnap_all_exon_reads.nostrand.tab.gz",
                         sep ="\t",header=T,comment.char = "#")

dfexons <- dplyr::tbl_df(exoncovtable)
dfexons$ExonID = paste(dfexons$Chr,dfexons$Start,dfexons$Start,sep="_")

head(select(dfexons,-c(Geneid,Chr,Start,End,Strand,Length)))
ExonCoverage <- select(dfexons,-c(Geneid,Chr,Start,End,Strand,Length))

ExonsDepthRaw <- gather(ExonCoverage,Library,ReadDepth,AC10:SRR891361)

ExonsDepthZero <- subset(ExonsDepthRaw,ReadDepth == 0)
ZeroExonByLibraries <- summarise(group_by(ExonsDepthZero,Library),length(Library))
colnames(ZeroExonByLibraries) <- c("Library","NumZeroExons")
write.csv(ZeroExonByLibraries,"ZeroExonByLibraries.csv")
ExonsDepth <- subset(ExonsDepthRaw,ReadDepth > 0)
head(ExonsDepth)

ExonsDepth$LogReadDepth <- log(ExonsDepth$ReadDepth)

pdf("Library_Exons_LogDepth.pdf")

ggplot(ZeroExonByLibraries,
        aes(x=reorder(Library,NumZeroExons),y=NumZeroExons)) + 
  geom_bar(stat="identity",color="black",fill="steelblue") +
    scale_fill_hue(l=40) + theme(axis.text.x = element_text(angle = 90, hjust = 1))

ggplot(ExonsDepth, aes(x = LogReadDepth, y = Library)) +
  geom_density_ridges(aes(fill = Library)) +
  scale_fill_hue(l=40)
#  scale_fill_manual(values = c("#00AFBB", "#E7B800", "#FC4E07"))