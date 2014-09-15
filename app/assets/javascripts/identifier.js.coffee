# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = () ->
  idType = $("#id-type").html()
  idValue = $("#id-value").html()
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

  if $.inArray(location.hash, ["connections","sent","received"]) != -1
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

  receivedSpinner = $("#received-spinner").ladda()
  $('#received-messages').infinitescroll
    navSelector: "#more-received"    
    nextSelector: "#more-received a:first"  
    itemSelector: ".message-panel"
    bufferPx: 1000
    loading:
      msgText: ""
      finishedMsg: ""
      img: ""
      start: (opts) ->
        receivedSpinner.ladda('start')
        $(this).data("infinitescroll").beginAjax(opts)
      finished: ->
        receivedSpinner.ladda('stop')
    errorCallback: ->
      receivedSpinner.ladda('stop')
    state:
      currPage: 0
      isPaused: !$('#received').is(':visible')
    path: (page) ->
      "/id/received/?type=" + encodeURIComponent(idType) + "&value=" + encodeURIComponent(idValue) + "&page=" + page
    , (arrayOfNewElems) ->
      setIdPopover()

  sentSpinner = $("#sent-spinner").ladda()
  $('#sent-messages').infinitescroll
    navSelector: "#more-sent"    
    nextSelector: "#more-sent a:first"  
    itemSelector: ".message-panel"
    bufferPx: 1000
    loading:
      msgText: ""
      finishedMsg: ""
      img: ""
      start: (opts) ->
        sentSpinner.ladda('start')
        $(this).data("infinitescroll").beginAjax(opts)
      finished: ->
        sentSpinner.ladda('stop')
    errorCallback: ->
      sentSpinner.ladda('stop')
    state:
      currPage: 0
      isPaused: !$('#sent').is(':visible')
    path: (page) ->
      "/id/sent/?type=" + encodeURIComponent(idType) + "&value=" + encodeURIComponent(idValue) + "&page=" + page
    , (arrayOfNewElems) ->
      setIdPopover()

  sliderEl = $('#write-feedback input.slider')
  if sliderEl.length > 0
    mySlider = sliderEl.slider
      selection: 'after'
      tooltip: 'hide'
      step: 0.1
    
    sliderHandler = ->
      val = parseInt($(this).val())
      $("#buttonvalue").val(val);
      $(".write-msg-icon").toggleClass('glyphicon-question-sign', val == 0)
      $(".write-msg-icon").toggleClass('glyphicon-thumbs-up', val > 0)
      $(".write-msg-icon").toggleClass('glyphicon-thumbs-down', val < 0)
      $("#write-msg-icons").toggleClass('has-warning', val == 0)
      $("#write-msg-icons").toggleClass('has-success', val > 0)
      $("#write-msg-icons").toggleClass('has-error', val < 0)
      writePanel = $('#write-feedback').parent()
      writePanel.toggleClass('panel-warning', val == 0)
      writePanel.toggleClass('panel-success', val > 0)
      writePanel.toggleClass('panel-danger', val < 0)
      if val != 0
        $('.write-msg-icon').hide()
        $('.write-msg-icon').slice(0, Math.abs(val)).show()
    
    mySlider.on 'slide', sliderHandler
    mySlider.on 'slideStop', sliderHandler

$(document).ready(ready)
$(document).on('page.load', ready)
