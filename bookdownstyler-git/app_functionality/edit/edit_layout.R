html_fonts <- list(
  "Arial",
  "Verdana",
  "Helvetica",
  "Times New Roman",
  "Courier New",
  "Georgia",
  "Trebuchet MS",
  "Lucida Sans Unicode",
  "Tahoma",
  "Impact"
)





observeEvent(input$edit_layout, {
  #User must have file opened to access this.
  if (!is.null(input$user_open_file_project_selected)){
    if (input$user_open_file_project_selected != ""){
      showModal(modalDialog(id = "edit_layout_modal",
                            uiOutput("edit_layout_ui"),
                            footer=tagList(
                              actionButton('update_layout_submit', 'Update'),
                              modalButton('close')
                            )))
      
      
      output$edit_layout_ui <- renderUI({
        user = credentials()$info[["user"]]
        project = input$user_open_file_project_selected
        default = readRDS(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",  user, "/", project,"/contents/settings.RData"))
        
        div(
          selectInput("select_layout", "layout Type", c("html_book","bs4_book"), selected = default$select_layout),
          uiOutput("conditional_layout_ui")
        )
      })
      
      
      output$conditional_layout_ui <- renderUI({
        
        if (input$select_layout == "bs4_book"){
          div(uiOutput("bs4_choice"))
        } else if (input$select_layout == "html_book"){
          div(uiOutput("html_choice"))
        }
      })
      
      
      
      
      output$bs4_choice <- renderUI({
        user = credentials()$info[["user"]]
        project = input$user_open_file_project_selected
        
        
        query1 = sqlite_dql(paste0("SELECT saved from projects where username = '",user,"' and project_name = '",project,"';"))$saved
        query2 = sqlite_dql(paste0("SELECT type from projects where username = '",user,"' and project_name = '",project,"';"))$type
        
        
        #if the book has not been rednered go with default settings else go with the new settings.
        if (query1 == 0 & query2 == "bs4_book"){
          default = readRDS(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",  user, "/", project,"/contents/bs4_settings.RData"))
        } else if(query1 == 1 & query2 == "bs4_book"){
          default = readRDS(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",  user, "/", project,"/contents/settings.RData"))
        } else if (query1 == 1 & query2 != "bs4_book"){
          default = readRDS(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",  user, "/", project,"/contents/bs4_settings.RData"))
        }
        
        
        
        div(selectInput("toc_font_family","TOC Font", 
                        c("-apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, \"Noto Sans\", \"Liberation Sans\", sans-serif, \"Apple Color Emoji\", \"Segoe UI Emoji\", \"Segoe UI Symbol\", \"Noto Color Emoji\"",
                          html_fonts), 
                        selected = trimws(default$toc_font_family)
        ),
        colourpicker::colourInput("toc_main_nav_color", label = "TOC Heading Font color",value = trimws(default$toc_main_nav_color)),
        colourpicker::colourInput("toc_main_nav_chapters_color", label = "TOC Chapters Font color",value = trimws(default$toc_main_nav_chapters_color)),
        sliderInput("toc_main_nav_chapters_font_size",label = "TOC Heading Font Size (REM)", min = 1, max = 5, step=0.05, value = trimws(gsub("rem","",default$toc_main_nav_chapters_font_size))),
        colourpicker::colourInput("toc_chapter_uline_color", label = "TOC Underline Color",value = trimws(default$toc_chapter_uline_color)),
        colourpicker::colourInput("toc_next_page_color", label = "Page content section color",value = trimws(default$toc_next_page_color)),
        sliderInput("toc_next_page_font_size",label = "Page content Font Size (REM)", min = 1, max = 5, step=0.05, value = trimws(gsub("rem","",default$toc_next_page_font_size))),
        colourpicker::colourInput("toc_next_page_name_color", label = "Page content section sub level color",value = trimws(default$toc_next_page_name_color)),
        sliderInput("toc_next_page_name_font_size",label = "Page content section sub level font size (REM)", min = 1, max = 5, step=0.05, value = trimws(gsub("rem","",default$toc_next_page_name_font_size))),
        selectInput("body_font_family","Body font", 
                    c("-apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, \"Noto Sans\", \"Liberation Sans\", sans-serif, \"Apple Color Emoji\", \"Segoe UI Emoji\", \"Segoe UI Symbol\", \"Noto Color Emoji\"",
                      html_fonts), 
                    selected = trimws(default$body_font_family)
        ),
        colourpicker::colourInput("body_font_color", label = "Body font color",value = trimws(default$body_font_color)),
        colourpicker::colourInput("caption_color", label = "Caption color",value = trimws(default$caption_color)),
        colourpicker::colourInput("body_background", label = "Body background",value = trimws(default$body_background )),
        selectInput("replace_order", "Replace order of TOC and Next", choices = c("TRUE", "FALSE"), selected = as.character(trimws(input$replace_order))),
        selectInput("remove_extra_col", "Remove the page contents tab", choices = c("TRUE", "FALSE"), selected = as.character(trimws(input$remove_extra_col)))
        )
      })
      
      
      
      
      
      
      output$html_choice <- renderUI({
        user = credentials()$info[["user"]]
        project = input$user_open_file_project_selected
        
        
        query1 = sqlite_dql(paste0("SELECT saved from projects where username = '",user,"' and project_name = '",project,"';"))$saved
        query2 = sqlite_dql(paste0("SELECT type from projects where username = '",user,"' and project_name = '",project,"';"))$type
        
        
        if (query1 == 0){
          default = readRDS(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",  user, "/", project,"/contents/html_settings.RData"))
        } else if(query1 == 1 & query2 == "html_book"){
          default = readRDS(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",  user, "/", project,"/contents/settings.RData"))
        } else if (query1 == 1 & query2 != "html_book"){
          default = readRDS(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",  user, "/", project,"/contents/html_settings.RData"))
        }
        
        
        #default = readRDS(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",  user, "/", project,"/contents/html_settings.RData"))
        
        
        div(
          selectInput("body_font_family", "Body Font", 
                      c("'Georgia', serif", html_fonts), 
                      selected = trimws(default$body_font_family)
          ),
          colourpicker::colourInput("body_background", label = "Body Background Color", value = trimws(default$body_background)),
          colourpicker::colourInput("body_font_color", label = "Body Font Color", value = trimws(default$body_font_color)),
          colourpicker::colourInput("caption_color", label = "Caption Color", value = trimws(default$caption_color)),
          
          colourpicker::colourInput("toc_background_color", label = "TOC Background Color", value = trimws(default$toc_background_color)),
          
          colourpicker::colourInput("main_tab_toc_lin_grad_min", label = "Main Tab TOC Gradient Min", value = trimws(default$main_tab_toc_lin_grad_min)),
          colourpicker::colourInput("main_tab_toc_lin_grad_max", label = "Main Tab TOC Gradient Max", value = trimws(default$main_tab_toc_lin_grad_max)),
          
          colourpicker::colourInput("main_tab_toc_lin_grad_min_hilite", label = "Main Tab TOC Gradient Min Highlight", value = trimws(default$main_tab_toc_lin_grad_min_hilite)),
          colourpicker::colourInput("main_tab_toc_lin_grad_max_hilite", label = "Main Tab TOC Gradient Max Highlight", value = trimws(default$main_tab_toc_lin_grad_max_hilite)),
          
          colourpicker::colourInput("main_tab_toc_font_color", label = "Main Tab TOC Font Color", value = trimws(default$main_tab_toc_font_color)),
          sliderInput("toc_font_size", label = "TOC Font Size (REM)", min = 1, max = 5, step = 0.05, value = trimws(gsub("rem","",default$toc_font_size))),
          selectInput("toc_font_family", "TOC Font", 
                      c("'Georgia', serif", html_fonts), 
                      selected = trimws(default$toc_font_family)
          ),
          
          sliderInput("toc_border_bottom_thickness", label = "TOC Border Bottom Thickness (px)", min = 1, max = 5, step = 1, value = trimws(gsub("px","",default$toc_border_bottom_thickness))),
          colourpicker::colourInput("toc_border_bottom_color", label = "TOC Border Bottom Color", value = trimws(default$toc_border_bottom_color)),
          
          colourpicker::colourInput("toc_dropdown_background_color", label = "TOC Dropdown Background Color", value = trimws(default$toc_dropdown_background_color)),
          colourpicker::colourInput("toc_dropdown_border_color", label = "TOC Dropdown Border Color", value = trimws(default$toc_dropdown_border_color)),
          selectInput("toc_dropdown_border_ltyple", "TOC Dropdown Border Style", 
                      c("dotted", "solid", "dashed"), 
                      selected = trimws(default$toc_dropdown_border_ltyple)
          ),
          sliderInput("toc_dropdown_border_width", label = "TOC Dropdown Border Width (px)", min = 1, max = 5, step = 1, value = trimws(gsub("px","",default$toc_dropdown_border_width))),
          colourpicker::colourInput("toc_drop_down_hilite_color", label = "TOC Dropdown Highlight Color", value = trimws(default$toc_drop_down_hilite_color)),
          colourpicker::colourInput("toc_dropdown_background_font_color", label = "TOC Dropdown Background Font Color", value = trimws(default$toc_dropdown_background_font_color)),
          sliderInput("toc_dropdown_font_size", label = "TOC Dropdown Font Size (REM)", min = 1, max = 5, step = 0.05, value = trimws(gsub("rem","",default$toc_dropdown_font_size))),
          
          colourpicker::colourInput("toc_hover_arrow_color", label = "TOC Hover Arrow Color", value = trimws(default$toc_hover_arrow_color))
          
        )
      })
      
      
      
      
    } else {
      shinyalert("Please open or create a file first.")  
    }
  } else {
    shinyalert("Please open or create a file first.")
    
  }
  
})





observeEvent(input$update_layout_submit, {
  user = credentials()$info[["user"]]
  
  project = input$user_open_file_project_selected
  
  if (input$select_layout == "bs4_book"){
  
  settings = list()
  settings$select_layout = input$select_layout
  settings$toc_font_family = paste0(" ",input$toc_font_family)
  settings$toc_main_nav_color = paste0(" ",input$toc_main_nav_color)
  settings$toc_main_nav_chapters_color = paste0(" ",input$toc_main_nav_chapters_color)
  settings$toc_main_nav_chapters_font_size =paste0(" ",input$toc_main_nav_chapters_font_size,"rem") 
  settings$toc_chapter_uline_color =  paste0(" ",input$toc_chapter_uline_color)
  settings$toc_next_page_color = paste0(" ",input$toc_next_page_color)
  settings$toc_next_page_font_size = paste0(" ",input$toc_next_page_font_size,"rem")
  settings$toc_next_page_name_color = paste0(" ",input$toc_next_page_name_color)
  settings$toc_next_page_name_font_size=paste0(" ",input$toc_next_page_name_font_size,"rem")
  
  settings$body_font_family = paste0(" ",input$body_font_family)
  settings$body_font_color = paste0(" ",input$body_font_color)
  settings$caption_color = paste0(" ",input$caption_color)
  settings$body_background = paste0(" ",input$body_background)
  
  settings$replace_order = input$replace_order
  settings$remove_extra_col = input$remove_extra_col
  
  sqlite_dml("UPDATE projects SET type = 'bs4_book' WHERE project_name = ? AND username = ?", 
             params = list(project, user))
  
  sqlite_dml("UPDATE projects SET saved = 1 WHERE project_name = ? AND username = ?", 
             params = list(project, user))
  
  print (settings)
  }
  
  if (input$select_layout == "html_book"){
    
    settings = list()
    settings$select_layout = input$select_layout
    settings$body_font_family = paste0(" ", input$body_font_family)
    settings$body_background = paste0(" ", input$body_background)
    settings$body_font_color = paste0(" ", input$body_font_color)
    settings$caption_color = paste0(" ", input$caption_color)
    
    settings$toc_background_color = paste0(" ", input$toc_background_color)
    
    settings$main_tab_toc_lin_grad_min = paste0(" ", input$main_tab_toc_lin_grad_min)
    settings$main_tab_toc_lin_grad_max = paste0(" ", input$main_tab_toc_lin_grad_max)
    
    settings$main_tab_toc_lin_grad_min_hilite = paste0(" ", input$main_tab_toc_lin_grad_min_hilite)
    settings$main_tab_toc_lin_grad_max_hilite = paste0(" ", input$main_tab_toc_lin_grad_max_hilite)
    
    settings$main_tab_toc_font_color = paste0(" ", input$main_tab_toc_font_color)
    settings$toc_font_size = paste0(" ", input$toc_font_size, "rem")
    settings$toc_font_family = paste0(" ", input$toc_font_family)
    
    settings$toc_border_bottom_thickness = paste0(" ", input$toc_border_bottom_thickness, "px")
    settings$toc_border_bottom_color = paste0(" ", input$toc_border_bottom_color)
    
    settings$toc_dropdown_background_color = paste0(" ", input$toc_dropdown_background_color)
    settings$toc_dropdown_border_color = paste0(" ", input$toc_dropdown_border_color)
    settings$toc_dropdown_border_ltyple = paste0(" ", input$toc_dropdown_border_ltyple)
    settings$toc_dropdown_border_width = paste0(" ", input$toc_dropdown_border_width, "px")
    settings$toc_drop_down_hilite_color = paste0(" ", input$toc_drop_down_hilite_color)
    settings$toc_dropdown_background_font_color = paste0(" ", input$toc_dropdown_background_font_color)
    settings$toc_dropdown_font_size = paste0(" ", input$toc_dropdown_font_size, "rem")
    
    settings$toc_hover_arrow_color = paste0(" ", input$toc_hover_arrow_color)
    
    
    sqlite_dml("UPDATE projects SET type = 'html_book' WHERE project_name = ? AND username = ?", 
               params = list(project, user))
    
    sqlite_dml("UPDATE projects SET saved = 1 WHERE project_name = ? AND username = ?", 
               params = list(project, user))
    
    
  }
  
  saveRDS(settings, paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",  user, "/", project,"/contents/settings.RData"))
  
})




