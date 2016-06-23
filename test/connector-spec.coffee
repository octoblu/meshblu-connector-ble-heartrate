Connector = require '../'

describe 'Connector', ->
  beforeEach (done) ->
    @sut = new Connector
    {@bleHeartRate} = @sut
    @sut.emit = sinon.stub()
    @bleHeartRate.connect = sinon.stub().yields null
    @sut.start {}, done

  afterEach (done) ->
    @sut.close done

  describe '->isOnline', ->
    it 'should yield running true', (done) ->
      @sut.isOnline (error, response) =>
        return done error if error?
        expect(response.running).to.be.true
        done()

  describe '->onConfig', ->
    beforeEach (done) ->
      options =
        autoDiscover: true
      @sut.onConfig {options}, done

    it 'should call bleHeartRate.connect', ->
      expect(@bleHeartRate.connect).to.have.been.calledWith autoDiscover: true, localName: undefined

  describe '->on data', ->
    beforeEach (done) ->
      @bleHeartRate.once 'data', => done()
      @bleHeartRate.emit 'data', foo: 'bar'

    it 'should emit message', ->
      expect(@sut.emit).to.have.been.calledWith 'message', {devices: ['*'], data: foo: 'bar'}
