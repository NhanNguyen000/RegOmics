#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Old Faithful Geyser Data"),
  
  # Part 1 - general information
  h3("Input and Run"),
  mainPanel(uiOutput("infoPage"), width = 12),
  
  # Part 2 - input
  h3("Input and Run"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file",
                label="Upload files (txt/csv) here",
                multiple = TRUE)
    ),
    mainPanel(textOutput("count"))
    ),
  
  # Part 3 - outcome
  h3("Outcome"),
  navlistPanel(
    tabPanel(title = "Input samples",
             textOutput("samples"),
             tableOutput("metadat")
    ),
    tabPanel(title = "Available TFs in the data",
             textOutput("avai_TFs_text"),
             tableOutput("avai_TFs_dat")
    )
  ),
  
  
  # Part 4 - original shiny
  h3("Original"),
  sidebarLayout(
    sidebarPanel( # Sidebar with a slider input for number of bins 
      sliderInput("bins", "Number of bins:",
                  min = 1, max = 50, value = 30)),
    mainPanel( # Show a plot of the generated distribution
      plotOutput("distPlot")))
))
