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

  # Go Full Screen
  $(".full-screen").hide()
  $(".full-screen").click () ->
    el = document.documentElement
    rfs = el.requestFullScreen || el.webkitRequestFullScreen || el.mozRequestFullScreen
    rfs.call el

  # Getting time spent writing & autosaving
  save_after_min = 1
  auto_save_timeout = 2
  auto_save = undefined
  last_activity_time = 0
  
  # $(".piece-body").click () ->
  #   update($(".update").data("path"), false)
  $(".note-editable").keyup () ->
    console.log "hello?"
    last_activity_time = Date.now()
    if auto_save == undefined
      console.log "kick off autosave"
      update($(".update").data("path"), false)
      auto_save = setInterval () ->
        update($(".update").data("path"), false)
        if Date.now() > last_activity_time + 1000 * 60 * auto_save_timeout
          console.log "stop autosave, timeout"
          last_activity_time = 0
          clearInterval(auto_save)
          auto_save = undefined
      , 1000 * 60 * save_after_min
  $(".note-editable").focusout () ->
    console.log "stop autosave, focusout"
    clearInterval(auto_save)
    auto_save = undefined


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



  # Control S, Cmd S
  document.addEventListener "keydown", (e) ->
    if e.keyCode is 83 and ((if navigator.platform.match("Mac") then e.metaKey else e.ctrlKey))
      e.preventDefault()
      update($(".update").data("path"), false) # no refresh
      $(".save").click() # will refresh
      console.log "save"
  , false

  update = (path, refresh) ->
    bodydiv = $(".update").data "body"
    $(".update").css("background", "#FBFBFB")
    setTimeout () ->
      $(".update").css("background", "#FFFFFF")
    , 500
    stats = getWordCount($(bodydiv))
    _refresh = refresh
    data = 
      piece:
        title: $(".piece-title").val()
        body: $(bodydiv).html()
        words: stats.words
        chars: stats.chars
        chars_no_space: stats.chars_no_space
        folders: $(".piece-folders").val()

    $.ajax({
      url: path + ".json", 
      type: "put", 
      data: data,
      success: (data) -> 
        console.log "saved", _refresh
        if _refresh
          window.location.href = path 
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "error", jqXHR, textStatus, errorThrown
    })

  $(".update").click () ->
    path = $(this).data "path"
    update(path, true)


  # Save New
  $(".save").click () ->
    path = $(this).data "path"
    bodydiv = $(this).data "body"
    titlediv = $(this).data "title"

    stats = getWordCount($(bodydiv))
    data = 
      piece:
        title: $(titlediv).val()
        body: $(bodydiv).html()
        words: stats.words
        chars: stats.chars
        chars_no_space: stats.chars_no_space
        folders: $(".piece-folders").val()

    $.ajax({
      url: path + ".json", 
      type: "post", 
      data: data,
      success: (data) -> 
        window.location.href = path + "/" + data
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "error", jqXHR, textStatus, errorThrown
    })

  # Show Parts of Speech
  $(".pos-show").click () ->
    text_to_process = ".piece-body"
    $(text_to_process).hide()

    pos = $(this).data("pos")
    processed_text = $(".possed")
    processed_text.empty().hide().css("color", "#AAA")

    $(".piece-body").find("div").each () ->
      text = "text=" + $(this).text()
      _this = $(this)
      $.ajax({
        url: '/pieces/pos.json',
        type: 'GET',
        data: text,
        async: false,
        success: (data) ->
          if data.possed == null
            processed_text.append $ "<div><br /></div>"
          else
            processed_text.append $ "<div>" + data.possed + "</div>"
            processed_text.find(pos).css("color", "#f00")
        error: (jqXHR, textStatus, errorThrown) ->
          console.log "error", jqXHR, textStatus, errorThrown
      })

    processed_text.show()
    $(text_to_process).hide()

  $(".possed").click () ->
    $(this).hide()
    $(".piece-body").show().css("color", "#000")

  # Word Counter

  $(".stats").each () ->
    text_to_count = $(this).data "for"
    _this = $(this)
    wordcount = setInterval () ->
      stats = getWordCount($(text_to_count))
      _this.text("#{stats.words} words") # | #{stats.chars} chars | #{stats.chars_no_space} chars no space
    , 1000
  
  
  getWordCount = (div) ->
    words = 0
    chars = 0
    chars_no_space = 0
    i = 1
    div = $(".note-editable")

    # console.log div.children()
    i = 0
    # while i < div.children().length
    for chunk in div.children()
      # console.log chunk
      # console.log chunk.text()
      val = $.trim $(chunk).text()
      # console.log val
      val.replace("&nbsp;", " ")
      if val.replace(/\s+/gi, ' ').split(' ')[0] == ""
        word_in_line = 0
      else
        word_in_line = val.replace(/\s+/gi, ' ').split(' ').length
      char_in_line = val.length
      char_in_line_nospace = val.replace(/\s/g,"").length
      words += word_in_line
      chars_no_space += char_in_line_nospace
      chars += char_in_line
      # i++

    # while i <= div.find("div").children().length
    #   val = $.trim div.find("div:nth-child(" + i + ")").text()
    #   if val.replace(/\s+/gi, ' ').split(' ')[0] == ""
    #     word_in_line = 0
    #   else
    #     word_in_line = val.replace(/\s+/gi, ' ').split(' ').length
    #   char_in_line = val.length
    #   char_in_line_nospace = val.replace(/\s/g,"").length
    #   words += word_in_line
    #   chars_no_space += char_in_line_nospace
    #   chars += char_in_line
    #   i++

    obj = 
      words: words
      chars: chars
      chars_no_space: chars_no_space

    obj