config = require "config"
dburi = "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"

expect = require("chai").expect
mongoose = require "mongoose"
{User} = require "../models/user"
clearDB = require('mocha-mongoose')(dburi, {noClear:true})

testModelBeacon = require "./test-model-beacon"

exports.createUser = ->
    return new User
        uuid: "test-uuid"
        screen_name: "tester"
        icon_url: "http://yuiseki.net/i"

exports.setBeaconToUser = (done) ->
    beacon = testModelBeacon.createBeacon()
    beacon.save ->
        user = exports.createUser()
        user.setBeaconByUUID beacon.uuid, ->
            done {
                user: user
                beacon: beacon
            }

describe "spec for user model", ->
    before (done) ->
        if (mongoose.connection.db)
            return done()
        mongoose.connect dburi, done
    beforeEach (done) ->
        clearDB done

    it "newしてsaveできる", (done) ->
        user = exports.createUser()
        user.save(done)

    it "new, save, findできる", (done) ->
        user = exports.createUser()
        user.save ->
            User.find {}, (err, docs) =>
                expect(docs.length).to.equal 1
                user_ = docs[0]
                expect(user_.uuid).to.equal "test-uuid"
                done()

    it "beaconをセットできる", (done) ->
        exports.setBeaconToUser (res)->
            User.find({}).populate("beacon").exec (err, docs) =>
                expect(docs.length).to.equal 1
                user = docs[0]
                expect(user.beacon.uuid).to.equal res.beacon.uuid
                done()
        
    it "user.update 特定のフィールドだけ", (done) ->
        user = exports.createUser()
        data =
            screen_name: "hogehoge"
        user.update data, (res)->
            expect(res.screen_name.toString()).to.equal "hogehoge"
            done()

    it "user.update with exist beacon uuid", (done) ->
        data =
            screen_name: "hogehoge"
            beacon_uuid: "test-beacon-uuid"
        user = exports.createUser()
        beacon = testModelBeacon.createBeacon()
        beacon.save ->
            user.update data, (res)->
                expect(res.screen_name.toString()).to.equal "hogehoge"
                expect(res.beacon.toString()).to.equal beacon.id
                beacon.getUsers (users)->
                    expect(users.length).to.equal 1
                    expect users[0].screen_name == "hogehoge"
                    done()

    it "user.update with new beacon uuid", (done) ->
        data =
            screen_name: "hogehoge"
            beacon_uuid: "test-beacon-uuid-new"
        user = exports.createUser()
        user.save ->
            user.update data, (res)->
                expect(res.screen_name.toString()).to.equal "hogehoge"
                expect(res.beacon).to.be.ok
                #expect(res.beacon).to.equal "test-beacon-uuid-new"
                done()



