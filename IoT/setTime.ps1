#http://ms-iot.github.io/content/en-US/win10/samples/PowerShell.htm
net start WinRM

Set-Item WSMan:\localhost\Client\TrustedHosts -Value 10.0.0.11

#NOTE: The connection process is not immediate and can take up to 30 seconds
#default: p@ssw0rd
Enter-PSSession -ComputerName 10.0.0.11 -Credential localhost\Administrator


# 19.1.2016 12:08 PM
set-date 1/19/2016 12:08 PM