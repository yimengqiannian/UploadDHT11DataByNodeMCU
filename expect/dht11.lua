local GPIO0 , GPIO2 = 3 , 4

local function getNum(bitStream,offset)
	local num=0
	for i=1,8 do
		num = bit.lshift(num,1)
		if (bitStream[i+offset] > 3) then
			num = num + 1
		end
	end
	return num
end

local function read(pin)
	local gpio_read, gpio_write = gpio.read, gpio.write
	local bitStream = {}
	local count = 0
	for j = 1, 40, 1 do bitStream[j]=0 end

	gpio.mode(pin, gpio.OUTPUT)
	gpio.write(pin, gpio.LOW)
	tmr.delay(18000)
	gpio.mode(pin, gpio.INPUT)
	count = 0
	while gpio_read(pin)==1 and count<100 do count=count+1 end
	while gpio_read(pin)==0 do end
	count = 0
	while gpio_read(pin)==1 and count<100 do count=count+1 end
	
	count = 0
	for j = 1,40 do
		while gpio_read(pin)==0 do end
		while gpio_read(pin)==1 and count<10 do
			count=count+1
		end
		bitStream[j]=count
		count=0
	end

	local Humidity = getNum(bitStream,0)
	local HumidityDec = getNum(bitStream,8)
	local Temperature = getNum(bitStream,16)
	local TemperatureDec = getNum(bitStream,24)
	local Checksum = getNum(bitStream,32)
	local ChecksumTest=(Humidity+HumidityDec+Temperature+TemperatureDec) % 0xFF

	if ChecksumTest == Checksum then
		return {
			temperature = Temperature.."."..TemperatureDec,
			humidity = Humidity.."."..HumidityDec
		}
	else
		return nil
    end
end

return {
	read = read,
	GPIO0 = GPIO0,
	GPIO2 = GPIO2
}
