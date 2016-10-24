library(edgeR)
library(dplyr)
library(readr)
library(magrittr)

setwd("C:/Users/Hoho/Desktop/MIA")
sampleInfo <- read_tsv("CountDataInfo.txt") %>% select(Label, Treat) %>% mutate(timepoint= sapply(strsplit(Label,"_"), "[[", 2), group=paste0(timepoint,"_",Treat))

expData <- read.delim("Counts_MIA.txt", row.names=1, stringsAsFactors=FALSE)
y <- DGEList(counts=expData, group = sampleInfo$group)
y$samples

keep <- rowSums(cpm(y)>0.5) >= 6 # 6 samples in the smallest group (E14_sal)
y <- y[keep, , keep.lib.sizes=FALSE]
y$samples
y <- calcNormFactors(y,method = "TMM")

design <- model.matrix(~0+sampleInfo$group)
colnames(design) <- c("E14_P","E14_S","P0_P","P0_S")
y <- estimateDisp(y, design)
fit <- glmQLFit(y,design)

all.contrasts <- makeContrasts(
  E14_PvS = E14_P-E14_S,
  P0_PvS = P0_P-P0_S,
  P_P0vE14 = P0_P-E14_P,
  S_P0vE14 = P0_S-E14_S,
  timeAvgEffect = (P0_P+P0_S)/2 - (E14_P+E14_S)/2,
  timeAvgEffect_interaction = (P0_P-E14_P) - (P0_S-E14_S),
  treatmentAvgEffect = (P0_P+E14_P)/2- (P0_S+E14_S)/2,
  treatmentAvgEffect_interatcion = (P0_P-P0_S) - (E14_P-E14_S),
  levels = design
  )

testContrasts <- function(fit,contrast){
  qlf <- glmQLFTest(fit,contrast = all.contrasts[,contrast])
  tt <- topTags(qlf,n=dim(y)[1])
  df <- as_data_frame(tt$table) %>% mutate(geneID = rownames(tt)) %>% select(geneID,everything())
  df
}

results_E14_PvS <- testContrasts(fit,"E14_PvS")
results_P0_PvS <- testContrasts(fit,"P0_PvS")
results_P_P0vE14 <- testContrasts(fit,"P_P0vE14")
results_S_P0vE14 <- testContrasts(fit,"S_P0vE14")
results_timeAvgEffect <- testContrasts(fit,"timeAvgEffect")
results_timeAvgEffect_interaction <- testContrasts(fit,"timeAvgEffect_interaction")
results_treatmentAvgEffect <- testContrasts(fit,"treatmentAvgEffect")
results_treatmentAvgEffect_interatcion <- testContrasts(fit,"treatmentAvgEffect_interatcion")

########################

sampleInfo2 <- sampleInfo %>% mutate(litter = sapply(strsplit(Label,"_"), "[[", 3), group2=ifelse(group!="P0_PolyIC",group,paste0(group,"_",litter)))


design2 <- model.matrix(~0+sampleInfo2$group2)
colnames(design2) <- c("E14_P","E14_S","P0_P_C","P0_P_E","P0_P_F","P0_S")
y2 <- estimateDisp(y, design2)
fit2 <- glmQLFit(y,design2)

all.contrasts2 <- makeContrasts(
  CvE = P0_P_C-P0_P_E,
  CvF = P0_P_C-P0_P_F,
  CvEF = P0_P_C-(P0_P_E+P0_P_F)/2,
  CvS = P0_P_C-P0_S,
  EvS = P0_P_E-P0_S,
  FvS = P0_P_F-P0_S,
  EFvS = (P0_P_E+P0_P_F)/2 - P0_S,
  levels = design2
)

testContrasts2 <- function(fit,contrast){
  qlf <- glmQLFTest(fit,contrast = all.contrasts2[,contrast])
  tt <- topTags(qlf,n=dim(y)[1])
  df <- as_data_frame(tt$table) %>% mutate(geneID = rownames(tt)) %>% select(geneID,everything())
  df
}

