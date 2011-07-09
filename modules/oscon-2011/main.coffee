#----------------------------------------------------------------------
_        = require "underscore"

appcache  = require "./appcache"
calendar  = require "./calendar"
favorites = require "./favorites"

calendars = 
    oscon: "data/oscon.ics"
    data:  "data/data.ics"
    java:  "data/java.ics"

#----------------------------------------------------------------------
entryToHtml = (entry) ->
    date = "#{ entry.dateS.day } #{ entry.dateS.time }"
    cal  = entry.calendarName
    html = """ 
        <tr id='#{ entry.uid }' class='event day-#{ entry.day }'>
            <td valign='top' class='fav-button'>&#x2606;
            <td valign='top' class='time' align='right'>#{ entry.dateS.time }&nbsp;-&nbsp;
            <td valign='top' class='summary' >#{ entry.summary }
        <tr id='#{ entry.uid }-desc' class='description'>
            <td>&nbsp;
            <td colspan='2'><div class='content'>#{ entry.description }</div>
    """

   #            <span class='calendar cal-#{ cal }'>#{ cal }</span>

#----------------------------------------------------------------------
entriesUpdated = (entries) ->
    console.log("calendar entries updated:")
    console.log(entries)
    
    entries = _.values(entries)
    entries.sort (a,b) ->
        return -1 if a.start   < b.start
        return  1 if a.start   > b.start
        return -1 if a.summary < b.summary
        return  1 if a.summary > b.summary
        return 0
        

    i        = 0
    lastDate = ""
    html     = []
    
    while i < entries.length
        entry = entries[i]
        if entry.dateS.day != lastDate
            lastDate = entry.dateS.day
            tr = "<tr><td class='day-divider' colspan='3'>#{entry.dateS.day}, #{entry.dateS.month} #{entry.dateS.date}"
            html.push tr
            
        html.push(entryToHtml entry)
        
        i += 1
            
        
    html = "<table width='100%'>#{html.join '\n'}</table>"
    
    $("#entries").html(html)
    
    setupDescriptions()
    favorites.setupFavorites()

#----------------------------------------------------------------------
setupDescriptions = () ->

    $(".event").bind("click", () ->
        descriptionId = this.id + "-desc"
        display = $("##{descriptionId}").css("display")
        if display == "none"
            display = "table-row"
        else
            display = "none"
            
        $("##{descriptionId}").css("display", display)
    )

    $(".description").bind("click", () ->
        $(this).css("display", "none")
    )

#----------------------------------------------------------------------
exports.main = () ->
    appcache.installListeners()

    for name, url of calendars
        calendar.addCalendar(name, url)

    calendar.events.bind("update", entriesUpdated)
    
    calendar.getEntries()
    
    $("#clear-button").bind("click", () ->
        calendar.updateEntries()
    )
    
    # just for testing
    # calendar.updateEntries()