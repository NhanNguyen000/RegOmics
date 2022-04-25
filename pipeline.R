# pipeline - link codes together (Need to move the folder later)
for (i in list.files("./code")){
  source(paste0("./code/", i))
}
library(tidyverse)

metadat <- load_samples()
TF_target_reference <- regula_database()
#TF_target_reference <- regula_database(tissue = "liver")
metadat_v2 <- metadat %>% filter(input_types != "-") %>% select(-note)
metadat_v2 <- get_existed_regula(metadat_v2)
metadat_v2 <- get_retrived_regula(metadat_v2, cutoff = 0.05)


# stop here -----------------------------------
metadat_v3 <- get.exist_regula(metadat_v2, TF_target_reference)
metadat_v4 <- get.traceback_regula(metadat_v3, TF_target_reference)
metadat_v5 <- get.frac_traceback_regula(metadat_v4, TF_target_reference, cutoff = 0.05)
metadat_v6 <- across_TFs(metadat_v5) 

outcome <- list()
for(i in list.files("./output")) {
  outcome[[i]] <- read.delim(paste0("./output", i)KimTaiTrung1986:)
  
}

save(metadat_v2, outcome, file = "outcome.RData")


write.table(metadat_v6, "./TF_target_metadata.txt", quote=FALSE,
            col.names=TRUE, row.names=TRUE, sep="\t")
# sum up the TF-target analysis result -----------------------------------
get.merged_files <- function(files_list, merged_label) {
  library(tidyverse)
  input <- list()
  for (file_name in files_list) {
    input[[file_name]] <- read.table(file_name, header = TRUE) %>% 
      mutate({{file_name}} := TRUE)
  }
  outcome <- input %>% purrr::reduce(dplyr::full_join, by = merged_label) %>% 
    rename_with(~gsub("./sample/", "", .x)) %>%
    rename_with(~gsub("./output/", "", .x)) %>%
    rename_with(~gsub(".txt", "", .x))
  return(outcome)
}

setwd("D:/Work/GitHub/Rifampicin_omics_integration/")
files_list_1 <- c("./sample/annot_RNAseq_Rif_The_DEgeneNames.txt",
                  "./sample/annot_RNAseq_Rif_Tox_DEgeneNames.txt",
                  "./sample/annot_RNAseq_DEgene_toProtein_Rif_The_geneNames.txt",
                  "./sample/annot_RNAseq_DEgene_toProtein_Rif_Tox_geneNames.txt",
                  "./output/traceback_across_TFs.txt",
                  "./output/existed_across_TFs.txt")

files_list_2 <- c("./output/traceback_TFs_RNAseq_Rif_The_DEgeneNames.txt",
                  "./output/traceback_TFs_RNAseq_Rif_Tox_DEgeneNames.txt",
                  "./output/traceback_TFs_RNAseq_DEgene_toProtein_Rif_The_geneNames.txt",
                  "./output/traceback_TFs_RNAseq_DEgene_toProtein_Rif_Tox_geneNames.txt")

outcome_TFs_info <- get.merged_files(files_list_1, merged_label = "SYMBOL") %>%
  full_join(get.merged_files(files_list_2, merged_label = "TF_traceback"),
            by = c("SYMBOL" = "TF_traceback")) %>% 
  dplyr::select(-starts_with("num_regula_targets")) %>%
  rename_with(~gsub("annot_", "", .x)) %>% 
  rename_with(~gsub("Names", "", .x)) %>%
  rename_with(~gsub("_gene", "", .x)) %>% 
  dplyr::rename(source = SYMBOL) %>% # change the name for the Cystoscape
  write.table(., "./outcome/outcome_TFs_info.txt", quote=FALSE,
              col.names=TRUE, row.names=FALSE, sep="\t")

setwd("D:/Work/GitHub/Rifampicin_omics_integration/output")
outcome_TF_relations <- lapply(list.files(pattern = "_relations_"),
                               function(x)read.table(x, header = TRUE) %>% 
                                 dplyr::select( c("TF", "target"))) %>%
  purrr::reduce(dplyr::full_join) %>% distinct() %>% 
  dplyr::rename(source = TF) #%>% # change the name for the Cystoscape
write.table(., "./outcome_TF_relations.txt", quote=FALSE,
            col.names=TRUE, row.names=FALSE, sep="\t")
dim(outcome_TF_relations)
## select information for the network ------------------
frac_TFs <- top_frac(read.table("./output/existed_relations_RNAseq_Rif_The_DEgeneNames.txt",
                                header=TRUE) %>% dplyr::select(TF, target) %>%
                       dplyr::add_count(TF, sort = TRUE) %>% dplyr::select(TF, n) %>% 
                       distinct() %>% dplyr::rename("num_regula_targets" = "n"),
                     0.05)
a <- read.table("./output/existed_relations_RNAseq_Rif_The_DEgeneNames.txt",
                header=TRUE) %>% dplyr::select(TF, target) %>%
  dplyr::add_count(TF, sort = TRUE) %>% dplyr::select(TF, n) %>% 
  distinct() %>% dplyr::rename("num_regula_targets" = "n")
a_2 <- top_frac(a, 0.05)
b <- read.table("./output/existed_relations_RNAseq_Rif_Tox_DEgeneNames.txt",
                header=TRUE) %>% dplyr::select(TF, target) %>%
  dplyr::add_count(TF, sort = TRUE) %>% dplyr::select(TF, n) %>% 
  distinct() %>% dplyr::rename("num_regula_targets" = "n")
