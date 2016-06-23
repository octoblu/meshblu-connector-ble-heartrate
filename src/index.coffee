{EventEmitter}      = require 'events'
debug               = require('debug')('meshblu-connector-ble-heartrate:index')
BleHeartRateManager = require './ble-heart-rate-manager'

class Connector extends EventEmitter
  constructor: ->
    @bleHeartRate = new BleHeartRateManager
    @bleHeartRate.on 'data', @_onData

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    callback()

  onConfig: (device={}, callback=->) =>
    { @options } = device
    debug 'on config', @options
    { autoDiscover, localName } = @options ? {}
    @bleHeartRate.connect { autoDiscover, localName }, callback

  _onData: (data) =>
    @emit 'message', {devices: ['*'], data}

  start: (device, callback) =>
    debug 'started'
    @onConfig device, callback

module.exports = Connector
