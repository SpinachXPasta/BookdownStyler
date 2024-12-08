#Function to intialize the database.
init_db <- function(){
  #Initialize the users table
  conn <- dbConnect(RSQLite::SQLite(), paste0(fileLoc_runApp,"/bookdownstyler/db/app.db"))
  
  
  print ("Databse Initialized")
  print ("users tables initialized")
  
  # Set the encryption key
  dbExecute(conn, "PRAGMA key = 'defenceoftheancients';")
  
  #create the users schema if not already created.
  dbExecute(conn, "
    CREATE TABLE IF NOT EXISTS users (
    username TEXT NOT NULL PRIMARY KEY,
    password TEXT NOT NULL,
    role TEXT NOT NULL CHECK(role IN ('admin', 'user'))
    );
  ")
  
  #create the manager user and test user, if they don't exists when starting the app.
  dbExecute(conn, "
    INSERT OR IGNORE INTO users (username, password, role)
    VALUES 
        ('shiny_manager', 'apple', 'admin'),
        ('test_user_1', 'apple', 'user');
")
  
  #disconnect app
  dbDisconnect(conn)
}


#This function returns SQL query as a table. Input is a SQL query string
sqlite_dql  <- function(dql){
  #Initialize the users table
  conn <- dbConnect(RSQLite::SQLite(), paste0(fileLoc_runApp,"/bookdownstyler/db/app.db"))
  
  # Set the encryption key
  dbExecute(conn, "PRAGMA key = 'defenceoftheancients';")
  
  result = dbGetQuery(conn, dql)
  
  dbDisconnect(conn)
  
  return (result)
}





#This function is to define schemas, input is a SQL command string
sqlite_ddl <- function(ddl,params=NULL){
  #Initialize the users table
  conn <- dbConnect(RSQLite::SQLite(), paste0(fileLoc_runApp,"/bookdownstyler/db/app.db"))
  
  # Set the encryption key
  dbExecute(conn, "PRAGMA key = 'defenceoftheancients';")
  
  dbExecute(conn, ddl, params=params)
  
  
  dbDisconnect(conn)
}


#This functions modifies a table, takes in a SQL command string.
sqlite_dml <- function(dml,params=NULL){
  #Initialize the users table
  conn <- dbConnect(RSQLite::SQLite(), paste0(fileLoc_runApp,"/bookdownstyler/db/app.db"))
  
  # Set the encryption key
  dbExecute(conn, "PRAGMA key = 'defenceoftheancients';")
  
  dbExecute(conn, dml, params=params)
  
  
  dbDisconnect(conn)
}


#This function will return a dataframe of active users, password and role.
create_user_base <- function(){
  
  
  conn <- dbConnect(RSQLite::SQLite(), paste0(fileLoc_runApp,"/bookdownstyler/db/app.db"))
  
  # Set the encryption key
  dbExecute(conn, "PRAGMA key = 'defenceoftheancients';")
  
  result = dbGetQuery(conn, "SELECT * FROM users")
  
  
  dbDisconnect(conn)
  
  
  
  user_base <- tibble::tibble(
    user = result$username,
    password = sapply(result$password, sodium::password_store),
    permissions = result$role
  )
  
  
  return (user_base)
  
  
}






#Function to intialize the database.
init_project_db <- function(){
  
  #Initialize the users table
  conn <- dbConnect(RSQLite::SQLite(), paste0(fileLoc_runApp,"/bookdownstyler/db/app.db"))
  
  
  print ("Project tables Initialized")
  
  # Set the encryption key
  dbExecute(conn, "PRAGMA key = 'defenceoftheancients';")
  
  #create the users schema if not already created.
  dbExecute(conn, "
    CREATE TABLE IF NOT EXISTS projects (
    username TEXT NOT NULL,
    project_name TEXT NOT NULL,
    project_location TEXT NOT NULL,
    create_date DATETIME,
    modify_date DATETIME,
    rendered INTEGER default 0,
    saved INTEGER default 0,
    type TEXT default 'bs4_book',
    PRIMARY KEY (username, project_name),
    FOREIGN KEY (username) REFERENCES users(username)
    );
  ")

  
  #disconnect app
  dbDisconnect(conn)
  
}



#Function to intialize the database.
init_project_content_db <- function(){
  
  #Initialize the users table
  conn <- dbConnect(RSQLite::SQLite(), paste0(fileLoc_runApp,"/bookdownstyler/db/app.db"))
  
  
  print ("Contents tables Initialized")
  
  # Set the encryption key
  dbExecute(conn, "PRAGMA key = 'defenceoftheancients';")
  
  #create the users schema if not already created.
  dbExecute(conn, "
    CREATE TABLE IF NOT EXISTS contents (
    filename TEXT NOT NULL,
    username TEXT NOT NULL,
    project_name TEXT NOT NULL,
    index_page INTEGER default 0,
    render_file INTEGER default 0,
    delete_file INTEGER default 0,
    file BLOB not null,
    run_order INTEGER,
    PRIMARY KEY (username, project_name, filename),
    FOREIGN KEY (username) REFERENCES users(username),
    FOREIGN KEY (project_name) REFERENCES projects(project_name)
    );
  ")
  
  
  #auto-increment on run_order
  dbExecute(conn, "
    CREATE TRIGGER IF NOT EXISTS increment_run_order
    AFTER INSERT ON contents
    FOR EACH ROW
    WHEN NEW.run_order IS NULL
    BEGIN
        UPDATE contents
        SET run_order = (
            SELECT IFNULL(MAX(run_order), 0) + 1
            FROM contents
            WHERE username = NEW.username AND project_name = NEW.project_name
        )
        WHERE rowid = NEW.rowid;
    END;
")
  
  
  
  
  
  #disconnect app
  dbDisconnect(conn)
  
}







