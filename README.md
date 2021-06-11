# TChopper

New technique I have discovered recently and give it a nickname (Chop chop) to perform lateral movement using windows services display name by smuggling the malicious binary as base64 chunks and automate the process using the TChopper tool. 

[![image](https://i.imgur.com/bTZlLC8.png)](https://twitter.com/zux0x3a/status/1402327825139441666)

![image](https://0xsp.com/storageCenter/1623166632.jpg)

## How it works 

* the tool will get the file you willing to smuggle and encode the file as base64 into memory stream 
* divide the length of each line to fit 150-250 character length (250 is maximum allowed space for service lpDisplayname parameter https://docs.microsoft.com/en-us/windows/win32/api/winsvc/nf-winsvc-createservicea).
* create a unique service for each segmented chunk => start the service => then delete it to avoid duplicates 
* modify service lpbinarypath parameter with required command line to grab service display name and pip out the results into tmp_payload.txt 
* finally, after finishing delivering all chuncks of the file as base64, the tool will create another service to decode the content into valid executbale and run it 

![image](https://0xsp.com/storageCenter/1623222054.png)

## Usage 

```
#chop chop mode 
chopper.exe -s -u USERNAME -p PASSWORD -d DOMAIN -f BINARYLOCAL PATH 


# chop chop done 
chopper.exe -m -u USERNAME -p PASSWORD -d DOMAIN -f BINARYLOCAL PATH 
```

https://youtu.be/xbvhzHul7w0

## Detailed research 
http://0xsp.com/security%20research%20&%20development%20(SRD)/smuggling-via-windows-services-display-name-lateral-movement

## Show support 

i create offsec tools for open-source community, show your support https://paypal.me/0xsp

