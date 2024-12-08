
#this is associated with R\serverside_ui_render\generic_user_page_ui_serverside.R output$generic_page


observeEvent(input$user_new | input$user_open | input$user_render | logout_init() , {

output$rmd_editor_ui <- renderUI({
  
  
  if (!is.null(input$file_edit_mode)){
    
    
    
    #when edit mode is set to TRUE
    if (input$file_edit_mode == 1 & input$user_open_file_project_selected != ""){
      
    
      
      user = credentials()$info[["user"]]
      
      project = input$user_open_file_project_selected
      
      
      query = sqlite_dql(paste0("SELECT rendered FROM projects where username = '",user,"' and project_name = '",project,"'"))
      
      
      
      
      
      
      if (query$rendered == 1){
        
        rendered_files = list.files(paste0(fileLoc_runApp, "/bookdownstyler/db/userfiles/",user,"/",project,"/rendered/"), pattern = ".html")
        div(
          fluidPage(
            selectInput("render_file_list", "Select File", choices = rendered_files, selected = "index.html"),
            div(id = "rmd_tool_display_box",
                #includeCSS(paste0(fileLoc_runApp, "/bookdownstyler/HTML/examples/style/bodyprod.css")),
                #includeCSS(paste0(fileLoc_runApp, "/bookdownstyler/HTML/examples/style/tocprod.css")),
                tags$script(HTML('MathJax.Hub.Queue(["Typeset", MathJax.Hub]);')),
                uiOutput("render_html_ui")
                
            )
          )
          
        )
        
      } else {
        
        
        #When the file is open get the template from "/bookdownstyler/db/userfiles/",user,"/",project,"/rendered/index.html"
        #HTML_text = includeHTML(paste0(fileLoc_runApp, "/bookdownstyler/db/userfiles/",user,"/",project,"/rendered/index.html"))
        HTML_text = read_html(paste0(fileLoc_runApp, "/bookdownstyler/db/userfiles/",user,"/",project,"/rendered/index.html"))
        
        #replace the place hodler with prject name.
        HTML_text = gsub("#plcHld3r@", project, HTML_text)
        
        
        HTML_text = gsub('img src="_main_files', paste0('img src="static/replica/',user,'/',project), HTML_text)
        
        div(
          fluidPage(
            div(id = "rmd_tool_display_box",
                #includeCSS(paste0(fileLoc_runApp, "/bookdownstyler/HTML/examples/style/bodyprod.css")),
                #includeCSS(paste0(fileLoc_runApp, "/bookdownstyler/HTML/examples/style/tocprod.css")),
                tags$script(HTML('MathJax.Hub.Queue(["Typeset", MathJax.Hub]);')),
                HTML(HTML_text),
                
            )
          )
          
        )
        
      }
      
      
      
      
      
      
      
    } else {
      #on cases when project is not selected display  /bookdownstyler/HTML/templates/edit-app.html in the main body of the app for a generic user.
      fluidPage(
        div(id = "rmd_unopened_project",
            includeHTML(paste0(fileLoc_runApp, "/bookdownstyler/HTML/templates/edit-app.html"))
        )
      )
      
      
      
      
    }
    
    
  } else {
    #on cases when project is not selected display  /bookdownstyler/HTML/templates/edit-app.html in the main body of the app for a generic user.
    fluidPage(
      div(id = "rmd_unopened_project",
          includeHTML(paste0(fileLoc_runApp, "/bookdownstyler/HTML/templates/edit-app.html"))
      )
    )
    
  }
    
    
    
  })

})



output$render_html_ui <- renderUI({
  
  user = credentials()$info[["user"]]
  
  project = input$user_open_file_project_selected
  
  
  #When the file is open get the template from "/bookdownstyler/db/userfiles/",user,"/",project,"/rendered/index.html"
  #HTML_text = includeHTML(paste0(fileLoc_runApp, "/bookdownstyler/db/userfiles/",user,"/",project,"/rendered/index.html"))
  HTML_text = read_html(paste0(fileLoc_runApp, "/bookdownstyler/db/userfiles/",user,"/",project,"/rendered/",input$render_file_list))
  
  #replace the place hodler with prject name.
  HTML_text = gsub("#plcHld3r@", project, HTML_text)
  
  HTML_text = gsub('<img src="_main_files/', paste0('<img src="static/replica/',user,'/',project,'/'), HTML_text)
  HTML_text = gsub('../style/tocprod.css', paste0('static/replica/',user,'/',project,'/tocprod.css'), HTML_text)
  HTML_text = gsub('../style/bodyprod.css', paste0('static/replica/',user,'/',project,'/bodyprod.css'), HTML_text)
  
  #HTML_text = paste0(HTML_text, "<script>reloadStylesheets()</script>")
  
  div(
    tags$script(HTML('MathJax.Hub.Queue(["Typeset", MathJax.Hub]);')),
    HTML(HTML_text)
  )
  
  
})

