# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready () -> 
  $(".editme").attr "contenteditable", "true"
  $('.dropdown-toggle').dropdown()

  $(".folder-collapse").click () ->
    $(".folder-container").hide()
    $(".folder-collapse").hide()
    $(".piece-title").hide()
    $(".hidewhenfullscreen").hide()
    $(".folder-expand").show()
    $(".writing-container").addClass("col-md-offset-2")
    $(".note-editable").css("height", $(window).height()-70 + "px")

  $(".folder-expand").click () -> 
    $(".folder-container").show()
    $(".folder-collapse").show()
    $(".piece-title").show()
    $(".hidewhenfullscreen").show()
    $(".folder-expand").hide()
    $(".writing-container").removeClass("col-md-offset-2") #.addClass("col-md-8")
    $(".note-editable").css("height", $(window).height()-135 + "px")

  # Reordering folders
  $.ajax({
    url: $("#folder").data("path-get") + ".json",
    type: "get",
    success: (data) ->
      if data.folder_order != "none"
        for i, folder of data.folder_order
          if folder.folder_id != undefined
            $("#folder").find(".panel[data-folderid='#{folder.folder_id}']").appendTo($("#folder"))
          for j, piece_id of folder.piece_order
            folderdiv = $("#folder").find(".panel[data-folderid='#{folder.folder_id}']")
            piecegroupdiv = folderdiv.find(".list-group")
            folderdiv.find(".list-group-item[data-pieceid='#{piece_id}']").appendTo piecegroupdiv
      $("#folder").show()
  })

  $("#folder").sortable({
    stop: (event, ui) ->
      update_folder_structure()
    })

  $("#folder").find(".list-group").sortable({
    stop: (event, ui) ->
      update_folder_structure()
    })

  update_folder_structure = () ->
    folder_order = {}
    j = 0
    $("#folder").find(".panel").each () ->
      obj = {folder_id: $(this).data("folderid")}
      obj.piece_order = {}

      i = 0
      $(this).find(".list-group-item").each () ->
        obj.piece_order[i] = $(this).data("pieceid")
        i++

      folder_order[j] = obj
      j++
      
    # window.obj = folder_order
    # x = JSON.stringify(folder_order)
    # console.log x

    data = "folder_order=" + JSON.stringify(folder_order)
    # console.log "data", data

    $.ajax({
      url: $("#folder").data("path") + ".json",
      data: data,
      type: "post",
      success: (data) ->
        console.log data.status
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "error", errorThrown #jqXHR, textStatus, 
    })


  # TODO merge this with pieces.js.coffee
  # Getting time spent writing & autosaving
  save_after_min = 1
  auto_save_timeout = 2
  auto_save = undefined
  last_activity_time = 0

  # All Words
  $(".chart-words").each () ->
    path = $(this).data("path")
    _show = $(this).data("show")
    dates = {} # dates --> piece --> info
    pieces = {} # pieces --> words at the end of the day
    window.d = dates
    window.p = pieces

    # Initiate the chart
    pw = $(this).parent().width()
    $(this).attr("width", pw).attr("height", Number(pw)*.5)
    chart_id = $(this).attr("id")
    ctx = document.getElementById(chart_id).getContext("2d")
    chart_data = {
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
        },
        {
          label: "Cumulative Word Count",
          fillColor: "rgba(220,220,220,0.2)",
          strokeColor: "rgba(220,220,220,1)",
          pointColor: "rgba(220,220,220,1)",
          pointStrokeColor: "#fff",
          pointHighlightFill: "#fff",
          pointHighlightStroke: "rgba(220,220,220,1)",
          data: []
        },
        {
          label: "Minutes",
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
    chart_data.datasets[0].data.push 0
    # chart_data.datasets[1].data.push 0
    # chart_data.datasets[2].data.push 0
    chart_data.labels.push ""

    if $(this).data("piece-id") != undefined
      _data = "piece_id=" + $(this).data("piece-id")
    else 
      _data = ""

    $.ajax({
      url: path + ".json",
      type: "get",
      data: _data,
      success: (data) ->
        # sort first by pieces, note: logs should already by sorted by created asc
        for d in data
          if pieces[d.piece_id] == undefined
            pieces[d.piece_id] = {}
            pieces[d.piece_id].yesterdays_words = 0
            pieces[d.piece_id].last_timestamp = 0
            # pieces[d.piece_id].total_seconds = 0


          if pieces[d.piece_id][d.created] == undefined
            pieces[d.piece_id][d.created] = {}
            pieces[d.piece_id][d.created].total_seconds = 0

          
          if pieces[d.piece_id].date_marker != undefined 
            if pieces[d.piece_id].date_marker != d.created # it's a new day!
              pieces[d.piece_id][d.created].total_seconds = 0 # restart minutes counter for the day
              yesterday = pieces[d.piece_id].date_marker
              pieces[d.piece_id].yesterdays_words = pieces[d.piece_id][yesterday].word_count
              pieces[d.piece_id].date_marker = d.created

          if pieces[d.piece_id].last_timestamp == 0
            pieces[d.piece_id].last_timestamp = d.timestamp

          elapsed_seconds = d.timestamp - pieces[d.piece_id].last_timestamp 
          if elapsed_seconds < auto_save_timeout * 60 # assume there's a timeout
            pieces[d.piece_id][d.created].total_seconds += elapsed_seconds
          pieces[d.piece_id].last_timestamp = d.timestamp

          pieces[d.piece_id][d.created].word_count = d.words
          pieces[d.piece_id][d.created].word_delta = Math.max(0, d.words - pieces[d.piece_id].yesterdays_words)
          pieces[d.piece_id].date_marker = d.created

        # sort first by dates
        for d in data
          if dates[d.created] == undefined
            dates[d.created] = { word_count: 0, word_delta: 0, total_seconds: 0 }
            dates[d.created].created_display = d.created_display
          if pieces[d.piece_id][d.created].counted == undefined
            # if d.created == "2014-11-07"
            #   console.log d.piece_id, d.created, pieces[d.piece_id][d.created].word_delta, dates[d.created].word_delta
            dates[d.created].word_count += pieces[d.piece_id][d.created].word_count # JUST for pieces worked on that day though, not a very useful number
            dates[d.created].word_delta += pieces[d.piece_id][d.created].word_delta
            if isNaN(pieces[d.piece_id][d.created].total_seconds)
              dates[d.created].total_seconds += 0
              # console.log "NaN", pieces[d.piece_id][d.created].total_seconds
            else
              dates[d.created].total_seconds += pieces[d.piece_id][d.created].total_seconds
            pieces[d.piece_id][d.created].counted = true
          # dates[d.created].created_display = d.created_display

        # add values to chart
        minutes_total = 0
        for key, value of dates
          # chart_data.datasets[0].data.push value.word_delta
          # chart_data.datasets[1].data.push value.word_count
          # console.log "hi", value.total_seconds, value.created_display
          # chart_data.datasets[2].data.push Math.round(value.total_seconds/60 * 10)/10 # minutes
          if _show == "wc_cumulative"
            chart_data.datasets[0].data.push value.word_count
          else if _show == "wc_per_day"
            chart_data.datasets[0].data.push value.word_delta
          else if _show == "minutes"
            chart_data.datasets[0].data.push Math.ceil(value.total_seconds/60) # minutes
          else if _show == "minutes_cumulative"
            minutes_total += Math.round(value.total_seconds/60 * 10)/10
            chart_data.datasets[0].data.push minutes_total # minutes
          chart_data.labels.push value.created_display
        chart_words = new Chart(ctx).Line(chart_data);

      error: (jqXHR, textStatus, errorThrown) ->
        console.log "error", jqXHR, textStatus, errorThrown

    })


  # Wrap Piece-Body in divs
  # divved_html = $ "<div></div>"
  # $(".piece-body").contents().each () ->
  #   if $(this)[0].nodeType == Node.TEXT_NODE
  #     temp = $ "<div></div>"
  #     temp.append $(this)
  #     divved_html.append temp
  #   else
  #     divved_html.append $(this)
  # $(".piece-body").html(divved_html.html())

