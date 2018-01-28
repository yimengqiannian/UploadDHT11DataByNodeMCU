# UploadDHT11DataByNodeMCU
Collecting temperature and humidity data, and uploading to web by NodeMCU.

Files in folder "expect" didn't work and never tested in not enough memory error.
The root directory file is finally used.

Don't use the code directly,because of no enough memory error.Compile them first.
Please compile lib.lua to lib.lc and init_src.lua to init.lua(renamed by init.lc), and then upload init.lua and lib.lc to NodeMCU.
Succeed on ESP8266-01.
