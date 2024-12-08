
#This is an unimportant out that prints the user role in the app html.
output$sidebarpanel <- renderUI({
  
  # Show only when authenticated
  req(credentials()$user_auth)
  
  tagList(
  
    column(width = 4,
           p(paste("You have", credentials()$info[["permissions"]],"permission"))
    )
  )
  
})

# Login UI / switch between admin and user UI.
# called palceholder, can be switched to a more sophisticated name later.
output$placeholder_1 <- renderUI({
  
  # Show plot only when authenticated
  req(credentials()$user_auth)
  
  
  
  
  div(
    
    # There are two output types below, or the other will be displayed
    # based on the user's role
    div(id = "admin_ui_div",
          uiOutput("admin_ui")
        ),

     #generic page ui can be found in    R\serverside_ui_render\generic_user_page_ui_serverside.R    
     div(id = "general_user_div",
          uiOutput("generic_page")
              
        )
    
      
    )
  
})


#renders the admin page
output$admin_ui <- renderUI({
  req(credentials()$user_auth)
  #require admin role.
  req(credentials()$info[["permissions"]] == "admin")
  
  fluidRow(
    div(id = "user_table_admin",
        dataTableOutput("user_table"))
  )
  
  
  
})







# The UI once user is logged in.
output$main_sub_ui_1 <- renderUI({
  
  #Once signed in update tab
  req(credentials()$user_auth)
  runjs('document.getElementById("main_tab_text").innerText = "Main Tab";');
  runjs('document.getElementById("main_tab_icon").classList.remove("fa-solid", "fa-arrow-right-to-bracket");');
  runjs('document.getElementById("main_tab_icon").classList.add("fa", "fa-file");');
  
  div(
  # Sidebar to show user info after login
  #uiOutput("sidebarpanel"),
  
  # Plot to show user info after login
  uiOutput("placeholder_1")#,
  )
})



# Run custom code on logout
observeEvent(logout_init(), {
  if (!credentials()$user_auth) {
    #close files before logout
    start_edit(FALSE)
    
    # Your custom code here
    runjs('document.getElementById("main_tab_text").innerText = "Login";');
    runjs('document.getElementById("main_tab_icon").classList.remove("fa", "fa-file");');
    runjs('document.getElementById("main_tab_icon").classList.add("fa-solid", "fa-arrow-right-to-bracket");');
    
    
    #referesh the page so any database updates are reflected.
    runjs("window.location.reload()") 
    print("User has logged out")
  }
})







