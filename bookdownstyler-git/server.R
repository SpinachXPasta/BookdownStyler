


shinyServer(function(input, output,session) {
  
  
  
  
  #creates a list of values that can store values in the server.
  working_mem = reactiveValues()
  
  source(file.path("server_components/debug_tab_server.R"), local = TRUE)$value # debug tab
  source(file.path("server_components/registration_modal_server.R"), local = TRUE)$value # registration modal tab
  source(file.path("server_components/admin_page_server.R"), local = TRUE)$value
  source(file.path("server_components/generic_user_page_server.R"), local = TRUE)$value
  
  
  #UI components rendered from serverside
  source(file.path("serverside_ui_render/generic_user_page_ui_serverside.R"), local = TRUE)$value
  source(file.path("serverside_ui_render/rmd_dev_ui_serverside.R"), local = TRUE)$value
  
  
  #load app functionality
  source(file.path("app_functionality/file/new_file.R"), local = TRUE)$value
  source(file.path("app_functionality/file/open_file.R"), local = TRUE)$value
  source(file.path("app_functionality/file/download_file.R"), local = TRUE)$value
  source(file.path("app_functionality/file/user_help.R"), local = TRUE)$value
  source(file.path("app_functionality/file/close_file.R"), local = TRUE)$value
  source(file.path("app_functionality/edit/edit_file.R"), local = TRUE)$value
  source(file.path("app_functionality/edit/edit_rmd.R"), local = TRUE)$value
  source(file.path("app_functionality/edit/edit_layout.R"), local = TRUE)$value
  source(file.path("app_functionality/run/render.R"), local = TRUE)$value
  
  
  
  #process inititializes database. source #bookdownstyler/functions/db_functions
  init_db()
  #create the projects table
  init_project_db()
  
  #create the contents database
  init_project_content_db()
  
  #create datframe with user info, source #bookdownstyler/functions/db_functions
  user_base <- create_user_base()


  
  #creates an authorization method using the user_base dataframe.
  credentials <- shinyauthr::loginServer(
    id = "login",
    data = user_base,
    user_col = user,
    pwd_col = password,
    sodium_hashed = TRUE,
    log_out = reactive(logout_init())
  )
  
  # Logout to hide
  logout_init <- shinyauthr::logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth)
  )
  
  
  #load the server component of the main page.
  source(file.path("server_components/main_server.R"), local = TRUE)$value # main page
  
  
  
  
  
  
})