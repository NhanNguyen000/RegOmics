get_retrived_regula <- function(metadat, cutoff = 0.05) {
  library(tidyverse)
  
  for (i in 1:nrow(metadat)) {
    dat <- read.delim(paste0("./process/annot_", metadat$samples[i]))
    
    if (file.exists(paste0("./process/existed_TFs_", metadat$samples[i]))) {
      existed_TFs <- read.delim(paste0("./process/existed_TFs_", metadat$samples[i]))
    } else {existed_TFs <- ""}
    
    # for retrived relations
    retrived_relations <- get_relations(targets = dat$SYMBOL) %>%
      dplyr::filter(!TF %in% existed_TFs) %>% 
      dplyr::add_count(TF, sort = TRUE) %>%
      dplyr::rename("num_regula_targets" = "n")
    metadat$num_retrived_TFs[i] <- length(unique(retrived_relations$TF))
    
    top_retrieved_TFs <- retrived_relations %>% 
      dplyr::select(TF, num_regula_targets) %>% 
      dplyr::distinct() %>% 
      dplyr::top_frac(0.05)
    metadat$num_top_retrived_TFs[i] <- length(unique(top_retrieved_TFs$TF))
    
    top_retrived_relations <- retrived_relations %>% 
      dplyr::filter(TF %in% top_retrieved_TFs$TF)
    
    write.table(top_retrived_relations, file = paste0("./process/top_retrieved_relations_", metadat$samples[i]),
                sep="\t", quote = FALSE,
                row.names = FALSE, col.names = TRUE)
    write.table(top_retrieved_TFs$TF, 
                file = paste0("./process/top_retrieved_TFs_", metadat$samples[i]),
                sep="\t", quote = FALSE,
                row.names = FALSE, col.names = "top_retrieved_TFs")
  }
  return(metadat)
}
