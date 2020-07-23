library(shiny)
library(shinythemes)
library(plotly)
library(DT)

# Define UI for data upload app ----
ui <- fluidPage(theme = shinytheme("spacelab"),

  # App title ----
  titlePanel(div(tags$img(src="./EW_logo.svg", height="15%", width="15%"), "Attendance Dashboard"), 
            windowTitle =  "Attendance Dashboard"),
  
  # Show course name
  h4(textOutput("course_name")),
  
      # Setup Tabs
      tabsetPanel(
        tabPanel("Upload PDF", 
                 # Input: Select a file ----
                 fileInput("file1", "",
                           multiple = FALSE,
                           accept = c("text/pdf",".pdf")
                 ),
                        h3("To Generate the 'Attendance Report' PDF for upload:"),
                        h4("In the Faculty Portal"),
                        tags$ul(
                          tags$li("Go to 'My Courses' > 'Course Options' > 'Attendance Report'."),
                          tags$li("Make sure that the smallest of the three available font sizes is selected."),
                          tags$li("Click 'View Attendance Report' button."),
                          tags$li("Click the printer icon."),
                          tags$li("Save as PDF."),
                          tags$li("Upload that PDF in the field above.")
                        ),
                 column(8, "The plots and table in the other tabs above are currently built off of mock data.  You may upload your own class's data if you have it.  Click the \"Mock Data Sample PDF\" to see what the mock data (and similar genuine CAMS data) looks like."),
                 
                 downloadButton("downloadData", label = "Mock Data Sample PDF"),
                 
        ),
        tabPanel("By Date (Plot)", plotlyOutput("date_plotly")),
        tabPanel("By Date (Table)", tableOutput("date_table")),
        tabPanel("By Student", dataTableOutput("student_table")),
        tabPanel("By Student and Date", dataTableOutput("student_date_table")) #,
        # , tabPanel("No Shows", textOutput("noshows"),),
        # tabPanel(
        #   "Download Report", downloadButton("report", "Generate report"),
        #   h4("Note 1: This report can only be generated once the 'Attendance Record.pdf' file is uploaded."),
        #   h4("Note 2: Report generation takes a few seconds after clicking the button.  Thank you for your patience."),
        # )
      ),

)
