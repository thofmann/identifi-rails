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
//= require jquery-ui/autocomplete
//= require jquery.infinitescroll.min
//= require spin.min
//= require md5
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
      t.unbind('mouseenter');
      t.data('mouseover', true);
      t.on('mouseenter', function(event) {
        $(this).data('mouseover', true);
      });
      $.post('/id/overview',{type:t.data('id-type'), value:t.data('id-value')},function(d) {
          $('.popover').hide();
          t.popover({content: d, html: true, trigger: 'hover', delay: 0});
          if (t.data('mouseover')) {
            t.popover('show');
          }
      });
  },
    function(event) {
      var t=$(this);
      t.data('mouseover', false);
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
          output.push(val);
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
      email = item.email ? item.email : item.type + ":" + item.value;
      img = "<img alt=\"\" class=\"mar-right5\" src=\"" + "https://www.gravatar.com/avatar/" + md5(email) + "?d=retro&s=30\">";
      return $( "<li>" )
      .append( img + "<a>" + item.value + "<br><small>" + item.type + "</small></a>" )
      .appendTo( ul );
    };
  });
}

function listenToSettingsChanges() {
  $(".trust-distance-selector button").click(
    function(event) {
      event.preventDefault();
      var el = $(event.target);
      el.toggleClass("active");
      $.post('/settings', {"max_trust_distance": el.data("val") }, function(data) {
        location.reload();
      });
    }
  );
  $(".msg-type-filter a").click(
    function(event) {
      event.preventDefault();
      var el = $(event.target).parents("li");
      el.addClass("active");
      $.post('/settings', {"msg_type_filter": el.data("val") }, function(data) {
        location.reload();
      });
    }
  );
}

ready = function() {
  $(".dropdown-toggle").dropdown();
  $(".identifi-search").submit(function(event) {
    event.preventDefault();
    var value = $(event.target).find("input:visible").val();
    if (value.trim().length > 0) {
      window.location.assign("/search/" + encodeURIComponent(value));
    }
  });

  $('#email-login').click(function() {
    loginViaEmail();
    return false;
  });

  setUpSearchAutocomplete();
  setIdPopover();
  setUpCreatePage();
  listenToSettingsChanges();
  Ladda.bind('button.ladda-button')
}

$(document).ready(ready);
$(document).on('page.load', ready);
