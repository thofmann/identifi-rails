// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui.min
//= require jquery.infinitescroll.min
//= require_tree .
//= require bootstrap

function loginViaEmail() {
  navigator.id.get(function(assertion) {
    if (assertion) {
      $('input[name=assertion]').val(assertion);
      $('#persona-form').submit();
    } else {
      window.location = "#{failure_path}"
    }
  });
}

function setIdPopover() {
  $('.id-link').unbind('mouseenter mouseleave');
  $('.id-link').hover(
    function(event) {
      var t=$(this);
      t.unbind('mouseenter mouseleave');
      $.get(t.attr('href')+'/overview',function(d) {
          $('.popover').hide();
          t.popover({content: d, html: true, trigger: 'hover', delay: 0}).popover('show');
      });
  },
    function(event) {
      var t=$(this);
      t.popover('hide');
    });
}

function hidePopoverOnClick(popoverTarget) {
  $('body').on('click', function (e) {
    var t = $(e.target);
    if (!(t.hasClass("popover") || t.parents(".popover").length > 0 || t.parents(".ui-autocomplete").length > 0)) {
      popoverTarget.popover('destroy');
      $('body').off('click');
    }
  });
}

function gotoPage(event) {
  event.preventDefault();
  window.location.assign("/id/" + encodeURIComponent($(".gotoType").val()) + "/" + encodeURIComponent($(".gotoValue").val()));
}

function setUpCreatePage() {
  $(".createPageForm").submit(gotoPage);
  $(".createpage").off('click').click(gotoPage);
}

function setUpSearchAutocomplete() {
  $(".identifi-search input").autocomplete({
    source: function(request, response) {
      var output = [];
      $.getJSON('/search/'+encodeURIComponent(request.term)+'?format=json', function(data) {
        $.each(data, function(key, val) {
          if (key > 2) return false;
          output.push({type: val[0], value: val[1]});
        });
        output.push({createPage: true, type: "", value: "Create page <i>" + request.term.replace(/(<([^>]+)>)/ig,"") + "</i>"});
        response(output);
      });
    },
    minLength: 1,
    autoFocus: true,
    focus: function( event, ui ) {
      return false;
    },
    select: function( event, ui ) {
      if (ui.item.createPage) {
        event.preventDefault();
        var content = "<form class=\"createPageForm\"><input class=\"gotoValue form-control\" placeholder=\"value\" value=\"" + 
            $("#nav-search-field").val() + 
            "\"><br><input class=\"gotoType form-control\" id=\"create-page-type\" placeholder=\"type (example: email)\">" +
            "<br><button class=\"createpage btn btn-primary\">" + 
            "<span class=\"glyphicon glyphicon-arrow-right\"></span> Create page</button></form>";
        var popoverTarget = $(event.target).parents("form").first();
        popoverTarget.popover({content: content, html: true, placement: 'bottom'}).popover('show');
        popoverTarget.on('hidden.bs.popover', function (e) {
          $(e.target).popover('destroy');
        });
        hidePopoverOnClick(popoverTarget);
        $("#create-page-type").focus();
        setUpCreatePage();
      } else {
        window.location.assign("/id/" + encodeURIComponent(ui.item.type) + "/" + encodeURIComponent(ui.item.value));        
      }
      return false;
    }
  })
  .each(function (i, val) {
    $(val).data( "ui-autocomplete" )._renderItem = function( ul, item ) {
      return $( "<li>" )
      .append( "<a>" + item.value + "<br><small>" + item.type + "</small></a>" )
      .appendTo( ul );
    };
  });
}

function listenToSettingsChanges() {
  $("#settings_trusted_only").click(
    function(event) {
      event.preventDefault();
      var el = $("#settings_trusted_only .glyphicon");
      el.toggleClass("glyphicon-check").toggleClass("glyphicon-unchecked");
      $.post('/settings', {"trusted_only": (el.hasClass("glyphicon-check")?1:0) });
    }
  );
}

ready = function() {
  $(".dropdown-toggle").dropdown();
  $(".identifi-search").submit(function(event) {
    event.preventDefault();
    window.location.assign("/search/" + encodeURIComponent($(event.target).find("input").val()));
  });

  $('#email-login').click(function() {
    loginViaEmail();
    return false;
  });

  setUpSearchAutocomplete();
  setIdPopover();
  setUpCreatePage();
  listenToSettingsChanges();
}

$(document).ready(ready);
$(document).on('page.load', ready);