# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = () ->
  idType = $("#id-type").html()
  idValue = $("#id-value").html()
  $("#btn-positive, #btn-neutral, #btn-negative").click (event) ->
    $("#btn-positive").toggleClass("btn-success", $(event.target).is("#btn-positive"))
    $("#btn-neutral").toggleClass("btn-warning", $(event.target).is("#btn-neutral"))
    $("#btn-negative").toggleClass("btn-danger", $(event.target).is("#btn-negative"))
    $(event.target).parents(".panel").toggleClass("panel-success", $(event.target).is("#btn-positive"))
    $(event.target).parents(".panel").toggleClass("panel-warning", $(event.target).is("#btn-neutral"))
    $(event.target).parents(".panel").toggleClass("panel-danger", $(event.target).is("#btn-negative"))
  $(".btn-group button").click ->
    $("#buttonvalue").val($(this).val());
  $(".btn-confirm, .btn-refute").click (event) ->
    event.preventDefault()
    method = if $(event.target).hasClass('btn-refute') then "refute" else "confirm"
    type = $(event.target).parents("tr").data("type")
    value = $(event.target).parents("tr").data("value")
    comment = $(event.target).siblings(".linkedComment").val()
    $.post "/id/"+method, {type:idType, value:idValue, linkedType:type, linkedValue:value, linkedComment:comment}, (data) ->
      location.hash or location.hash = "connections"
      location.reload()
      $(event.target).addClass("disabled")
      $(event.target).addClass("btn-success")
  $(".id-row").click (event) ->
    return if $(event.target).is("a,input,button")
    event.preventDefault()
    row = $(event.target).parents("tr").next(".connectingmsgs")
    row.toggle()
    type = $(event.target).parents("tr").data("type")
    value = $(event.target).parents("tr").data("value")
    connecting = row.children("td.connectingmsgs")
    unless $.trim(connecting.html())
      l = connecting.ladda()
      l.ladda('start')
      $.post "/id/getconnectingmsgs", {id1type:idType, id1value:idValue, id2type:type, id2value:value}, (data) ->
        connecting.html(data)
        l.ladda('stop')
  $(".linkedComment").keypress (event) ->
    if event.which == 13 
      $(event.target).parents(".id-row").find(".btn-confirm").click()
  $("#addButton").click (event) ->
    event.preventDefault()
    $.post '/id/confirm', {type:idType, value:idValue, linkedType:$("#addType").val(), linkedValue:$("#addValue").val(), linkedComment:$("#addComment").val()}, (data) ->
      location.hash or location.hash = "connections"
      location.reload()
      $(event.target).addClass("disabled")
      $(event.target).addClass("btn-success")
  $(".add-row").keypress (event) ->
    if event.which == 13
      $("#addButton").click()

  activeTab = $('[href=' + location.hash + ']')
  activeTab && activeTab.tab('show')

  $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    $('#sent-messages').infinitescroll 'bind'
    $('#received-messages').infinitescroll 'bind'
    $('#sent-messages').infinitescroll
      state: 
        isPaused: !$('#sent').is(':visible')
    $('#received-messages').infinitescroll
      state:
        isPaused: !$('#received').is(':visible')

  $('#received-messages').infinitescroll
    navSelector: "#more-received"    
    nextSelector: "#more-received a:first"  
    itemSelector: ".message-panel"
    bufferPx: 1000
    loading:
      msgText: ""
      finishedMsg: ""
      img: ""
    state:
      currPage: 0
      isPaused: !$('#received').is(':visible')
    path: (page) ->
      "/id/received/?type=" + encodeURIComponent(idType) + "&value=" + encodeURIComponent(idValue) + "&page=" + page
    , (arrayOfNewElems) ->
      setIdPopover()

  $('#sent-messages').infinitescroll
    navSelector: "#more-sent"    
    nextSelector: "#more-sent a:first"  
    itemSelector: ".message-panel"
    bufferPx: 1000
    loading:
      msgText: ""
      finishedMsg: ""
      img: ""
    state:
      currPage: 0
      isPaused: !$('#sent').is(':visible')
    path: (page) ->
      "/id/sent/?type=" + encodeURIComponent(idType) + "&value=" + encodeURIComponent(idValue) + "&page=" + page
    , (arrayOfNewElems) ->
      setIdPopover()

$(document).ready(ready)
$(document).on('page.load', ready)
