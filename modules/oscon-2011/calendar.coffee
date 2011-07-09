#----------------------------------------------------------------------
ical     = require "ical"
Backbone = require "backbone"
_        = require "underscore"

#----------------------------------------------------------------------
Calendars       = {}
Entries         = {}
Callbacks       = []
Events          = {}
SavedEntries    = {}
OutstandingXHRs = 0

_.extend(Events, Backbone.Events)

#----------------------------------------------------------------------
exports.addCalendar = (name, url) ->
    Calendars[name] = url

#----------------------------------------------------------------------
exports.events = Events

#----------------------------------------------------------------------
exports.getEntries = () ->
    if !_.isEmpty(Entries)
        Events.trigger("update", Entries)
        return
    
    cacheLoad()
    
    return if !_.isEmpty(Entries)
    
    exports.updateEntries()

#----------------------------------------------------------------------
exports.updateEntries = () ->
    SavedEntries = Entries
    Entries = {}
    for name, url of Calendars
        updateCalendar(name, url)

#----------------------------------------------------------------------
updateCalendar = (name, url) ->
    xhrSettings =
        error:   xhrError
        success: xhrSuccess
        
    xhr = $.ajax(url, xhrSettings)
    
    xhr.calendarName  = name
    xhr.url           = url
    
    OutstandingXHRs++

#----------------------------------------------------------------------
updateEntries = (entries) ->
    _.extend(Entries, entries)
    
    cacheSave()
    
    OutstandingXHRs--
    OutstandingXHRs = Math.max(0, OutstandingXHRs)
    
    Events.trigger("update", Entries) if OutstandingXHRs == 0

#----------------------------------------------------------------------
right2 = (number, fill) ->
    return "" + number if number >= 10
    return fill + number
    
#----------------------------------------------------------------------
entryEnhanceDate = (entry, date, key) ->
    entry = entry[key] = {}
    entry.month = MonthNames[date.getUTCMonth()]
    entry.date  = date.getUTCDate()
    entry.day   = DayNames[date.getUTCDay()]
    
    hr  = date.getUTCHours()
    min = date.getUTCMinutes()
    
    if hr <= 12
        ampm = "am"
    else
        ampm = "pm"
        hr -= 12
    
    entry.time = right2(hr,  " ") + ":" + 
                 right2(min, "0") + 
                 ampm

#----------------------------------------------------------------------
entryEnhance = (entry, calendarName) ->
    entry.calendarName = calendarName
    entryEnhanceDate(entry, entry.start, "dateS")
    entryEnhanceDate(entry, entry.end, "dateE")
    
    millis  = entry.end.getTime() - entry.start.getTime()
    seconds = Math.floor(millis / 1000)
    minutes = Math.floor(seconds / 60)
    hours   = Math.floor(minutes / 60)
    minutes -= hours * 60
    
    entry.length = hours + ":" + right2(minutes,"0")
    
    entry.uid = entry.uid.replace(/\:|\/|\.|\-/g, "_")
    
    delete entry.type
    delete entry.params

#----------------------------------------------------------------------
entryFreeze = (entry) ->
    entry = _.clone(entry)
    entry.start = entry.start.toUTCString()
    entry.end   = entry.end.toUTCString()
    
    delete entry.dateS
    delete entry.dateE
    
    localStorage.setItem("calendar-description-" + entry.uid, entry.description)
    
    delete entry.description
    
    entry

#----------------------------------------------------------------------
entryThaw = (entry) ->
    entry.start = new Date(entry.start)
    entry.end   = new Date(entry.end)

    entryEnhanceDate(entry, entry.start, "dateS")
    entryEnhanceDate(entry, entry.end, "dateE")

    entry.description = localStorage.getItem("calendar-description-" + entry.uid)

#----------------------------------------------------------------------
cacheSave = () ->
    return if ! window.localStorage
    
    entries = {}
    entries[id] = entryFreeze(entry) for id, entry of Entries
    
    s = JSON.stringify(entries)
    localStorage.setItem("calendar-entries", s)

#----------------------------------------------------------------------
cacheLoad = () ->
    return if ! window.localStorage
    
    s = localStorage.getItem("calendar-entries")
    return if !s
    
    try
        Entries = JSON.parse(s)
    catch error
        console.log("Unable to parse cached entries: " + e)
        
    entryThaw(entry) for id, entry of Entries
    
    Events.trigger("update", Entries)

#----------------------------------------------------------------------
xhrError = (jqXHR, textStatus, errorThrown) ->
    alert("error XHRing '" + jqXHR.url + "': " + errorThrown)
    Entries = SavedEntries

    updateEntries Entries

#----------------------------------------------------------------------
xhrSuccess = (data, textStatus, jqXHR) ->
    calendarName = jqXHR.calendarName

    entries = ical.parseICS data
    
    entryEnhance(entry, calendarName) for id, entry of entries

    updateEntries entries

#----------------------------------------------------------------------
DayNames = [ 
    "Sunday"
    "Monday"
    "Tuesday"
    "Wednesday"
    "Thursday"
    "Friday"
    "Saturday"
]

#----------------------------------------------------------------------
MonthNames = [ 
    "January"
    "February"
    "March"
    "April"
    "May"
    "June"
    "July"
    "August"
    "September"
    "October"
    "November"
    "December"
]
