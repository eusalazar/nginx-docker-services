{{ $CurrentContainer := where $ "ID" .Docker.CurrentContainerID | first }}

{{ $nginx_proxy_version := coalesce $.Env.NGINX_PROXY_VERSION "" }}
{{ $external_http_port := coalesce $.Env.HTTP_PORT "80" }}
{{ $external_https_port := coalesce $.Env.HTTPS_PORT "443" }}
{{ $debug_all := $.Env.DEBUG }}
{{ $sha1_upstream_name := parseBool (coalesce $.Env.SHA1_UPSTREAM_NAME "false") }}
{{ $default_root_response := coalesce $.Env.DEFAULT_ROOT "404" }}

{{ define "ssl_policy" }}
	{{ if eq .ssl_policy "Mozilla-Modern" }}
		ssl_protocols TLSv1.3;
		{{/* nginx currently lacks ability to choose ciphers in TLS 1.3 in configuration, see https://trac.nginx.org/nginx/ticket/1529 /*}}
		{{/* a possible workaround can be modify /etc/ssl/openssl.cnf to change it globally (see https://trac.nginx.org/nginx/ticket/1529#comment:12 ) /*}}
		{{/* explicitly set ngnix default value in order to allow single servers to override the global http value */}}
		ssl_ciphers HIGH:!aNULL:!MD5;
		ssl_prefer_server_ciphers off;
	{{ else if eq .ssl_policy "Mozilla-Intermediate" }}
		ssl_protocols TLSv1.2 TLSv1.3;
		ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
		ssl_prefer_server_ciphers off;
	{{ else if eq .ssl_policy "Mozilla-Old" }}
		ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
		ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA256:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA';
		ssl_prefer_server_ciphers on;
	{{ else if eq .ssl_policy "AWS-TLS-1-2-2017-01" }}
		ssl_protocols TLSv1.2 TLSv1.3;
		ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:AES128-GCM-SHA256:AES128-SHA256:AES256-GCM-SHA384:AES256-SHA256';
		ssl_prefer_server_ciphers on;
	{{ else if eq .ssl_policy "AWS-TLS-1-1-2017-01" }}
		ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
		ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:AES128-GCM-SHA256:AES128-SHA256:AES128-SHA:AES256-GCM-SHA384:AES256-SHA256:AES256-SHA';
		ssl_prefer_server_ciphers on;
	{{ else if eq .ssl_policy "AWS-2016-08" }}
		ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
		ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:AES128-GCM-SHA256:AES128-SHA256:AES128-SHA:AES256-GCM-SHA384:AES256-SHA256:AES256-SHA';
		ssl_prefer_server_ciphers on;
	{{ else if eq .ssl_policy "AWS-2015-05" }}
		ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
		ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:AES128-GCM-SHA256:AES128-SHA256:AES128-SHA:AES256-GCM-SHA384:AES256-SHA256:AES256-SHA:DES-CBC3-SHA';
		ssl_prefer_server_ciphers on;
	{{ else if eq .ssl_policy "AWS-2015-03" }}
		ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
		ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:AES128-GCM-SHA256:AES128-SHA256:AES128-SHA:AES256-GCM-SHA384:AES256-SHA256:AES256-SHA:DHE-DSS-AES128-SHA:DES-CBC3-SHA';
		ssl_prefer_server_ciphers on;
	{{ else if eq .ssl_policy "AWS-2015-02" }}
		ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
		ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:AES128-GCM-SHA256:AES128-SHA256:AES128-SHA:AES256-GCM-SHA384:AES256-SHA256:AES256-SHA:DHE-DSS-AES128-SHA';
		ssl_prefer_server_ciphers on;
	{{ end }}
{{ end }}

