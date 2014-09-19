# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
  
search = ->
  $.get "/search",
    query: "" + $(".search-search").val() + ""
  , (data) ->
      $("#search-page").html $(data).find("#search-page").html()

$(document).ready ->
  $(".search-result-row").click (e) ->
    if !$(e.target).is("a")
      $(e.target).closest("tr").find("a")[0].click()

  $(".search-search").keyup ->
    clearTimeout $.data(this, "timer")
    wait = setTimeout(search, 500)
    $(this).data "timer", wait
