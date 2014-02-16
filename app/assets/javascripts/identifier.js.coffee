# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $("#btn-positive, #btn-neutral, #btn-negative").click (event) ->
    $(event.target).toggleClass("btn-success", $(event.target).is("#btn-positive:active"))
    $(event.target).toggleClass("btn-warning", $(event.target).is("#btn-neutral:active"))
    $(event.target).toggleClass("btn-danger", $(event.target).is("#btn-negative:active"))
    $(event.target).parents(".panel").toggleClass("panel-success", $(event.target).is("#btn-positive"))
    $(event.target).parents(".panel").toggleClass("panel-warning", $(event.target).is("#btn-neutral"))
    $(event.target).parents(".panel").toggleClass("panel-danger", $(event.target).is("#btn-negative"))