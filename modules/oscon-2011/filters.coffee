#----------------------------------------------------------------------
Filters = {
    day: "Monday"
    fav: false
}

#----------------------------------------------------------------------
freeze = () ->
    localStorage.setItem("filters", JSON.stringify(Filters))

#----------------------------------------------------------------------
thaw = () ->
    s = localStorage.getItem("filters")
    return if !s
    Filters = JSON.parse(s)

#----------------------------------------------------------------------
exports.setupFilters = () ->
    thaw()
    installListeners()

    $(".button-day-#{Filters.day}").addClass("on")
    
    if Filters.fav
        $(".button-fav").addClass("on")

    filterEntries()
    
#----------------------------------------------------------------------
filterFav = () ->
    if !$(this).hasClass("fav") 
        $(this).hide()

#----------------------------------------------------------------------
filterEntries = () ->
    $(".event").hide()
    $(".description").hide()
    $(".day-divider").hide()
    
    $(".day-#{Filters.day}").css("display", "table-row")
    
    if Filters.fav
        $(".event").each(filterFav)
    
#----------------------------------------------------------------------
installListeners = () ->
    days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    
    for day in days
        $(".button-day-" + day).click({day:day}, clickedDay)

    $(".button-fav").click(clickedFav)
    
#----------------------------------------------------------------------
clickedDay = (event) ->
    $(".button-day-#{Filters.day}").removeClass("on")

    Filters.day = event.data.day
    
    $(".button-day-#{Filters.day}").addClass("on")
    
    freeze()
    filterEntries()
    
#----------------------------------------------------------------------
clickedFav = (event) ->
    if Filters.fav
        Filters.fav = false
        $(".button-fav").removeClass("on")
        
    else
        Filters.fav = true
        $(".button-fav").addClass("on")

    freeze()
    filterEntries()
