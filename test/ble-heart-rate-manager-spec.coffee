{EventEmitter}      = require 'events'
BleHeartRateManager = require '../src/ble-heart-rate-manager'

describe 'BleHeartRateManager', ->
  beforeEach ->
    @sut = new BleHeartRateManager
    {@noble} = @sut
    @noble.startScanning = sinon.stub()
    @noble.stopScanning = sinon.stub()
    @noble.emit 'stateChange', 'poweredOn'
    @characteristic = new EventEmitter
    @characteristic.subscribe = sinon.stub()
    @characteristic.unsubscribe = sinon.stub()
    @characteristic.read = sinon.stub().yields null, new Buffer(2)
    @peripheral = new EventEmitter
    @peripheral.uuid = 'my-perif'
    @peripheral.connect = sinon.stub().yields null
    @peripheral.discoverSomeServicesAndCharacteristics = sinon.stub().yields null, null, [@characteristic]
    @peripheral.disconnect = sinon.stub()

  beforeEach (done) ->
    @sut.connect {autoDiscover: true}, done

  it 'should exist', ->
    expect(@sut).to.exist

  it 'should call noble.startScanning', ->
    expect(@noble.startScanning).to.have.been.calledWith ["180d"], false

  describe '-> on discover', ->
    beforeEach (done) ->
      @noble.once 'discover', => done()
      @noble.emit 'discover', @peripheral

    it 'should call peripheral.connect', ->
      expect(@peripheral.connect).to.have.been.called

    it 'should call peripheral.discoverSomeServicesAndCharacteristics', ->
      expect(@peripheral.discoverSomeServicesAndCharacteristics).to.have.been.calledWith ["180d"], ["2a37"]

    it 'should set sut.peripheral', ->
      expect(@sut.peripheral).to.equal @peripheral

    it 'should set sut.characteristic', ->
      expect(@sut.characteristic).to.equal @characteristic

    it 'should call noble.stopScanning', ->
      expect(@noble.stopScanning).to.have.been.called

    it 'should call characteristic.subscribe', ->
      expect(@characteristic.subscribe).to.have.been.called

    it 'should call characteristic.read', ->
      expect(@characteristic.read).to.have.been.called
