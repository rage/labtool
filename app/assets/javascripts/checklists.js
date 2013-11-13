$(function() {

  function getScoreInitializer(scoretypes) {
    return function() {
      var scores = {};
      $.each(scoretypes, function(id, score) {
        score.min = score.min == null ? -Infinity : parseFloat(score.min);
        score.max = score.max == null ? Infinity : parseFloat(score.max);
        score.val = parseFloat(score.initial);
        score.set = function(val) {
          score.val = Math.min(score.max, Math.max(score.min, val));
        }
        score.add = function(val) {
          score.set(score.val + val);
        }

        scores[id] = score;
      });
      return scores;
    };
  }

  function addQuestions(checklist, questionData) {
    $.each(questionData, function(question_id,question) {
      $.each(question.answers, function(answer_id,answer) {
        var element = $("#"+answer_id);
        answer.checked_value = parseFloat(answer.value) || 0;
        answer.unchecked_value = parseFloat(answer.unchecked_value) || 0;
        answer.checked_feedback = answer.feedback || "";
        answer.unchecked_feedback = answer.missing_feedback || "";
        answer.checked = function() {
          return element.is(":checked");
        }
        answer.value = function() {
          return answer.checked() ? answer.checked_value : answer.unchecked_value;
        }
        answer.feedback = function() {
          return answer.checked() ? answer.checked_feedback : answer.unchecked_feedback;
        }
        /* Todo: logic to implement answer varname */
      });

      var element = $("#"+question_id).parent();
      var feedbackContainer = element.find(".feedback");
      question.update = function() {
        question.feedbacks = [];
        question.score = 0;
        $.each(question.answers, function() {
          question.score += this.value();
          var feedback = this.feedback();
          if (feedback) question.feedbacks.push(feedback);
        });
        question.update_callback.call(question, checklist);
        question.feedback = question.feedbacks.join(" ");
        feedbackContainer.html(question.feedback);
      }

      element.find('input[type="checkbox"]').change(function() {
        question.update();
        checklist.update(); 
      });


      if (question.varname) {
        checklist.questions[question.varname] = question;
      } else {
        checklist.questions[question_id] = question;
      }
    });
  }

  $.fn.autograding = function(questionData) {
    var feedbackContainer = $(this).find('.feedbacks');
    var scoreContainer  = $(this).find('.scores');
    var initScores = getScoreInitializer(questionData.scoretypes);
    delete questionData.scoretypes;

    var checklist = { 
      questions: {},
      reset: function() {
        $.each(checklist.questions, function(k,q) {
          q.update();
        });
        checklist.update(); 
      },
      update: function() {
        feedbackContainer.empty();
        scoreContainer.empty();

        var scores = initScores();
        $.each(checklist.questions, function(k,q) {
          if (q.feedback) {
            feedbackContainer.append("<li>"+q.feedback+"</li>");
          }
          scores[q.scoretype].add(q.score);
        });
        $.each(scores, function() {
          scoreContainer.append("<p>"+this.name+": "+this.val+"</p>");
        });
      }
    };
    addQuestions(checklist, questionData)
    
    checklist.reset();

    $(this).find('.question button').click(function(e) {
      e.preventDefault();
      $(this).parents('.questionContainer').toggleClass("done");
      return false;
    });

  };
});


