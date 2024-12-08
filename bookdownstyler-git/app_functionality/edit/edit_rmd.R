#on add metadata
#when R\serverside_ui_render\generic_user_page_ui_serverside.R -> edit_rmd is triggered.
observeEvent(input$edit_rmd, {
  runjs("Shiny.setInputValue('rmd_files_table_2',document.getElementById('rmd_files_table').innerHTML )")
  #User must have file opened to access this.
  if (!is.null(input$user_open_file_project_selected)){
    if (input$user_open_file_project_selected != ""){
      showModal(modalDialog(id = "edit_rmd_modal",
                            fileInput("upload_rmd", NULL, buttonLabel = "Select FIles", multiple = TRUE, accept = ".rmd"),
                            uiOutput("edit_rmd_file_ui"),
                            footer=tagList(
                              actionButton('update_rmd_submit', 'Update'),
                              actionButton('upload_rmd_submit', 'Upload'),
                              modalButton('close')
                            )))
      
    } else {
      shinyalert("Please open or create a file first.")  
    }
  } else {
    shinyalert("Please open or create a file first.")
      
    }
  
  
  
})



#on submit from modal button of observeEvent(input$edit_rmd)
observeEvent(input$upload_rmd_submit, {
  
  runjs("Shiny.setInputValue('rmd_table_contents', document.getElementById('rmd_files_table').innerHTML)")
  
  user = credentials()$info[["user"]]

  project = input$user_open_file_project_selected
  
  uploaded = input$upload_rmd

   
  #see if any rmd files have been uploaded
  validation_query = sqlite_dql(paste0("SELECT * from CONTENTS where username = '",user,"' and project_name = '",project,"';"))
  
  #only if there are uploads availabe
  if (!is.null(uploaded)){
    if (nrow(uploaded) > 0){
      
      #if no files have been uploaded before to this project or there have been files uploaded but are not same as the ones already
      if (nrow(validation_query) == 0 | (nrow(validation_query) > 0 & (length(dplyr::intersect(uploaded$name, validation_query$filename)) == 0 ))){
        for (i in 1:nrow(uploaded)) {
          print (uploaded[i,])
          row = uploaded[i,]
          print (row)
          
          # Read the Rmd file as a binary object
          rmd_file_path <- row$datapath
          rmd_blob <- readBin(rmd_file_path, what = "raw", n = file.info(rmd_file_path)$size)
          
          rmd_blob <- list(rmd_blob)
          
          filename = row$name

          #insert the upload details into database.
          sqlite_dml("INSERT OR IGNORE INTO contents (filename, username, project_name, file)
                      VALUES (?,?,?,?)", params = list(filename, user, project,rmd_blob))
        }
        
        
        runjs("Shiny.setInputValue('upload_rmd', null)")
        
        
      } else if (length(dplyr::intersect(uploaded$name, validation_query$filename)) > 0) {
        
        #case when the file has already been uploaded
        shinyalert("File uploaded already exists, to upload please delete the same old file.", type = "error")
        runjs("Shiny.setInputValue('upload_rmd', null)")
          
         
        
      }
      
    } else {
      #send a message to user if no files are to be uploaded but uploaded button is pressed.
      shinyalert("No files to be uploaded")
    }
  
    
  }
  
  
  
  
  
  
})


#when update button is pressed.
#1. it should not upload any files qured for uploading.
#2. It should collect all the data that is in the UI and update the database accordingly.

observeEvent(input$update_rmd_submit,{
  
  #runjs("Shiny.setInputValue('rmd_table_contents', document.getElementById('rmd_files_table').innerHTML)")
  
 
  
  user = credentials()$info[["user"]]
  project = input$user_open_file_project_selected
  #see if any rmd files have been uploaded
  validation_query = sqlite_dql(paste0("SELECT * from CONTENTS where username = '",user,"' and project_name = '",project,"';"))
  
  if (nrow(validation_query) > 0 ){
    
    
    #rmd_tab = rvest::read_html(input$rmd_table_contents) %>% rvest::html_table(fill = TRUE)
    #print (rmd_tab)
    
    
    
    
    html <- rvest::read_html(input$rmd_table_contents)
    
    
    
    # Extract the table rows
    rows <- html %>% rvest::html_nodes("tr")
    
    # Initialize an empty list to store the data
    data <- list()
    
    # Loop through each row and extract the data
    for (i in 2:length(rows)) { # Skip the header row
      cells <- rows[i] %>% rvest::html_nodes("td")
      
      #print (cells)
      
      filename <- cells[1] %>% rvest::html_text(trim = TRUE)
      
      #runorder <- cells[2] %>% rvest::html_text(trim = TRUE)
      runorder <- cells[2] %>% rvest::html_node("input") %>% rvest::html_attr("value")
      
      indexpage <- cells[3] %>% rvest::html_node("input") %>% rvest::html_attr("value")
      #indexpage <- ifelse(is.na(indexpage), 0, 1)
      
      renderfile <- cells[4] %>% rvest::html_node("input") %>% rvest::html_attr("value")
      #renderfile <- ifelse(is.na(renderfile), 0, 1)
      
      deletefile <- cells[5] %>% rvest::html_node("input") %>% rvest::html_attr("value")
      #deletefile <- ifelse(is.na(deletefile), 0, 1)
      
      data[[i-1]] <- c(filename,runorder,indexpage,renderfile,deletefile)
      
      
    }
    
    
    # Convert the list to a data frame
    df <- do.call(rbind, data)
    colnames(df) <- c("filename", "run_order", "index_page","render_file","delete_file")
    df <- as.data.frame(df, stringsAsFactors = FALSE)
    
    # Convert Age to numeric
    df$run_order <- as.numeric(df$run_order)
    df$index_page <- as.numeric(df$index_page)
    df$render_file <- as.numeric(df$render_file)
    df$delete_file <- as.numeric(df$delete_file)
    
    
    # View the data frame
    #print(df)
    
   
    
    
    #bookdownstyler/functions/validate_update_contents.R
    action = validate_update_contents(validation_query,df, user=user, project=project)
    
    #print (action)
    
  }
  
})


#observes the rmd_trigger
observeEvent(input$rmd_trigger_1, {
  print ("triggered")
  runjs("Shiny.setInputValue('rmd_table_contents', document.getElementById('rmd_files_table').innerHTML)")
})






#every time the edit rmd button is either opened or updated, run this code to list all rmd files, if they exist (file > 0)
observeEvent(input$upload_rmd_submit | input$edit_rmd | input$update_rmd_trigger,{
  
  output$edit_rmd_file_ui <- renderUI({
    
    if (!is.null(input$user_open_file_project_selected)){
      if (input$user_open_file_project_selected != ""){
        
        print ("UI Rendered First")
        
          user = credentials()$info[["user"]]
          project = input$user_open_file_project_selected
          validation_query = sqlite_dql(paste0("SELECT * from CONTENTS where username = '",user,"' and project_name = '",project,"' ORDER BY run_order;"))
          if (nrow(validation_query) > 0){
           
            #every time, after (assumming after) the rendering below occurs, we want rmd_trigger_1 to initiate the observe event
            runjs("Shiny.setInputValue('rmd_trigger_1', 1, {priority: \"event\"}) ")
            
            out = "<div id = 'rmd_files_table'><table class = 'rmd-table' >
                      <thead>
                        <tr>
                          <th>File Name</th>
                          <th>Run Order</th>
                          <th>Index Page</th>
                          <th>render File</th>
                          <th>Delete File</th>
                        </tr>
                      </thead>
                      <tbody>
                      
                    
            "
            new_proj = FALSE
            if (sum(validation_query$render_file) == 0){
              new_proj = TRUE
            } 
            
            for (i in 1:nrow(validation_query)){
              row = validation_query[i,]
              print (row$index_page == 1)
              
              tr = paste0("<tr>",
                           "<td>",row$filename,"</td>")
              
              #the onChange function iside www/js/miscjsfunc handles the updates
              tr = paste0(tr,"<td><input type='text' maxlength = '3' style = 'width:25%;' value= ",row$run_order," onChange = triggerRMD(event,this) ></td>")
              
              
              if (row$index_page == 1){
                tr = paste0(tr,"<td><input type='checkbox' value = '1' onclick='updateCheckBox(this)' checked></td>")
              } else {
                tr = paste0(tr,"<td><input type='checkbox' value = '0' onclick='updateCheckBox(this)'></td>")
              }
              
              #if new project mark first 4 files for rendering
              if (new_proj){
                if (i <= 4){
                  tr = paste0(tr,"<td><input type='checkbox' value = '1' onclick='updateCheckBox(this)' checked></td>")
                } else {
                  tr = paste0(tr,"<td><input type='checkbox' value = '0' onclick='updateCheckBox(this)' ></td>")
                }
              } else {
                #only mark the files that have been selected before.
                if (row$render_file == 1){
                  tr = paste0(tr,"<td><input type='checkbox' value = '1' onclick='updateCheckBox(this)' checked></td>")
                } else {
                  tr = paste0(tr,"<td><input type='checkbox' value = '0' onclick='updateCheckBox(this)' ></td>")
                }
                
              }
              
              
              tr = paste0(tr,"<td><input type='checkbox' value = '0' onclick='updateCheckBox(this)'></td> </tr>")
              
              
              out = paste0(out,tr)
              
            }
            
            
            out = paste0(out,"</tbody></table></div>")
            HTML(out)
            
          }
      }
    }
    
  })
 
  
})










