config = require "config"

mongoose = require "mongoose"
mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"

{User} = require "../models/user"

User.find {beacon:{$exists:true}}, (err, users)->
    if not users?
        console.log err
        return
    for user in users
        user.beacon = null
        console.log user
        user.save()

