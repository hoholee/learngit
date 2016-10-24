

library(Hmisc)
library(ggthemes)
library(viridis)


tpm <- read_delim("TPMs_MIA.txt", delim = " ")
tpm.sub <- tpm %>% select(P_E14_A_01:S_P0_J_04)
tpm.cor.matrix <- rcorr(as.matrix(tpm.sub), type = "pearson")
tpm.cor.df <- as_data_frame(tpm.cor.matrix$r)
tpm.cor.gg <-
  tpm.cor.df %>% mutate(sample = rownames(tpm.cor.matrix$r)) %>% select(sample, everything()) %>% gather(sampleY, cor, P_E14_A_01:S_P0_J_04)

p <- ggplot(tpm.cor.gg, aes(sample, sampleY, fill = cor))


p + geom_tile() +
  scale_fill_viridis(name = "Pearson Correlaion",
                     direction = 1,
                     option = "D") +
  coord_equal() + labs(x = NULL, y = NULL) + theme_tufte(base_family = "Helvetica") +
  theme(
    axis.ticks = element_blank(),
    axis.text.x = element_text(
      angle = 90,
      hjust = 1,
      vjust = 0.5
    ),
    panel.margin.x = unit(0.5, "cm"),
    panel.margin.y = unit(0.5, "cm")
  )



cpm.sub <- cpm(y)
cpm.cor.matrix <- rcorr(as.matrix(cpm.sub), type = "pearson")

cpm.cor.df <- as_data_frame(cpm.cor.matrix$r)
cpm.cor.gg <-
  cpm.cor.df %>% mutate(sample = rownames(cpm.cor.matrix$r)) %>% select(sample, everything()) %>% gather(sampleY, cor, P_E14_A_01:S_P0_J_04)

p <- ggplot(cpm.cor.gg, aes(sample, sampleY, fill = cor))






