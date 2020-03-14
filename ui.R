library(shiny)
library(shinythemes)
library(plotly)
library(DT)

# Define UI for data upload app ----
ui <- fluidPage(theme = shinytheme("sandstone"),

  # App title ----
  titlePanel("East-West University Attendance Dashboard"),
  
      # Setup Tabs
      tabsetPanel(
        tabPanel("Upload PDF", 
                 # Input: Select a file ----
                 fileInput("file1", "",
                           multiple = FALSE,
                           accept = c("text/pdf",".pdf")
                 ),
                 p("In the Faculty Portal, go to 'My Courses' > 'Course Options' > 'Attendance Report'.
                 Make sure that the largest of the three available font sizes is selected, 
                 and click 'View Attendance Report' button.  
                 Click the printer icon, save the results as a PDF, and upload that PDF in the field above.  
                 It is recommended your browser be full screen when using this webapp.
                   ")
                 ),
        tabPanel("By Date (Plot)", plotlyOutput("date_plotly")),
        tabPanel("By Date (Table)", tableOutput("date_table")),
        # tabPanel("By Date (Table)", dataTableOutput("date_table")),
        tabPanel("By Student", dataTableOutput("student_table")),
        tabPanel("By Student and Date", dataTableOutput("student_date_table"))
      ),

)
