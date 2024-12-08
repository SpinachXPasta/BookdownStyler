is_continuous_from_one <- function(vec) {
 
  #case for where there is only 1 file
  if (length(vec) == 1 && vec == 1){
    return(TRUE)
  }
  
  # Check if the vector starts from 1
  if (vec[1] != 1) {
    return(FALSE)
  }
  
  # Check if the vector is continuous
  for (i in 2:length(vec)) {
    if (vec[i] != vec[i-1] + 1) {
      return(FALSE)
    }
  }
  
  return(TRUE)
}






validate_update_contents <- function(odf,ndf, user,project){
  
  print ("****************************************************")
  print (Sys.time())
  print (odf)
  print (ndf)
  print ("****************************************************")
  if (sum(ndf$index_page) != 1){
    shinyalert("There needs to be one 1 index page, it can't be 0 or > 1", type = "error")
    return (FALSE)
  }
  
  
  if (nrow(ndf %>% filter(index_page == 1 & delete_file == 1)) != 0){
    shinyalert("Index page cannot be deleted", type = "error")
    return (FALSE)
  }
  
  print ("Step1")
  
  #query = ndf %>% filter(delete_file != 1)
  if (!is_continuous_from_one(sort(ndf$run_order))){
    shinyalert("Run order needs to continuous and start from 1 for files not deleted. Consider deleting the files before reordering. ", type = "error")
    return (FALSE)
  }
  print ("Step2")
  
  if (nrow(ndf %>% filter(index_page == 1 & render_file)) != 1){
    shinyalert("Index page must be rendered", type = "error")
    return (FALSE)
  }
  
  
  if (sum(ndf$render_file) > 4){
    shinyalert("Only upto 4 files can be rendered for preview", type = "error")
    return (FALSE)
  }
  
  print ("No issues with data entered")
  
  #set the index page
  query1 = ndf %>% filter(index_page == 1)
  query2 = odf %>% filter(index_page == 1)
  print ("query1 and query 2 rand succesfully")
  
  
  #if no index page has been set
  if (nrow(query2) == 0){
  sqlite_dml("UPDATE contents SET index_page = 1 WHERE filename = ? AND project_name = ? AND username = ?", 
             params = list(query1$filename, project, user))
    
    if (query1$run_order != 1){
      
      
      sqlite_dml("UPDATE contents SET run_order = 1 WHERE filename = ? AND project_name = ? AND username = ?", 
                 params = list(query1$filename, project, user))
      
      #get the files that are not index
      changed_order = ndf %>% filter(filename != query1$filename)
      
      #print ("Step 2")
      
      #if there are any remaining
      if (nrow(changed_order) > 0) {
        #change the order from 2 to n
        #we can do this because as index operations are the first, we will be dealing with a refreshed database with initialized run_orders
        
        
        #print ("Step 3")
        changed_order$run_order = 2:(nrow(changed_order)+1)
        
        #print ("Step 4")
        for (i0 in  1:nrow(changed_order)){
          f = changed_order[i0,]
          sqlite_dml("UPDATE contents SET run_order = ? WHERE filename = ? AND project_name = ? AND username = ?", 
                     params = list(f$run_order,f$filename, project, user))
          
        }
        
        
        
      }
      
    }
    
    
  } else {
  
    #if the index is changed
    if (query1$filename != query2$filename){
      
      #print ("Step 1")
      sqlite_dml("UPDATE contents SET index_page = 1 WHERE filename = ? AND project_name = ? AND username = ?", 
                 params = list(query1$filename, project, user))
      
      
      sqlite_dml("UPDATE contents SET index_page = 0 WHERE filename = ? AND project_name = ? AND username = ?", 
                 params = list(query2$filename, project, user))
      
      #set the run order to 1 for the new index
      sqlite_dml("UPDATE contents SET run_order = 1 WHERE filename = ? AND project_name = ? AND username = ?", 
                 params = list(query1$filename, project, user))
      
      #get the files that are not index
      changed_order = ndf %>% filter(filename != query1$filename)
      
      #print ("Step 2")
      
      #if there are any remaining
      if (nrow(changed_order) > 0) {
        #change the order from 2 to n
        #we can do this because as index operations are the first, we will be dealing with a refreshed database with initialized run_orders
        
        
        #print ("Step 3")
        changed_order$run_order = 2:(nrow(changed_order)+1)
        
        #print ("Step 4")
        for (i0 in  1:nrow(changed_order)){
          f = changed_order[i0,]
          sqlite_dml("UPDATE contents SET run_order = ? WHERE filename = ? AND project_name = ? AND username = ?", 
                     params = list(f$run_order,f$filename, project, user))
          
        }
        
        
        
      }
      
    }
    
  }
  
  
  #next choose the files that need to be rendered
  
    q1 = ndf %>% select(c(filename, render_file))
    q2 = odf %>% select(c(filename, render_file))
    
    qx = isTRUE(all.equal(q1,q2))
    if (qx != TRUE){
      for (i0 in  1:nrow(ndf)){
        f = ndf[i0,]
        sqlite_dml("UPDATE contents SET render_file = ? WHERE filename = ? AND project_name = ? AND username = ?", 
                   params = list(f$render_file,f$filename, project, user))
        
      }
      
    }
    
    
    
    q1 = ndf %>% select(c(filename, run_order))
    q2 = odf %>% select(c(filename, run_order))
    
    
    end_warn = FALSE
    
    if (nrow(ndf %>% filter(run_order == 1 & index_page == 1)) == 1){
    
      qx = isTRUE(all.equal(q1,q2))
      if (qx != TRUE){
        for (i0 in  1:nrow(ndf)){
          f = ndf[i0,]
          sqlite_dml("UPDATE contents SET run_order = ? WHERE filename = ? AND project_name = ? AND username = ?", 
                     params = list(f$run_order,f$filename, project, user))
          
        }
        
      }
    } else {
      end_warn = TRUE
    }
    
  
  
  
  
  # if there are files to be deleted
  if (sum(ndf$delete_file)>0){
    #delete those files
    delete_list <- ndf %>% filter(delete_file == 1)
    for (f in delete_list$filename){
      del_df <- ndf %>% filter(filename == f)
      
      sqlite_dml("DELETE FROM contents WHERE filename = ? AND project_name = ? AND username = ?", 
                 params = list(del_df$filename, project, user))
      
      
    }
    
    #reorder the run order after delete
    #get the files that have not been deleted
    query = ndf %>% filter(delete_file != 1)
    #remove those files from the old project files
    remaining = odf %>% filter(filename %in% query$filename)
    if (nrow(remaining) > 0){
      
      remaining = remaining %>% arrange(run_order)
      remaining$run_order = (1:nrow(remaining))
      
      #using the old files and the new run_order update it in the database
      for (i0 in  1:nrow(remaining)){
        f = remaining[i0,]
        sqlite_dml("UPDATE contents SET run_order = ? WHERE filename = ? AND project_name = ? AND username = ?", 
                   params = list(f$run_order,f$filename, project, user))
        
      }
      
      
      
    }
    
    
    
    
    #after delete update run order
    
    
  }
    
    
  if (end_warn){
    shinyalert("Change of run order given has been skipped, due to index not having run order 1. Run order is determined by previous state and index page. ")
  }  
  
  
  runjs("Shiny.setInputValue('update_rmd_trigger', 1, {priority: \"event\"});")
  
  
  
  
  
}