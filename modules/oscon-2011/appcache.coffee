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
exports.installListeners = () ->
    addAppCacheListeners()
    stark_diags()

#----------------------------------------------------------------------
cacheStatusValues = []

stark_diags = () ->
    cacheStatusValues[0] = 'uncached'
    cacheStatusValues[1] = 'idle'
    cacheStatusValues[2] = 'checking'
    cacheStatusValues[3] = 'downloading'
    cacheStatusValues[4] = 'updateready'
    cacheStatusValues[5] = 'obsolete'
    
    cache = window.applicationCache
    cache.addEventListener('cached', logEvent, false)
    cache.addEventListener('checking', logEvent, false)
    cache.addEventListener('downloading', logEvent, false)
    cache.addEventListener('error', logEvent, false)
    cache.addEventListener('noupdate', logEvent, false)
    cache.addEventListener('obsolete', logEvent, false)
    cache.addEventListener('progress', logEvent, false)
    cache.addEventListener('updateready', logEvent, false)
    
logEvent = (e) ->
    cache = window.applicationCache

    online = (navigator.onLine) ? 'yes' : 'no'
    status = cacheStatusValues[cache.status]
    type = e.type
    message = 'online: ' + online
    message+= ', event: ' + type
    message+= ', status: ' + status
    if (type == 'error' && navigator.onLine)
        message+= ' (prolly a syntax error in manifest)'

    console.log(message)
