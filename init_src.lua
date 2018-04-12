wifi.setmode(wifi.STATION)
wifi.sta.config("yourSID","yourPassword")
wifi.sta.autoconnect(1)

local domain = "yourDomain"
local ip = "yourIP"
dofile"lib.lc"
function openServer()
	print"Server Opening..."
	local s=net.createServer(net.TCP,180)
	s:listen(80,function(c)
		node.output(function(str)
			if(c~=nil) then
				c:send('\r\n'..str)
			end
		end, 1)
		local content = "<html><head><title>NodeMCU["..tmr.time().."]</title></head><body><h1>温度:"..(data and data.temperature or "unknown").."<br />湿度:"..(data and data.humidity or "unknown").."</h1></body></html>"
		c:send("HTTP/1.1 200 OK\r\nServer: NodeMCU 0.9.5\r\nContent-Type: text/html;charset=utf-8\r\nContent-Length: "..string.len(content)..
				"\r\nCache-Control: no-cache\r\npragma: no-cache\r\nRefresh: 300;URL=/\r\nexpires: -1\r\n\r\n"..content)
		content = nil
		c:on("receive",function(c,l)
			node.input(l)
		end)
		c:on("disconnection",function(c)
			node.output(nil)
		end)
	end)
	print"Server OK!"
end

function timerTask()
	pcall(readDHT11,4)
    for i=1,10 do
        tmr.delay(5000000)
	    _,data = pcall(readDHT11,4)
        if data then break end
    end
    if not data then return false end
	local params = "time="..tmr.time().."&temperature="..(data.temperature or "unknown").."&humidity="..(data.humidity or "unknown")
	params = params..'&md5='..encrypt(params)
	print(params)
	local pkg = "POST /collect/humiture.do HTTP/1.1\r\nHost: "..domain.."\r\nConnection: keep-alive\r\nContent-Length: "..
			string.len(params).."\r\nUser-Agent: NodeMCU 0.9.5\r\nAccept: */*\r\n\r\n"..params
	params = nil
	tmr.alarm(3,5000,0,function()
		local conn=net.createConnection(net.TCP, false)
		conn:connect(80,ip)
		conn:on("receive", function(conn, pl)
            conn:close()
            conn=nil
			print(pl)
        end)
		conn:send(pkg)
	end)
    return true
end

tmr.alarm(0,30*1000,0,timerTask)
tmr.alarm(1,60*1000,0,openServer)
tmr.alarm(2,5*60*1000,1,timerTask)

