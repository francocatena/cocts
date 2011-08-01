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