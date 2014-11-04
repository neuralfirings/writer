# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready -> 
  $(".editme").attr "contenteditable", "true"

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
    console.log data, path

    $.ajax({
      url: path + ".json", 
      type: "post", 
      data: data,
      success: (data) -> 
        window.location.href = path + "/" + data
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "error", jqXHR, textStatus, errorThrown
    })

  $(".update").click () ->
    path = $(this).data "path"
    bodydiv = $(this).data "body"
    stats = getWordCount($(bodydiv))
    data = 
      piece:
        title: $($(this).data "title").val()
        body: $(bodydiv).html()
        words: stats.words
        chars: stats.chars
        chars_no_space: stats.chars_no_space
    console.log data, path

    $.ajax({
      url: path + ".json", 
      type: "put", 
      data: data,
      success: (data) -> 
        console.log "success", data
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "error", jqXHR, textStatus, errorThrown
    })


  # Show Parts of Speech
  $(".pos-show").click () ->
    text_to_process = $(this).data "for"
    $(text_to_process).css("color", "#CCC")

    pos = $(this).data("pos")
    processed_text = $(".possed").empty().hide()
    processed_text.css("color", "#AAA")

    $(text_to_process).find("div").each () ->
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

    $(".possed").show()
    $(text_to_process).hide()

  $(".possed").click () ->
    $(this).hide()
    $($(this).data("toggle")).show().css("color", "#000")

  # Word Counter

  $(".stats").each () ->
    text_to_count = $(this).data "for"
    _this = $(this)
    wordcount = setInterval () ->
      stats = getWordCount($(text_to_count))
      _this.text("#{stats.words} words | #{stats.chars} chars | #{stats.chars_no_space} chars no space")
    , 1000
  
  getWordCount = (div) ->
    words = 0
    chars = 0
    chars_no_space = 0
    i = 1

    while i <= div.find("div").length
      val = $.trim div.find("div:nth-child(" + i + ")").text()
      if val.replace(/\s+/gi, ' ').split(' ')[0] == ""
        word_in_line = 0
      else
        word_in_line = val.replace(/\s+/gi, ' ').split(' ').length
      char_in_line = val.length
      char_in_line_nospace = val.replace(/\s/g,"").length
      words += word_in_line
      chars_no_space += char_in_line_nospace
      chars += char_in_line
      i++

    obj = 
      words: words
      chars: chars
      chars_no_space: chars_no_space

    obj

