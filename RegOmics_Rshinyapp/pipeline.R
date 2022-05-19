# pipeline - link codes together (Need to move the folder later)
for (i in list.files("./code")){
  source(paste0("./code/", i))
}
library(tidyverse)

input_metadat <- load_samples()
TF_target_reference <- regula_database()
#TF_target_reference <- regula_database(tissue = "liver")

metadat_used <- input_metadat %>% filter(input_types != "-") %>% dplyr::select(-note)
metadat_used <- get_existed_regula(metadat_used)
metadat_used <- get_retrived_regula(metadat_used, cutoff = 0.05)
get_across_TFs()

# input for Cystoscape
TFs <- read.delim("./process/across_TFs.txt")
get_input_Cytos(TFs = read.delim("./process/across_TFs.txt")$TFs,
                samples = metadat_used$samples)
