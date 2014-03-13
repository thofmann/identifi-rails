# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = () ->
  $("#btn-positive, #btn-neutral, #btn-negative").click (event) ->
    $("#btn-positive").toggleClass("btn-success", $(event.target).is("#btn-positive"))
    $("#btn-neutral").toggleClass("btn-warning", $(event.target).is("#btn-neutral"))
    $("#btn-negative").toggleClass("btn-danger", $(event.target).is("#btn-negative"))
    $(event.target).parents(".panel").toggleClass("panel-success", $(event.target).is("#btn-positive"))
    $(event.target).parents(".panel").toggleClass("panel-warning", $(event.target).is("#btn-neutral"))
    $(event.target).parents(".panel").toggleClass("panel-danger", $(event.target).is("#btn-negative"))
    $(".btn-group button").click ->
      $("#buttonvalue").val($(this).val());

$(document).ready(ready)
$(document).on('page.load', ready)