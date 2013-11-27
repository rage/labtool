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
      var answers = {}
      $.each(question.answers, function(answer_id,answer) {
        var element = $("#"+answer_id);
        answer.enabled = true;
        answer.checked_value = parseFloat(answer.value) || 0;
        answer.unchecked_value = parseFloat(answer.unchecked_value) || 0;
        answer.checked_feedback = answer.feedback || "";
        answer.unchecked_feedback = answer.missing_feedback || "";
        answer.checked = function() {
          return element.is(":checked");
        }
        answer.makevisible = function(shown) {
          element.parent().toggle(shown);
        }
        answer.value = function() {
          return answer.checked() ? answer.checked_value : answer.unchecked_value;
        }
        answer.feedback = function() {
          return answer.checked() ? answer.checked_feedback : answer.unchecked_feedback;
        }
        answers[answer.varname ? answer.varname : answer_id] = answer;
      });

      var element = $("#"+question_id).parent();
      var feedbackContainer = element.find(".feedback");
      var own_update_callback = question.update_callback;
      var update_callbacks = [own_update_callback];
      

      question.answers = answers;
      question.addUpdateCallback = function(fun) {
        if (typeof(fun) == "function") {
          update_callback.push(fun);
        }
      }
      question.init = function() {
        update_callbacks = [own_update_callback];
        question.feedbacks = {};
        question.score = 0;
        question.init_callback.call(question, checklist);
      }

      question.update = function() {
        question.init();
        $.each(question.answers, function(k) {
          this.makevisible(this.enabled);
          if (!this.enabled) return;

          question.score += this.value();
          var feedback = this.feedback();
          if (feedback) question.feedbacks[k] = feedback;
        });
        $.each(update_callbacks, function() {
          this.call(question, checklist);
        });
        question.feedback = [];
        $.each(question.feedbacks, function() {
          if (this) question.feedback.push(this);
        });
        question.feedback = question.feedback.join(" ");
        feedbackContainer.text(question.feedback);
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
            var f_elem = $("<div class='questionfeedback'></div>");
            f_elem.text(q.feedback);
            feedbackContainer.append(f_elem);
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


