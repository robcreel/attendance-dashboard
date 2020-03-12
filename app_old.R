library(shiny)
library(pdftools)
library(magrittr)
library(lubridate)
library(tibble)
library(dplyr)
library(ggplot2)
library(here)
library(kableExtra)
library(tidyr)
library(stringr)
library(stringi)

# Define UI for data upload app ----
ui <- fluidPage(
    
    # App title ----
    titlePanel("Uploading Files"),
    
    # Sidebar layout with input and output definitions ----
    sidebarLayout(
        
        # Sidebar panel for inputs ----
        sidebarPanel(
            
            # Input: Select a file ----
            fileInput("file1", "Choose File",
                      multiple = FALSE,
                      accept = c("text/pdf",
                                 # "text/comma-separated-values,text/plain",
                                 ".pdf")
                      ),
            
            # # Horizontal line ----
            # tags$hr(),
            # 
            # # Input: Checkbox if file has header ----
            # checkboxInput("header", "Header", TRUE),
            # 
            # # Input: Select separator ----
            # radioButtons("sep", "Separator",
            #              choices = c(Comma = ",",
            #                          Semicolon = ";",
            #                          Tab = "\t"),
            #              selected = ","),
            # 
            # # Input: Select quotes ----
            # radioButtons("quote", "Quote",
            #              choices = c(None = "",
            #                          "Double Quote" = '"',
            #                          "Single Quote" = "'"),
            #              selected = '"'),
            # 
            # # Horizontal line ----
            # tags$hr(),
            # 
            # # Input: Select number of rows to display ----
            # radioButtons("disp", "Display",
            #              choices = c(Head = "head",
            #                          All = "all"),
            #              selected = "head")
            
        ),
        
        # Main panel for displaying outputs ----
        mainPanel(
            
            # Output: Date Table
            tableOutput("contents"),
            
            # Output: Date Plot
            plotOutput("date_plot")
            
        )
        
    )
)



# Define server logic to read selected file ----
server <- function(input, output) {
    
    output$contents <- renderTable({
        
        # input$file1 will be NULL initially. After the user selects
        # and uploads a file, head of that data file by default,
        # or all rows if selected, will be shown.
        
        req(input$file1)
        
        # Set flag for identifying rows with desired data.
        a0 <- "A00000"
        
        # Set flag for holiday because CAMS is too stupid to exclude holidays from reports.
        # MLK Day
        
        # holiday <- "2020-01-20"
        holiday <- "01-20"
        
        
        # Initialize empty data frame.
        df <- data.frame(Student=character(), 
                         Presence=character(), 
                         Date=character(), 
                         stringsAsFactors=FALSE) 
        
        # when reading semicolon separated files,
        # having a comma separator causes `read.csv` to error
        tryCatch(
            {
                # df <- read.csv(input$file1$datapath,
                #                header = input$header,
                #                sep = input$sep,
                #                quote = input$quote)
                raw_data <- pdf_text(input$file1$datapath)
                raw_data <- strsplit(raw_data, split = "\n")
                header <- raw_data[[1]][2]
            },
            error = function(e) {
                # return a safeError if a parsing error occurs
                stop(safeError(e))
            }
        )
        
        # Function to extract name from a linelist of strings
        get_name <- function(a_line_list){
            student_name <- paste(a_line_list[3:2], collapse = " ")
            student_name <- str_remove(student_name, ",") # Strip out the comma
            return(student_name)
        }
        
        # Function to extract presence status from a linelist of strings
        get_presence <- function(a_line_list){
            suppressWarnings({
                if (TRUE %in%  stri_detect_fixed(a_line_list, "Left")) {
                    return("Left Early")
                } else if (TRUE %in%  stri_detect_fixed(a_line_list, "Present")) {
                    return("Present")
                } else if (TRUE %in%  stri_detect_fixed(a_line_list, "Absent")) {
                    return("Absent")
                } else if (TRUE %in%  stri_detect_fixed(a_line_list, "Late")) {
                    return("Late")
                }
            })
            # return(student_presence)
        }
        
        # Function to extract the date from a linelist of strings
        
        get_date <- function(a_line_list){
            suppressWarnings({
                for (it in 1:length(a_line_list)){
                    if (!is.na(mdy(a_line_list[it]))){
                        return(a_line_list[it])
                    } else {
                        result <- NA
                    }
                }
            })
            return(result)
        }
        
        
        
        # Iterate over each page, over each line.
        for (i in 1:length(raw_data)) {
            page <- raw_data[[i]]
            for (j in 1:length(page)) {
                # line <- page[[j]]
                line <- page[j]
                # Strip each line into a list, and store its length.
                linelist <- strsplit(line, "\\s+")[[1]]
                n <- length(linelist)
                
                
                # Check if line contains student data by
                # checking whether that flagged string is in
                # any word in the list.
                if (TRUE %in%  stri_detect_fixed(linelist, a0)) {
                    # Get name, presence, and date and save them to new_row
                    new_row <- c(get_name(linelist), 
                                 get_presence(linelist), 
                                 get_date(linelist))
                    # Add new_row to dataframe.
                    df[nrow(df)+1,] <- new_row
                }
            }
        }
        
        # Correct Student name capitalization.
        df$Student <- str_to_title(df$Student)
        # Set the date string as a Date object.
        df$Date <- mdy(df$Date)
        df$Date <- format(df$Date, format="%m-%d")
        # Exclude holidays.
        df %>% filter(Date != holiday) -> df
        # Get number of class days.
        class_days_n <- length(unique(df$Date))
        
        # Group data by date and get total number of enrolled students each day.
        df %>% group_by(Date) %>% 
            count(name = "Total") -> date_df
        
        # Group data by date and count all who were in class any time that day.
        df %>% group_by(Date) %>% 
            filter(
                Presence == "Present" | 
                    Presence == "Late" | 
                    Presence == "Left Early"
            ) %>% 
            count(name = "In_Class") -> date_p_df
        
        # Aggregate counts for In_Class, Total (Enrolled), and Percent.
        date_df %>% add_column(In_Class = date_p_df$In_Class)  %>% 
            mutate(Percent = round(In_Class / Total * 100)) %>% 
            select(Date, In_Class, Total, Percent) -> date_df
        
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
        
        qplot(c(1, 2, 3), c(1, 2, 2))
        
        
        # Make plot
        # ggplot(date_df, aes(factor(Date), Percent, group = 1)) +
        #     geom_line() +
        #     theme(axis.text.x = element_text(angle = 60, vjust = 0.5)) +
        #     xlab("Date") +
        #     ylim(0, 100) 
        

        
    )
    
}

# Create Shiny app ----
shinyApp(ui, server)
