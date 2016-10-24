library(pamr)
library(tidyr)
library(ggthemes)
# load annotations and gene expression (TPM) matrix

geneAnnotation <- read_tsv("gencode.vM10.gene.annotation.txt")
tpm <- read_delim("TPMs_MIA.txt", delim = " ")

# tpm.mat <- as.matrix(tpm[,-c(1:8)])
tpm.mat <- as.matrix(tpm %>% select(contains("P0"),-contains("C")))
tpm.mat <- as.matrix(tpm %>% select(contains("E14")))
rownames(tpm.mat) <- tpm$EnsID

SD <- apply(tpm.mat, 1, sd)
SD.rm0 <- SD[SD > 0]
# tpm.mat.filtered <- tpm.mat[SD > median(SD.rm0),]
tpm.mat.filtered <- tpm.mat[SD > quantile(SD.rm0)[4],]

## N fold cross-validation

gID <- rownames(tpm.mat.filtered)
gNames <-
  data_frame(gID) %>% left_join(geneAnnotation, by = c("gID" = "geneID")) %>% extract2("geneName")
sampleID <- colnames(tpm.mat.filtered)
group <-
  data_frame(sampleID) %>% left_join(sampleInfo, by = c("sampleID" = "Label")) %>% extract2("group")
train.dat <-
  list(
    x = tpm.mat.filtered,
    y = group,
    genenames = gNames,
    geneid = gID,
    sampleid = sampleID
  )
set.seed(666)
threshold.list <- seq(0, 4, length.out = 101)
model <- pamr.train(train.dat, threshold = threshold.list)
model.cv <- pamr.cv(model, train.dat)
pamr.plotcv(model.cv)
pamr.plotcvprob(model.cv, train.dat, 3.2)
pamr.confusion(model.cv, 3.2)
pamr.plotcen(model, train.dat, 3.2)
pamr.geneplot(model, train.dat, 3.2)
chosen.genes <-
  as_data_frame(pamr.listgenes(model, train.dat, 3.2, fitcv = model.cv, genenames = T))
chosen.genes.exp <-
  chosen.genes %>% left_join(tpm, by = c("id" = "EnsID")) %>% 
  select(id, gene_name, contains("P0"), -contains("C")) %>% gather(sample,tpm,contains("P0")) %>% left_join(sampleInfo,by=c("sample"="Label")) %>% mutate(gene_name=factor(gene_name,levels=chosen.genes$name))

chosen.genes %>% left_join(tpm, by = c("id" = "EnsID")) %>%
  select(id, gene_name, contains("E14"),-starts_with("E14"))%>% gather(sample,tpm,contains("E14")) %>% left_join(sampleInfo,by=c("sample"="Label")) %>% mutate(gene_name=factor(gene_name,levels=chosen.genes$name))


p <- ggplot(chosen.genes.exp,aes(sample,tpm,color=group))
p + geom_point()+facet_wrap(~gene_name,scales = "free_y",nrow = 3)+scale_color_brewer(palette = "Set1")+theme_bw(base_size = 12)+theme(strip.background=element_rect(fill="white"),axis.text.x=element_text(angle=90,vjust=0.5))


## use model to predict litter C

tpm.test.litterC <-
  tpm %>% filter(EnsID %in% rownames(tpm.mat.filtered)) %>% select(contains("P0_C")) %>% as.matrix()
pamr.predict(model, tpm.test.litterC, 3.2, type = "posterior")
pamr.predictmany(model, tpm.test.litterC)

## Leave-one-out
sampleID.list <- seq(1:dim(tpm.mat.filtered)[2])


getTF <- function(sampleID) {
  tpm.test.sample <- tpm.mat.filtered[, sampleID, drop = F]
  tpm.train.sample <- tpm.mat.filtered[, -sampleID]
  gID <- rownames(tpm.train.sample)
  gNames <-
    data_frame(gID) %>% left_join(geneAnnotation, by = c("gID" = "geneID")) %>% extract2("geneName")
  sampleID <- colnames(tpm.train.sample)
  group <-
    data_frame(sampleID) %>% left_join(sampleInfo, by = c("sampleID" = "Label")) %>% extract2("group")
  train.dat <-
    list(
      x = tpm.train.sample,
      y = group,
      genenames = gNames,
      geneid = gID,
      sampleid = sampleID
    )
  set.seed(666)
  threshold.list <- seq(0, 4, length.out = 101)
  model <- pamr.train(train.dat, threshold = threshold.list)
  pamr.predict(model, tpm.test.sample, 2, type = "posterior")
  trueClass <-
    sampleInfo %>% filter(Label %in% colnames(tpm.test.sample)) %>% extract2("group")
  as.vector(pamr.predictmany(model, tpm.test.sample)[["predclass"]]) == trueClass
}

