mongoose = require "mongoose"
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

beaconSchema = new Schema
    uuid: {type:String, index: {unique:true, dropDups:true}}
    name: String
    room: String
    lat: Number
    lon: Number

beaconSchema.set "toJSON",
    transform: (doc, ret, options)->
        uuid: ret.uuid
        name: ret.name
        room: ret.room
        lat: ret.lat
        lon: ret.lon

beaconSchema.methods.getUsers = (done) ->
    User = mongoose.model('User')
    User.find {beacon:@}, (err, users)->
        done users

exports.beaconSchema = beaconSchema
Beacon = mongoose.model "Beacon", beaconSchema
exports.Beacon = Beacon
