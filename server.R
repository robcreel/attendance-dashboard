library(shiny)


# Define server logic to read selected file ----
server <- function(input, output) {
  
  ###
  #
  # Build report components
  #
  ###
  
  # Build master dataframe.
  master_df <- reactive({
    req(input$file1)
    raw_data <- pre_process(input$file1$datapath)
    build_df(raw_data)
    })
  
  # Build date dataframe.
  date_df <- reactive(build_date_df(master_df()))
  
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
  
  # Render date dataframe as table.
  output$date_table <- renderTable(date_df(), digits = 0)
  
  # Render date plot.
  output$date_plot <- renderPlot(build_date_plot(date_df()))
  
  # Render by-student table.
  output$student_table <- renderTable(student_df(), digits = 0)
  
  # Render by-date/by-student table
  output$student_date_table <- renderTable(student_date_df(), digits = 0)
}
