# pipeline - link codes together (Need to move the folder later)
for (i in list.files("./code")){
  source(paste0("./code/", i))
}
library(tidyverse)

metadat <- load_samples()
TF_target_reference <- regula_database()
#TF_target_reference <- regula_database(tissue = "liver")

metadat_v2 <- metadat %>% filter(input_types != "-") %>% dplyr::select(-note)
metadat_v2 <- get_existed_regula(metadat_v2)
metadat_v2 <- get_retrived_regula(metadat_v2, cutoff = 0.05)
get_across_TFs()
# input for Cystoscape

TFs <- read.delim("./process/across_TFs.txt")
samples <- c("Protein_Rif_The_002.txt", "Protein_Rif_The_008.csv")
get_input_Cytos(TFs = read.delim("./process/across_TFs.txt")$TFs,
                samples = metadat_v2$samples)
