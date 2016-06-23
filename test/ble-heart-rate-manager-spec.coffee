BleHeartRateManager = require '../src/ble-heart-rate-manager'

describe 'BleHeartRateManager', ->
  beforeEach ->
    @sut = new BleHeartRateManager
    {@noble} = @sut
    # @noble.startScanning = sinon.stub()
    # @noble.stopScanning = sinon.stub()

  beforeEach (done) ->
    @sut.connect {}, done

  # afterEach (done) ->
  #   @sut.close done

  it 'should exist', ->
    expect(@sut).to.exist

  # it 'should call noble.startScanning', ->
  #   expect(@noble.startScanning).to.have.been.calledWith ["180d"], false
