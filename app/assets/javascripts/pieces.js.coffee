# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready () ->
  $(".piece-body").bind 'paste', (e) ->
    setTimeout () ->
      rawtext = $(".piece-body").html()
      data = {text: rawtext}
      url = "/pieces/cleanup.json"
      $.ajax({
        url: url,
        data: data,
        type: "post", 
        success: (data) ->
          santext = data.santext 
          $(".piece-body").html(data.santext)
        error: (jqXHR, textStatus, errorThrown) ->
          console.log "error", jqXHR, textStatus, errorThrown
      })
    , 100