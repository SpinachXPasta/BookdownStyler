








run_render <- function(loc0,user,project,contents_loc){
  
  progMsg = ifelse(contents_loc == "preview_contents","partial render", "full render")
  
  withProgress(message = paste0('Rendering PRM file for',progMsg),
               detail = 'This may take a while...', value = 0, {

  settings = readRDS(paste0(fileLoc_runApp,"/bookdownstyler/db/userfiles/",  user, "/", project,"/contents/settings.RData"))
  
  
  location = paste0(loc0,"/bookdownstyler/db/userfiles/",user,"/",project)


  yaml = stringr::str_split('--- 
  title: "A Minimal Book Example"
  author: "Author Name"
  date: "`r Sys.Date()`"
  site: bookdown::bookdown_site
  documentclass: book
  bibliography: [../content/book.bib, ../content/packages.bib]
  biblio-style: apalike
  link-citations: yes
  github-repo: rstudio/bookdown-demo
  description: "This is a minimal example of using the bookdown package to write a book. The output format for this example is bookdown::html_book."
  ---','\n')[[1]]
  
  
  
  
  bib = stringr::str_split('```{r chunk2, include=FALSE} 
  # automatically create a bib database for R packages
knitr::write_bib(c(
  .packages(), "bookdown", "knitr", "rmarkdown"
), "../content/../content/../content/../content/../content/../content/../content/../content/../content/../content/packages.bib")
  ```','\n')[[1]]
  
  
  #applies css
  out_dir = paste0(location,'/',contents_loc,'/output/_book')
  
  applycss = TRUE
  
  #<option>
  #fmt = 'html_book'
  fmt = settings$select_layout#'bs4_book'
  
  
  #<selectable>
  toc_style = ifelse(fmt == 'bs4_book', "sidepanel", "tabpanel")
  
  
  toc_template = ifelse(fmt == 'bs4_book',paste0(location,'/style/side-panel-toc.css'), paste0(location, '/style/tabpanel-toc.css'))
  body_template = ifelse(fmt == 'bs4_book', paste0(location,'/style/basic-body-bs4.css'), paste0(location,'/style/basic-body.css') )
  
  
  
  #toc_template = '../style/tabpanel-toc.css'
  #toc_template = '../style/side-panel-toc.css'
  #toc_template = '../style/side-panel-media-query.css'
  
  
  file.copy(toc_template, paste0(location,'/style/toc.css'), overwrite = TRUE)
  file.copy(body_template, paste0(location,'/style/body.css'), overwrite = TRUE)
  
  
  ##### style settings
  
  read_css <- function(ftpn = 1){
    
    ftp = ifelse(ftpn==1,"toc.css","body.css")
    
    store = list()
    
    key = ""
    value = ""
    lock = FALSE
    for (row in readLines(paste0(location,'/style/', ftp))){
      
      if (grepl( "\\{", row)){
        key = paste0(key,stringr::str_split(row, "\\{")[[1]][1])
        lock = TRUE
        next
      }
      
      
      
      
      if (lock & !grepl( "\\}", row)){
        value = paste0(value,row)
        
      } else if (!grepl( "\\}", row)) {
        key = paste0(key,row)
      }
      
      if (grepl( "\\}", row)){
        lock = FALSE
        
        sublist = list()
        for (v in stringr::str_split(value,";")[[1]]){
          if (v != ""){
            subv =stringr::str_split(v,":")[[1]]   
            sublist[[subv[1]]] = subv[2]
          }
        }
        
        
        
        store[[key]] = sublist
        key = ""
        value = ""
      }
      
    }
    
    return (store)
    
  }
  
  
  # rewrite into file
  write_css <- function(ftpn=1,store){
    
    ftp = ifelse(ftpn==1,"tocprod.css","bodyprod.css")
    
    css_out = ""
    for (ids in names(store)){
      css_out = paste0(css_out, ids, " { \n")
      
      for (subids in names(store[[ids]])){
        css_out = paste0(css_out, subids, ": ",store[[ids]][[subids]], "; \n" )
      }
      
      
      
      css_out = paste0(css_out, " } \n\n")
      
      
      
      
    }
    
    
    cat(css_out,sep = '', file = paste0(location,'/style/',ftp))
    
    
  }
  
  ###########################
  #CSS options
  
  
  if (toc_style == "tabpanel") {
    
    #<option>
    body_font_family = settings$body_font_family
    body_background = settings$body_background
    body_font_color = settings$body_font_color
    caption_color = settings$caption_color
    
    toc_background_color = settings$toc_background_color
    
    main_tab_toc_lin_grad_min = settings$main_tab_toc_lin_grad_min
    main_tab_toc_lin_grad_max = settings$main_tab_toc_lin_grad_max
    
    main_tab_toc_lin_grad_min_hilite = settings$main_tab_toc_lin_grad_min_hilite
    main_tab_toc_lin_grad_max_hilite = settings$main_tab_toc_lin_grad_max_hilite
    
    main_tab_toc_font_color = settings$main_tab_toc_font_color
    toc_font_size = settings$toc_font_size
    toc_font_family = settings$toc_font_family
    
    toc_border_bottom_thickness = settings$toc_border_bottom_thickness
    toc_border_bottom_color = settings$toc_border_bottom_color
    
    toc_dropdown_background_color = settings$toc_dropdown_background_color
    toc_dropdown_border_color = settings$toc_dropdown_border_color
    toc_dropdown_border_ltyple = settings$toc_dropdown_border_ltyple
    toc_dropdown_border_width = settings$toc_dropdown_border_width
    toc_drop_down_hilite_color = settings$toc_drop_down_hilite_color
    toc_dropdown_background_font_color = settings$toc_dropdown_background_font_color
    toc_dropdown_font_size = settings$toc_dropdown_font_size
    
    toc_hover_arrow_color = settings$toc_hover_arrow_color
    
    #</option>
    
    
    
    
    ####################
    
    find_css_tag <- function(css_,search){
      names(css_)[grep(search,names(css_))]
    }
    
    
    
    
    css_toc = read_css(ftpn=1)
    
    
    ##toc
    
    
    
    css_toc[["#TOC " ]][["  background"]] = paste0(" linear-gradient(to bottom,",main_tab_toc_lin_grad_min  ," 0%, ",main_tab_toc_lin_grad_max ," 100%)")
    css_toc[["#TOC " ]][["  font-family"]] = toc_font_family 
    css_toc[["#TOC " ]][["  border-bottom"]] = paste0(toc_border_bottom_thickness," solid ", toc_border_bottom_color)
    
    css_toc[["#TOC a "]][["  background"]] = paste0(" linear-gradient(to bottom,",main_tab_toc_lin_grad_min ," 0%, ",main_tab_toc_lin_grad_max," 100%)")
    css_toc[["#TOC a "]][["  color"]] = main_tab_toc_font_color
    css_toc[["#TOC ul "]][["  font-size"]] = toc_font_size
    
    css_toc[["#TOC > ul > li:hover:after "]][["  border-bottom"]] = paste0(" 10px solid ",toc_hover_arrow_color)
    
    css_toc[["#TOC .has-sub ul li a " ]][["  background"]] = toc_dropdown_background_color
    css_toc[["#TOC .has-sub ul li a " ]][["  font-size"]] = toc_dropdown_font_size
    css_toc[["#TOC .has-sub ul li a " ]][["  color"]] = toc_dropdown_background_font_color
    css_toc[["#TOC .has-sub ul li a " ]][["  border-bottom"]] = paste0(toc_dropdown_border_width,toc_dropdown_border_ltyple,toc_dropdown_border_color)
    css_toc[["#TOC > ul > li.active > a,#TOC > ul > li:hover > a " ]][["  background"]] = paste0(" linear-gradient(to bottom, ",main_tab_toc_lin_grad_min_hilite," 0%, ",main_tab_toc_lin_grad_max_hilite," 100%)")
    css_toc[["#TOC .has-sub ul li:hover a "]][["  background"]] = toc_drop_down_hilite_color
    
    
    
    
    
    
    write_css(ftpn=1, css_toc)
    
    
    #if (toc_style == "sidepanel"){
    #  f1 = readr::read_file('../style/tocprod.css')
    #  f2 = readr::read_file('../style/side-panel-media-query.css')
    #  cat(paste0(f1,f2),sep = '', file = '../style/tocprod.css')
    #}
    
    
    
    
    
    
    ###Body
    
    
    css_body = read_css(ftpn=2)
    
    
    css_body[[
      find_css_tag(css_body,"#bookdowndiv")
    ]][[
      find_css_tag(css_body[[
        find_css_tag(css_body,"#bookdowndiv")
      ]],"font-family" 
      )
    ]] = body_font_family
    
    
    
    css_body[[
      find_css_tag(css_body,"#bookdowndiv")
    ]][[
      find_css_tag(css_body[[
        find_css_tag(css_body,"#bookdowndiv")
      ]],"background" 
      )
    ]] = body_background
    
    
    
    css_body[[
      find_css_tag(css_body,"#bookdowndiv")
    ]][[
      find_css_tag(css_body[[
        find_css_tag(css_body,"#bookdowndiv")
      ]],"color" 
      )
    ]] = body_font_color 
    
    
    
    css_body[[
      find_css_tag(css_body,"p.caption")
    ]][[
      find_css_tag(css_body[[
        find_css_tag(css_body,"p.caption")
      ]],"color" 
      )
    ]] = caption_color
    
    
    
    
    
    
    write_css(ftpn=2, css_body)
    
    
    
  }
  
  #################
  
  if (toc_style == "sidepanel") {
    print ("Settings Check")
    print (settings$replace_order == "TRUE")
    print (settings$remove_extra_col == "TRUE")
    replace_order = ifelse(settings$replace_order == "TRUE",TRUE,FALSE)#FALSE #change orintation
    remove_extra_col = ifelse(settings$remove_extra_col == "TRUE",TRUE,FALSE)#FALSE # remove extra column
    
    toc_font_family = settings$toc_font_family#" -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, \"Noto Sans\", \"Liberation Sans\", sans-serif, \"Apple Color Emoji\", \"Segoe UI Emoji\", \"Segoe UI Symbol\", \"Noto Color Emoji\""
    toc_main_nav_color = settings$toc_main_nav_color#" #333"
    toc_main_nav_chapters_color = settings$toc_main_nav_chapters_color#" #0068D9"
    toc_main_nav_chapters_font_size = settings$toc_main_nav_chapters_font_size#" 1rem"
    toc_chapter_uline_color =  settings$toc_chapter_uline_color#" #00438d"
    toc_next_page_color = settings$toc_next_page_color#" #333"
    toc_next_page_font_size = settings$toc_next_page_font_size#" 1rem"
    toc_next_page_name_color = settings$toc_next_page_name_color#" #0068D9"
    toc_next_page_name_font_size=settings$toc_next_page_name_font_size#" 1rem"
    
    css_toc = read_css(ftpn=1)
    
    css_toc[["#main-nav " ]][["  font-family"]] =  toc_font_family
    css_toc[["#main-nav " ]][["  color"]] = toc_main_nav_color
    css_toc[["#main-nav a " ]][["  color"]] = toc_main_nav_chapters_color
    css_toc[["#main-nav a " ]][["  font-size"]] = toc_main_nav_chapters_font_size
    css_toc[["#main-nav a:hover " ]][["  color"]] =toc_chapter_uline_color
    css_toc[["#toc " ]][["  font-family"]] =  toc_font_family
    css_toc[["#toc " ]][["  color"]] =  toc_next_page_color
    css_toc[[".next-color " ]][["  color"]] = toc_next_page_name_color
    
    
    
    write_css(ftpn=1, css_toc)
    
    
    
    
    
    css_body = read_css(ftpn=2)
    
    body_font_family = settings$body_font_family#" -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, \"Noto Sans\", \"Liberation Sans\", sans-serif, \"Apple Color Emoji\", \"Segoe UI Emoji\", \"Segoe UI Symbol\", \"Noto Color Emoji\""
    body_font_color =settings$body_font_color#" #333"
    caption_color = settings$caption_color#" #777"
    body_background = settings$body_background#" #ffffff"
    
    css_body[["    #bookdowndiv "]][["    background"]] = body_background
    css_body[["    #bookdowndiv "]][["    color"]] = body_font_color
    css_body[["    #bookdowndiv "]][["    font-family"]] = body_font_family 
    css_body[["p.caption "]][["    color"]] = body_font_color
    
    
    write_css(ftpn=2, css_body)
  }
  
  
  
  
  
  
  ##################
  
  incProgress(0.25, message = "CSS settings completed, next is book rendering this may take a while")
  
  
  print ("Major debug")
  print(getwd())
  tocstyle = paste0('"../style/tocprod.css"')
  bodystyle = paste0('"../style/bodyprod.css"')
  
  styles = c(tocstyle, bodystyle)
  style_list = paste0(styles, collapse = ", ") 
  
  
  print ("Starting bookdown generation")
  print (paste0("Location variable has  been assigned to ", location))
  print (paste0("out_dir variable has  been assigned to ", out_dir))
  
  
  unlink(out_dir , recursive = TRUE)
  
  x = readLines(paste0(location,'/',contents_loc,'/index.rmd'))
  
  print (paste("Index page is being read from ",location,'/',contents_loc,'/index.rmd'))
  
  yaml = gsub('book.bib','../content/book.bib',yaml)
  yaml = gsub('packages.bib','../content/packages.bib',yaml)
  
  
  x = c(yaml,x)
  
  
  #x = gsub('book.bib','../content/book.bib',x)
  #x = gsub('packages.bib','../content/packages.bib',x)
  
  #s = paste0('title: "A Minimal Book Example (', c('Bootstrap', 'Tufte'), ' Style)"')
  s = paste0('title: "A Minimal Book Example"')
  
  unlink(out_dir , recursive = TRUE)
  file.copy(paste0(location, '/',contents_loc,'/index.rmd'), paste0(location,'/',contents_loc,'/_index.rmd'))
  file.copy(paste0(location, '/',contents_loc,'/_output.yml'), paste0(location,'/',contents_loc,'/_output.yml2'))

  
  #writeLines(
  #  gsub('^title: ".*"', s, gsub('gitbook', fmt, x)), '../content/index.rmd'
  #)
  
  if (applycss){
    cat(
      'bookdown::', fmt, ':\n', '  css: [',style_list,']\n', sep = '', file = paste0(location, '/',contents_loc,'/_output.yml'),
      append = TRUE
    )
  }
  

  
  
  
  bookdown::render_book(paste0(location, '/',contents_loc,'/'), paste0('bookdown::',fmt), quiet = TRUE, output_dir = out_dir, config_file = paste0(location,"/",contents_loc,"/_bookdown.yml"))
  
  incProgress(0.75, message = "Book rendering completed")
  
  
  print ("Bookdown generation completed.")
  
  file.copy(from = paste0(location,'/',contents_loc,'/index.rmd'),to= paste0(location,'/',contents_loc,'/index2.rmd'), overwrite = TRUE)
  
  file.copy(from=paste0(location,'/',contents_loc,'/_output.yml'),to=paste0(location,'/',contents_loc,'/_output2.yml'), overwrite = TRUE)
  
  file.rename(paste0(location,'/',contents_loc,'/_index.rmd'), paste0(location,'/',contents_loc,'/index.rmd'))
  file.rename(paste0(location,'/',contents_loc,'/_output.yml2'), paste0(location,'/',contents_loc,'/_output.yml'))
  
  
  html_files = list.files(paste0(location,"/",contents_loc,'/output/_book/'), pattern = "*.html")
  
  print ("Formatting HTML.")
  
  if (toc_style == "tabpanel" ) {
    
    for (f in html_files) {
      book = read_html(paste0(location,"/",contents_loc,'/output/_book/',f))
      content <- book %>% html_nodes(".container-fluid.main-container")
      content_html <- as.character(content)
      
      new_div <- read_html('<div id="bookdowndiv"></div>') %>% html_node("div") 
      
      # Append the content to the new div
      xml_add_child(new_div, read_html(content_html) %>% html_node("div"))
      
      original_div <- book %>% html_node(".container-fluid.main-container")
      xml_replace(original_div, new_div)
      write_html( book, paste0(location,"/",contents_loc,'/output/_book/',f))
      
      
    } 
    
  } 
  
  
  if (toc_style == "sidepanel") {
    print ("Side Panel Tasks")
    for (f in html_files) {
      
      book = read_html(paste0(location,"/",contents_loc,'/output/_book/',f))
      
      content <- book %>% html_nodes(".container-fluid")
      content_html <- as.character(content)
      
      new_div <- read_html('<div id="bookdowndiv"></div>') %>% html_node("div") 
      
      # Append the content to the new div
      xml_add_child(new_div, read_html(content_html) %>% html_node("div"))
      
      original_div <- book %>% html_node(".container-fluid")
      xml_replace(original_div, new_div)
      
      
      # Remove form tag inside div with id=main nav
      main_nav_div <- book %>% html_node("#main-nav")
      if (!is.null(main_nav_div)) {
        form_tag <- main_nav_div %>% html_node("form")
        if (!is.null(form_tag)) {
          xml_remove(form_tag)
        }
      }
      
      
      footer = book %>% html_node(".bg-primary.text-light.mt-5")
      if (!is.null(footer)){
        xml_remove(footer)
      }
      
      # Remove class sidebar-book from head tag
      header_tag <- book %>% html_node("header")
      if (!is.null(header_tag)) {
        header_tag <- xml_attr(header_tag, "class", NULL)
        if (!is.null(header_tag)) {
          header_tag <- strsplit(header_tag, " ")[[1]]
          header_tag <- paste0(header_tag[header_tag != "sidebar"], collapse = " ")
          xml_set_attr(book %>% html_node("header"), "class", header_tag)
        }
      }
      
      
      
      # Remove class sidebar-book from head tag
      nav_link <- book %>% html_node(".nav-link")
      if (!is.null(nav_link)) {
        nav_link <- xml_attr(nav_link, "class", NULL)
        if (!is.null(nav_link)) {
          nav_link <- paste0(nav_link, " next-color")
          xml_set_attr(book %>% html_node(".nav-link"), "class", nav_link)
        }
      }
      
      
      
      
      write_html( book, paste0(location,"/",contents_loc,'/output/_book/',f))
      
        
    } 
    print ("Side panel tasks succesful")
    
    
    
    if (replace_order){
      
      #switch order of columns
      for (f in html_files) {
        
        book <- read_html(paste0(location,"/",contents_loc,'/output/_book/',f))
        
        # Extract the columns
        col1 <- book %>% html_nodes(".col-sm-12.col-lg-3.sidebar.sidebar-book")
        col1_html <- as.character(col1)
        original_c1 <- book %>% html_node(".col-sm-12.col-lg-3.sidebar.sidebar-book")
        
        if (length(col1_html) == 0){
          col1 <- book %>% html_nodes(".col-sm-12.col-lg-3.sidebar-book")
          col1_html <- as.character(col1)
          original_c1 <- book %>% html_node(".col-sm-12.col-lg-3.sidebar-book")
          
        }
        
        col2 <- book %>% html_nodes("#content")
        col2_html <- as.character(col2)
        original_c2 <- book %>% html_node("#content")
        
        col3 <- book %>% html_nodes(".col-md-3.col-lg-2.d-none.d-md-block.sidebar.sidebar-chapter")
        col3_html <- as.character(col3)
        original_c3 <- book %>% html_node(".col-md-3.col-lg-2.d-none.d-md-block.sidebar.sidebar-chapter")
        
        if (length(col1_html) == 0){
          col3 <- book %>% html_nodes(".col-md-3.col-lg-2.d-none.d-md-block.sidebar-chapter")
          col3_html <- as.character(col3)
          original_c3 <- book %>% html_node(".col-md-3.col-lg-2.d-none.d-md-block.sidebar-chapter")
          
        }
        
        
        
        
        # Replace the original nodes with the swapped content
        xml_replace(original_c1, read_html(col3_html) %>% html_node("div"))
        xml_replace(original_c3, read_html(col1_html) %>% html_node("header"))
        
        # Write the modified HTML back to the file
        write_html(book, paste0(location,"/",contents_loc,'/output/_book/',f))
      }
      
      
      
    }
    
    
    
    
    if (remove_extra_col){
      
      #switch order of columns
      for (f in html_files) {
        book <- read_html(paste0(location,"/",contents_loc,'/output/_book/',f))
        
        tryCatch({
          rmcol <- book %>% html_nodes(".col-md-3.col-lg-2.d-none.d-md-block.sidebar.sidebar-chapter")
          
          xml_remove(rmcol)
          
        }, error = function(e){
          rmcol <- book %>% html_nodes(".col-md-3.col-lg-2.d-none.d-md-block.sidebar-chapter")
          
          xml_remove(rmcol)
          
        })
        
        
        # Write the modified HTML back to the file
        write_html(book, paste0(location,"/",contents_loc,'/output/_book/',f))
        
        
      }
      
    }
    
    
    
  }
  
  
  print ("Formatting HTML ended. run_redner exectured to last step.")
  
  
               })

}




