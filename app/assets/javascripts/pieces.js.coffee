# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready () ->
  console.log $(window).height()-135
  $('.piece-body').summernote {
    height: $(window).height()-135,
    minHeight: 200,
    toolbar: [
      ['style', ['style']],
      ['style', ['bold', 'italic', 'underline', 'clear']],
      ['para', ['ul', 'ol']],
      ['insert', ['link', 'picture', 'video', 'hr']],
      # ['misc', ['codeview', 'fullscreen']]
    ]
  }


  # Resizing writing space
  if $(".navbar-collapse").is(":visible") # big device, navbar on side
    $(".note-editable").css("height", $(window).height()-135 + "px")
  else # small device, navbar collapsed
    $(".note-editable").css("height", $(window).height()-200 + "px")

  $(window).resize () ->
    if $(".hidewhenfullscreen").css("display") != "none" # not full screen
      if $(".navbar-collapse").is(":visible") # big device, navbar on side
        $(".note-editable").css("height", $(window).height()-135 + "px")
      else # small device, navbar collapsed
        $(".note-editable").css("height", $(window).height()-200 + "px")
    else # is full screen
      console.log "fs"
      $(".note-editable").css("height", $(window).height()-70 + "px")


  # $(".note-editable").bind 'paste', (e) ->
  #   setTimeout () ->
  #     rawtext = $(".piece-body").html()
  #     data = {text: rawtext}
  #     url = "/pieces/cleanup.json"
  #     $.ajax({
  #       url: url,
  #       data: data,
  #       type: "post", 
  #       success: (data) ->
  #         santext = data.santext 
  #         $(".note-editable").html(data.santext)
  #       error: (jqXHR, textStatus, errorThrown) ->
  #         console.log "error", jqXHR, textStatus, errorThrown
  #     })
  #   , 100