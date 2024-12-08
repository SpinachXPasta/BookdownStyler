#observer user render from spachhai_app/bookdownstyler/serverside_ui_render/generic_user_page_ui_serverside.R
observeEvent(input$user_render,{
  user = credentials()$info[["user"]]
  
  project = input$user_open_file_project_selected
  
  
  #see if any rmd files have been uploaded
  validation_query = sqlite_dql(paste0("SELECT * from CONTENTS where username = '",user,"' and project_name = '",project,"';")) %>% arrange(run_order)
  
  #render the files that are selected for rendering
  render_only_df = validation_query %>% filter(render_file == 1)
  tryCatch({
    check = render_only(render_only_df)
    if (check == TRUE){
    render_full(validation_query)
    } else {
      unlink(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/rendered/*"), recursive = TRUE)
      file.copy( paste0(fileLoc_runApp,"/bookdownstyler/HTML/templates/index.html"),
                 paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/rendered/index.html"))
      shinyalert::shinyalert("Rmd files should have at least 1 h1 header", type = "error")
      
    }
  }, error = function(e) {
    unlink(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/rendered/*"), recursive = TRUE)
    file.copy( paste0(fileLoc_runApp,"/bookdownstyler/HTML/templates/index.html"),
               paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/rendered/index.html"))
    showModal(modalDialog(id = "render_error_modal",
                          includeHTML(paste0(fileLoc_runApp, "/bookdownstyler/HTML/templates/render-error.html")),
                          footer=tagList(
                            modalButton('cancel')
                          )))
    
  })
})



render_only <- function(rdf){
  user = credentials()$info[["user"]]
  project = input$user_open_file_project_selected
  
  
  rdf$new_name = ifelse(rdf$index_page != 1,paste0("file_",rdf$run_order - 1,".rmd"),"index.rmd")
  
  write_loc = paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/preview_contents/")
  # Delete all files and subdirectories within the directory
  unlink(paste0(write_loc, "*"), recursive = TRUE)
  unlink(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/rendered/*"), recursive = TRUE)
  
  file.copy(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/_output.yml"),
            paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/preview_contents/_output.yml"))
  
  file.copy(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/book.bib"),
            paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/preview_contents/book.bib"))
  
  
  file.copy(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/_bookdown.yml"),
            paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/preview_contents/_bookdown.yml"))
  
  
  
  
  for (r in 1:nrow(rdf)){
    row_ = rdf[r,]
    writeBin(row_$file[[1]], paste0(write_loc,row_$new_name))
  }
  

  
  
  check01 = FALSE
  lock = FALSE
  
  
  for (r in 1:nrow(rdf)){
    row_ = rdf[r,]
    x = readLines(paste0(write_loc,row_$new_name))
    x = paste0(x, collapse = " ")
    print (x)
    
    if (!lock){
      if (grepl("(\\s#|^#) \\w+",x)){
        lock = TRUE
        check01 = TRUE 
      }
    }
  }
  
  if (check01 == FALSE){
    return(FALSE)
  }
  
  print (rdf)
  
  
  
  run_render(loc0=fileLoc_runApp,user=user,project=project, contents_loc = "preview_contents")
  
  
  
  
  from.dir <- paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/preview_contents/output/_book")
  to.dir   <- paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/rendered/")
  fs::dir_copy(paste0(from.dir), to.dir, overwrite = TRUE)
  
  
  #copy over files to be rendered
  if (dir.exists(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/rendered/_main_files"))){
    from.dir <- paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/rendered/_main_files")
    to.dir   <- paste0(fileLoc_runApp,"/bookdownstyler/www/static/replica/",user,"/",project,"/")
    fs::dir_copy(paste0(from.dir), to.dir, overwrite = TRUE)
  }
  
  
  #copy over css files to be rendered
  from.dir <- paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/preview_contents/output/style")
  to.dir   <- paste0(fileLoc_runApp,"/bookdownstyler/www/static/replica/",user,"/",project,"/")
  fs::dir_copy(paste0(from.dir), to.dir, overwrite = TRUE)
  
  
  
  sqlite_dml("UPDATE projects SET rendered = 1 WHERE project_name = ? AND username = ?", 
             params = list(project, user))
  
  runjs(' $("#rmd_tool_display_box").load(" #rmd_tool_display_box > *");')
  
  return (TRUE)
}



render_full <- function(rdf){
  user = credentials()$info[["user"]]
  project = input$user_open_file_project_selected
  rdf$new_name = ifelse(rdf$index_page != 1,paste0("file_",rdf$run_order - 1,".rmd"),"index.rmd")
  
  write_loc = paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/uploaded/")
  # Delete all files and subdirectories within the directory
  unlink(paste0(write_loc, "*"), recursive = TRUE)
  unlink(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/saved/*"), recursive = TRUE)
  
  file.copy(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/_output.yml"),
            paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/uploaded/_output.yml"))
  
  file.copy(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/book.bib"),
            paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/uploaded/book.bib"))
  
  
  file.copy(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/_bookdown.yml"),
            paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/uploaded/_bookdown.yml"))
  
  
  for (r in 1:nrow(rdf)){
    row_ = rdf[r,]
    #print (row_$file)
    writeBin(row_$file[[1]], paste0(write_loc,row_$new_name))
  }
  print (rdf)
  
  run_render(loc0=fileLoc_runApp,user=user,project=project, contents_loc = "uploaded")
  
  
  
  
  from.dir <- paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/uploaded/output/_book")
  to.dir   <- paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/saved/")
  fs::dir_copy(paste0(from.dir), to.dir, overwrite = TRUE)
  
  unlink(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/download"), recursive = TRUE)
  create_file_dir(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/download"))
  create_file_dir(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/download/HTML"))
  create_file_dir(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/download/style"))
  
  
  from.dir <- paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/saved")
  to.dir   <- paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/download/HTML/")
  fs::dir_copy(paste0(from.dir), to.dir, overwrite = TRUE)
  
  file.copy(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/style/tocprod.css"),
            paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/download/style/tocprod.css"))
  
  file.copy(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/style/bodyprod.css"),
            paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",project,"/contents/download/style/bodyprod.css"))
  
  
  
}


