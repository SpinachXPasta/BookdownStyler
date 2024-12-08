start_edit <- function(default=TRUE){

  #this indicates that the file is ready to be edited.
  if (default) {
    runjs("Shiny.setInputValue('file_edit_mode',1);")
  }
  else {
    # this is the process of closing a file
    runjs("Shiny.setInputValue('file_edit_mode',0);")
    runjs("Shiny.setInputValue('user_open_file_project_selected','');")
  }
}


create_file_dir <- function(new_dir){
  
  # Check if the directory exists, and create it if it doesn't
  if (!dir.exists(new_dir)) {
    dir.create(new_dir)
    message("Directory created: ", new_dir)
  } else {
    message("Directory already exists: ", new_dir)
  }
  
  
  
  
  
}
