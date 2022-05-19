get_input_Cytos <- function(TFs, samples) {
  library(tidyverse)
  
  # Network
  relations <- list()
  for (name in samples){
    dat <- read.delim(paste0("./process/annot_", name))
    relations[[name]] <- get_relations(TF = TFs, targets = dat$SYMBOL)
  }
  network <- relations %>% purrr::reduce(dplyr::full_join) %>%
    dplyr::rename(source = TF)
  
  write.table(network, file = "./output/network.txt",
              sep="\t", quote = FALSE,
              row.names = FALSE, col.names = TRUE)
  
  # Information for entities (nodes)
  nodes <- list()
  for (name in samples) {
    nodes[[name]] <- read.delim(paste0("./process/annot_", name)) %>% 
      dplyr::mutate({{name}} := TRUE) %>% dplyr::rename(TFs = 1)
  }
  nodes_Info <- nodes %>% purrr::reduce(dplyr::full_join) %>% 
    dplyr::rename(entity=1) %>% 
    filter(entity %in% c(network$source, network$target)) %>% 
    mutate(in_allSamples = ifelse(!is.na(rowSums(.[-1])), TRUE, NA)) %>%
    relocate(in_allSamples, .after = entity) %>%
    mutate(TF = ifelse(entity %in% TF_target_reference$TF, TRUE, FALSE)) %>%
    relocate(TF, .after = entity)
  
  write.table(nodes_Info, file = "./output/nodes_info.txt",
              sep="\t", quote = FALSE,
              row.names = FALSE, col.names = TRUE)
}
