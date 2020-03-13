library(shiny)
library(shinythemes)

# Define UI for data upload app ----
ui <- fluidPage(theme = shinytheme("yeti"),
  
  # App title ----
  titlePanel("East-West University Attendance Dashboard"),
  

    # Main panel for displaying outputs ----
    mainPanel(
      
      # Input: Select a file ----
      fileInput("file1", "Choose File",
                multiple = FALSE,
                accept = c("text/pdf",".pdf")
      ),
      
      # Output: Tabbed analysis options
      tabsetPanel(
        tabPanel("By Date (Plot)", plotOutput("date_plot")),
        tabPanel("By Date (Table)", tableOutput("date_table")),
        tabPanel("By Student", tableOutput("student_table")),
        tabPanel("By Student and Date", tableOutput("student_date_table"))
      )
      
    )
    
)
