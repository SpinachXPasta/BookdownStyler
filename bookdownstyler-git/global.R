library(dplyr)
library(shiny)
library(shinyauthr)
library(DBI)
library(RSQLite)
library("shiny.router")

library(shiny)
library(shinyjs)
library(purrr)
library(shinyFiles)
library(ggplot2)
library(stringr)
library(tidyr)
library(dplyr)
#library(xlsx) #doesn't work in mac
library(openxlsx)
library(writexl)
library(kableExtra)
library(DT)
library(grid)
library(gtable)
library(htmlwidgets)
library(shinyalert)
library(readr)
library(rvest)
library(xml2)
library(fs)
library(colourpicker)
library(R.utils)
library(bookdown)
library(rstudioapi)
library(downlit)
library(lubridate)
library(survival)
library(magrittr)


# Create ADMIN user
# dataframe that holds usernames, passwords and other user data
#user_base <- tibble::tibble(
#  user = c("shiny_manager", "test_user_1"),
#  password = sapply(c("apple", "apple"), sodium::password_store),
#  permissions = c("admin", "standard"),
#  name = c("Shiny APP Admin", "Test User")
#)



#The purpose of this function is to generate the path of the current script.
  getCurrentFileLocation <-  function()
  {
    this_file <- commandArgs() %>% 
      tibble::enframe(name = NULL) %>%
      tidyr::separate(col=value, into=c("key", "value"), sep="=", fill='right') %>%
      dplyr::filter(key == "--file") %>%
      dplyr::pull(value)
    if (length(this_file)==0)
    {
      this_file <- rstudioapi::getSourceEditorContext()$path
    }
    return(dirname(this_file))
  }
  
  #Save the current location of the runApp script to be used by other scripts.
  fileLoc_runApp = getwd()#getCurrentFileLocation()
  fileLoc_runApp = gsub(pattern = "/bookdownstyler",replacement = "",fileLoc_runApp)
  print (paste0("fileLoc_App resolves to", fileLoc_runApp))
  
  
  print (list.files(recursive = TRUE))
  
  #fileLoc_runApp = substr(fileLoc_runApp,1,nchar(fileLoc_runApp)-2)




#load modules for the server
source(file.path(fileLoc_runApp, "bookdownstyler/functions/db_functions.R"), local = FALSE)$value # Load Libraries
source(file.path(fileLoc_runApp, "bookdownstyler/functions/onclick_functions.R"), local = FALSE)$value # Load Libraries
source(file.path(fileLoc_runApp, "bookdownstyler/functions/rmd_editor_func.R"), local = FALSE)$value 
source(file.path(fileLoc_runApp, "bookdownstyler/functions/helper.R"), local = FALSE)$value 
source(file.path(fileLoc_runApp, "bookdownstyler/functions/validate_update_contents.R"), local = FALSE)$value 
source(file.path(fileLoc_runApp, "bookdownstyler/functions/run_render.R"), local = FALSE)$value 