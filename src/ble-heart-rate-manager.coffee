{EventEmitter} = require 'events'
noble          = require 'noble'
debug          = require('debug')('meshblu-connector-ble-heartrate:ble-heart-rate-manager')

HEART_RATE_SERVICE        = '180d'
HEART_RATE_CHARACTERISTIC = '2a37'
ON_STATE                  = 'poweredOn'

class BleHeartRateManager extends EventEmitter
  constructor: ->
    # hook for testing
    @noble = noble
    process.on 'exit', @close
    @noble.on 'discover', @_onDiscover

  close: (callback=->) =>
    @_stopScanning()
    @peripheral?.disconnect()
    @characteristic?.notify false
    callback()

  connect: ({}, callback) =>
    @noble.on 'stateChange',  (state) =>
      return unless state == ON_STATE
      @_startScanning()
      callback()

  _onDiscover: (peripheral) =>
    console.log {peripheral}
    debug 'discovered', peripheral.uuid

    peripheral.connect (error) =>
      debug 'connected to peripheral', error: error
      return callback error if error?
      @peripheral = peripheral
      @stopScanning()
      callback null, @peripheral

  _startScanning: =>
    @noble.startScanning [HEART_RATE_SERVICE], false

  _stopScanning: =>
    @noble.stopScanning()

module.exports = BleHeartRateManager
