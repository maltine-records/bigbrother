config = require "config"
console.log "load config", JSON.stringify config, "\n"

http = require "http"
express = require "express"
bodyParser = require "body-parser"
logger = require "morgan"
#socketio = require "socket.io"


mongoose = require "mongoose"
mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"

{User} = require "./models/user"
{Beacon} = require "./models/beacon"

app = express()
#app.use express.static __dirname+"/public"
app.use bodyParser()
app.use logger("dev")
app.set "views", __dirname+"/views"
app.set "view engine", "jade"

app.get "/", (req, res) ->
    Beacon.find({}).sort({uuid:1}).exec (err, beacons) ->
        res.render "index", {beacons:beacons, pretty:true}

### Beacon ###

# GET /beacon
# ビーコンの一覧を取得する
app.get "/beacon", (req, res) ->
    Beacon.find {}, (err, beacons) =>
        res.send beacons

# POST /beacon
# ビーコンを新規作成または更新する
app.post "/beacon", (req, res) ->
    console.log "/beacon", req.body
    b = new Beacon
        uuid: req.body.uuid
    b.save ->
        res.send {result:"succeed"}

# GET /beacon/:uuid
# 特定のビーコンの情報と、その近くにいるユーザーの一覧を取得する
app.get "/beacon/:uuid", (req, res) ->
    console.log req.params.uuid
    Beacon.findOne {uuid:req.params.uuid}, (err, beacon) ->
        if beacon?
            beacon.getUsers (users) ->
                res.send
                    beacon:beacon
                    users: users
        else
            res.send {result:"failed", reason:"beacon not found"}, 401

app.get "/beacon/:uuid/html", (req, res) ->
    Beacon.findOne {uuid:req.params.uuid}, (err, beacon) ->
        if beacon?
            beacon.getUsers (users) ->
            res.render "beacon", {beacon:beacon}
        else
            res.send "beacon not found", 401

app.post "/beacon/:uuid/html", (req, res) ->
    console.log req.body
    Beacon.findOne {uuid:req.params.uuid}, (err, beacon) ->
        if beacon?
            beacon.name = req.body.name
            beacon.lat = req.body.lat
            beacon.lon = req.body.lon
            beacon.save ->
                res.redirect "/"
        else
            res.send "beacon not found", 401

### User ###

# GET /user
# userの一覧を取得する
app.get "/user", (req, res) ->
    resp = {}
    User.find({}).populate("beacon").exec (err, users)->
        for user in users
            if user.beacon?
                if resp[user.beacon.uuid]?
                    resp[user.beacon.uuid]["users"].push user.toJSON()
                else
                    if user.beacon.lon? and user.beacon.lat?
                        resp[user.beacon.uuid] = {}
                        resp[user.beacon.uuid].name = user.beacon.name
                        resp[user.beacon.uuid].lon = user.beacon.lon
                        resp[user.beacon.uuid].lat = user.beacon.lat
                        resp[user.beacon.uuid]["users"] = new Array()
                        resp[user.beacon.uuid]["users"].push user.toJSON()
        res.send resp

# POST /user
# userのプロパティを更新する
# 存在しなければ作成する
# beaconもuuidにあうものが存在しなければ作成する
# { uuid, screen_name, icon_url, 
#   soku
#   beacon_uuid, proximity}
app.post "/user", (req, res) ->
    data = req.body
    if not data.uuid?
        console.log "uuid not found", data
        res.send {result:"failed", reason:"uuid is required"}, 401
    User.findOne {uuid:data.uuid}, (err, user) ->
        if user?
            user.update data, ->
                res.send {result:"succeed"}
        else
            user = new User({uuid:data.uuid})
            user.save ->
                user.update data, ->
                    res.send {result:"succeed"}

module.exports = app
if not module.parent
    server = http.createServer(app).listen(config.http.port)
    console.log "app start #{config.http.port}"
