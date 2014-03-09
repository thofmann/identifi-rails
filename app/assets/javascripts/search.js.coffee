# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = () ->
  $('#messages').infinitescroll
    navSelector: "#more"    
    nextSelector: "#more a:first"  
    itemSelector: ".message-panel"          
    path: (page) ->
      "/?page=" + page

$(document).ready(ready)
$(document).on('page.load', ready)