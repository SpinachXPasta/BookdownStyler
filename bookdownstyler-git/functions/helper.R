string_to_key_value_pairs <- function(input) {
  # Split the input string by new lines
  lines <- strsplit(input, "\n")[[1]]
  
  # Initialize an empty list to store key-value pairs
  key_value_pairs <- list()
  
  # Loop through each line
  for (line in lines) {
    # Split each line by the colon
    parts <- strsplit(line, ":")[[1]]
    
    # Check if the split resulted in exactly two parts
    if (length(parts) == 2) {
      key <- trimws(parts[1])
      value <- trimws(parts[2])
      key_value_pairs[[key]] <- value
    }
  }
  
  return(key_value_pairs)
}