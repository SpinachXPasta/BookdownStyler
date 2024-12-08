#The purpose of this function is to return an onclick function that assigns the shiny ID with the id that triggered it.
# For example multiple buttons can trigger the same shiny input, but it is not known which button triggered it, this function
# assignes the value to the input so we can use that infromtation.
#the priority event means the function will be treated as an event
onclick_to_event_id <- function(trigger_id) {
  return(paste0("onClick = '((ev) => {
  
                Shiny.setInputValue(\"", trigger_id  ,"\", ev.target.id, {priority: \"event\"});
            
            
            })(event)'"))
}


#two of these are required to create a button that increases in count each time.
onclick_inc_for_tags <- function(trigger_id) {
  return(paste0("globalThis.",trigger_id,"_count ++;Shiny.setInputValue(\"", trigger_id  ,"\", globalThis.",trigger_id,"_count, {priority: \"event\"});"))
}

#this creates a global window variable.
create_global_this <- function(trigger_id) {
  return(paste0("globalThis.",trigger_id,"_count = 0;"))
}