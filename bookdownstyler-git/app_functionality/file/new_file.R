#this is the event handler to input$user_new from bookdownstyler/server_components/generic_user_page_server

observeEvent(input$user_new_modal_submit, {
  user = credentials()$info[["user"]]
  
  #Sets the label of input to project name, when submit button from modal is clicked.
  #this is to reset asthetics every time the function is run.
  runjs('document.getElementById("user_new_project_name-label").innerHTML = "Project Name";')
  
  
  if (input$user_new_project_name == ""){
    #validation that reqyures name not be empty
    runjs('document.getElementById("user_new_project_name-label").innerHTML = "Project Name <span style=\'color: red;\'>cannot be empty</span>";');
  } else {

    #check exising project names for the users with the same name
    projects = sqlite_dql(paste0("SELECT * FROM projects where username = '",user,"' and project_name = '",input$user_new_project_name,"'"))
    
    #if there are no existing projects for the user
    if (nrow(projects) == 0){
      print ("Creating new project")
      
      #we create a new directory for the user with the project name
      new_dir <- paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",  user, "/", input$user_new_project_name)
      
      
      
      #The subfolders required to be created for the app.
      create_file_dir(new_dir)
      create_file_dir(paste0(new_dir,"/contents"))
      create_file_dir(paste0(new_dir,"/uploaded"))
      create_file_dir(paste0(new_dir,"/output"))
      create_file_dir(paste0(new_dir,"/rendered"))
      create_file_dir(paste0(new_dir,"/saved"))
      create_file_dir(paste0(new_dir,"/preview_contents"))
      #create_file_dir(paste0(new_dir,"/style"))
      
      #create a replica in www to serve images
      create_file_dir(paste0(fileLoc_runApp,"/bookdownstyler/www/static/replica/",  user, "/", input$user_new_project_name))
      
      
      # we copy over css foles into the style directory of the project
      R.utils::copyDirectory( paste0(fileLoc_runApp,"/bookdownstyler/CSS/templates"),paste0(new_dir,"/style"))
      
      #we copy over book.bib, metadat.txt and index.html from templates to the project folders to initialise the project.
      file.copy( paste0(fileLoc_runApp,"/bookdownstyler/misc/templates/book.bib"),paste0(new_dir,"/contents/book.bib"))
      file.copy( paste0(fileLoc_runApp,"/bookdownstyler/misc/templates/settings.RData"),paste0(new_dir,"/contents/settings.RData"))
      file.copy( paste0(fileLoc_runApp,"/bookdownstyler/misc/templates/html_settings.RData"),paste0(new_dir,"/contents/html_settings.RData"))
      file.copy( paste0(fileLoc_runApp,"/bookdownstyler/misc/templates/bs4_settings.RData"),paste0(new_dir,"/contents/bs4_settings.RData"))
      file.copy( paste0(fileLoc_runApp,"/bookdownstyler/misc/templates/metadat.txt"),paste0(new_dir,"/contents/metadat.txt"))
      file.copy( paste0(fileLoc_runApp,"/bookdownstyler/misc/templates/_output.yml"),paste0(new_dir,"/contents/_output.yml"))
      file.copy( paste0(fileLoc_runApp,"/bookdownstyler/HTML/templates/index.html"),paste0(new_dir,"/rendered/index.html"))
      
      
      #enter new data into DB
      #The project is inserted into the database or future querying and references.
      dml = paste0("INSERT INtO projects VALUES ('",user,"','",input$user_new_project_name,"','",new_dir,"', '",Sys.time(),"','",Sys.time(),"', 0, 0, 'bs4_book');")
      
      sqlite_dml(
        dml
      )
      
      
      #verifies that the project is created with green check mark in the label of the input
      runjs('document.getElementById("user_new_project_name-label").innerHTML = "Project Name <span style=\'color: green;\'>&#x2705;</span>" ;');
      Sys.sleep(1.2)
      removeModal()
      
      #creating new file should close old one and opening new file should close old the old one.
      runjs(paste0("Shiny.setInputValue('user_open_file_project_selected','",input$user_new_project_name,"');"))

      #starts editor can be found in R\functions\rmd_editor_func.R
      start_edit()
    } else {
      
      #If codition fails = , the file already exists.
      runjs('document.getElementById("user_new_project_name-label").innerHTML = "Project Name <span style=\'color: red;\'>already exists</span>";');
    }
    
  }
  
  
  
})