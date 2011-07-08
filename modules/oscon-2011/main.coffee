#----------------------------------------------------------------------
aclUpdateReady = () ->
    return if (applicationCache.status != applicationCache.UPDATEREADY)
    
    console.log "app cache update ready, reloading"
    
    applicationCache.swapCache()
    window.location.reload()

#----------------------------------------------------------------------
aclError = () ->

#----------------------------------------------------------------------
addAppCacheListeners = () ->
    return if !window.applicationCache
    
    applicationCache.addEventListener("updateready", aclUpdateReady)
    applicationCache.addEventListener("error",       aclError)

#----------------------------------------------------------------------
exports.main = () ->
    addAppCacheListeners()
