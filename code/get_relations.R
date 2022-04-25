get_relations <- function(TFs = NULL, targets) {
  library(tidyverse)

  if (is.null(TFs)) {
    output <- TF_target_reference %>% 
      filter(target %in% targets) %>% distinct()} 
  else {
    output <- TF_target_reference %>% 
      filter(target %in% targets) %>% filter(TF %in% TFs) %>% 
      distinct()
    }

  return(output)
}

