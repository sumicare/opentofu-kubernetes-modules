resource "kubernetes_manifest" "configmap_opencost_opencost_ui_nginx_config" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "nginx.conf" = <<-EOT
      gzip_static  on;
      gzip on;
      gzip_min_length 50000;
      gzip_proxied expired no-cache no-store private auth;
      gzip_types
          application/atom+xml
          application/geo+json
          application/javascript
          application/x-javascript
          application/json
          application/ld+json
          application/manifest+json
          application/rdf+xml
          application/rss+xml
          application/vnd.ms-fontobject
          application/wasm
          application/x-web-app-manifest+json
          application/xhtml+xml
          application/xml
          font/eot
          font/otf
          font/ttf
          image/bmp
          image/svg+xml
          text/cache-manifest
          text/calendar
          text/css
          text/javascript
          text/markdown
          text/plain
          text/xml
          text/x-component
          text/x-cross-domain-policy;

      upstream model {
              server release-name-opencost.opencost:9003;
      }

      server {
          server_name _;
          root /var/www;
          index index.html;
          large_client_header_buffers 4 32k;
          add_header Cache-Control "must-revalidate";

          error_page 504 /custom_504.html;
          location = /custom_504.html {
              internal;
          }

          add_header Cache-Control "max-age=300";
          location / {
              alias /var/www/;
              try_files $uri /index.html;
          }

          add_header ETag "1.96.0";
          listen 9090;
          listen [::]:9090;
          resolver 127.0.0.1 valid=5s;
          location /healthz {
              access_log /dev/null;
              return 200 'OK';
          }
          location /model/ {
              proxy_connect_timeout       180;
              proxy_send_timeout          180;
              proxy_read_timeout          180;
              proxy_pass http://model/;
              proxy_redirect off;
              proxy_http_version 1.1;
              proxy_set_header Connection "";
              proxy_set_header  X-Real-IP  $remote_addr;
              proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
          }
      }

      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "name" = "opencost-ui-nginx-config"
      "namespace" = "opencost"
    }
  }
}

resource "kubernetes_manifest" "configmap_opencost_custom_metrics" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "metrics.json" = "{\"disabledMetrics\": [] }"
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "release-name"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "opencost"
        "app.kubernetes.io/part-of" = "opencost"
        "app.kubernetes.io/version" = "1.117.6"
        "helm.sh/chart" = "opencost-2.3.2"
      }
      "name" = "custom-metrics"
      "namespace" = "opencost"
    }
  }
}
