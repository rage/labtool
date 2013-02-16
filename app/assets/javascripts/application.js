// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(document).ready(function () {
    $(".review-form").hide();
    $(".reviews").hide();

    var toggle_review_form = function (e) {
        $(".review-form").toggle();
    };

    var toggle_reviews = function (e) {
        $(".reviews").toggle();
    };

    $(".button#review-form").click(toggle_review_form);
    $(".button#review").click(toggle_reviews);

    $('table').rotateTableCellContent();
});

(function ($) {
  $.fn.rotateTableCellContent = function (options) {
  /*
  Version 1.0
  7/2011
  Written by David Votrubec (davidjs.com) and
  Michal Tehnik (@Mictech) for ST-Software.com
  */

		var cssClass = ((options) ? options.className : false) || "vertical";

		var cellsToRotate = $('.' + cssClass, this);

		var betterCells = [];
		cellsToRotate.each(function () {
			var cell = $(this)
		  , newText = cell.text()
		  , height = cell.height()
		  , width = cell.width()+20
		  , newDiv = $('<div>', { height: width, width: height })
		  , newInnerDiv = $('<div>', { text: newText, 'class': 'rotated' });

			newDiv.append(newInnerDiv);

			betterCells.push(newDiv);
		});

		cellsToRotate.each(function (i) {
			$(this).html(betterCells[i]);
		});
	};
})(jQuery);