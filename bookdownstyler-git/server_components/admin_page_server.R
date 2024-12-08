##admin

#when admin is logged in display table with all users.
output$user_table <- renderDataTable({
  
  req(credentials()$user_auth)
  #require admin role.
  req(credentials()$info[["permissions"]] == "admin")
  
  users = sqlite_dql("SELECT * FROM users")
  
  # add a modify and delete button to the table.
  #the buttons withh have userid + buttonid, and a generic trigger ID i.e admin_modify_trigger/admin_delete_trigger
  users["modify"] = paste0("<button id = ",users$username,"_modify class='shiny-bound-input action-button'",onclick_to_event_id("admin_modify_trigger"),", style = 'font-weight: 700; cursor: pointer;'>Modify</button>") #when the modify button is triggered the button id is assigned to the value of trigger
  users["delete"] = paste0("<button id = ",users$username,"_delete class='shiny-bound-input action-button'",onclick_to_event_id("admin_delete_trigger"),", style = 'font-weight: 700; cursor: pointer;'>Delete</button>") 
  
  #admins can't be deleted.
  users  = users %>%
    mutate(delete = if_else(role == "admin", "", delete))
  
  #https://stackoverflow.com/questions/62794827/r-shiny-run-js-after-htmlwidget-renders
  data.table::data.table(users)
  
  
},escape = FALSE,  options = list(dom = 't', ordering=FALSE),
class = list(stripe = FALSE), colnames = c("User Name", "Password", "Role", "",""), selection = "none")


#case when generic modify button is triggered
observeEvent(input$admin_modify_trigger, {
  
  
  
  #show which button triggered modal
  #req(input$admin_modify_trigger
  #this apoints the value of the button that triggered the event)
  x = input$admin_modify_trigger 
  
  
  user = sqlite_dql(paste0("SELECT * FROM users where username = '",str_split(x, "_modify")[[1]][1],"'"))
  
  print (user)
  
  #create a shiny input value called admin_modify_selected_username and assign it the username which should be modified.
  # this value will be utilized in admin_modify_submit
  runjs(paste0("Shiny.setInputValue('admin_modify_selected_username','",user$username,"')"))
  
  
  #shows the modal for input, it has a generic submit button.
  showModal(modalDialog(id = paste0("admin_modify_modal","_",str_split(x, "_modify")[[1]][1]),
                        HTML(paste0("<span User style = 'font-weight:700;color:blue;'>","User: ", user$username, "</span></br></br>")),
                        textInput('admin_modify_modal_password', 'Password', value = user$password),
                        footer=tagList(
                          actionButton('admin_modify_submit', 'Submit'),
                          modalButton('cancel')
                        )
  ))
})



# The following scenario is when the delete button is triggered.
observeEvent(input$admin_delete_trigger, {
  
  #create id's for rows
  # index 1 is the which holds the username
  runjs("document.querySelectorAll('#user_table_admin table tbody tr').forEach(row => {
               const secondTdText = row.querySelectorAll('td')[1].textContent;
               row.id = secondTdText + '_row_id';
             });")
  
  #show which button triggered modal
  #req(input$admin_modify_trigger)
  x = input$admin_delete_trigger #this apoints the value of the button that triggered the event
  
  #get the username
  user_0 = str_split(x, "_delete")[[1]][1]
  
  #delete from DB
  sqlite_dml(paste0("DELETE FROM users WHERE username =  '",user_0,"'"))
  
  #remove the row from the table
  removeUI(paste0("#",user_0,"_row_id"))
  
  print (paste0(user_0, " has been delated."))
  
  
})




#when the admin modifies password etc.
observeEvent(input$admin_modify_submit,{
  

  p1 = 0
  reg = 0
  

  #default label for password
  runjs('document.getElementById("admin_modify_modal_password-label").innerHTML = "Password";');
  
  #validation check for PW with HTML feedback.
  if ( input$admin_modify_modal_password == ""){
    print ("Registration is null")
    runjs('document.getElementById("admin_modify_modal_password-label").innerHTML = "Password <span style=\'color: red;\'>cannot be empty</span>";');
    p1 = 1
  }
  
  

  
  if (p1 == 0){
    #
    #
    
    runjs(paste0("
    
          // Select the first element with an ID that starts with admin_modify_modal
          const firstnode = document.querySelector('[id^=\"admin_modify_modal\"]');
          
          // Extract the username part from the ID of the selected element
          const username_admin_mod = firstnode.id.split(\"admin_modify_modal_\")[1]
          
          // Iterate over each row in the user table
          document.querySelectorAll('#user_table_admin table tbody tr').forEach(row => {
          
               // Get the text content of the second cell (td) in the row
               const secondTdText = row.querySelectorAll('td')[1].textContent;
               
               // Set the ID of the row to the text content of the second cell followed by row_id
               row.id = secondTdText + '_row_id';
               
             });
             
          // Create the ID for the row corresponding to the extracted username             
          const row_username_id = username_admin_mod +'_row_id';
          
          // Select all rows with the created ID
          document.querySelectorAll(`#${row_username_id}`).forEach(row => {
          
              // Set the text content of the third cell (td) in the row to the new password
               row.querySelectorAll('td')[2].innerText = '",input$admin_modify_modal_password,"';
             });
          
          "))
    
    #update the password
    sqlite_dml(paste0("UPDATE users
        SET password = '",input$admin_modify_modal_password,"'
        WHERE username = '",input$admin_modify_selected_username,"';
                      "))
    
    removeModal()
    
  }
  
  
  
})






##