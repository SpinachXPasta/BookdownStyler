
open_file_html_table <- function(){

#output$user_open_table <- renderDataTable({
#  user = credentials()$info[["user"]]
#  query = paste0("SELECT * from projects where username = '", user,"';")
#  #print (query)
#  file_table = sqlite_dql(query)
#  file_table = file_table %>% select(-c(project_location,username))
#  #print (file_table)
#  data.table::data.table(file_table)
#  
#},escape = FALSE,  options = list(dom = 't', ordering=FALSE),
#class = list(stripe = FALSE), selection = "none",colnames = c("Project Name","Creation Date", "Modification Date"))


# Associated with output$conditional_open_ui from  R\serverside_ui_render\generic_user_page_ui_serverside.R
#  Generates a list of projects for the user
output$user_open_table <- renderUI({
  
  user = credentials()$info[["user"]]
  query = paste0("SELECT * from projects where username = '", user,"';")
  file_table = sqlite_dql(query)
  file_table = file_table %>% select(-c(project_location,username))
  
  

  
  
  #creates a table of projects that can be selected. 
  # the  highlightRow(this) function can be found in R\www\js\miscjsfuncs.js
  # The function is loaded in ui.R
  #this refers to the HTML tags selected by the user which contains details on the project.
  output = "<table>
              <thead>
                  <tr>
                    <td>Project Name</td>
                    <td>Create Date</td>
                    <td>Modification Date</td>
                  </tr>
              </thead>
              <tbody>
  "
  
  for (row in 1:nrow(file_table)){
    new_html = paste0("<tr onClick ='highlightRow(this)' >",
                      "<td>",file_table$project_name[row],"</td>",
                      "<td>",file_table$create_date[row],"</td>",
                      "<td>",file_table$modify_date[row],"</td>",
                      "</tr>")
    output = paste0(output,new_html)
    
    
  }
  
  output = paste0(output,"</tbody>")
  HTML(output)
  
  
}
  
)

}