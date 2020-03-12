library(shiny)


# Define server logic to read selected file ----
server <- function(input, output) {
  
  output$contents <- renderTable({
    
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, head of that data file by default,
    # or all rows if selected, will be shown.
    
    req(input$file1)
    
    raw_data <- pre_process(input$file1$datapath)

    # Build dataframe
    df <<- build_df(raw_data)
    
    # Build by-date dataframe
    date_df <<- build_date_df(df)
    

    # if(input$disp == "head") {
    # return(head(df))
    return(date_df)
    # }
    # else {
    #     # return(df)
    #     return(5)
    # }
    
  })
  
  output$date_plot <- renderPlot(
    
    fake_plot
    # build_date_plot(date_df)

  )
  
}
