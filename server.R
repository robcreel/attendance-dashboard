library(shiny)


# Define server logic to read selected file ----
server <- function(input, output) {

  ###
  #
  # Build report components
  #
  ###
  
  # Preprocess default (mock) unless there is genuine uploaded data.
  raw_data <- reactive({
    inFile <- input$file1

    if (!is.null(inFile)){
      # raw_data <- inFile$datapath
      raw_data <- pre_process(input$file1$datapath)
    } else {
      raw_data <- pre_process("www/Attendance_Report_Fake.pdf")
    }
  })
  
  # Build master dataframe.
  master_df <- reactive({
    build_df(raw_data())
    })
  
  # Get class name
  course_name <- reactive(get_course_name(raw_data()))
  
  # Get title
  title <- reactive(course_name() %>% str_extract("[A-Z]{2}[0-9]{3}"))
  
  # course_name %>% str_extract("[A-Z]{2}[0-9]{3}") -> title

  # Build date dataframe.
  date_df <- reactive(build_date_df(master_df()))
  # date_dt <- reactive(DT::renderDataTable(date_df()))
  
  # Subset master dataframe to include only currently enrolled students
  current_df <- reactive(get_current_df(master_df()))
  
  # Build by-student table
  student_df <- reactive(build_student_df(current_df()))
  
  # # Get noshows
  # noshows <- reactive(get_noshows(student_df()))
  
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
  
  # # Render noshows
  # output$noshows <- renderUI(noshows())
  
  # Sample PDF for download and re-upload
  output$downloadData <- downloadHandler(
    filename <- function() {"Attendance_Report_Fake.pdf"},
    content <- function(file) {
      file.copy("www/Attendance_Report_Fake.pdf", file)
    },
  )
  
  ### Report Download
  output$report <- downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = paste("Attendance_Report_", title(), ".pdf", sep = ""),
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "attendance_report.rmd")
      file.copy("attendance_report.rmd", tempReport, overwrite = TRUE)
      
      # Set up parameters to pass to Rmd document
      # params <- list(n = input$slider)
      params = list(input_file = input$file1$datapath)
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(tempReport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
    }
  )
  ### End report download
}
