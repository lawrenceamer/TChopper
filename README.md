# TChopper

New technique I have discovered recently to perfrom lateral movement using windows services displayname by sumggling the malicious binary as base64 chuncks and automate the process using the TChopper tool. 


![image](https://0xsp.com/storageCenter/1623166632.jpg)

# How it works 

* the tool will get the file you willing to smuggle and encode the file as base64 into memory stream 
* divide the length of each line to fit 150-250 character length (250 is maximum allowed space for service lpDisplayname parameter https://docs.microsoft.com/en-us/windows/win32/api/winsvc/nf-winsvc-createservicea).
* create a unique service for each segmented chunk => start the service => then delete it to avoid duplicates 
* modify service lpbinarypath parameter with required commandline to grab service displayname and pip out the results into tmp_payload.txt 
* finally, after finishing delivering all chuncks of the file as base64, the tool will create another service to decode the content into valid executbale and run it 

# Usage 

```
chopper.exe -s -u USERNAME -p PASSWORD -d DOMAIN -f BINARYLOCAL PATH 
```

https://youtu.be/xbvhzHul7w0

# Detailed research 
http://0xsp.com/security%20research%20&%20development%20(SRD)/smuggling-via-windows-services-display-name-lateral-movement



