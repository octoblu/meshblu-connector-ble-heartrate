parseHeartRate = (data) ->
  if data instanceof Uint8Array
    bytes = data
    #Check for data
    if bytes.length == 0
      return
    #Get the first byte that contains flags
    flag = bytes[0]
    #Check if u8 or u16 and get heart rate
    hr = undefined
    if (flag & 0x01) == 1
      u16bytes = bytes.buffer.slice(1, 3)
      u16 = new Uint16Array(u16bytes)[0]
      hr = u16
    else
      u8bytes = bytes.buffer.slice(1, 2)
      u8 = new Uint8Array(u8bytes)[0]
      hr = u8
    hr
  else
    data.readUInt8 1

module.exports = parseHeartRate
