local net = require"net"
local AGENT = "NodeMCU 0.9.5"

--[[
	param key: ip(string,necessarily),domain(string,necessarily),
		params(string,default ''), url(string,default '/'),receive(function,default print);
	return: connect object or nil
--]]
local function post(param)
	local ip = param.ip
	local domain = param.domain
	if type(ip)~='string' or type(ip)~='string' then return nil end
	local receive = param.receive;
	local conn=net.createConnection(net.TCP, false)
	local params = param.params
	local url = param.url
	if type(params)~='string' then params="" end
	conn:on("receive", function(conn, pl)
		if string.find(type(receive),'function') then receive(pl) else print(pl) end
		conn:close()
		conn=nil
	end)
	conn:connect(80,ip or domain)
	conn:send("POST "..(url or "/").." HTTP/1.1\r\n"
		.."Host: "..(domain or ip).."\r\n"
		.."Connection: keep-alive\r\n"
		.."Content-Length: "..string.len(params).."\r\n"
		.."User-Agent: "..AGENT.."\r\n"
		.."Content-Type: application/x-www-form-urlencoded; charset=UTF-8"
		.."Accept: */*\r\n"
		.."\r\n"
		..params)
	return conn
end

--[[
	param key: ip(string,necessarily),domain(string,necessarily),
		params(string,default ''), url(string,default '/'),receive(function,default print);
	return: connect object or nil
--]]
local function get(param)
	local ip = param.ip
	local domain = param.domain
	if type(ip)~='string' or type(ip)~='string' then return nil end
	local receive = param.receive;
	local conn=net.createConnection(net.TCP, false)
	local params = param.params
	local url = param.url
	if type(params)~='string' then params="" end
	conn:on("receive", function(conn, pl)
		if string.find(type(receive),'function') then receive(pl) else print(pl) end
		conn:close()
		conn=nil
	end)
	conn:connect(80,ip or domain)
	conn:send("GET "..(url or "/")..(params and "?"..params or "").." HTTP/1.1\r\n"
		.."Host: "..(domain or ip).."\r\n"
		.."Connection: keep-alive\r\n"
		.."User-Agent: "..AGENT.."\r\n"
		.."Content-Type: application/x-www-form-urlencoded; charset=UTF-8"
		.."Accept: */*\r\n"
		.."\r\n")
	return conn
end

--[[
	params: content(string,default ''),isNoCache(bool,default false),
		refreshTime(int,default false), refreshURL(string,default '');
	return: connect object or nil
--]]
-- params: ,isNoCache,refreshTime,refreshURL; return: response package string
local function response(content,isNoCache,refreshTime,refreshURL)
	if type(content)~='string' then content='' end
	return "HTTP/1.1 200 OK\r\n"
		.."Server: "..AGENT.."\r\n"
		.."Content-Type: text/html\r\n"
		.."Content-Length: "..string.len(content).."\r\n"
		..(refreshTime and "Refresh: "..refreshTime..";URL="..(refreshURL or '').."\r\n" or "")
		..(isNoCache
			and "Cache-Control: no-cache\r\n"
			.."pragma: no-cache\r\n"
			.."expires: -1\r\n"
			or "")
		.."\r\n"
		..(content or "")
end

return {
	AGENT = AGENT,
	post = post,
	get = get,
	response = response
}
