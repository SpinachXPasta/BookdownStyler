

# When register is triggered in the login page, display the modal.
observeEvent(input$register_button_trigger, {
  # display a modal dialog with a header, textinput and action buttons
  showModal(modalDialog(id = "registration_modal",
    tags$h2('Please enter your information'),
    textInput('registration_modal_username', 'Username'),
    passwordInput('registration_modal_password', 'Password'),
    passwordInput('registration_modal_password_2', 'Retype Password'),
    footer=tagList(
      actionButton('user_registration_submit', 'Submit'),
      modalButton('cancel')
    )
  ))
})


#after the modal is opened, when the user hits submit.
observeEvent(input$user_registration_submit,{
  
  uname = 0
  p1 = 0
  p2 = 0
  reg = 0
  
  #reset the labels for the input
  runjs('document.getElementById("registration_modal_username-label").innerHTML = "Username";')
  runjs('document.getElementById("registration_modal_password-label").innerHTML = "Password";');
  
  
  # if registered username is blank, send HTML messege
  if (input$registration_modal_username == ""){
    print ("Registration is null")
    runjs('document.getElementById("registration_modal_username-label").innerHTML = "Username <span style=\'color: red;\'>cannot be empty</span>";');
    uname = 1
  }
  
  # If either pw1 or pw2 is wrong
  if ( input$registration_modal_password == "" | input$registration_modal_password_2 == ""){
    print ("Registration is null")
    runjs('document.getElementById("registration_modal_password-label").innerHTML = "Password <span style=\'color: red;\'>cannot be empty</span>";');
    p1 = 1
    p2 = 1
  }
  
  
  # if pw dont match
  if ( (input$registration_modal_password != "" & input$registration_modal_password_2 != "") &
       (input$registration_modal_password != input$registration_modal_password_2)
       
       ){
    print ("Registration is null")
    runjs('document.getElementById("registration_modal_password-label").innerHTML = "Password <span style=\'color: red;\'>need to macth</span>";');
    p1 = 1
    p2 = 1
  }
  
  
  # if info is valid
  if (uname + p1 + p2 == 0){
    #check all the existing users & specific user.
    db_query_registration_1 = sqlite_dql("SELECT * FROM users")
    db_query_registration_2 = sqlite_dql(paste0("SELECT * FROM users WHERE username = '",input$registration_modal_username,"'"))
    
    
    
    if (nrow(db_query_registration_1) == 0 | nrow(db_query_registration_2) == 0){
      #enter new data into DB
      sqlite_dml(
        paste0("INSERT INtO users VALUES ('",input$registration_modal_username,"','",input$registration_modal_password,"','user')")
      )
    } else {
      #case user alreay eixsts
      runjs('document.getElementById("registration_modal_username-label").innerHTML = "Username <span style=\'color: red;\'>already exists</span>";');
      reg = 1
    }
    
    
    #print ("Looks good")
  }
  
  
  if (sum(uname,p1,p2,reg) == 0){
    #Success & refresh page, include green check marks.
    runjs('document.getElementById("registration_modal_username-label").innerHTML = "Username <span style=\'color: green;\'>&#x2705;</span>";');
    runjs('document.getElementById("registration_modal_password-label").innerHTML = "Password <span style=\'color: green;\'>&#x2705;</span>";');
    runjs('document.getElementById("registration_modal_password_2-label").innerHTML = "Password <span style=\'color: green;\'>&#x2705;</span>";');
    Sys.sleep(1.2)
    removeModal()
    runjs("window.location.reload()")
  }
  
  
  
})