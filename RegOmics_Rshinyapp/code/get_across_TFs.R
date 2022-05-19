get_across_TFs <- function() {
  library(tidyverse)
  
  file_names <- c(list.files("./process/", pattern="existed_TFs_"),
                  list.files("./process/", pattern="top_retrieved_TFs_"))
  TFs <- list()
  for (name in file_names) {
    TFs[[name]] <- read.delim(paste0("./process/", name)) %>% 
      dplyr::mutate({{name}} := TRUE) %>% dplyr::rename(TFs = 1)
  }
  outcome <- TFs %>% purrr::reduce(dplyr::full_join)
  
  write.table(outcome, file = "./process/across_TFs.txt",
              sep="\t", quote = FALSE,
              row.names = FALSE, col.names = TRUE)
}

