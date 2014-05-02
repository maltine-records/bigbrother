config = require "config"
console.log config

mongoose = require "mongoose"
mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"

async = require 'async'

{User} = require "../models/user"
{Beacon} = require "../models/beacon"

Beacon.find({}).sort({uuid:1}).exec (err, beacons) ->
    console.log beacons.length
    async.eachSeries beacons
    , (beaconn, next)->
        console.log 0
        if beaconn.uuid.indexOf("00000000")==0
            for idx in [1..5]
                userid = beaconn.uuid+"-"+idx
                User.findOne {uuid:userid}, (err, user)->
                    console.log beaconn.uuid
                    user.beacon = beaconn
                    user.save()
                    next()
        else
            next()
    , (err) ->
       console.log "err", err
