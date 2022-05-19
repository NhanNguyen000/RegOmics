load_samples <- function() {
  library(AnnotationDbi)
  library(org.Hs.eg.db)
  
  samples <- list.files("./input")
  metadat <- as.data.frame(samples)
  
  # collect the metadata information
  for (i in 1:nrow(metadat)) {
    dat_temp <- read.delim(paste0("./input/", metadat$samples[i]),  header = FALSE)
    
    metadat$input_types[i] <- ifelse("SYMBOL" %in% dat_temp[1,], "SYMBOL",
                                 ifelse("UNIPROT" %in% dat_temp[1,], "UNIPROT",
                                    ifelse("ENSEMBL" %in% dat_temp[1,], "ENSEMBL", "-")))
    metadat$total_entities[i] <- nrow(dat_temp)
    metadat$pvalue[i] <- ifelse("pvalue" %in% dat_temp[1,], TRUE, FALSE)
    metadat$note[i] <- ifelse(metadat$input_types[i] == "-",
                              "Could not detect the gene/protein identifier", "NA")
  }
  
  # adjust the file (if needed) and move to the process folder
  for (i in 1:nrow(metadat)) {
    dat_temp <- read.delim(paste0("./input/", metadat$samples[i]))
    
    if (metadat$input_types[i] == "-") print(paste0("Please, check the format of this file: ",
                                                    metadat$samples[i]))
    else {
      if (metadat$input_types[i] == "SYMBOL") SYMBOL <- dat_temp$SYMBOL
      else {
        annot <- AnnotationDbi::select(org.Hs.eg.db,
                                           keys = dat_temp[,metadat$input_types[i]],
                                           column = "SYMBOL",
                                           keytype = metadat$input_types[i],
                                           multiVals = "list")
        SYMBOL <- annot$SYMBOL
        }
      write.table(SYMBOL, file = paste0("./process/annot_", metadat$samples[i]),
                  sep="\t", quote = FALSE,
                  row.names = FALSE, col.names = "SYMBOL")}}
  
  return(metadat)
}