library(shiny)


# Define server logic to read selected file ----
server <- function(input, output) {

  ###
  #
  # Build report components
  #
  ###
  
  # Extract raw data from PDF.
  raw_data <- reactive({
    req(input$file1)
    raw_data <- pre_process(input$file1$datapath)
  })
  
  # Build master dataframe.
  master_df <- reactive({
    # course_name <- get_course_name(raw_data())
    build_df(raw_data())
    })
  
  # Get class name
  course_name <- reactive(get_course_name(raw_data()))

  # Build date dataframe.
  date_df <- reactive(build_date_df(master_df()))
  # date_dt <- reactive(DT::renderDataTable(date_df()))
  
  # Subset master dataframe to include only currently enrolled students
  current_df <- reactive(get_current_df(master_df()))
  
  # Build by-student table
  student_df <- reactive(build_student_df(current_df()))
  
  # Build by-date/by-student table
  student_date_df <- reactive(build_date_student_df(current_df()))

  ###
  #
  # Render report components
  #
  ###
  
  # Render date plot.
  # output$date_plot <- renderPlot(build_date_plot(date_df()))
  output$date_plotly <- renderPlotly(build_date_plotly(date_df()))
  
  # Render date dataframe as table.
  output$date_table <- renderTable(date_df(), digits = 0)
  # output$date_table <- renderDataTable(date_df())
  
  # Render by-student table.
  output$student_table <- renderDataTable(student_df(),
                                          options = list(pageLength = 50))
  
  # Render by-date/by-student table
  output$student_date_table <- renderDataTable(student_date_df(),
                                               options = list(pageLength = 50))
  
  # Render course name
  output$course_name <- renderText(course_name())
  
  # Sample PDF for download and re-upload
  output$downloadData <- downloadHandler(
    filename <- function() {
      "Attendance_Report_Fake.pdf"
    },
    
    content <- function(file) {
      file.copy("www/Attendance_Report_Fake.pdf", file)
    },
    # contentType = 
  )
}
