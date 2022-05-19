regula_database <- function(tissue = "NA") {
  database <- list.files("./reference")
  geneTF <- list()
  for (i in database) {
    geneTF_temp <-read.csv(paste0("./reference/", i), sep = "\t")
    if (tissue == "NA") geneTF[[i]] <- geneTF_temp[,-3]
    if (tissue != "NA") {
      if (ncol(geneTF_temp) == 2) geneTF[[i]] <- NULL
      if (ncol(geneTF_temp) > 2) {
        if (length(tissue) == 1) {
          geneTF[[i]] <-geneTF_temp[grep(tissue,
                                         geneTF_temp[,c("tissue")],
                                         ignore.case = TRUE),]
        }
        if (length(tissue) > 1) {
          geneTF[[i]] <- geneTF_temp[grep(paste(tissue, collapse="|"),
                                          geneTF_temp[,c("tissue")],
                                          ignore.case = TRUE),]
        }
      }
    }
  }
  library(tidyverse)
  TF_target_unique <- bind_rows(geneTF)
  TF_target_unique <-  as.data.frame(TF_target_unique[!duplicated(TF_target_unique),])
  return(TF_target_unique)
}

