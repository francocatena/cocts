jQuery -> 
  $(".pagination a").live("click", -> 
    $.get this.href, null, null, "script"
    false
  )



