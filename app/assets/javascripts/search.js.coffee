# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
  
$(document).ready ->
  $(".search-result-row").click (e) ->
    $(e.target).find("a")[0].click()
