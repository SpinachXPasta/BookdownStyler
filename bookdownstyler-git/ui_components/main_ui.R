source(file.path(fileLoc_runApp, "bookdownstyler/functions/onclick_functions.R"), local = FALSE)$value # Load Libraries

# This is the layout for the main app once logged in, which is in a tab panel format.
main_ui <- tabPanel(
  div(
    div(id = "main_tab_icon", role = "navigation", class = "fa-solid fa-arrow-right-to-bracket"), tags$span("Login", id = "main_tab_text"), id = "main_tab"),
  value = "main",
  
  div(id = "main_panel",
      fluidPage(
        # logout button
        fluidRow(id ="logout_button_row",class = "pull-right", shinyauthr::logoutUI(id = "logout")),
        
        # login section
        shinyauthr::loginUI(
          id = "login", additional_ui = div(style = "text-align: center;padding-top: 10px;", HTML(text = paste0("<p id ='",paste0("register_button"),
                                                                                                                "'",onclick_to_event_id("register_button_trigger"),", style = 'font-weight: 700; cursor: pointer;'>Register</p>"))
          ) 
        ),
        
        
        uiOutput("main_sub_ui_1"),
        
        
        #router_ui(
        #  route("/", home_page),
        #  route("Registration", Registration_page))
        
      ))
  )