{{ define "location" }}
	location {{ .Path }} {
	{{ if eq .NetworkTag "internal" }}
		# Only allow traffic from internal clients
		include /etc/nginx/network_internal.conf;
	{{ end }}

	{{ if eq .Proto "uwsgi" }}
		include uwsgi_params;
		uwsgi_pass {{ trim .Proto }}://{{ trim .Upstream }};
	{{ else if eq .Proto "fastcgi" }}
		root   {{ trim .VhostRoot }};
		include fastcgi_params;
		fastcgi_pass {{ trim .Upstream }};
	{{ else if eq .Proto "grpc" }}
		grpc_pass {{ trim .Proto }}://{{ trim .Upstream }};
	{{ else }}
		proxy_pass {{ trim .Proto }}://{{ trim .Upstream }}{{ trim .Dest }};
	{{ end }}

	{{ if (exists (printf "/etc/nginx/htpasswd/%s" .Host)) }}
		auth_basic	"Restricted {{ .Host }}";
		auth_basic_user_file	{{ (printf "/etc/nginx/htpasswd/%s" .Host) }};
	{{ end }}

	{{ if (exists (printf "/etc/nginx/vhost.d/%s_%s_location" .Host (sha1 .Path) )) }}
		include {{ printf "/etc/nginx/vhost.d/%s_%s_location" .Host (sha1 .Path) }};
	{{ else if (exists (printf "/etc/nginx/vhost.d/%s_location" .Host)) }}
		include {{ printf "/etc/nginx/vhost.d/%s_location" .Host}};
	{{ else if (exists "/etc/nginx/vhost.d/default_location") }}
		include /etc/nginx/vhost.d/default_location;
	{{ end }}
}
{{ end }}

{{ define "upstream" }}
	{{ $networks := .Networks }}
	{{ $debug_all := .Debug }}
upstream {{ .Upstream }} {
	{{ $server_found := "false" }}
	{{ range $container := .Containers }}
        {{ $debug := (eq (coalesce $container.Env.DEBUG $debug_all "false") "true") }}
        {{/* If only 1 port exposed, use that as a default, else 80 */}}
        {{ $defaultPort := (when (eq (len $container.Addresses) 1) (first $container.Addresses) (dict "Port" "80")).Port }}
        {{ $port := (coalesce $container.Env.VIRTUAL_PORT $defaultPort) }}
        {{ $address := where $container.Addresses "Port" $port | first }}
        {{ if $debug }}
        # Exposed ports: {{ $container.Addresses }}
        # Default virtual port: {{ $defaultPort }}
        # VIRTUAL_PORT: {{ $container.Env.VIRTUAL_PORT }}
            {{ if not $address }}
        # /!\ Virtual port not exposed
            {{ end }}
        {{ end }}
		{{ range $knownNetwork := $networks }}
			{{ range $containerNetwork := $container.Networks }}
				{{ if (and (ne $containerNetwork.Name "ingress") (or (eq $knownNetwork.Name $containerNetwork.Name) (eq $knownNetwork.Name "host"))) }}
        ## Can be connected with "{{ $containerNetwork.Name }}" network
                    {{ if $address }}
                        {{/* If we got the containers from swarm and this container's port is published to host, use host IP:PORT */}}
                        {{ if and $container.Node.ID $address.HostPort }}
                            {{ $server_found = "true" }}
        # {{ $container.Node.Name }}/{{ $container.Name }}
        server {{ $container.Node.Address.IP }}:{{ $address.HostPort }};
                        {{/* If there is no swarm node or the port is not published on host, use container's IP:PORT */}}
                        {{ else if $containerNetwork }}
                            {{ $server_found = "true" }}
        # {{ $container.Name }}
        server {{ $containerNetwork.IP }}:{{ $address.Port }};
                        {{ end }}
                    {{ else if $containerNetwork }}
        # {{ $container.Name }}
                        {{ if $containerNetwork.IP }}
                            {{ $server_found = "true" }}
        server {{ $containerNetwork.IP }}:{{ $port }};
                        {{ else }}
        # /!\ No IP for this network!
                    	{{ end }}
					{{ end }}
				{{ else }}
        # Cannot connect to network '{{ $containerNetwork.Name }}' of this container
				{{ end }}
			{{ end }}
		{{ end }}
	{{ end }}
	{{/* nginx-proxy/nginx-proxy#1105 */}}
	{{ if (eq $server_found "false") }}
        # Fallback entry
        server 127.0.0.1 down;
	{{ end }}
}
{{ end }}

