#----------------------------------------------------------------------
exports.setupTools = () ->
    $(".button-tools").bind("click", (event) ->
        tools = $(".tools")
        toolsButton = $(".button-tools")
        
        if tools.hasClass "show"
            tools.removeClass "show"
            toolsButton.removeClass "on"
        else
            tools.addClass "show"
            toolsButton.addClass "on"
    )
    