b_2 <- top_frac(b, 0.05)

selected_files <- c("./output/existed_relations_RNAseq_DEgene_toProtein_Rif_The_geneNames.txt")
selected_TF_relations <- lapply(list.files(pattern = "_relations_"),
                                function(x)read.table(x, header = TRUE) %>% 
                                  dplyr::select( c("TF", "target"))) %>%
  purrr::reduce(dplyr::full_join) %>% distinct() %>% 
  dplyr::rename(source = TF) #%>% # change the name for the Cystoscape
write.table(., "./outcome_TF_relations.txt", quote=FALSE,
            col.names=TRUE, row.names=FALSE, sep="\t")
dim(outcome_TF_relations)

# network ----------------------------------
library(igraph) # better for large input --> net to check the network analysis
library(tidyverse)

setwd("D:/Work/GitHub/Rifampicin_omics_integration")

nodes <- as_tibble(read.table("./outcome/outcome_TFs_info.txt", header = TRUE)) %>% 
  tibble::rowid_to_column("id")

edges <- as_tibble(read.table("./output/outcome_TF_relations.txt", header = TRUE)) %>% 
  left_join(nodes[, c("id", "source")], by = c("source")) %>%
  relocate(id) %>% dplyr::rename(from = id) %>% 
  left_join(nodes[, c("id", "source")], by = c("target" = "source")) %>%
  relocate(id, .after = target) %>% dplyr::rename(to = id) %>% 
  drop_na() %>% distinct()

selected_nodes <- nodes[which(nodes$source %in% edges$source & nodes$source %in% edges$target),]
selected_edges <- as_tibble(read.table("./output/outcome_TF_relations.txt", header = TRUE)) %>% 
  left_join(selected_nodes[, c("id", "source")], by = c("source")) %>%
  relocate(id) %>% dplyr::rename(from = id) %>% 
  left_join(selected_nodes[, c("id", "source")], by = c("target" = "source")) %>%
  relocate(id, .after = target) %>% dplyr::rename(to = id) %>% 
  drop_na() %>% distinct()

write.table(selected_nodes[,-1], "./network_selected_TFs.txt", quote=FALSE,
            col.names=TRUE, row.names=FALSE, sep="\t")
write.table(selected_edges[,c(2,3)], "./network_selected_TF_relations.txt", quote=FALSE,
            col.names=TRUE, row.names=FALSE, sep="\t")

write.table(full_join(selected_edges[,c(2,3)], selected_nodes[,-1]),
            "./network_selection.txt", quote=FALSE,
            col.names=TRUE, row.names=FALSE, sep="\t")
# focus on DDX5 - existed in both RNAseq and protein:
selected_net <-read.table("./outcome/network_selection.txt", header = TRUE)
selected_net_DDX5 <- selected_net[which(selected_net$source == "DDX5" | selected_net$target == "DDX5"),]
write.table(selected_net_DDX5,
            "./outcome/network_selection_forDDX5.txt", quote=FALSE,
            col.names=TRUE, row.names=FALSE, sep="\t")
source <- unique(c(selected_net_DDX5$source, selected_net_DDX5$target))

selected_TF_info <- as.data.frame(source) %>%
  left_join(read.table("./outcome/outcome_TFs_info.txt", header = TRUE)) %>%
  mutate(TF = ifelse(source %in% TF_target_reference$TF, TRUE, FALSE))


selected_TF_info <- as.data.frame(source) %>%
  left_join(read.table("./outcome/outcome_TFs_info.txt", header = TRUE)) %>%
  mutate(TF = ifelse(source %in% TF_target_reference$TF, TRUE, FALSE)) %>% 
  full_join(selected_net_DDX5) %>% relocate(target, .after = source) %>%
  mutate(DEgene = ifelse(RNAseq_Rif_The_DEgene==TRUE & RNAseq_Rif_Tox_DEgene == TRUE,
                         "both_conditions", "Rif_The/Tox")) %>%
  mutate(DEgene_inProtein = ifelse(RNAseq_DEgene_toProtein_Rif_The==TRUE & RNAseq_DEgene_toProtein_Rif_Tox== TRUE,
                                   "both_conditions", "Rif_The/Tox")) %>%
  select(source, target, DEgene, DEgene_inProtein, TF)
write.table(selected_TF_info ,
            "./outcome/network_selection_forDDX5_info.txt", quote=FALSE,
            col.names=TRUE, row.names=FALSE, sep="\t")


#network_info <- list("nodes" = nodes, "edges" = edges)
network_info <- list("nodes" = selected_nodes, "edges" = selected_edges)

edges.igraph <- network_info$edges %>% dplyr::select(from, to)
nodes.igraph <-  network_info$nodes %>% rename(source = "label")
dat_igraph <- graph_from_data_frame(d = edges.igraph, vertices= nodes.igraph, 
                                    directed = TRUE)
print(dat_igraph, e=TRUE, v=TRUE)
pdf("test.pdf")
plot(dat_igraph)
dev.off()
## check number of gene in the TF-target
a <- read.table("./sample/annot_RNAseq_Rif_The_DEgeneNames.txt", header = TRUE)
a <- read.table("./sample/annot_RNAseq_Rif_Tox_DEgeneNames.txt", header = TRUE)
d_3 <- a[which(a$SYMBOL %in% TF_target_reference$TF | a$SYMBOL %in% TF_target_reference$target),]
