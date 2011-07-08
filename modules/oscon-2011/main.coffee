#----------------------------------------------------------------------
_        = require "underscore"

appcache = require "./appcache"
calendar = require "./calendar"

calendars = 
    oscon: "http://oscon-2011.muellerware.org/data/oscon.ics"
    data:  "http://oscon-2011.muellerware.org/data/data.ics"
    java:  "http://oscon-2011.muellerware.org/data/java.ics"

#----------------------------------------------------------------------
entryToHtml = (entry) ->
    date = "#{ entry.dateS.day } #{ entry.dateS.time }"
    cal  = entry.calendarName
    html = """ 
        <div class='entry'>
           <div class='title'       >#{ entry.summary }</div>
           <div>
               <span class='date'>#{ date } for #{ entry.length }</span>
               <span class='location'>#{ entry.location }</span>
               <span class='calendar cal-#{ cal }'>#{ cal }</span>
           </div>
           <div class='description' >#{ entry.description }</div>
        </div>
    """

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
        
    html = ""
    
    html += entryToHtml entry for entry in entries
    
    $(document).ready ()->
        $("#entries").html(html)

#----------------------------------------------------------------------
exports.main = () ->
    appcache.installListeners()

    for name, url of calendars
        calendar.addCalendar(name, url)

    calendar.events.bind("update", entriesUpdated)
    
    calendar.getEntries()
    
    # just for testing
    # calendar.updateEntries()