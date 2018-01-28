local config = require"config"
local collect = require"collect"
local localIP = collect.configWIFI(config.wifiSID,config.wifiPWD)
local privateKey = config.postKey
local domain = config.postDomain
local url = config.postURL
local interval = config.taskInterval
local pin = config.dht11pin
local serverPort = config.serverPort
local connTimeout = config.connTimeout
local data;

function timeTask(domain,ip)
	data = require"dht11".read(pin)
	if not data then return false end
	local params = "time="..tmr.time().."&temperature="..(data.temperature or "unknown").."&humidity="..(data.humidity or "unknown")
	params = params..'&md5='..require"md5m".hexMD5(params..privateKey)
	require"http".post{domain=domain, ip=ip, url=url, params=params}
	print(params)
end

collect.openServer(serverPort,connTimeout,function(sk)
	return "<html><head><title>NodeMCU["..tmr.time().."]</title></head><body><h1>温度:"..(data and data.temperature or "unknown").."<br />湿度:"..(data and data.humidity or "unknown").."</h1></body></html>"
end)

collect.dns(domain, function(ip)
	--trigger once right now
	timeTask(domain,ip)
    --do task every 5 minutes
	tmr.alarm(0,interval,1,function()
        timeTask(domain,ip)
    end)
end)