getGeneNum <- function(sampleID) {
  tpm.test.sample <- tpm.mat.filtered[, sampleID, drop = F]
  tpm.train.sample <- tpm.mat.filtered[,-sampleID]
  gID <- rownames(tpm.train.sample)
  gNames <-
    data_frame(gID) %>% left_join(geneAnnotation, by = c("gID" = "geneID")) %>% extract2("geneName")
  sampleID <- colnames(tpm.train.sample)
  group <-
    data_frame(sampleID) %>% left_join(sampleInfo, by = c("sampleID" = "Label")) %>% extract2("group")
  train.dat <-
    list(
      x = tpm.train.sample,
      y = group,
      genenames = gNames,
      geneid = gID,
      sampleid = sampleID
    )
  set.seed(666)
  threshold.list <- seq(0, 4, length.out = 101)
  model <- pamr.train(train.dat, threshold = threshold.list)
  model$nonzero
}


results.TF <- sapply(sampleID.list, getTF)
LOO.accuracy <- rowSums(results.TF) / dim(results.TF)[2]
sample.accuracy <- colSums(results.TF) / dim(results.TF)[1]

results.geneNum <- sapply(sampleID.list, getGeneNum)

acc.df <-
  data_frame(accuracy = LOO.accuracy,
             threshold = seq(0, 4, length.out = 101))
geneNum.df <- as_data_frame(results.geneNum, coln)
colnames(geneNum.df) = colnames(tpm.mat.filtered)
geneNum.df %<>% mutate(threshold = seq(0, 4, length.out = 101)) %>% gather(sample, geneNum, contains("P0"))

p <- ggplot(acc.df, aes(threshold, accuracy))
plot1 <- p + geom_line(color = "red") + theme_few()

p <- ggplot(geneNum.df, aes(threshold, geneNum, group = threshold))
plot2 <- p + geom_boxplot() + theme_few()


tmp.treatment <- results.TF[, 1:4]
tmp.control <- results.TF[,-c(1:4)]
acc.treatment <- rowSums(tmp.treatment) / dim(tmp.treatment)[2]
acc.control <- rowSums(tmp.control) / dim(tmp.control)[2]

acc.df2 <-
  data_frame(
    OverallAccuracy = LOO.accuracy,
    treatmentAccuracy = acc.treatment,
    controlAccuracy = acc.control,
    threshold = seq(0, 4, length.out = 101)
  )
acc.df2 %<>% gather(group, acc, contains("Accuracy"))
p <- ggplot(acc.df2, aes(threshold, acc, color = group))
plot3 <-
  p + geom_line() + theme_few() #+ theme(legend.position = c(.8, .2))

## compared to shuffle control (shuffle sample labels once)
set.seed(123)
group.shuffled <- group[sample(length(group))]
train.dat.shuffled <-
  list(
    x = tpm.mat.filtered,
    y = group.shuffled,
    genenames = gNames,
    geneid = gID,
    sampleid = sampleID
  )
set.seed(666)
model.shuffled <-
  pamr.train(train.dat.shuffled, threshold = threshold.list)
model.cv.shuffled <- pamr.cv(model.shuffled, train.dat.shuffled)
pamr.plotcv(model.cv.shuffled)
pamr.plotcvprob(model.cv.shuffled, train.dat.shuffled, 1.8)
pamr.confusion(model.cv.shuffled, 1.8)

# getTFshuffle <- function(sampleID) {
#   tpm.test.sample <- tpm.mat.filtered[, sampleID, drop = F]
#   tpm.train.sample <- tpm.mat.filtered[,-sampleID]
#   gID <- rownames(tpm.train.sample)
#   gNames <-
#     data_frame(gID) %>% left_join(geneAnnotation, by = c("gID" = "geneID")) %>% extract2("geneName")
#   sampleID <- colnames(tpm.train.sample)
#   group <- group.shuffled[!sampleID]
#   train.dat <-
#     list(
#       x = tpm.train.sample,
#       y = group,
#       genenames = gNames,
#       geneid = gID,
#       sampleid = sampleID
#     )
#   set.seed(666)
#   threshold.list <- seq(0, 4, length.out = 101)
#   model <- pamr.train(train.dat, threshold = threshold.list)
#   pamr.predict(model, tpm.test.sample, 2, type = "posterior")
#   trueClass <-
#     sampleInfo %>% filter(Label %in% colnames(tpm.test.sample)) %>% extract2("group")
#   as.vector(pamr.predictmany(model, tpm.test.sample)[["predclass"]]) == trueClass
# }
#
# results.TF.shuffled <- sapply(sampleID.list, getTFshuffle)
# LOO.accuracy <- rowSums(results.TF) / dim(results.TF)[2]
# sample.accuracy <- colSums(results.TF) / dim(results.TF)[1]