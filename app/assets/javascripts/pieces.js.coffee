# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready () ->
  $(".piece-body").bind 'paste', (e) ->
    console.log "paste"
    rawtext = $(this).html()
    data = {text: rawtext}
    url = "/pieces/cleanup.json"
    $.ajax({
      url: url,
      data: data,
      type: "post", 
      success: (data) ->
        santext = data.santext 
        # santext.find("div").each () ->
        #   console.log "hey", $(this).text()
        #   if $(this).text() == ""
        #     $(this).html("<br />")
        $(".piece-body").html(data.santext)
        # console.log santext
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "error", jqXHR, textStatus, errorThrown
    })