# pipeline - link codes together (Need to move the folder later)
for (i in list.files("./code")){
  source(paste0("./code/", i))
}
library(tidyverse)

input_metadat <- load_samples()

# to reduce the required memory for the R shiny app online, we process the TF_target_reference and save it as .rds file
#TF_target_reference <- regula_database() %>% as_tibble() %>%
#  dplyr::select(TF, target) %>% distinct()
#saveRDS(TF_target_reference, file = "TF_target_reference.rds")
TF_target_reference <- readRDS(file = "TF_target_reference.rds")

metadat_used <- input_metadat %>% filter(input_types != "-") %>% dplyr::select(-note)
metadat_used <- get_existed_regula(metadat_used)
metadat_used <- get_retrived_regula(metadat_used, cutoff = 0.05)
get_across_TFs()

# input for Cystoscape
TFs <- read.delim("./process/across_TFs.txt")
get_input_Cytos(TFs = read.delim("./process/across_TFs.txt")$TFs,
                samples = metadat_used$samples)
