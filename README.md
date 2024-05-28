# unifi-controller
UniFi Controller that runs as non-root user. Requires an external MongoDB service, which the Helm chart deploys with the controller.

## Helm Chart Deployment
Review and modify the values.yaml file as needed
<br>
Example: helm install unifi-controller unifi-helm/ -n unifi --set gateway.ipaddress=10.0.0.100 --set gateway.enabled=true --set db.env.MONGO_PASS=MYPASSWORD --set gateway.controller.host=unifi.example.com --set gateway.portal.host=portal.example.com
- Sets the IP Address for the Gateway to use, which also sets UniFi configuration to advertise this
- Sets the controller DNS for routing through the gateway to the management interface (tcp/8443)
- Sets the portal DNS for routing through the gateway to the portal interface (tcp/8843)
<br>
## Status (27May2024)
- I have not verified the UDPRoute's are functional
- The HTTP/HTTPs routes are functional in my cluster and all my nodes showed up. During debugging the TLSRoute and HTTPRoute, I set the inform on each node via ssh.
- Moved to the Ubuntu base image due to running into library dependencies needed for the inform java class (systemd, etc). Will likely look at using a hardened base vs the default ubuntu base image.
- To use the Gateway with TLSRoute, HTTPRoute, and UDPRoute: requires Kubernetes experimental CRDs for the Gateway API specs
- Have not yet verified the Guest Portal; however, seperated the host to eventually try having the controller and portal use default tcp/443. 
- Have not yet generated TLS certs and verified the Gateway terminates and still functions.
<br>
## Acknowledgements
This project includes code from [linuxserver.io's docker-unifi-network-application](https://github.com/linuxserver/docker-unifi-network-application/tree/main), which is licensed under the GNU General Public License, Version 3 (GPLv3).
