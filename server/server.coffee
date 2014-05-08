Hapi = require "hapi"
TeamsFetcher = require("./teamsFetcher")

defaults =
  port: +process.env.PORT or 8000

server = new Hapi.Server defaults.port, "0.0.0.0",
  cache: 'catbox-redis'

HOUR = 1000 * 60 * 60

server.method 'getTeams', TeamsFetcher.getTeams,
  cache:
    expiresIn: 1 * HOUR
    shared: true

server.route([
  {
    method: "GET",
    path: "/teams",
    config:
      handler: server.methods.getTeams
      cache:
        expiresIn: 1 * HOUR
  },
  {
    method: "GET",
    path: "/{path*}",
    handler:
      directory:
        path: "./app",
        listing: false,
        index: true
  }
])

server.start ->
  server.info.uri = if process.env.HOST? then "http://#{process.env.HOST}:#{process.env.PORT}" else server.info.uri
  console.log "Server started at #{server.info.uri}"