results_CvE <- testContrasts2(fit2,"CvE")
results_CvF <- testContrasts2(fit2,"CvF")
results_CvEF <- testContrasts2(fit2,"CvEF")
results_CvS <- testContrasts2(fit2,"CvS")
results_EvS <- testContrasts2(fit2,"EvS")
results_FvS <- testContrasts2(fit2,"FvS")
results_EFvS <- testContrasts2(fit2,"EFvS")



##########################

sampleInfo2 %>% rownames_to_column() %>% filter(litter=="F")
sampleInfo3 <- sampleInfo2 %>% filter(litter!="C", litter!="E")
expData.rmC <- expData[,-c(10:15)]

y <- DGEList(counts=expData.rmC, group = sampleInfo3$group)
y$samples

keep <- rowSums(cpm(y)>0.5) >= 2 # 4 samples in the smallest group (P0_PolyIC)
y <- y[keep, , keep.lib.sizes=FALSE]
y$samples
y <- calcNormFactors(y,method = "TMM")

design <- model.matrix(~0+sampleInfo3$group)
colnames(design) <- c("E14_P","E14_S","P0_P","P0_S")
y <- estimateDisp(y, design)
fit <- glmQLFit(y,design)

all.contrasts <- makeContrasts(
  E14_PvS = E14_P-E14_S,
  P0_PvS = P0_P-P0_S,
  P_P0vE14 = P0_P-E14_P,
  S_P0vE14 = P0_S-E14_S,
  timeAvgEffect = (P0_P+P0_S)/2 - (E14_P+E14_S)/2,
  timeAvgEffect_interaction = (P0_P-E14_P) - (P0_S-E14_S),
  treatmentAvgEffect = (P0_P+E14_P)/2- (P0_S+E14_S)/2,
  treatmentAvgEffect_interatcion = (P0_P-P0_S) - (E14_P-E14_S),
  levels = design
)

testContrasts <- function(fit,contrast){
  qlf <- glmQLFTest(fit,contrast = all.contrasts[,contrast])
  tt <- topTags(qlf,n=dim(y)[1])
  df <- as_data_frame(tt$table) %>% mutate(geneID = rownames(tt)) %>% select(geneID,everything())
  df
}


results_E14_PvS <- testContrasts(fit,"E14_PvS")
results_P0_PvS <- testContrasts(fit,"P0_PvS")
results_P_P0vE14 <- testContrasts(fit,"P_P0vE14")
results_S_P0vE14 <- testContrasts(fit,"S_P0vE14")
results_timeAvgEffect <- testContrasts(fit,"timeAvgEffect")
results_timeAvgEffect_interaction <- testContrasts(fit,"timeAvgEffect_interaction")
results_treatmentAvgEffect <- testContrasts(fit,"treatmentAvgEffect")
results_treatmentAvgEffect_interatcion <- testContrasts(fit,"treatmentAvgEffect_interatcion")




geneIDtoGeneName <- read_tsv("gencode.vM10.geneIDToGeneName.txt")



expData.P0 <- expData %>% select(contains("P0"))
sampleInfo3 <- sampleInfo %>% filter(timepoint=="P0")
y <- DGEList(counts=expData.P0, group = sampleInfo3$group)
y$samples

keep <- rowSums(cpm(y)>0.5) >= 7 
y <- y[keep, , keep.lib.sizes=FALSE]
y$samples
y <- calcNormFactors(y,method = "TMM")

design <- model.matrix(~0+sampleInfo3$group)
colnames(design) <- c("P0_P","P0_S")
y <- estimateDisp(y, design)
fit <- glmQLFit(y,design)

p0.contrasts <- makeContrasts(
  P0_PvS = P0_P-P0_S,
  levels = design
)

qlf <- glmQLFTest(fit,contrast = p0.contrasts[,"P0_PvS"])
tt <- topTags(qlf,n=dim(y)[1])
df <- as_data_frame(tt$table) %>% mutate(geneID = rownames(tt)) %>% select(geneID,everything())
df