{{ if ne $nginx_proxy_version "" }}
# nginx-proxy version : {{ $nginx_proxy_version }}
{{ end }}

# If we receive X-Forwarded-Proto, pass it through; otherwise, pass along the
# scheme used to connect to this server
map $http_x_forwarded_proto $proxy_x_forwarded_proto {
  default $http_x_forwarded_proto;
  ''      $scheme;
}

# If we receive X-Forwarded-Port, pass it through; otherwise, pass along the
# server port the client connected to
map $http_x_forwarded_port $proxy_x_forwarded_port {
  default $http_x_forwarded_port;
  ''      $server_port;
}

# If we receive Upgrade, set Connection to "upgrade"; otherwise, delete any
# Connection header that may have been passed to this server
map $http_upgrade $proxy_connection {
  default upgrade;
  '' close;
}

# Apply fix for very long server names
server_names_hash_bucket_size 128;

# Default dhparam
{{ if (exists "/etc/nginx/dhparam/dhparam.pem") }}
ssl_dhparam /etc/nginx/dhparam/dhparam.pem;
{{ end }}

# Set appropriate X-Forwarded-Ssl header based on $proxy_x_forwarded_proto
map $proxy_x_forwarded_proto $proxy_x_forwarded_ssl {
  default off;
  https on;
}

gzip_types text/plain text/css application/javascript application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

log_format vhost '$host $remote_addr - $remote_user [$time_local] '
                 '"$request" $status $body_bytes_sent '
                 '"$http_referer" "$http_user_agent" '
                 '"$upstream_addr"';

access_log off;

{{/* Get the SSL_POLICY defined by this container, falling back to "Mozilla-Intermediate" */}}
{{ $ssl_policy := or ($.Env.SSL_POLICY) "Mozilla-Intermediate" }}
{{ template "ssl_policy" (dict "ssl_policy" $ssl_policy) }}
error_log /dev/stderr;

{{ if $.Env.RESOLVERS }}
resolver {{ $.Env.RESOLVERS }};
{{ end }}

{{ if (exists "/etc/nginx/proxy.conf") }}
include /etc/nginx/proxy.conf;
{{ else }}
# HTTP 1.1 support
proxy_http_version 1.1;
proxy_buffering off;
proxy_set_header Host $http_host;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection $proxy_connection;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $proxy_x_forwarded_proto;
proxy_set_header X-Forwarded-Ssl $proxy_x_forwarded_ssl;
proxy_set_header X-Forwarded-Port $proxy_x_forwarded_port;
proxy_set_header X-Original-URI $request_uri;

# Mitigate httpoxy attack (see README for details)
proxy_set_header Proxy "";
{{ end }}

{{ $access_log := (or (and (not $.Env.DISABLE_ACCESS_LOGS) "access_log /var/log/nginx/access.log vhost;") "") }}

{{ $enable_ipv6 := eq (or ($.Env.ENABLE_IPV6) "") "true" }}
server {
	server_name _; # This is just an invalid value which will never trigger on a real hostname.
	server_tokens off;
	listen {{ $external_http_port }};
	{{ if $enable_ipv6 }}
	listen [::]:{{ $external_http_port }};
	{{ end }}
	{{ $access_log }}
	return 503;
}

