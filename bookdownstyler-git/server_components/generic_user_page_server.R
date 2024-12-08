
#Create folder for the user if it doesn't already exist
#we can observe login's in the way mentioned below.
#This observe event creates the fodler  for the current user so it can hold projects for the user.
observeEvent(req(credentials()$user_auth),{
  
  req(credentials()$info[["permissions"]] != "admin")
  user = credentials()$info[["user"]]
  new_dir <- paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",  user)
  
  
  # Check if the directory exists, and create it if it doesn't
  if (!dir.exists(new_dir)) {
    dir.create(new_dir)
    message("Directory created: ", new_dir)
  } else {
    message("Directory already exists: ", new_dir)
  }
  
  
  
  new_dir <- paste0(fileLoc_runApp,"/bookdownstyler/www/static/replica/",  user)
  # replica in www folder
  if (!dir.exists(new_dir)) {
    dir.create(new_dir)
    message("Directory created: ", new_dir)
  } else {
    message("Directory already exists: ", new_dir)
  }
  
  
})



#when user clicks on new on  the user page
#a modal pops up requesting the name of the new project they want to create
# the button to be observed here is user_new_modal_submi
#the request handlers are located in bookdownstyler/app_functionality/file/new_file
observeEvent(input$user_new,{
  showModal(modalDialog(id = "user_new_modal",
                        tags$h3('Please enter the name of the new project'),
                        textInput('user_new_project_name', 'Project Name'),
                        footer=tagList(
                          actionButton('user_new_modal_submit', 'Submit'),
                          modalButton('cancel')
                        )))
  
})








#very important lesson learned here, for ui compnents nested inside a observe event, they need to be inside the observe
#event as well or else they will not rerender.
#putting the nested ui from bookdownstyler/serverside_ui_redner/generic_user_page_ui_serverside and bookdownstyler/app_functionality/file/open_file
# as functions withint observe event block

#when user clicks open
observeEvent(input$user_open,{
  print ("trigegred!")

  #reset the modal.
  removeModal()

  #show the modal with two different action buttons, user_open_modal_submit  & user_open_modal_cancel
  showModal(modalDialog(id = "user_open_modal",
                        uiOutput("open_modal_ui"),
                        footer=tagList(
                          actionButton('user_open_modal_submit', 'Submit'),
                          actionButton('user_open_modal_cancel', 'Cancel')
                        )))
  
  
  #this function is located in R\server_components\generic_user_page_server.R
  #this function has handlers for uiOutput("open_modal_ui") from this same observe block.
  open_file_modal_ui()
  
  #associated with R\app_functionality\file\open_file.R & output$conditional_open_ui from R\serverside_ui_render\generic_user_page_ui_serverside.R
  open_file_html_table()
  
})


#When the cancel button is pressed
# Set user_open_file_project_sele to ''
# this is related to the ...
observeEvent(input$user_open_modal_cancel, {

  #if files have been selected in the past
  if (!is.null(input$user_open_file_project_selected)){
    #but files are not currently being selected then its ok to cancel
    #cancel should not exit the current project
    if (input$user_open_file_project_selected == ""){
      removeModal()
      start_edit(FALSE)
      runjs("Shiny.setInputValue('user_open_file_project_selected','');")
    } else {
      #if file is currently open and we cancel opening new file, just remove modal
      removeModal()
    }
  # if no files have ever been select in the pat its ok to cancel
  } else {
      removeModal()
      start_edit(FALSE)
      runjs("Shiny.setInputValue('user_open_file_project_selected','');")
    }
})



#When the submit button is selected load the project which is in the variable user_open_file_project_selected.
# Then execute start_edit function
observeEvent(input$user_open_modal_submit, {
  if (!is.null(input$user_open_file_project_selected)){
    if (input$user_open_file_project_selected != ""){
      removeModal()

      #starts editor can be found in R\functions\rmd_editor_func.R
      start_edit()  
    }  
  }
  
  
  
})




