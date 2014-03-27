# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = () ->
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
    method = "confirm"
    if $(event.target).hasClass('btn-refute')
      method = "refute"
    type = $(event.target).parents("tr").data("type")
    value = $(event.target).parents("tr").data("value")
    $.post window.location.href+"/"+method, {linkedType:type, linkedValue:value}, (data) ->
      location.reload()
      $(event.target).addClass("disabled")
      $(event.target).addClass("btn-success")
  $("#addButton").click (event) ->
    event.preventDefault()
    $.post window.location.href+'/confirm', {linkedType:$("#addType").val(), linkedValue:$("#addValue").val()}, (data) ->
      location.reload()
      $(event.target).addClass("disabled")
      $(event.target).addClass("btn-success")

  $('#received-messages').infinitescroll
    navSelector: "#more-received"    
    nextSelector: "#more-received a:first"  
    itemSelector: ".message-panel"
    loading:
      msgText: ""
      finishedMsg: ""
    state:
      currPage: 0
    path: (page) ->
      location.protocol + '//' + location.host + location.pathname + "/received/?page=" + page
    , (arrayOfNewElems) ->
      setIdPopover();

  $('#sent-messages').infinitescroll
    navSelector: "#more-sent"    
    nextSelector: "#more-sent a:first"  
    itemSelector: ".message-panel"
    loading:
      msgText: ""
      finishedMsg: ""
    state:
      currPage: 0
    path: (page) ->
      location.protocol + '//' + location.host + location.pathname + "/sent/?page=" + page
    , (arrayOfNewElems) ->
      setIdPopover();

$(document).ready(ready)
$(document).on('page.load', ready)