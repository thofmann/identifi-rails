# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $(".btn-success, .btn-warning, .btn-danger").click (event) ->
    $(event.target).parents(".panel").toggleClass("panel-success", $(event.target).hasClass("btn-success"))
    $(event.target).parents(".panel").toggleClass("panel-warning", $(event.target).hasClass("btn-warning"))
    $(event.target).parents(".panel").toggleClass("panel-danger", $(event.target).hasClass("btn-danger"))