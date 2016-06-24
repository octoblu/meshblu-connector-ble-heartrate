_              = require 'lodash'
{EventEmitter} = require 'events'
debug          = require('debug')('meshblu-connector-ble-heartrate:ble-heart-rate-manager')
parseHeartRate = require './heart-rate-parser'

if process.env.SKIP_REQUIRE_NOBLE == 'true'
  noble = new EventEmitter
else
  try
    noble = require 'noble'
  catch error
    console.error error

HEART_RATE_SERVICE        = '180d'
HEART_RATE_CHARACTERISTIC = '2a37'
ON_STATE                  = 'poweredOn'

class BleHeartRateManager extends EventEmitter
  constructor: ->
    # hook for testing
    @noble = noble
    {@state} = @noble
    process.on 'exit', @close
    @noble.on 'discover', @_onDiscover
    @noble.on 'stateChange', @_onStateChange

  close: (callback=->) =>
    @_stopScanning()
    @_disconnect()
    callback()

  connect: ({@autoDiscover, @localName}, callback) =>
    @_emit = _.throttle @emit, 500, {leading: true, trailing: false}
    @_startScanning()
    callback()

  _disconnect: (callback=->) =>
    if @peripheral?
      @peripheral?.disconnect()
      delete @peripheral

    if @characteristic?
      @characteristic.removeAllListeners 'data'
      @characteristic.unsubscribe()
      delete @characteristic

    callback()

  _onData: (rawData) =>
    data = parseHeartRate rawData
    @_emit 'data', heartRate: data

  _onDisconnect: =>
    @_disconnect =>
      @_startScanning()

  _onDiscover: (peripheral) =>
    debug 'discovered', peripheral.uuid

    peripheral.connect (error) =>
      return if error?
      @_onPeripheral peripheral, (error) =>
        return @_disconnect() if error?

  _onPeripheral: (@peripheral, callback) =>
    unless @autoDiscover
      return callback new Error 'localName does not match' unless @localName == @peripheral?.advertisement?.localName

    @peripheral.discoverSomeServicesAndCharacteristics [HEART_RATE_SERVICE], [HEART_RATE_CHARACTERISTIC], (error, services, [characteristic]) =>
      return callback error if error?
      return callback new Error 'Characteristic not found' unless characteristic?
      @_onCharacteristic characteristic
      @_stopScanning()
      @peripheral.once 'disconnect', @_onDisconnect

  _onCharacteristic: (@characteristic) =>
    @characteristic.on 'data', @_onData
    @characteristic.read (error, data) =>
      return if error?
      @_onData data
    @characteristic.subscribe()

  _onStateChange: (@state) =>
    @_startScanning()

  _startScanning: =>
    return unless @state == ON_STATE
    @_disconnect =>
      @noble.startScanning [HEART_RATE_SERVICE], false

  _stopScanning: =>
    @noble.stopScanning()

module.exports = BleHeartRateManager
