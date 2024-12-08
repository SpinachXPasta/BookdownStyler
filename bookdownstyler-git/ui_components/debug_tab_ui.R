#This is the panel layout for the debug tab.
debug_tab_ui = tabPanel(
  div(
    div(class="fa fa-file", role = "navigation"), "Debug Tab"),
  value = "diff",
  
  div(id = "debug_panel",
      fluidPage(
        uiOutput("debug_table")
        
      )
      
  )
  
  
  
)