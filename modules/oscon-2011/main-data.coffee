
#----------------------------------------------------------------------
ical = require "ical"

#----------------------------------------------------------------------
exports.main = () ->
    processCalendar("oscon", "oscon.ics")
    processCalendar("data",  "data.ics")
    processCalendar("java",  "java.ics")

#----------------------------------------------------------------------
xhrError = (jqXHR, textStatus, errorThrown) ->
    alert("error XHRing '" + jqXHR.url + "': " + errorThrown)

#----------------------------------------------------------------------
fixEntry = (entry, conference) ->
    entry.conference = conference
    entry

#----------------------------------------------------------------------
toHtml = (entry) ->
    "<pre>" + JSON.stringify(entry,null,4) + "</pre>"

#----------------------------------------------------------------------
xhrSuccess = (data, textStatus, jqXHR) ->
    conference = jqXHR.conference

    entries = ical.parseICS(data)
    
    entries = (fixEntry(entry, conference) for id, entry of entries)
    
    htmlEntries = (toHtml(entry) for entry in entries)
    
    $(".list-entries.#{conference}").html(htmlEntries.join("\n"))
    
#----------------------------------------------------------------------
processCalendar = (conference, url) ->

    xhrSettings =
        error:   xhrError
        success: xhrSuccess
        
    xhr = $.ajax(url, xhrSettings)
    xhr.conference = conference
    xhr.url        = url