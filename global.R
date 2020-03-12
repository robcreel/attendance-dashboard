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




# Set flag for identifying rows with desired data.
a0 <- "A00000"

# Set flag for holiday because CAMS is too stupid to exclude holidays from reports.
# MLK Day

# holiday <- "2020-01-20"
holiday <- "01-20"


pre_process <- function(input_file){
  raw <- pdf_text(input_file)
  raw <- strsplit(raw, split = "\n")
  header <<- raw[[1]][2]
  return(raw)
}

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

build_df <- function(input_data){
  # Initialize empty data frame.
  df <- data.frame(Student=character(),
                   Presence=character(),
                   Date=character(),
                   stringsAsFactors=FALSE)
  
  # Iterate over each page, over each line.
  for (i in 1:length(input_data)) {
    page <- input_data[[i]]
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
  return(df)
}

build_date_df <- function(input_df){
  # Group data by date and get total number of enrolled students each day.
  input_df %>% group_by(Date) %>% 
    count(name = "Total") -> date_df
  
  # Group data by date and count all who were in class any time that day.
  input_df %>% group_by(Date) %>% 
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
  
  return(date_df)
}


build_date_plot <- function(input_df){
  date_plot <- ggplot(input_df, aes(factor(Date), Percent, group = 1)) +
    geom_line() +
    theme(axis.text.x = element_text(angle = 60, vjust = 0.5)) +
    xlab("Date") +
    ylim(0, 100)
  return(date_plot)
}


###
#
# Execution
#
###
# 
# raw_data <- pre_process(input$file1$datapath)
# 
# # Build dataframe
# df <<- build_df(raw_data)
# 
# # Build by-date dataframe
# date_df <<- build_date_df(df)

fake_plot <<- qplot(0, 0)
