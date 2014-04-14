config = require "config"
dburi = "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"

{expect} = require "chai"
mongoose = require "mongoose"
{Beacon} = require "../models/beacon"
clearDB = require('mocha-mongoose')(dburi, {noClear:true})

testModelUser = require "./test-model-user"

exports.createBeacon = ->
    return new Beacon
        uuid: "test-beacon-uuid"
        name: "test beacon"

describe "spec for beacon model", ->
    before (done) ->
        if (mongoose.connection.db)
            return done()
        mongoose.connect dburi, done
    beforeEach (done) ->
        clearDB done

    it "newしてsaveできる", (done) ->
        beacon = exports.createBeacon()
        beacon.save(done)

    it "beacon.getUsers", (done) ->
        testModelUser.setBeaconToUser (res)->
            res.beacon.getUsers (users)->
                expect(users.length).to.be.equal 1
                done()




