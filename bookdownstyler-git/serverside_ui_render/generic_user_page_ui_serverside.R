#place holder, for the app for generic user.
output$generic_page = renderUI({
  req(credentials()$user_auth)
  req(credentials()$info[["permissions"]] != "admin")
  div(style = "margin-top:20px;",
    div(style="padding-top:12;",HTML("</br>")),
    navbarPage(
      div(),
      # the full width class allows the entire span to be selected, improving toggle UI
      #these are the tabs for generic user.
      #code for the functionality is spread out but the main functions are listed as below
      navbarMenu("File",

                #R\app_functionality\file\new_file.R
                 runjs(create_global_this("user_new")),
                 tabPanel(tags$span("New", onclick = onclick_inc_for_tags("user_new"), class = "full-width-span"  )),
                 
                 #R\app_functionality\file\open_file.R
                 runjs(create_global_this("user_open")),
                 tabPanel(tags$span("Open",onclick = onclick_inc_for_tags("user_open")  , class = "full-width-span"     )),
                 
             
                 
                 runjs(create_global_this("user_download")),
                 tabPanel(tags$span("Download", onclick = onclick_inc_for_tags("user_download")   , class = "full-width-span"  )),
                
                
                runjs(create_global_this("user_help")),
                tabPanel(tags$span("Help", onclick = onclick_inc_for_tags("user_help")   , class = "full-width-span"  )),
                 
                 #R\app_functionality\file\close_file.R
                 runjs(create_global_this("user_close_editor")),
                 tabPanel(tags$span("Close Project", onclick = onclick_inc_for_tags("user_close_editor")   , class = "full-width-span"  ))
      ),
      navbarMenu("Edit",
                # R\app_functionality\edit\edit_file.R
                 #runjs(create_global_this("edit_meta")),
                 #tabPanel(tags$span("Edit Metadata", onclick = onclick_inc_for_tags("edit_meta")   , class = "full-width-span"  )),
                 
                 #R\app_functionality\edit\edit_rmd.R
                 runjs(create_global_this("edit_rmd")),
                 tabPanel(tags$span("Edit RMD", onclick = onclick_inc_for_tags("edit_rmd")   , class = "full-width-span"  )),
                
                 runjs(create_global_this("edit_layout")),
                 tabPanel(tags$span("Edit Layout", onclick = onclick_inc_for_tags("edit_layout")   , class = "full-width-span"  ))
      ),
      navbarMenu("Run",
                 runjs(create_global_this("user_render")),
                 tabPanel(tags$span("Render", onclick = onclick_inc_for_tags("user_render")   , class = "full-width-span"  ))
      ),

      #this will load rmd editor when edit mode is on, see R\functions\rmd_editor_func.R start_edit()
      #the output hanlder is in R\serverside_ui_render\rmd_dev_ui_serverside.R
      div(uiOutput("rmd_editor_ui"))
    )
    
  )
})

#this function is associated with observeEvent(input$user_open) from R\server_components\generic_user_page_server.R.
#It has redners when the open file is executed.
open_file_modal_ui <- function(){

  #this holds the conditional_open_ui depending on if files are created or not.
  output$open_modal_ui <- renderUI({
    print ("Modal UI activated")
    div(tags$h3(paste0('Select ', Sys.time())),
        div(class="scrollable-window", uiOutput("conditional_open_ui"))
        )
  })
  
  
  #Handles output$open_modal_ui  from above.
  output$conditional_open_ui <- renderUI({
    print ("Switch activated")
    user = credentials()$info[["user"]]
    
    #If files exist for the user.
    if (nrow(sqlite_dql( paste0("SELECT * from projects where username = '", user,"';")))>0){
      #div(dataTableOutput("user_open_table"),
      #    runjs("
      #      
      #      document.querySelectorAll('#user_open_table tbody tr').forEach(row => {
      #          row.addEventListener('click', () => {
      #              rows.forEach(r => r.classList.remove('highlight'));
      #              row.classList.add('highlight');
      #          });
      #      });
      #      
      #      
      #      "))
      
      #If files exist = ,  handler in R\app_functionality\file\open_file.R, open_file_html_table
      div(uiOutput("user_open_table"))
      
    } else {
      div(tags$h3("No files exist create new file."))
    }
    
  })
  
  
  
  #observeEvent(input$user_open_modal_cancel,{
  #  removeModal()
  #  runjs("Shiny.setInputValue('user_open_file_project_selected','');")
  #  
  #})
  
  
  
  


}