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
  titlePanel("RegOmics"),
  mainPanel(uiOutput("infoPage"), width = 12),
  
  # Part 1 - general information & input
  h3("Input and Run"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file",
                label="Upload files (txt/csv) here",
                multiple = TRUE),
      actionButton("runScript", "Click me to run the tool")
    ),
    mainPanel(uiOutput("Regulatory_database"))
    ),
  
  # Part 2 - outcome
  h3("Outcome"),
  navlistPanel(
    tabPanel(title = "Input samples",
             textOutput("input_metadat_text"),
             tableOutput("input_metadat")
    ),
    tabPanel(title = "Samples used",
             textOutput("metadat_used_text"),
             tableOutput("metadat_used")
    ),
    tabPanel(title = "Across TFs in the data",
             textOutput("across_TFs_text"),
             DT::dataTableOutput("across_TFs")
    ),
    tabPanel(title = "TF-target network",
             textOutput("network_text"),
             DT::dataTableOutput("network"),
             textOutput("download_text"),
             downloadButton("network_table.txt", "Network table"),
             downloadButton("nodes_table.txt", "Node table")
    )
  ),
  # Part 3 - clean the tools and re-run
  h3("Reset the tool"),
  sidebarLayout(
    sidebarPanel(
      actionButton("reset", "Click me to reset the tool")
    ),
    mainPanel(textOutput("reset_text"))
  )
))
