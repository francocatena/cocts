var Question = {
  current: function() {
    return parseInt($('.question_instance:visible').data('number'));
  },
  
  show: function(n, showNext) {
    var currentQuestion = $('.question_instance:visible');
    var increment = showNext ? 1 : -1;
    var next = $('.question_instance[data-number="' + (n + increment) + '"]');

    if(next.length > 0) {
      currentQuestion.fadeOut(300, function() { next.fadeIn(300); });
    } 

    if(showNext && $('.question_instance[data-number="' + (n + 2) + '"]').length == 0) {
      $('.actions input[type="submit"]').attr('disabled', false);
    }
  }
};

jQuery(function($) {
  $('#in_training_teacher_status').click(function(event) {
       $('#teacher').fadeIn(300);
  });
  $('#in_exercise_teacher_status').click(function(event) {
       $('#teacher').fadeIn(300);
  });
  $('#not_a_teacher_teacher_status').click(function(event) {
       $('#teacher').fadeOut(300);
  });
  
  if($('.project_instance').length > 0) {
    $('.question_instance:first').show();

    $('#prev_question').click(function(event) {
      Question.show(Question.current(), false);

      event.stopPropagation();
      event.preventDefault();
    });

    $('#next_question').click(function(event) {
      Question.show(Question.current(), true);

      event.stopPropagation();
      event.preventDefault();
    });
    
    $('#show_questions').click(function(event) {
      $('#showed_data').fadeOut(300);
      $('.project_instance_data').fadeIn(300);
      $('#show_complete_data').fadeIn(300);
      $('.show_questions').fadeOut(300);
      $('.hide_complete_cuestionnaire').fadeOut(300);
      $('.show_complete_cuestionnaire').fadeIn(300);
      
      if ($(this).attr('data-href') == 'edit'){
        $('.actions input[type="submit"]').attr('disabled', false);
      }
      
      if ($('#other_teacher_level').attr('value') == ''){
        $('#other_teacher_level').attr('disabled', true);
      }
      
      if ($('#other_degree').attr('value') == ''){
        $('#other_degree').attr('disabled', true);
      }
      
    });

    $('#show_complete_data').click(function(event) {
       $('#show_complete_data').fadeOut(300);
       $('#showed_data').fadeIn(300);
       $('.hide_complete_cuestionnaire').fadeIn(300);
       $('.show_complete_cuestionnaire').fadeOut(300);
    });
    
    $('#hide_complete_data').click(function(event) {
       $('#show_complete_data').fadeIn(300);
       $('#showed_data').fadeOut(300);
       $('.hide_complete_cuestionnaire').fadeOut(300);
       $('.show_complete_cuestionnaire').fadeIn(300);
    });
    
    $(document).keydown(function(e) {
      var key = e.which;
      // 39 = right arrow
      var nextKeys = [39];
      // 37 = left arrow
      var prevKeys = [37];


      if($(':focus').length == 0) {
        if($.inArray(key, nextKeys) != -1) {
          Question.show(Question.current(), true);
        } else if($.inArray(key, prevKeys) != -1) {
          Question.show(Question.current(), false);
        }
      }
    });
  }
});