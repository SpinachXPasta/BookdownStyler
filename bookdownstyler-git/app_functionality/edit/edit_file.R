#on add metadata
# this is for edit meta dat
observeEvent(input$edit_meta, {

  if (!is.null(input$user_open_file_project_selected))
    if (input$user_open_file_project_selected != ""){
      showModal(modalDialog(id = "add_meta_modal",
                            tags$h3('Please enter meta data for Bookdown Project'),
                            uiOutput("meta_modal_form"),
                            footer=tagList(
                              actionButton('update_meta_submit', 'Update'),
                              actionButton('reset_meta_submit', 'Reset'),
                              modalButton('cancel')
                            )))
      
    }
  
  
  
})


observeEvent(input$edit_meta, {
  output$meta_modal_form = renderUI({
    "reloaded"
    user = credentials()$info[["user"]]
    meta_file = readr::read_file(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",input$user_open_file_project_selected,"/contents/metadat.txt"))
    meta_file = gsub('\"','',meta_file)
    meta = string_to_key_value_pairs(meta_file)
    
    div(
      textInput(inputId = "meta_title", "Title", value = meta$title),
      textInput(inputId = "meta_author", "Author", value = meta$author),
      textInput(inputId = "meta_date", "Date", value = meta$date),
      textInput(inputId = "meta_site", "Site", value = meta$site),
      textInput(inputId = "meta_link-citations", "Link-Citations", value = meta$`link-citations`),
      textInput(inputId = "meta_github-repo", "Github-Repo", value = meta$`github-repo`),
      textInput(inputId = "meta_description", "Description", value = meta$description)
    )
  })

})





observeEvent(input$update_meta_submit, {
  user = credentials()$info[["user"]]
  text_out = ""
  text_out =paste0(text_out, 'title: "',input$meta_title,'"\n')
  text_out =paste0(text_out, 'author: "',input$meta_author,'"\n')
  text_out =paste0(text_out, 'date: "',input$meta_date,'"\n')
  text_out =paste0(text_out, 'site: ',input$meta_site,'\n')
  text_out =paste0(text_out, 'documentclass: ',"book",'\n')
  text_out =paste0(text_out, 'bibliography: ',"[../content/book.bib, ../content/packages.bib]",'\n')
  text_out =paste0(text_out, 'biblio-style: ',"apalike",'\n')
  text_out =paste0(text_out, 'link-citations: ',input$`meta_link-citations`,'\n')
  text_out =paste0(text_out, 'github-repo: ',input$`meta_github-repo`,'\n')
  text_out =paste0(text_out, 'description: "',input$description,'"\n')
  
  cat(text_out, file = paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",user,"/",input$user_open_file_project_selected,"/contents/metadat.txt"))
  removeModal()
})


observeEvent(input$reset_meta_submit, {
  
  updateTextInput(inputId = "meta_title", value = "")
  updateTextInput(inputId = "meta_author", value = "")
  updateTextInput(inputId = "meta_date",value = "`r Sys.Date()`")
  updateTextInput(inputId = "meta_site",value = "bookdown::bookdown_site")
  updateTextInput(inputId = "meta_link-citations", value = "yes")
  updateTextInput(inputId = "meta_github-repo", value = "")
  updateTextInput(inputId = "meta_description", value = "")
  
})


