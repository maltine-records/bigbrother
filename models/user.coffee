mongoose = require "mongoose"
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

userSchema = new Schema
    uuid: {type:String, index: {unique:true, dropDups:true}}
    screen_name: String
    icon_url: String
    soku: Number
    proximity: Number
    beacon: {type: Schema.Types.ObjectId, ref: "Beacon"}

userSchema.set "toJSON",
    transform: (doc, ret, options)->
        uuid: ret.uuid
        screen_name: ret.screen_name
        icon_url: ret.icon_url
        soku: ret.soku
        proximity: ret.proximity
        beacon_uuid: ret.beacon.uuid

userSchema.statics.getsByBeacon = (beacon, done) ->
    @find({beacon:beacon}).exec (err, users)->
        done users

userSchema.methods.setBeaconByUUID = (uuid, done) ->
    Beacon = mongoose.model('Beacon')
    Beacon.findOne {uuid:uuid}, (err, beacon)=>
        if beacon?
            console.log "exists beacon", beacon
            @beacon = beacon
            @save => done(@)
        else
            beacon = new Beacon(uuid:uuid)
            console.log "new beacon", beacon
            beacon.save =>
                @beacon = beacon
                @save => done(@)

userSchema.methods.update = (data, done) ->
    atts = ["screen_name", "icon_url", "soku", "proximity"]
    for attr in atts
        if data[attr]?
            console.log attr, data[attr]
            @[attr] = data[attr]
    if data.beacon_uuid?
        @setBeaconByUUID data.beacon_uuid, (res)->
            done res
    else
        @save => done(@)

exports.userSchema = userSchema
User = mongoose.model "User", userSchema
exports.User = User
