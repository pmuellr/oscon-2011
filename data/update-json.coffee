#!/usr/bin/env coffee

ical = require "ical"
_    = require "underscore"

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

#---------------------------------------------------------------------
setCalendarName = (calendarName, records) ->
    _.each(records, (val, key) ->
        val.calendarName = calendarName
    )
    
    records

#---------------------------------------------------------------------
right2 = (number, fill) ->
    return "" + number if number >= 10
    return fill + number
    
#---------------------------------------------------------------------
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

#---------------------------------------------------------------------
entryEnhance = (entry) ->
    entryEnhanceDate(entry, entry.start, "dateS")
    entryEnhanceDate(entry, entry.end,   "dateE")
    
    millis  = entry.end.getTime() - entry.start.getTime()
    seconds = Math.floor(millis / 1000)
    minutes = Math.floor(seconds / 60)
    hours   = Math.floor(minutes / 60)
    minutes -= hours * 60
    
    entry.length = hours + ":" + right2(minutes,"0")
    
    entry.uid = entry.uid.replace(/\:|\/|\.|\-/g, "_")
    
    delete entry.type
    delete entry.params


#---------------------------------------------------------------------

allRecords = {}

_.extend(allRecords, 
    setCalendarName("oscon", ical.parseFile("oscon.ics")),
    setCalendarName("data",  ical.parseFile("data.ics")),
    setCalendarName("java",  ical.parseFile("java.ics"))
)

for id, entry of allRecords
    entryEnhance(entry)

oFileName = "calendar.json.js"

console.log("CalendarEntries = #{JSON.stringify(_.values(allRecords))}")

