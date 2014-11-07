# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready () -> 
  $(".editme").attr "contenteditable", "true"
  $('.dropdown-toggle').dropdown()

  $(".folder-collapse").click () ->
    $(".folder-container").hide()
    $(".folder-collapse").hide()
    $(".folder-expand").show()
    $(".writing-container").removeClass("col-md-8").addClass("col-md-8 col-md-offset-2")
  $(".folder-expand").click () -> 
    $(".folder-container").show()
    $(".folder-collapse").show()
    $(".folder-expand").hide()
    $(".writing-container").removeClass("col-md-8 col-md-offset-2").addClass("col-md-8")


  # Resizing writing space
  $(".piece-body").height($(window).height()-135 + "px")
  $(window).resize () ->
    $(".piece-body").height($(window).height()-135 + "px")

  # Getting time spent writing & autosaving
  save_after_min = 1
  auto_save_timeout = 2
  auto_save = undefined
  last_activity_time = 0
  
  # $(".piece-body").click () ->
  #   update($(".update").data("path"), false)
  $(".piece-body").keyup () ->
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
  $(".piece-body").focusout () ->
    console.log "stop autosave, focusout"
    clearInterval(auto_save)
    auto_save = undefined

  # Initiate le Chart
  # if $("#chart-words").length == 1
  #   console.log "not all"
  #   pw = $("#chart-words").parent().width()
  #   $("#chart-words").attr("width", pw).attr("height", Number(pw)*.6)
  #   ctx = document.getElementById("chart-words").getContext("2d")
  #   chart_words_data = {
  #     labels: [],
  #     datasets: [
  #       {
  #         label: "Word Count",
  #         fillColor: "rgba(220,220,220,0.2)",
  #         strokeColor: "rgba(220,220,220,1)",
  #         pointColor: "rgba(220,220,220,1)",
  #         pointStrokeColor: "#fff",
  #         pointHighlightFill: "#fff",
  #         pointHighlightStroke: "rgba(220,220,220,1)",
  #         data: []
  #       }
  #     ]
  #   };
  #   window.cwd = chart_words_data

  #   $(".chart-words-data").find("div").each () ->
  #     chart_words_data.datasets[0].data.push $(this).data("words")
  #     chart_words_data.labels.push "" #$(this).data("created")

  #   chart_words = new Chart(ctx).Line(chart_words_data);
  #   window.cw = chart_words

  # All Words
  if $("#chart-words-all").length == 1
    pw = $("#chart-words-all").parent().width()
    $("#chart-words-all").attr("width", pw).attr("height", Number(pw)*.5)
    ctx = document.getElementById("chart-words-all").getContext("2d")
    data = {
      labels: [],
      datasets: [
        {
          label: "Word Count",
          fillColor: "rgba(220,220,220,0.2)",
          strokeColor: "rgba(220,220,220,1)",
          pointColor: "rgba(220,220,220,1)",
          pointStrokeColor: "#fff",
          pointHighlightFill: "#fff",
          pointHighlightStroke: "rgba(220,220,220,1)",
          data: []
        }
      ]
    };

    wordcounts = {}

    $(".chart-words-all-data").find("div").each () ->
      piece_id = $(this).data("piece-id")
      word_count = $(this).data("words")
      created_date = $(this).data("created")

      if wordcounts[created_date] == undefined
        wordcounts[created_date] = []
      wordcounts[created_date][piece_id] = word_count

    # start
    data.datasets[0].data.push 0
    data.labels.push ""

    window.wc = wordcounts
    piece_wordcount_holder = []
    for datename, date of wordcounts
      total_words = 0
      for piece_id, words of date
        if words != undefined and words != NaN
          if $(".chart-words-all-data").data("cumulative") == "no"
            if piece_wordcount_holder[piece_id] == undefined
              piece_wordcount_holder[piece_id] = Number(words)
            else  
              # console.log "hello",piece_id, Number(words), piece_wordcount_holder[piece_id]
              old_piece_word = piece_wordcount_holder[piece_id]
              piece_wordcount_holder[piece_id] = Number(words)
              words = Math.max(0, Number(words) - old_piece_word)
          total_words += Number(words)
      data.datasets[0].data.push total_words
      data.labels.push datename
    chart_words = new Chart(ctx).Line(data);
    window.cw = chart_words



  # Go Full Screen
  $(".full-screen").hide()
  $(".full-screen").click () ->
    el = document.documentElement
    rfs = el.requestFullScreen || el.webkitRequestFullScreen || el.mozRequestFullScreen
    rfs.call el

  # Wrap Piece-Body in divs
  divved_html = $ "<div></div>"
  $(".piece-body").contents().each () ->
    if $(this)[0].nodeType == Node.TEXT_NODE
      temp = $ "<div></div>"
      temp.append $(this)
      divved_html.append temp
    else
      divved_html.append $(this)
  $(".piece-body").html(divved_html.html())

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

  update = (path, refresh) ->
    bodydiv = $(".update").data "body"
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
    $.update(path, true)
    # path = $(this).data "path"
    # bodydiv = $(this).data "body"
    # stats = getWordCount($(bodydiv))
    # data = 
    #   piece:
    #     title: $($(this).data "title").val()
    #     body: $(bodydiv).html()
    #     words: stats.words
    #     chars: stats.chars
    #     chars_no_space: stats.chars_no_space
    #     folders: $(".piece-folders").val()
    # console.log data, path

    # $.ajax({
    #   url: path + ".json", 
    #   type: "put", 
    #   data: data,
    #   success: (data) -> 
    #     console.log "saved"
    #     window.location.href = path 
    #   error: (jqXHR, textStatus, errorThrown) ->
    #     console.log "error", jqXHR, textStatus, errorThrown
    # })


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
