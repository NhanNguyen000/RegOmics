#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  output$infoPage <- renderUI({
    HTML(markdown::markdownToHTML(knit('./infoPage.Rmd', quiet = TRUE)))
  })
  
  uploaded_files <-reactive({
    file.copy(from = input$file$datapath, 
              to = paste0("input/", input$file$name))
    list.files("input/")
  })
  output$count <- renderText(paste("You uploaded ", length(uploaded_files()), " file(s)."))
  
  output$metadat <- renderTable({
    metadat <- load_samples()
    metadat
  })
  
  output$avai_TFs_text<- renderText({
    print("The input list contains TF(s):")
  })
  output$avai_TFs_dat <- renderTable({
    load("outcome.RData")
    avai_TFs_dat <- avai_TFs[[1]]
  })
  
  output$distPlot <- renderPlot({
    # generate bins based on input$bins from ui.R
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)

    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')

  })
  
})
