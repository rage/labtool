$(function() {
  var new_counter = 0;

  /* Topics are sortable */
  function updateTopicSort() {
    $('.topics .topic_ordering').each(function(i) {
      $(this).val(i+1);
    });
  }
  $('.topics').sortable({
    handle: '.topic_handle' 
  }).bind('sortupdate', updateTopicSort);
  
  /* UI toggles */
  $("#show_feedbacks").change(function() {
    var displayed = $(this).is(":checked");
    $('.values_table').toggleClass('hide_feedbacks',!displayed);
    $('.spanOverFeedbacks').attr('colspan', displayed ? 3 : 1);
  });
  $("#reorder_topics").change(function() {
    var minimize = $(this).is(":checked");
    $('.values_table, .topics button').toggle(!minimize);
  });

  /* Creating a new topic */
  $('#new_topic').click(function() {
    new_counter++;
    var new_key = "new_"+new_counter;
    $.get("/checklists/ajax/new_topic_form",   
      {
        new_key: new_key,
        title: $("#new_topic_title").val()
      },
      function(text) {
        $('#topics').append(text);
        updateTopicSort();
      }
    );
  });

  /* Checks */

  $('.values_table').each(function() {
    var table = $(this);
    var topic_id = table.attr('id').replace('topic_','');
    var min_text = table.find('.min');
    var max_text = table.find('.max');
    var min_text_scaled = table.find('.min_scaled');
    var max_text_scaled = table.find('.max_scaled');
    var cells1 = table.find('input.value');
    var cells2 = table.find('input.unchecked_value');
    var scale_num = table.find('input.scale_num');
    var scale_denom = table.find('input.scale_denom');

    table.find('textarea').css('overflow', 'hidden').autogrow(function() {
      this.data('neededHeight', this.height());

      var h = 0;
      var areas = this.parents('tr').find('textarea');
      areas.each(function() { h = Math.max(h, $(this).data('neededHeight')); });
      areas.height(h);
    });
    
    function updateCheckSort() {
      cells1 = table.find('input.value');
      cells2 = table.find('input.unchecked_value');
      calc();

      table.find('.check_ordering').each(function(i) {
        $(this).val(i+1);
      });
      table.find('.topic_id_field').each(function() {
        $(this).val(topic_id);
      });
    }
    table.find('tbody').sortable({
      handle: '.name',
      connectWith: '.values_table tbody' 
    }).bind('sortupdate', updateCheckSort);

    function calc() {
      var score_target = parseFloat(table.find('input.score_target')[0].value, 10);
      var min = 0;
      var max = 0;
      for(var i=0; i<cells1.length; i++) {
        var val1 = parseFloat(cells1[i].value,10);
        var val2 = parseFloat(cells2[i].value,10);
        min += Math.min(val1,val2);
        max += Math.max(val1,val2);
      }
      min_text.text(min);
      max_text.text(max);

      var factor = 1;
      if (score_target != 0) {
        scale_num.val(score_target);
        if (score_target < 0) {
          scale_denom.val(min);
          factor = score_target / min;
        } else {
          scale_denom.val(max);
          factor = score_target / max;
        }
      } else {
        scale_num.val(1);
        scale_denom.val(1);
      }
      min_text_scaled.text(min*factor);
      max_text_scaled.text(max*factor);
    }

    table.parents('.topicContainer').find('.new_check').click(function() {
      new_counter++;
      var new_key = "new_"+new_counter;
      var form = $(this).parents('.new_check_form_container');
      var table = form.parents('.topicContainer').find('tbody');
      var title = form.find('input[type=text]').val();

      if (title == "") {
        alert("Give a name to your check");
        return;
      }

      $.get("/checklists/ajax/new_check_form",   
        {
          new_key: new_key,
          topic_key: topic_id,
          title: title
        },
        function(text) {
          table.append(text);
          activateRows();
        }
      );
    });
  
    function activateRows() {
      table.find('tr:not(.activated)').each(function() {
        var row = $(this);
        row.addClass("activated");
        row.find('input[type="number"]').change(calc);
        row.find('.deleteCheck').click(function() {
          var id = row.find('.link_id').val();

          if (id != "new") {
            var deleteInput = $('<input type="hidden" name="deleted_topics_checks[]" />');
            deleteInput.val(id.replace('linked_check_',''));
            $('form').append(deleteInput);
          }

          row.remove();
          updateCheckSort();
        });
      });
      updateCheckSort();
    }
    
    activateRows();
  })
}); 
