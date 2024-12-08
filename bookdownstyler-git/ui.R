library("shiny.router")

#load all the UI components.
#https://stackoverflow.com/a/60036846
walk(list.files("ui_components", full.names = TRUE), ~ source(.x))
source(file.path(fileLoc_runApp, "bookdownstyler/functions/onclick_functions.R"), local = FALSE)$value # Load Libraries






# Define UI for application
shinyUI(tagList(
  useShinyjs(),
  #Uses a nav bar layout
  div(
  navbarPage(
    
    # add PHS logo to navigation bar 
    title = div(style = "position: center; 
                       top: -15px; 
                       margin-left: 10px; 
                       margin-top: 5px;",
                tags$span(HTML("BookdownStyler"), style="postion:center")
    ),
    
    
    # make navigation bar collapse on smaller screens
    windowTitle = "Bookdown Styler",
    collapsible = TRUE,
    
    header = tags$head(
      
      # sourcing css style sheet 
      #includeCSS("www/styles.css"),
      # we need to put the css in the www folder. https://stackoverflow.com/questions/75652365/how-to-style-a-shiny-app-with-css-file-base
      #tags$link(rel = "stylesheet", type = "text/css", href = "style/style1.css"),
      # include scotpho icon in web browser
      HTML("<html lang='en'>"),
      tags$link(rel = "shortcut icon", 
                href = "favicon_scotpho.ico"),
      tags$link(rel = "stylesheet", type = "text/css", href = "style/app_styles.css"),
      tags$script(src = "js/miscjsfuncs.js"),
      
      
      
      
      # include google analytics scripts
      #includeScript("google-analytics.js"), # GA 3 
      #HTML('<script async src="https://www.googletagmanager.com/gtag/js?id=G-KE1C59RLNS"></script>'),
      #includeScript("gtag.js") # GA 4 
      
      #https://stackoverflow.com/questions/44043475/adjust-size-of-shiny-progress-bar-and-center-it
      #solves shiny bar location
      tags$style(
        HTML(".shiny-notification {
              height: 100px;
              width: 800px;
              position:fixed;
              top: calc(80% - 50px);;
              left: calc(50% - 400px);;
            }
           "
        )
      )
      
    ),
    
    
    # order of tabs --------------------------------
    main_ui, # bookdownstyler/ui/ui_components/main_ui.R
    debug_tab_ui #only for debugging purposes in prodction. bookdownstyler/ui/ui_components/debug_tab_ui.R
    
    
  ))
  
  
) # close taglist
)

  