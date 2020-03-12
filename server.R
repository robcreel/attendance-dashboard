library(shiny)


# Define server logic to read selected file ----
server <- function(input, output) {
  
  # Build master dataframe.
  master_df <- reactive({
    req(input$file1)
    raw_data <- pre_process(input$file1$datapath)
    build_df(raw_data)
    })
  
  # Build date dataframe
  date_df <- reactive({
    build_date_df(master_df())
  })
  
  output$contents <- renderTable({
    
    # # Build by-date dataframe
    # date_df <- build_date_df(master_df())
    
    return(date_df())
    
  })
  
  output$date_plot <- renderPlot(
    
    # fake_plot
    build_date_plot(date_df())

  )
  
}
