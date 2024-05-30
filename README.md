# unifi-controller
UniFi Controller that runs as non-root user. Requires an external MongoDB service, which the Helm chart deploys with the controller.

## Helm Chart Deployment
Review and modify the values.yaml file as needed. Still working on templating the Kubernetes Gateway manifest files.

Note: Recommend installing the Gateway CRDs with TLSRoute experimental CRD as well. This will allow TLS passthrough since UniFi is unable to disable HTTPS redirection. Once the Gateway TLS Backend Policy is implemented and we can leverage the reencrypt for the backend, TLS passthrough appears to be the best option. If using the Ingress configurations, you will also need to see if your ingress supports forwarding raw UDP and TCP ports (NGINX Ingress supports this, but its set on a cluster-wide configuration). The Gateway spec supports TCP and UDP via UDPRoute and TCPRoute.

Cilium docs w/ Gateway API Support: https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/

Once deployed, I have my current test gateway manifest files checked in for reference. For the TLS certificate, I am using cert-manager with reflector to replicate the TLS certificate into the unifi namespace. Cert-manager in the next release will support JKS alias, in which will make things much cleaner.

Example:

helm install unifi-controller unifi-helm/ -n unifi --set gateway.ipaddress=LB_IP --set gateway.controller.tlsSecretName=controller-example-com-tls --set db.env.MONGO_PASS=CHANGEME

## Unknowns w/ Gateway API
- UDPRoute operational. Installed the routes, but have not verified if the UDP portion is functioning as intended.
- Guest Portal. I have not yet verified this functions as intended.


## Acknowledgements
This project includes code from [linuxserver.io's docker-unifi-network-application](https://github.com/linuxserver/docker-unifi-network-application/tree/main), which is licensed under the GNU General Public License, Version 3 (GPLv3).
