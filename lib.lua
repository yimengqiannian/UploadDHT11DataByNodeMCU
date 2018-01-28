function getNum(bitStream,offset)
	local num=0
	for i=1,8 do
		num = bit.lshift(num,1)
		if (bitStream[i+offset] > 3) then
			num = num + 1
		end
	end
	return num
end
function readDHT11(pin)
	local rd = gpio.read
	local wr = gpio.write
	local bitStream = {}
	local count = 0
	for j = 1, 40, 1 do bitStream[j]=0 end
	gpio.mode(pin, gpio.OUTPUT)
	gpio.write(pin, gpio.LOW)
	tmr.delay(18000)
	gpio.mode(pin, gpio.INPUT)
	count = 0
	while rd(pin)==1 and count<100 do count=count+1 end
	while rd(pin)==0 do end
	count = 0
	while rd(pin)==1 and count<100 do count=count+1 end
	count = 0
	for j = 1,40 do
		while rd(pin)==0 do end
		while rd(pin)==1 and count<10 do
			count=count+1
		end
		bitStream[j]=count
		count=0
	end

	local Humidity = getNum(bitStream,0)
	local HumidityDec = getNum(bitStream,8)
	local Temperature = getNum(bitStream,16)
	local TemperatureDec = getNum(bitStream,24)
	if getNum(bitStream,32) == ((Humidity+HumidityDec+Temperature+TemperatureDec) % 0xFF) then
		return {temperature = Temperature.."."..TemperatureDec, humidity = Humidity.."."..HumidityDec}
	else
		return nil
    end
end

function encrypt(str)
	return "yourKeyHere"
end
