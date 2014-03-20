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

ready = function() {
  $(".dropdown-toggle").dropdown();
  $(".identifi-search").submit(function(event) {
    event.preventDefault();
    window.location.assign("/search/" + encodeURIComponent($(event.target).find("input").val()));
  });

  $(".identifi-search input").autocomplete({
    source: function(request, response) {
      var output = [];
      $.getJSON('/search/'+encodeURIComponent(request.term)+'?format=json', function(data) {
        $.each(data, function(key, val) {
          if (key > 2) return false;
          output.push({type: val[0], value: val[1]});
        });
        response(output);
      });
    },
    minLength: 1,
    autoFocus: true,
    focus: function( event, ui ) {
      return false;
    },
    select: function( event, ui ) {
      window.location.assign("/id/" + encodeURIComponent(ui.item.type) + "/" + encodeURIComponent(ui.item.value));
      return false;
    }
  })
  .data( "ui-autocomplete" )._renderItem = function( ul, item ) {
    console.log(item);
    return $( "<li>" )
    .append( "<a>" + item.value + "<br><small>" + item.type + "</small></a>" )
    .appendTo( ul );
  };

}

$(document).ready(ready);
$(document).on('page.load', ready);