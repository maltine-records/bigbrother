bigbrother
==========

## setup
```
npm install coffee-script -g
npm install mocha -g
npm install
```

## run
```
npm start
```

## test
```
npm test
```


## API

### GET /user

- response

```
{
    "beacon-uuid":{
        name: "name",
        lat: 35.3535,
        lon: 139.3939,
        users:[
            {
                uuid: "user1-uuid",
                screen_name: "hoge",
                icon_url: "http://oq.la/i",
                beacon_uuid: "beacon-uuid"
            },
            {
                uuid: "user2-uuid",
                screen_name: "huga",
                icon_url: "http://yuiseki.net/i",
                beacon_uuid: "beacon-uuid"
            }
        ]
    }
}
```


### POST /user

- request headers
'Content-Type': 'application/json'

- request params
    - uuid          : required. vender uuid of client device
    - screen_name   : optional. ピンに表示される名前
    - icon_url      : optional. ピンに表示される画像
    - followers_count: optional. twitterフォロワー数
    - beacon_uuid   : optional. 一番近いビーコンのuuid
    - proximity     : optional. 一番近いビーコンまでの距離

```
{
"uuid": "user-ios-uuid",
"screen_name": "unko"
"icon_url": "http://oq.la/i",
"followers_count": 500
"beacon_uuid": "beacon-uuid",
"proximity": 10,
}
```


- response

```
succeed
```



