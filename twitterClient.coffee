config = require "config"
request = require "request"
twitterApi = require "twitter"
class TwitterClient
    constructor: () ->
        @twitter = new twitterApi
            consumer_key: config.twitter.consumerKey
            consumer_secret: config.twitter.consumerSecret
            access_token_key: config.twitter.botToken
            access_token_secret: config.twitter.botTokenSecret
        return @
    roomTweet: (screen_name, beacon) ->
        if screen_name? and beacon?
            text = "#{screen_name} は ##{beacon.room}_#{beacon.name} にいるぞ → http://tokyo-bb.cs8.biz/  #tokyo0505"
            @tweet(text)
    tweet: (text, done) ->
        @twitter.updateStatus text, (data) =>
            if done?
                done(data, {result:"succeed"})
exports.TwitterClient = TwitterClient
