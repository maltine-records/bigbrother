mongoose = require "mongoose"
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
{TwitterClient} = require "../twitterClient"

userSchema = new Schema
    uuid: {type:String, index: {unique:true, dropDups:true}}
    screen_name: String
    icon_url: String
    followers_count: Number
    soku: Number
    proximity: Number
    beacon: {type: Schema.Types.ObjectId, ref: "Beacon"}

userSchema.set "toJSON",
    transform: (doc, ret, options)->
        uuid: ret.uuid
        screen_name: ret.screen_name
        icon_url: ret.icon_url
        followers_count: ret.followers_count
        soku: ret.soku
        proximity: ret.proximity
        beacon_uuid: ret.beacon.uuid

userSchema.statics.getsByBeacon = (beacon, done) ->
    @find({beacon:beacon}).exec (err, users)->
        done users

userSchema.methods.setBeaconByUUID = (uuid, done) ->
    Beacon = mongoose.model('Beacon')
    Beacon.findOne {uuid:uuid}, (err, beacon)=>
        time = new Date()
        if beacon?
            if true#@proximity > 0
                console.log "#{time}, #{@screen_name}, #{beacon.room}, #{beacon.name}, #{beacon.lat}, #{beacon.lon}"
                @beacon = beacon
                @save => done(@)
            if @proximity > 0
                console.log "tweet"
                twCli = new TwitterClient
                twCli.roomTweet(@screen_name, beacon)
        else
            if true#@proximity > 0
                beacon = new Beacon(uuid:uuid)
                console.log "#{time}, #{@screen_name}, #{beacon.uuid}"
                beacon.save =>
                    @beacon = beacon
                    @save => done(@)

userSchema.methods.update = (data, done) ->
    atts = ["screen_name", "icon_url", "followers_count", "soku", "proximity"]
    for attr in atts
        if data[attr]?
            @[attr] = data[attr]
    if data.beacon_uuid?
        @setBeaconByUUID data.beacon_uuid, (res)->
            done res
    else
        @save => done(@)

exports.userSchema = userSchema
User = mongoose.model "User", userSchema
exports.User = User
