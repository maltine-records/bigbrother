mongoose = require "mongoose"
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

beaconSchema = new Schema
    uuid: {type:String, index: {unique:true, dropDups:true}}
    name: String

beaconSchema.set "toJSON",
    transform: (doc, ret, options)->
        uuid: ret.uuid
        name: ret.name

beaconSchema.methods.getUsers = (done) ->
    User = mongoose.model('User')
    User.find {beacon:@}, (err, users)->
        done users

exports.beaconSchema = beaconSchema
Beacon = mongoose.model "Beacon", beaconSchema
exports.Beacon = Beacon