{{ if (and (exists "/etc/nginx/certs/default.crt") (exists "/etc/nginx/certs/default.key")) }}
server {
	server_name _; # This is just an invalid value which will never trigger on a real hostname.
	server_tokens off;
	listen {{ $external_https_port }} ssl http2;
	{{ if $enable_ipv6 }}
	listen [::]:{{ $external_https_port }} ssl http2;
	{{ end }}
	{{ $access_log }}
	return 503;

	ssl_session_cache shared:SSL:50m;
	ssl_session_tickets off;
	ssl_certificate /etc/nginx/certs/default.crt;
	ssl_certificate_key /etc/nginx/certs/default.key;
}
{{ end }}

{{ range $host, $containers := groupByMulti $ "Env.VIRTUAL_HOST" "," }}

{{ $host := trim $host }}
{{ $is_regexp := hasPrefix "~" $host }}
{{ $upstream_name := when (or $is_regexp $sha1_upstream_name) (sha1 $host) $host }}

{{ $paths := groupBy $containers "Env.VIRTUAL_PATH" }}
{{ $nPaths := len $paths }}

{{ if eq $nPaths 0 }}
	# {{ $host }}
	{{ template "upstream" (dict "Upstream" $upstream_name "Containers" $containers "Networks" $CurrentContainer.Networks "Debug" $debug_all) }}
{{ else }}
	{{ range $path, $containers := $paths }}
		{{ $sum := sha1 $path }}
		{{ $upstream := printf "%s-%s" $upstream_name $sum }}
		# {{ $host }}{{ $path }}
		{{ template "upstream" (dict "Upstream" $upstream "Containers" $containers "Networks" $CurrentContainer.Networks "Debug" $debug_all) }}
	{{ end }}
{{ end }}

{{ $default_host := or ($.Env.DEFAULT_HOST) "" }}
{{ $default_server := index (dict $host "" $default_host "default_server") $host }}

{{/* Get the SERVER_TOKENS defined by containers w/ the same vhost, falling back to "" */}}
{{ $server_tokens := trim (or (first (groupByKeys $containers "Env.SERVER_TOKENS")) "") }}


{{/* Get the HTTPS_METHOD defined by containers w/ the same vhost, falling back to "redirect" */}}
{{ $https_method := or (first (groupByKeys $containers "Env.HTTPS_METHOD")) (or $.Env.HTTPS_METHOD "redirect") }}

{{/* Get the SSL_POLICY defined by containers w/ the same vhost, falling back to empty string (use default) */}}
{{ $ssl_policy := or (first (groupByKeys $containers "Env.SSL_POLICY")) "" }}

{{/* Get the HSTS defined by containers w/ the same vhost, falling back to "max-age=31536000" */}}
{{ $hsts := or (first (groupByKeys $containers "Env.HSTS")) (or $.Env.HSTS "max-age=31536000") }}

{{/* Get the VIRTUAL_ROOT By containers w/ use fastcgi root */}}
{{ $vhost_root := or (first (groupByKeys $containers "Env.VIRTUAL_ROOT")) "/var/www/public" }}


{{/* Get the first cert name defined by containers w/ the same vhost */}}
{{ $certName := (first (groupByKeys $containers "Env.CERT_NAME")) }}

{{/* Get the best matching cert  by name for the vhost. */}}
{{ $vhostCert := (closest (dir "/etc/nginx/certs") (printf "%s.crt" $host))}}

{{/* vhostCert is actually a filename so remove any suffixes since they are added later */}}
{{ $vhostCert := trimSuffix ".crt" $vhostCert }}
{{ $vhostCert := trimSuffix ".key" $vhostCert }}

{{/* Use the cert specified on the container or fallback to the best vhost match */}}
{{ $cert := (coalesce $certName $vhostCert) }}

{{ $is_https := (and (ne $https_method "nohttps") (ne $cert "") (exists (printf "/etc/nginx/certs/%s.crt" $cert)) (exists (printf "/etc/nginx/certs/%s.key" $cert))) }}

{{ if $is_https }}

