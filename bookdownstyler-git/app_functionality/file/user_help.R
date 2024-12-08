observeEvent(input$user_help,{
  showModal(modalDialog(id = "render_error_modal",
                        includeHTML(paste0(fileLoc_runApp, "/bookdownstyler/HTML/templates/user_help.html")),
                        footer=tagList(
                          modalButton('cancel')
                        )))
})