# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $("#createpage").click (event) ->
    event.preventDefault()
    window.location.assign("/id/" + encodeURIComponent($("#addType").val()) + "/" + encodeURIComponent($("#addValue").val()));