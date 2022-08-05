# MyCrypto in Docker optimized for Unraid
MyCrypto is an open-source tool that allows you to manage your Ethereum accounts privately and securely. Developed by and for the community since 2015!

**ATTENTION:** Please don't store your keyfile in the .../bin folder since this folder get's deleted if a update from MyCrypto is released, use the Home directory instead!
I strongly recommend you to backup your keyfile on a regular basis!

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Please don't store your keyfile in the .../bin folder since this folder get's deleted if a update from MyCrypto is released, use the Home directory instead! I strongly recommend you to backup your keyfile on a regular basis! | /mycrypto |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| UMASK | Umask value | 000 |

## Run example
```
docker run --name MyCrypto -d \
	-p 8080:8080 \
	--env 'UID=99' \
	--env 'GID=100' \
	--env 'UMASK=000' \
	--env 'DATA_PERM=770' \
    --env 'TURBOVNC_PARAMS=-securitytypes none' \
	--volume /path/to/mycrypto:/mycrypto \
	--restart=unless-stopped \
	ich777/mycrypto
```
### Webgui address: http://[IP]:[PORT:8080]/vnc.html?autoconnect=true

## Set VNC Password:
 Please be sure to create the password first inside the container, to do that open up a console from the container (Unraid: In the Docker tab click on the container icon and on 'Console' then type in the following):

1) **su $USER**
2) **vncpasswd**
3) **ENTER YOUR PASSWORD TWO TIMES AND PRESS ENTER AND SAY NO WHEN IT ASKS FOR VIEW ACCESS**

Unraid: close the console, edit the template and create a variable with the `Key`: `TURBOVNC_PARAMS` and leave the `Value` empty, click `Add` and `Apply`.

All other platforms running Docker: create a environment variable `TURBOVNC_PARAMS` that is empty or simply leave it empty:
```
    --env 'TURBOVNC_PARAMS='
```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/
