function highlightRow(row) {
    const rows = document.querySelectorAll('#user_open_table tbody tr');
    rows.forEach(r => {
        //if (!r.classList.contains('highlight')) {
            r.classList.remove('highlight');
            Shiny.setInputValue('user_open_file_project_selected','')
        //}
    });
    

    // Toggle highlight on the clicked row
    if (!row.classList.contains('highlight')) {
        row.classList.add('highlight');
        const firstTdText = row.querySelector('td').innerText;
        Shiny.setInputValue('user_open_file_project_selected',firstTdText)
    } else {
        row.classList.remove('highlight');
        Shiny.setInputValue('user_open_file_project_selected','')
    }
}

function updateCheckBox(checkbox) {
            if (checkbox.checked) {
                checkbox.value = "1";
            } else {
                checkbox.value = "0";
            }
            Shiny.setInputValue('rmd_trigger_1', 1, {priority: "event"});
}

function triggerRMD(evnt, obj){
  //console.log(evnt.target.value);
  //console.log(obj);
  //console.log(obj.value);
  //window.investigate = obj;
  
  //we need to use setAttribute to update the tag
  obj.setAttribute("value",evnt.target.value);
  Shiny.setInputValue('rmd_trigger_1', 1, {priority: "event"});
}



function reloadStylesheets() {
    var queryString = '?reload=' + new Date().getTime();
    $('link[rel="stylesheet"]').each(function () {
        this.href = this.href.replace(/\?.*|$/, queryString);
    });
}






