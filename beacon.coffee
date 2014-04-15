request = require "superagent"

Bleacon = require "bleacon"
Bleacon.startScanning()

console.log "start scanning"
console.log Bleacon

proximity_list = [ "immediate", "near", "far"]
Bleacon.on "discover", (bcon)->
    if bcon.proximity is "immediate"
        uuid = "#{bcon.major}-#{bcon.minor}"
        console.log "discover #{uuid}, post"
        request.post("http://yuiseki.net:3000/beacon")
                .set('Content-Type', 'application/json')
                .send({uuid:uuid})
                .end (res)->
                   console.log res