{{ if eq $https_method "redirect" }}
server {
	server_name {{ $host }};
	{{ if $server_tokens }}
	server_tokens {{ $server_tokens }};
	{{ end }}
	listen {{ $external_http_port }} {{ $default_server }};
	{{ if $enable_ipv6 }}
	listen [::]:{{ $external_http_port }} {{ $default_server }};
	{{ end }}
	{{ $access_log }}

	# Do not HTTPS redirect Let'sEncrypt ACME challenge
	location ^~ /.well-known/acme-challenge/ {
		auth_basic off;
		auth_request off;
		allow all;
		root /usr/share/nginx/html;
		try_files $uri =404;
		break;
	}

	location / {
		{{ if eq $external_https_port "443" }}
		return 301 https://$host$request_uri;
		{{ else }}
		return 301 https://$host:{{ $external_https_port }}$request_uri;
		{{ end }}
	}
}
{{ end }}

server {
	server_name {{ $host }};
	{{ if $server_tokens }}
	server_tokens {{ $server_tokens }};
	{{ end }}
	listen {{ $external_https_port }} ssl http2 {{ $default_server }};
	{{ if $enable_ipv6 }}
	listen [::]:{{ $external_https_port }} ssl http2 {{ $default_server }};
	{{ end }}
	{{ $access_log }}

	{{ template "ssl_policy" (dict "ssl_policy" $ssl_policy) }}

	ssl_session_timeout 5m;
	ssl_session_cache shared:SSL:50m;
	ssl_session_tickets off;

	ssl_certificate /etc/nginx/certs/{{ (printf "%s.crt" $cert) }};
	ssl_certificate_key /etc/nginx/certs/{{ (printf "%s.key" $cert) }};

	{{ if (exists (printf "/etc/nginx/certs/%s.dhparam.pem" $cert)) }}
	ssl_dhparam {{ printf "/etc/nginx/certs/%s.dhparam.pem" $cert }};
	{{ end }}

	{{ if (exists (printf "/etc/nginx/certs/%s.chain.pem" $cert)) }}
	ssl_stapling on;
	ssl_stapling_verify on;
	ssl_trusted_certificate {{ printf "/etc/nginx/certs/%s.chain.pem" $cert }};
	{{ end }}

	{{ if (not (or (eq $https_method "noredirect") (eq $hsts "off"))) }}
	add_header Strict-Transport-Security "{{ trim $hsts }}" always;
	{{ end }}

	{{ if (exists (printf "/etc/nginx/vhost.d/%s" $host)) }}
	include {{ printf "/etc/nginx/vhost.d/%s" $host }};
	{{ else if (exists "/etc/nginx/vhost.d/default") }}
	include /etc/nginx/vhost.d/default;
	{{ end }}

	{{ if eq $nPaths 0 }}
		{{/* Get the VIRTUAL_PROTO defined by containers w/ the same vhost, falling back to "http" */}}
		{{ $proto := trim (or (first (groupByKeys $containers "Env.VIRTUAL_PROTO")) "http") }}

		{{/* Get the NETWORK_ACCESS defined by containers w/ the same vhost, falling back to "external" */}}
		{{ $network_tag := or (first (groupByKeys $containers "Env.NETWORK_ACCESS")) "external" }}
		{{ template "location" (dict "Path" "/" "Proto" $proto "Upstream" $upstream_name "Host" $host "VhostRoot" $vhost_root "Dest" "" "NetworkTag" $network_tag) }}
	{{ else }}
		{{ range $path, $container := $paths }}
			{{/* Get the VIRTUAL_PROTO defined by containers w/ the same vhost-vpath, falling back to "http" */}}
			{{ $proto := trim (or (first (groupByKeys $container "Env.VIRTUAL_PROTO")) "http") }}

			{{/* Get the NETWORK_ACCESS defined by containers w/ the same vhost, falling back to "external" */}}
			{{ $network_tag := or (first (groupByKeys $container "Env.NETWORK_ACCESS")) "external" }}
			{{ $sum := sha1 $path }}
			{{ $upstream := printf "%s-%s" $upstream_name $sum }}
			{{ $dest := (or (first (groupByKeys $container "Env.VIRTUAL_DEST")) "") }}
			{{ template "location" (dict "Path" $path "Proto" $proto "Upstream" $upstream "Host" $host "VhostRoot" $vhost_root "Dest" $dest "NetworkTag" $network_tag) }}
		{{ end }}
		{{ if (not (contains $paths "/")) }}
			location / {
				return {{ $default_root_response }};
			}
		{{ end }}
	{{ end }}
}

