# Coturn deployment with SSL at port 443

This Coturn is an automation to deploy a (STUN/TURN server) deployment listening at port 443 with an SSL/TLS Letsencrypt certificate. This Coturn (STUN/TURN server) deployment will be prepared to work with strict firewalls.

The process to install and configure it for OpenVidu is very simple. You just need to follow the next instructions.

# 1. Requirements

You need an individual Linux machine which should have:

1. A **public IP**
2. A **FQDN pointing to this public IP**. No proxys or anything else, just a simple domain/subdomain with a registar of type A pointing to its public IP.
3. Recommended requirements: 4 CPUs and 4 GB of RAM. This is a generous setup, it depends of your use case. The more people using relay connections, the more consumption it will have.

Also, you will need to open these ports:
![Inbound rules](docs/images/inbound_ports.png)
> - Port 80 TCP is needed by certbot to renew certificates
> - Port 443 TCP/UDP is needed to connect to coturn from browsers
> - 40000 - 65535 TCP/UDP is needed for Coturn to connect to relayed peers outside the network
> - Port 22 TCP is only necessary if you want to SSH into your instance

![Outbound rules](docs/images/outbound_ports.png)

4. If an application is running in one of the above mentioned ports, the deployment will not work as it is intended. All of these ports must be available for this deployment.


# 2. Installation

1. SSH into the machine you will deploy coturn

2. Git clone this repository in `/opt` as sudo, and enter to its directory
```
sudo su
cd /opt
git clone https://github.com/OpenVidu/openvidu-external-coturn.git
cd openvidu-external-coturn
```
3. Fill in the file `/opt/openvidu-external-coturn` these environment variables:
- `COTURN_DOMAIN_NAME`: The domain which is pointing to the public ip of the machine.
- `LETSENCRYPT_EMAIL`: The email you want to use for letsencrypt
- `TURN_USERNAME`: Turn username fixed credential
- `TURN_PASSWORD`: Turn password fixed credential

4. Execute coturn:
```
./openvidu_coturn --start
```

Now you have your Coturn prepared to listening at standard SSL port 443.

# 3. OpenVidu browser configuration

Every time the instance of `OpenVidu` is instanciated in your frontend app using `openvidu-browser` you need to configure to use the STUN/TURN server we've configured:

```
// This openvidu instance should be somewhere in your app
let openvidu = new OpenVidu()

// This is the important part, where we're configuring the new STUN/TURN deployment
let turnUsername = <TURN_USERNAME>
let turnCredential = <TURN_PASSWORD>
openvidu.setAdvancedConfiguration({
    iceServers: [
        {
            urls: "turn:<COTURN_DOMAIN_NAME>:443?transport=udp",
            username: turnUsername,
            credential: turnCredential
        },
        {
            urls: "turn:<COTURN_DOMAIN_NAME>:443?transport=tcp",
            username: turnUsername,
            credential: turnCredential
        },
        {
            urls: "turns:<COTURN_DOMAIN_NAME>:443?transport=tcp",
            username: turnUsername,
            credential: turnCredential
        }
    ]
});
```

Obviously you need to replace:
    - `COTURN_DOMAIN_NAME`: the domain name you're using for your Coturn server.
    - `TURN_USERNAME`: Username fixed credential
    - `TURN_PASSWORD`: Password fixes credential