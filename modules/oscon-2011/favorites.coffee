#----------------------------------------------------------------------
_ = require "underscore"

#----------------------------------------------------------------------
StarFilled = "&#x2605;"
StarEmpty  = "&#x2606;"
StarColor  = "#DDB700" # "#FFD700"

Favorites = {}

#----------------------------------------------------------------------
freeze = () ->
    localStorage.setItem("favorites", JSON.stringify(Favorites))

#----------------------------------------------------------------------
thaw = () ->
    s = localStorage.getItem("favorites")
    return if !s
    Favorites = JSON.parse(s)

#----------------------------------------------------------------------
highlightFavorite = (id) ->
    $("##{id}").addClass("fav")
    $("##{id} .fav-button").html(StarFilled)

#----------------------------------------------------------------------
addFavorite = (id) ->
    Favorites[id] = true
    freeze()
    highlightFavorite(id)

#----------------------------------------------------------------------
removeFavorite = (id) ->
    delete Favorites[id]
    freeze()
    $("##{id}").removeClass("fav")
    $("##{id} .fav-button").html(StarEmpty)

#----------------------------------------------------------------------
favoriteClicked = (element) ->
    eventId = element.parentElement.id
    if Favorites[eventId]
        removeFavorite(eventId, element)
    else
        addFavorite(eventId, element)

#----------------------------------------------------------------------
exports.setupFavorites = () ->
    $(".fav-button").bind("click", (event) ->
        favoriteClicked(this)
        event.stopPropagation()
    )
    
    highlightFavorite(id) for id, junk of Favorites 
    
#----------------------------------------------------------------------
exports.getFavorites = () ->
    return _.keys(Favorites)
    
#----------------------------------------------------------------------
thaw()

    