{{ end }}

{{ if or (not $is_https) (eq $https_method "noredirect") }}

server {
	server_name {{ $host }};
	{{ if $server_tokens }}
	server_tokens {{ $server_tokens }};
	{{ end }}
	listen {{ $external_http_port }} {{ $default_server }};
	{{ if $enable_ipv6 }}
	listen [::]:{{ $external_http_port }} {{ $default_server }};
	{{ end }}
	{{ $access_log }}

	{{ if (exists (printf "/etc/nginx/vhost.d/%s" $host)) }}
	include {{ printf "/etc/nginx/vhost.d/%s" $host }};
	{{ else if (exists "/etc/nginx/vhost.d/default") }}
	include /etc/nginx/vhost.d/default;
	{{ end }}

	{{ if eq $nPaths 0 }}
		{{/* Get the VIRTUAL_PROTO defined by containers w/ the same vhost, falling back to "http" */}}
		{{ $proto := trim (or (first (groupByKeys $containers "Env.VIRTUAL_PROTO")) "http") }}

		{{/* Get the NETWORK_ACCESS defined by containers w/ the same vhost, falling back to "external" */}}
		{{ $network_tag := or (first (groupByKeys $containers "Env.NETWORK_ACCESS")) "external" }}
		{{ template "location" (dict "Path" "/" "Proto" $proto "Upstream" $upstream_name "Host" $host "VhostRoot" $vhost_root "Dest" "" "NetworkTag" $network_tag) }}
	{{ else }}
		{{ range $path, $container := $paths }}
			{{/* Get the VIRTUAL_PROTO defined by containers w/ the same vhost-vpath, falling back to "http" */}}
			{{ $proto := trim (or (first (groupByKeys $container "Env.VIRTUAL_PROTO")) "http") }}

			{{/* Get the NETWORK_ACCESS defined by containers w/ the same vhost, falling back to "external" */}}
			{{ $network_tag := or (first (groupByKeys $container "Env.NETWORK_ACCESS")) "external" }}
			{{ $sum := sha1 $path }}
			{{ $upstream := printf "%s-%s" $upstream_name $sum }}
			{{ $dest := (or (first (groupByKeys $container "Env.VIRTUAL_DEST")) "") }}
			{{ template "location" (dict "Path" $path "Proto" $proto "Upstream" $upstream "Host" $host "VhostRoot" $vhost_root "Dest" $dest "NetworkTag" $network_tag) }}
		{{ end }}
		{{ if (not (contains $paths "/")) }}
			location / {
				return {{ $default_root_response }};
			}
		{{ end }}
	{{ end }}
}

{{ if (and (not $is_https) (exists "/etc/nginx/certs/default.crt") (exists "/etc/nginx/certs/default.key")) }}
server {
	server_name {{ $host }};
	{{ if $server_tokens }}
	server_tokens {{ $server_tokens }};
	{{ end }}
	listen {{ $external_https_port }} ssl http2 {{ $default_server }};
	{{ if $enable_ipv6 }}
	listen [::]:{{ $external_https_port }} ssl http2 {{ $default_server }};
	{{ end }}
	{{ $access_log }}
	return 500;

	ssl_certificate /etc/nginx/certs/default.crt;
	ssl_certificate_key /etc/nginx/certs/default.key;
}
{{ end }}


{{ end }}
{{ end }}