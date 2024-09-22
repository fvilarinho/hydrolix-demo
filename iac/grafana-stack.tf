# Creates the ingress settings file.
resource "local_sensitive_file" "grafanaIngressSettings" {
  filename = local.grafanaIngressSettingsFilename
  content  = <<EOT
server {
    listen 80;
    listen 443 ssl;
    http2 on;
    ssl_certificate /etc/tls/fullchain.pem;
    ssl_certificate_key /etc/tls/privkey.pem;

    location / {
        proxy_pass http://grafana:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }

    location = /404.html {
        internal;
    }
}
EOT
}

# Creates the stack file.
resource "local_sensitive_file" "grafanaStack" {
  filename = local.grafanaStackFilename
  content  = <<EOT
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
spec:
  ports:
    - name: http
      port: 3000
      targetPort: 3000
  selector:
    app: grafana
---
apiVersion: v1
kind: Service
metadata:
  name: ingress
spec:
  ports:
    - name: http
      port: 80
      targetPort: 80
    - name: https
      port: 443
      targetPort: 443
  selector:
    app: ingress
  type: LoadBalancer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  labels:
    app: grafana
spec:
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      securityContext:
        fsGroup: 472
        supplementalGroups:
          - 0
      containers:
        - name: grafana
          image: grafana/grafana:latest
          imagePullPolicy: Always
          env:
            - name: GF_INSTALL_PLUGINS
              value: "grafana-clickhouse-datasource"
            - name: GF_SECURITY_ADMIN_USER
              value: "${var.settings.general.email}"
            - name: GF_SECURITY_ADMIN_PASSWORD
              value: "${var.settings.grafana.password}"
          ports:
            - containerPort: 3000
          volumeMounts:
            - mountPath: /var/lib/grafana
              name: grafana
      volumes:
        - name: grafana
          persistentVolumeClaim:
            claimName: grafana
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ingress
  labels:
    app: ingress
spec:
  selector:
    matchLabels:
      app: ingress
  template:
    metadata:
      labels:
        app: ingress
    spec:
      restartPolicy: Always
      containers:
        - name: ingress
          image: nginx:latest
          imagePullPolicy: Always
          ports:
            - containerPort: 80
            - containerPort: 443
          volumeMounts:
            - name: ingress-settings
              mountPath: /etc/nginx/conf.d/default.conf
              subPath: ingress.conf
            - name: ingress-tls-certificate
              mountPath: /etc/tls/fullchain.pem
              subPath: fullchain.pem
            - name: ingress-tls-certificate-key
              mountPath: /etc/tls/privkey.pem
              subPath: privkey.pem
      volumes:
        - name: ingress-settings
          configMap:
            name: ingress-settings
        - name: ingress-tls-certificate
          configMap:
            name: ingress-tls-certificate
        - name: ingress-tls-certificate-key
          configMap:
            name: ingress-tls-certificate-key
EOT
}

# Applies the stack in the LKE cluster.
resource "null_resource" "applyGrafanaStack" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    # Required variables.
    environment = {
      KUBECONFIG                = local.grafanaKubeconfigFilename
      NAMESPACE                 = var.settings.grafana.namespace
      INGRESS_SETTINGS_FILENAME = local.grafanaIngressSettingsFilename
      STACK_FILENAME            = local.grafanaStackFilename
      CERTIFICATE_FILENAME      = local.certificateFilename
      CERTIFICATE_KEY_FILENAME  = local.certificateKeyFilename
    }

    quiet   = true
    command = local.grafanaApplyStackScript
  }

  depends_on = [
    local_sensitive_file.grafanaKubeconfig,
    local_sensitive_file.grafanaIngressSettings,
    local_sensitive_file.grafanaStack
  ]
}

# Fetches the origin hostname.
data "external" "grafanaOrigin" {
  program = [
    local.fetchGrafanaOriginScript,
    local.grafanaKubeconfigFilename,
    var.settings.grafana.namespace
  ]

  depends_on = [ null_resource.applyGrafanaStack ]
}