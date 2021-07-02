# nagios-led-strip# RGB strip - nagios status (quick and nasty) with tasmota firmware

For this setup I used H801 module based on ESP8266 with cheap piece of RGB Led tape

Flashed tasmota using FTDI onto board. (you need to solder pins 3.3v, gnd, tx, rx in order to do this). All detail available on tasmota website. 

[https://tasmota.github.io/docs/Getting-Started/ https://tasmota.github.io/docs/Getting-Started/]

[https://tasmota.github.io/docs/devices/H801/ https://tasmota.github.io/docs/devices/H801/]

Latest tasmota release:

[http://ota.tasmota.com/tasmota/release/ http://ota.tasmota.com/tasmota/release/]

One flashed it's booting up with it's own access point called tasmota_XXXXX. Conect setup Wifi access point credentials, and reboot. 

My DHCP range is 100-120, so scanned with nmap to see if module 

    nmap 192.168.1.100-120

and surely there is:

    adam@adam-flat:~$ nmap 192.168.1.100-120
    Starting Nmap 7.80 ( https://nmap.org ) at 2021-07-02 09:39 BST
    Nmap scan report for 192.168.1.100
    Host is up (0.0077s latency).
    Not shown: 999 closed ports
    PORT   STATE SERVICE
    80/tcp open  http

Go to ip and set address in web browser, and configure (if you want) static ip address.

Go to colsole and type:

    IPAddress1 = set device IP address
    IPAddress2 = set gateway IP address
    IPAddress3 = set subnet mask
    IPAddress4 = set DNS server IP address

additianally set time and timezone (beloa for UK):

    NtpServer1 192.168.1.94
    NtpServer2 192.168.1.96
    TimeZone 99
    TimeDST 0,0,3,1,1,60
    TimeSTD 0,0,10,1,2,0

Configure module as Generic(18)

Set GPIO's as follow:

**GPIO 1 - Led2**

**GPIO 5 - Led1**

**GPIO12 - PWM3**

**GPIO13 - PWM1**

**GPIO15 - PWM2**

Check if all is good from web interface switching to different colours.

Time to test web requests.

[https://tasmota.github.io/docs/Commands/#with-web-requests]

power on:

    curl -s http://192.168.1.53/cm?cmnd=Power%20On

power off:

    curl -s http://192.168.1.53/cm?cmnd=Power%20Off

Let's check what colours to use for nagios. For warning I set amber and swap to console to check the exactl command:

    13:54:28.916 RSL: RESULT = {"POWER":"ON","Dimmer":52,"Color":"855700","HSBColor":"39,100,52","Channel":[52,34,0]}

critial - red:

    13:54:55.178 RSL: RESULT = {"POWER":"ON","Dimmer":52,"Color":"850200","HSBColor":"1,100,52","Channel":[52,1,0]}

So all stripped down, and interesting part left like this:

**Color:8C0004,HSBColor:358,100,55,Channel:[55,0,2]**

Go to [https://www.urlencoder.org/] and have a look how to encode it

same after encoding:

**Color%3A8C0004%2CHSBColor%3A358%2C100%2C55%2CChannel%3A%5B55%2C0%2C2%5D**

full command:

    curl -s http://192.168.1.53/cm?cmnd=Color%3A8C0004%2CHSBColor%3A358%2C100%2C55%2CChannel%3A%5B55%2C0%2C2%5D

dimmer if needed (30%)

    curl -s http://192.168.1.53/cm?cmnd=dimmer%2030

To grab status of the switch if needed:

    curl -s http://192.168.1.53/cm?cmnd=STATUS | jq '.Status.Power'

Now time to grab nagios status and check if all good or not.

Some nasty status.dat greping:

status script when run on local machine:

    cat /var/log/nagios/status.dat | awk '{printf("%s",$1)}' | awk -F"servicestatus" '{i=2;while(i<=NF){print $i;i++}}' | grep -v 'scheduled_downtime_depth=1' | grep 'notifications_enabled=1' | grep 'problem_has_been_acknowledged=0' | grep 'current_state=2' | wc -l

*current_state=2* - critial
*-F"servicestatus"* - services status
*-F"hoststatus"* - hosts status

or through ssh from nagios server (if nagios server is somewhere else):

    ssh nagios.local.net 'cat /var/log/nagios/status.dat' | awk '{printf("%s",$1)}' | awk -F"servicestatus" '{i=2;while(i<=NF){print $i;i++}}' | grep -v 'scheduled_downtime_depth=1' | grep 'notifications_enabled=1' | grep 'problem_has_been_acknowledged=0' | grep 'current_state=2' | wc -l

based on above fire curl event every 5 min or so by cron

