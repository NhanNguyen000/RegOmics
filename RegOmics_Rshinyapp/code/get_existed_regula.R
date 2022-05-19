get_existed_regula <- function(metadat) {
  library(tidyverse)
  
  for (i in 1:nrow(metadat)) {
    dat <- read.delim(paste0("./process/annot_", metadat$samples[i]))
    
    # for exsited relations
    existed_relations <- get_relations(TF = dat$SYMBOL, targets = dat$SYMBOL)
    write.table(existed_relations, 
                file = paste0("./process/existed_relations_", metadat$samples[i]),
                sep="\t", quote = FALSE,
                row.names = FALSE, col.names = TRUE)
    
    # for exsited TFs
    existed_TFs <- unique(existed_relations$TF)
    if (length(existed_TFs) > 0) {
      write.table(existed_TFs, 
                  file = paste0("./process/existed_TFs_", metadat$samples[i]),
                  sep="\t", quote = FALSE,
                  row.names = FALSE, col.names = "existed_TFs")
    }
    
    metadat$num_existed_TFs[i] <- length(existed_TFs)
    
  }
  return(metadat)
}
