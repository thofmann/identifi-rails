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
      location.reload()
      $(event.target).addClass("disabled")
      $(event.target).addClass("btn-success")
  $(".btn-more").click (event) ->
    event.preventDefault()
    row = $(event.target).parents("tr").next(".connectingpackets")
    row.toggle()
    type = $(event.target).parents("tr").data("type")
    value = $(event.target).parents("tr").data("value")
    unless $.trim(row.children("td.connectingpackets").html())
      $.post "/id/getconnectingpackets", {id1type:idType, id1value:idValue, id2type:type, id2value:value}, (data) ->
        row.children("td.connectingpackets").html(data)
  $("#addButton").click (event) ->
    event.preventDefault()
    $.post '/id/confirm', {type:idType, value:idValue, linkedType:$("#addType").val(), linkedValue:$("#addValue").val(), linkedComment:$("#addComment").val()}, (data) ->
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
      "/id/received/?page=" + page # todoo!
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
      "/id/sent/?page=" + page
    , (arrayOfNewElems) ->
      setIdPopover();

$(document).ready(ready)
$(document).on('page.load', ready)