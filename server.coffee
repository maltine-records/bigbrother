config = require "config"
console.log "load config", JSON.stringify config, "\n"

http = require "http"
express = require "express"
socketio = require "socket.io"

mongoose = require "mongoose"
mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"

{User} = require "./models/user"
{Beacon} = require "./models/beacon"

app = express()
#app.use express.static __dirname+"/public"
app.set "views", __dirname+"/views"
app.set "view engine", "jade"

app.get "/", (req, res) ->
    Beacon.find {}, (err, beacons) ->
        res.render "index", {beacons:beacons}

### Beacon ###

# GET /beacon
# ビーコンの一覧を取得する
app.get "/beacon", (req, res) ->
    Beacon.find {}, (err, beacons) ->
        res.send {beacons:beacons}

# POST /beacon
# ビーコンを新規作成する
app.post "/beacon", (req, res) ->
    b = new Beacon
        uuid: req.body.uuid
        name: req.body.name
    b.save ->
        res.send "succeed"

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
            res.send "beacon not found", 401

### User ###

# GET /user
# userの一覧を取得する
app.get "/user", (req, res) ->
    User.find({}).populate("beacon").exec (err, users)->
        res.send {users:users}

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
        res.send "failed", 401
    User.findOne {uuid:data.uuid}, (err, user) ->
        if user?
            user.update data, ->
                res.send "succeed"
        else
            user = new User({uuid:data.uuid})
            user.save ->
                user.update data, ->
                    res.send "succeed"

module.exports = app
if not module.parent
    server = http.createServer(app).listen(config.http.port)
    console.log "app start #{config.http.port}"
