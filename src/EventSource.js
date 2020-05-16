"use strict"; 

exports._createEventSource = url => options => () => {
  options.https = { rejectUnauthorized:  options.httpsRejectUnauthorized }
  delete options.httpsRejectUnauthorized
  return new EventSource(url, options);
}

exports._readyState = evs => () => {
  evs.readyState 
}
exports._addEventListener = evs => e => cb => () => {
  evs.addEventListener(e, cb)
}

exports._removeEventListener = evs => e => cb => () => {
  evs.removeEventListener(e, cb)
}

exports.close = evs => () => {
  evs.close()
}

exports._onOpen = evs => cb => () => {
  evs.onopen = cb
}

exports._onMessage = evs => cb => () => {
  evs.onmessage = cb 
}

exports._onError = evs => closeError => evsError => cb => () => {
  evs.onerror = (err) => {
    if (err.status){
      const evsErr = evsError({ code: err.status, message: status.message })
      return cb(evsErr)()
    }

    return cb(closeError(err.message))()
  }
}