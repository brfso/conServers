# conServers.sh
Script used to list servers from `HTML` page.

## How it's works
This is script list all server from html page with table (<td>) and automatc connect in selected server.

## Requirements

1. Linux or MacOSX
2. Ruby with bundle (gem install bundle)
2. SSH RSA Key to connect on Server
3. HTML Page with table (Company | Hostname or ip Address| user| port | alias )
	
## How to Install
The `install.sh` should be used to install `conServers` and requirements. 
```
cd ~/
wget https://github.com/brfso/conServers/archive/master.zip
unzip conServers-master.zip
cd $PWD/conServers-master/
./install.sh
```
	
## How to Use

1. Set SSH Key in SSH_KEY in /etc/conservers.config
2. Configure Page to connect (url) in /etc/conservers.config
3. Execute conServers.sh

`$ conservers.sh`
		
### To Update Server List	
To update server list from html page, execute with option `-u` or `--update`

```bash
$ conserver.sh --update
```

### Help and Troubleshoot
For help, usage: 
```
$ conserver.sh -h
Usage:  conserver [OPTIONS]

conServer

Options:
 -u,   --update        Update Server List
 -gui, --gui-mode      Use GUI Mode
 -h,   --help          Displays usage info
```

For troubleshoot use:
```
$ bash -x conserver.sh [option]
```

## toDO
To view,  report bug or request new features, use: https://github.com/brfso/conServers/issues
