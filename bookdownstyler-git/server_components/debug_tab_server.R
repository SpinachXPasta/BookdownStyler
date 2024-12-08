
flatten_list <- function(x) {
  # Recursively flatten nested lists
  if (is.list(x)) {
    unlisted <- unlist(x, recursive = FALSE)
    if (all(sapply(unlisted, is.list))) {
      return(flatten_list(unlisted))
    }
  }
  
  # Convert elements to character strings
  return(as.character(x))
}



# Display the input values and id in debug tab.
AllInputs <- reactive({
  x <- reactiveValuesToList(input)
  data.frame(names = names(x),
             values = flatten_list(x))
})


output$debug_table <- renderTable({
  AllInputs()
})