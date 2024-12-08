observeEvent(input$user_download, {
  
  if (!is.null(input$user_open_file_project_selected)){
    
    
    user = credentials()$info[["user"]]
    project = input$user_open_file_project_selected
    
    check = dir.exists(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/download"))
    
    if (check){
      
      
      if (file.exists(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/download.zip"))){
        unlink(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/download.zip"))
      }
      
      folder_to_zip <- paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/download")
      zip_file <- paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/download.zip")
      
      
      # Save the current working directory
      original_wd <- getwd()
      
      # Change to the directory containing the folder to zip
      setwd(dirname(folder_to_zip))
      
      # Create the zip archive
      zip(zipfile = zip_file, files = basename(folder_to_zip))
      
      # Restore the original working directory
      setwd(original_wd)
      
      
      
      
      
      file.copy(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/download.zip"),
                paste0(fileLoc_runApp,"/bookdownstyler/www/static/replica/",user,"/",project,"/download.zip"), overwrite = TRUE)
      
      runjs(paste0('
          
          const downloadFile = (path, filename) => {
    const anchor = document.createElement("a");
    anchor.href = path;
    anchor.download = filename;
    document.body.appendChild(anchor);
    anchor.click();
    document.body.removeChild(anchor);
};

// Usage
downloadFile("',paste0("static/replica/",user,"/",project,"/download.zip"),'", "',paste0(project,"_",Sys.time(),".zip"),'");
          
          
          
          '))
      
      
      
    } else {
      
      shinyalert("Please render file first.")
      
    }
    
    
    
    
    }
  
 
    
    
  
  
})
  