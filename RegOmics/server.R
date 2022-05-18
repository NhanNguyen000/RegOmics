#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  output$infoPage <- renderUI({
    HTML(markdown::markdownToHTML(knit('./infoPage.Rmd', quiet = TRUE)))
  })
  
  output$Regulatory_database <- renderUI({
    HTML(markdown::markdownToHTML(knit('./Regulatory_database.Rmd', quiet = TRUE)))
  })
  
  observe({
    file.copy(from = input$file$datapath, 
              to = paste0("./input/", input$file$name))
    list.files("./input/")
  })

  
  observeEvent(input$runScript, {
    message("running pipeline.R")
    source("pipeline.R")
    
    output$input_metadat_text<- renderText({
      print(paste0("You uploaded ", nrow(input_metadat), " file(s):"))})
    output$input_metadat <- renderTable({input_metadat})
    
    
    output$metadat_used_text <- renderText({
      print(paste("RegOmics tool can only read ", nrow(metadat_used), " file(s).",
                  "Here are the overview of the TF-targer analysis outcome:"))})
    output$metadat_used <- renderTable({metadat_used})
    
    
    output$across_TFs_text <- renderText({
      print("The TF(s) that appeared across samples:")
    })
    output$across_TFs <- renderDataTable({read.delim("./process/across_TFs.txt")})
    
    
    output$network_text <- renderText({
      print("The network based on across TF(s).")})
    output$network <- renderDataTable({read.delim("./output/network.txt")})
    
    
    output$download_text <- renderText({
      print("Download files to import in Cytoscape for visualization:")})
    output$download_network.txt <- downloadHandler(
      filename = function() {"network.txt"},
      content = function(file) {
        write.table(read.delim("./output/network.txt"), file,
                    sep="\t", quote = FALSE, row.names = FALSE)},
      contentType = "text/plain")
    output$download_nodes_info.txt <- downloadHandler(
      filename = function() {"nodes_info.txt"},
      content = function(file) {
        write.table(read.delim("./output/nodes_info.txt"), file,
                    sep="\t", quote = FALSE, row.names = FALSE)},
      contentType = "text/plain")
  })
  
  observeEvent(input$reset, {
    rm(list = ls())
    do.call(file.remove, list(list.files("./input/", full.names = TRUE)))
    do.call(file.remove, list(list.files("./process/", full.names = TRUE)))
    do.call(file.remove, list(list.files("./output/", full.names = TRUE)))
  })
  output$reset_text <- renderText({
    print("Clear all the uploaded data and reset the R environment before the new run")})
  
})

