library(shiny)
library(shinythemes)
library(plotly)
library(DT)

# Define UI for data upload app ----
ui <- fluidPage(theme = shinytheme("spacelab"),

  # App title ----
  titlePanel(title=div(tags$img(src="./EW_logo.svg", height="15%", width="15%"),
             "Attendance Dashboard")),
  
      # Setup Tabs
      tabsetPanel(
        tabPanel("Upload PDF", 
                 # Input: Select a file ----
                 fileInput("file1", "",
                           multiple = FALSE,
                           accept = c("text/pdf",".pdf")
                 ),
                 column(8,
                        h3("To Generate the 'Attendance Report' PDF for upload:"),
                        h4("In the Faculty Portal"),
                        tags$ul(
                          tags$li("Go to 'My Courses' > 'Course Options' > 'Attendance Report'."),
                          tags$li("Make sure that the largest of the three available font sizes is selected,"),
                          tags$li("Click 'View Attendance Report' button."),
                          tags$li("Click the printer icon."),
                          tags$li("Save as PDF."),
                          tags$li("Upload that PDF in the field above.")
                        ),
                 )
        ),
        tabPanel("By Date (Plot)", plotlyOutput("date_plotly")),
        tabPanel("By Date (Table)", tableOutput("date_table")),
        # tabPanel("By Date (Table)", dataTableOutput("date_table")),
        tabPanel("By Student", dataTableOutput("student_table")),
        tabPanel("By Student and Date", dataTableOutput("student_date_table"))
      ),

)
