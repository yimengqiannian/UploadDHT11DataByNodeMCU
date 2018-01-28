local AGENT = "NodeMCU 0.9.5"

local function configWIFI(name,pwd)
	local wifi = require"wifi"
	wifi.setmode(wifi.STATION)
	wifi.sta.config(name,pwd)
	return wifi.sta.getip()
end

--open telnet/http to debug
local function openServer(port,timeout,contentHandle)
	local net = require"net"
	local http = require"http"
	if type(port)~='number' or type(timeout)~='number' then return nil end
	local s=net.createServer(net.TCP,timeout)
	s:listen(port,function(c)
		node.output(function(str)
			if(c~=nil) then
				c:send('\r'..str)
			end
		end, 1)
		local content = string.find(type(receive),'function') and receive(c) or "Welcom to "..AGENT
		c:send(http.response(content))
		content = nil
		c:on("receive",function(c,l)
			node.input(l)
		end)
		c:on("disconnection",function(c)
			node.output(nil)
		end)
	end)
	return s
end

--get domain IP by DNS
local function dns(domain,receive)
    local sk = net.createConnection(net.TCP, 0)
    sk:dns(domain, function(skconn, ip)
        sk:close() sk = nil
        if string.find(type(receive),'function') then receive(pl) else print(pl) end
    end)
	return sk
end

return {
	AGENT = AGENT,
	configWIFI = configWIFI,
	openServer = openServer,
	dns = dns
}
