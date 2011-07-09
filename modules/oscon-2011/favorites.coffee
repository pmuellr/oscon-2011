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
addFavorite = (id, element) ->
    Favorites[id] = true
    freeze()
    $(element).html(StarFilled)
    $(element).css("color", StarColor)

#----------------------------------------------------------------------
removeFavorite = (id, element) ->
    delete Favorites[id]
    freeze()
    $(element).html(StarEmpty)
    $(element).css("color", "#000000")

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
    
#----------------------------------------------------------------------
exports.getFavorites = () ->
    return _.keys(Favorites)
    
#----------------------------------------------------------------------
thaw()

    