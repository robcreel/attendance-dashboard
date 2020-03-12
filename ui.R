library(shiny)

# Define UI for data upload app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Uploading Files"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Select a file ----
      fileInput("file1", "Choose File",
                multiple = FALSE,
                accept = c("text/pdf",
                           # "text/comma-separated-values,text/plain",
                           ".pdf")
      ),
      
      # # Horizontal line ----
      # tags$hr(),
      # 
      # # Input: Checkbox if file has header ----
      # checkboxInput("header", "Header", TRUE),
      # 
      # # Input: Select separator ----
      # radioButtons("sep", "Separator",
      #              choices = c(Comma = ",",
      #                          Semicolon = ";",
      #                          Tab = "\t"),
      #              selected = ","),
      # 
      # # Input: Select quotes ----
      # radioButtons("quote", "Quote",
      #              choices = c(None = "",
      #                          "Double Quote" = '"',
      #                          "Single Quote" = "'"),
      #              selected = '"'),
      # 
      # # Horizontal line ----
      # tags$hr(),
      # 
      # # Input: Select number of rows to display ----
      # radioButtons("disp", "Display",
      #              choices = c(Head = "head",
      #                          All = "all"),
      #              selected = "head")
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Date Table
      tableOutput("contents"),
      
      # Output: Date Plot
      plotOutput("date_plot")
      
    )
    
  )
)