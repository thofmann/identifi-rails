# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$('#messages').infinitescroll {
    navSelector: "#more",            
    nextSelector: "#more a:first",    
    itemSelector: ".message-panel"          
    dataType: 'json',
    appendCallback: false
  }, (json, opts) ->
    console.log "moi"
    # Get current page
    page = opts.state.currPage
    # Do something with JSON data, create DOM elements, etc ..
    alert "a"