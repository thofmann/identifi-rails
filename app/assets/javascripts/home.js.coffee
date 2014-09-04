# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = () ->
  feedSpinner = $("#feed-spinner").ladda()
  $('#messages').infinitescroll
    navSelector: "#more"    
    nextSelector: "#more a:first"  
    itemSelector: ".message-panel"
    bufferPx: 1500
    loading:
      msgText: ""
      finishedMsg: ""
      img: ""
      start: (opts) ->
        feedSpinner.ladda('start')
        $(this).data("infinitescroll").beginAjax(opts)
      finished: ->
        feedSpinner.ladda('stop')
    state:
      currPage: 0
    path: (page) ->
      "/?page=" + page
    , (arrayOfNewElems) ->
      setIdPopover();

$(document).ready(ready)
$(document).on('page.load', ready)
