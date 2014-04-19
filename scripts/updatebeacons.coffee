config = require "config"

mongoose = require "mongoose"
mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"

{Beacon} = require "../models/beacon"

Beacon.find({}).sort({uuid:1}).exec (err, beacons) ->
    for beacon in beacons
        idx = beacon.uuid.indexOf("-", 0)
        count = 0
        while idx >= 0
            idx = beacon.uuid.indexOf "-", ++idx
            count++
        if count == 6
            console.log beacon.uuid
            beacon.remove()
        if count == 2 and beacon.uuid.length > 20
            new_uuid = beacon.uuid.toUpperCase()
            new_uuid = new_uuid.replace(/(.{8})/, "$1-")
            new_uuid = new_uuid.replace(/(.{8}-.{4})/, "$1-")
            new_uuid = new_uuid.replace(/(.{8}-.{4}-.{4})/, "$1-")
            new_uuid = new_uuid.replace(/(.{8}-.{4}-.{4}-.{4})/, "$1-")
            beacon.uuid = new_uuid
            console.log beacon.uuid
            beacon.save()
    #mongoose.connection.close()
