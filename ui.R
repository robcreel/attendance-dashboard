library(shiny)
library(shinythemes)

# Define UI for data upload app ----
ui <- fluidPage(theme = shinytheme("yeti"),

  # App title ----
  titlePanel("East-West University Attendance Dashboard"),
  
      # Input: Select a file ----
      fileInput("file1", "",
                multiple = FALSE,
                accept = c("text/pdf",".pdf")
      ),
      
      # Output: Tabbed analysis options
      tabsetPanel(
        tabPanel("By Date (Plot)", plotOutput("date_plot")),
        tabPanel("By Date (Table)", tableOutput("date_table")),
        tabPanel("By Student", tableOutput("student_table")),
        tabPanel("By Student and Date", tableOutput("student_date_table")),
        tabPanel("Help", 
                 p("In the Faculty Portal, go to 'My Courses' > 'Course Options' > 'Attendance Report'.
                 Make sure that the largest of the three available font sizes is selected, 
                 and click 'View Attendance Report' button.  
                 Click the printer icon, save the results as a PDF, and upload that PDF in the field above.  
                 It is recommended your browser be full screen when using this webapp.
                   ")
                 )
      ),

)
