request = require "superagent"

data =
    uuid: "hoge-user-uuid"
    screen_name: "hoge"
    icon_url: "http://oq.la/i"
    beacon_uuid: "0000000031d91001b000001c4dc4c8af-0-1"

req = request.post "http://yuiseki.net:3000/user"
req = req.set 'Content-Type', 'application/json'
req = req.send data
req.end (res)->
    console.log res.body
    console.log res.status
