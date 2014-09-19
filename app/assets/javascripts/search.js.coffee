# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

scrollTo = (el) ->
  if el.position()
    if el.position().top < $(window).scrollTop()
      $('html,body').animate({scrollTop:el.position().top - 80}, 100)
    else if(el.position().top + el.height() > $(window).scrollTop() + (window.innerHeight || document.documentElement.clientHeight))
      $('html,body').animate({scrollTop:el.position().top - (window.innerHeight || document.documentElement.clientHeight) + el.height() + 15}, 100)
  
search = ->
  $.get "/search",
    query: "" + $(".search-search").val() + ""
  , (data) ->
      $("#search-page").html $(data).find("#search-page").html()
      $(".search-result-row").first().addClass("active")

$(document).ready ->
  $(".search-search").focus()
  $(".search-result-row").click (e) ->
    unless $(e.target).is("a")
      $(e.target).closest("tr").find("a")[0].click()

  $(".search-search").keydown (e) ->
    switch e.which
      when 13
        e.preventDefault()
        el = $(".search-result-row.active").find("a")[0].click()
      when 38
        e.preventDefault()
        el = $(".search-result-row.active")
        unless el.prev().length == 0
          el.prev().addClass "active"
          el.removeClass "active"
          scrollTo el.prev()
      when 40
        e.preventDefault()
        el = $(".search-result-row.active")
        unless el.next().length == 0
          el.next().addClass "active"
          el.removeClass "active"
          scrollTo el.next()
      else
        clearTimeout $.data(this, "timer")
        wait = setTimeout(search, 500)
        $(this).data "timer", wait
