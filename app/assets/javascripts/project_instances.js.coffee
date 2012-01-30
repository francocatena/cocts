Question = 
  current: -> 
    parseInt $('.question_instance:visible').data('number')
    
  show: (n, showNext) ->
    currentQuestion = $('.question_instance:visible')
    increment = if showNext then 1 else -1
    next = $('.question_instance[data-number="' + (n + increment) + '"]')

    if next.length > 0 
      currentQuestion.fadeOut(300, -> next.fadeIn(300))

    if showNext && $('.question_instance[data-number="' + (n + 2) + '"]').length == 0
      $('.actions input[type="submit"]').attr('disabled', false)
    
$ ->
  $('#degree_school').click (event) ->
    $('#degree_university').fadeOut(300)
  $('#degree_university').click (event) ->
    $('#degree_school').fadeOut(300)
  $('#in_training_teacher_status').click (event) -> 
    $('#teacher').fadeIn(300)
  $('#in_exercise_teacher_status').click (event) ->
    $('#teacher').fadeIn(300)
  $('#not_a_teacher_teacher_status').click (event) -> 
    $('#teacher').fadeOut(300)
    
  if $('.project_instance').length > 0 
    $('.question_instance:first').show()

    $('#prev_question').click (event) ->
      Question.show(Question.current(), false)
      event.stopPropagation()
      event.preventDefault()
    
    $('#next_question').click (event) -> 
      Question.show(Question.current(), true)
      event.stopPropagation()
      event.preventDefault()
       
    $('#show_questions').click (event) ->
      $('#showed_data').fadeOut(300)
      $('.project_instance_data').fadeIn(300)
      $('#show_complete_data').fadeIn(300)
      $('.show_questions').fadeOut(300)
      $('.hide_complete_cuestionnaire').fadeOut(300)
      $('.show_complete_cuestionnaire').fadeIn(300)
      
      if ($(this).attr('data-href') == 'edit')
        $('.actions input[type="submit"]').attr('disabled', false)
      
      if ($('#other_teacher_level').attr('value') == '')
        $('#other_teacher_level').attr('disabled', true)
      
      if ($('#other_degree').attr('value') == '')
        $('#other_degree').attr('disabled', true)
      
    $('#show_complete_data').click (event) -> 
      $('#show_complete_data').fadeOut(300)
      $('#showed_data').fadeIn(300)
      $('.hide_complete_cuestionnaire').fadeIn(300)
      $('.show_complete_cuestionnaire').fadeOut(300)
    
    $('#hide_complete_data').click (event) -> 
      $('#show_complete_data').fadeIn(300)
      $('#showed_data').fadeOut(300)
      $('.hide_complete_cuestionnaire').fadeOut(300)
      $('.show_complete_cuestionnaire').fadeIn(300)
      
    $(document).keydown (e) -> 
      key = e.which
      # 39 = right arrow
      nextKeys = [39]
      # 37 = left arrow
      prevKeys = [37]
      if $(':focus').length == 0 
        if($.inArray(key, nextKeys) != -1) 
          Question.show(Question.current(), true)
        else if($.inArray(key, prevKeys) != -1) 
          Question.show(Question.current(), false)
        
      
   
  
