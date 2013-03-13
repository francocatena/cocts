jQuery -> 
  $(".pagination a").on "click", -> 
    $.get this.href, null, null, "script"
    false
  



