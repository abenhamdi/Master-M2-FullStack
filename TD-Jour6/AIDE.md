# Guide d'Aide - TP Docker Avancé

Ce document contient des indices, bonnes pratiques et exemples pour vous aider à réaliser le TP.

---

## Partie 1 : Optimisation des Images Docker

### Multi-Stage Build - Exemple de Structure

```dockerfile
# Stage 1: Build dependencies
FROM python:3.11-slim AS builder

WORKDIR /app

# Installer uniquement les dépendances de build
RUN apt-get update && apt-get install -y --no-install-recommends \
 gcc \
 g++ \
 && rm -rf /var/lib/apt/lists/*

# Copier et installer les dépendances Python
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim

WORKDIR /app

# Copier uniquement les dépendances installées
COPY --from=builder /root/.local /root/.local

# Copier le code applicatif
COPY . .

# Créer un utilisateur non-root
RUN addgroup --system --gid 1001 appuser && \
 adduser --system --uid 1001 --ingroup appuser appuser && \
 chown -R appuser:appuser /app

USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
 CMD python -c "import requests; requests.get('http://localhost:8000/health')" || exit 1

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "app:app"]
```

### .dockerignore - Exemple Complet

```
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
*.egg-info/
dist/
build/

# Tests
.pytest_cache/
.coverage
htmlcov/
.tox/

# IDE
.vscode/
.idea/
*.swp
*.swo

# Git
.git/
.gitignore

# Documentation
*.md
docs/

# Docker
Dockerfile*
docker-compose*.yml
.dockerignore

# Logs
*.log

# OS
.DS_Store
Thumbs.db
```

### Commandes d'Analyse

```bash
# Taille des images
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Détail des layers
docker history --no-trunc ml-service:latest

# Analyse de sécurité
docker scout cves ml-service:latest --only-severity critical,high

# Scanner avec Trivy
trivy image --severity HIGH,CRITICAL ml-service:latest

# Dive - exploration interactive des layers
dive ml-service:latest
```

---

## Partie 2 : Docker Compose Avancé

### Template Complet de Service

```yaml
services:
 example-service:
 image: myimage:latest
 build:
 context: ./app/service
 dockerfile: Dockerfile
 args:
 - BUILD_ENV=production
 cache_from:
 - myimage:latest
 
 container_name: example-service
 hostname: example
 
 environment:
 - APP_ENV=production
 - LOG_LEVEL=info
 
 env_file:
 - .env.common
 - .env.prod
 
 secrets:
 - db_password
 - api_key
 
 configs:
 - source: app_config
 target: /etc/app/config.yml
 
 ports:
 - "8080:8080"
 
 expose:
 - "9090"
 
 volumes:
 - app_data:/data
 - ./logs:/var/log/app:rw
 
 networks:
 - frontend
 - backend
 
 depends_on:
 postgres:
 condition: service_healthy
 redis:
 condition: service_started
 
 healthcheck:
 test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
 interval: 30s
 timeout: 10s
 retries: 3
 start_period: 40s
 
 deploy:
 replicas: 3
 resources:
 limits:
 cpus: '0.50'
 memory: 512M
 reservations:
 cpus: '0.25'
 memory: 256M
 restart_policy:
 condition: on-failure
 delay: 5s
 max_attempts: 3
 window: 120s
 
 restart: unless-stopped
 
 logging:
 driver: "json-file"
 options:
 max-size: "10m"
 max-file: "3"
 
 labels:
 - "com.example.description=Example service"
 - "com.example.version=1.0"

volumes:
 app_data:
 driver: local
 driver_opts:
 type: none
 o: bind
 device: /data/app

networks:
 frontend:
 driver: bridge
 backend:
 driver: bridge
 internal: true

secrets:
 db_password:
 file: ./secrets/db_password.txt
 api_key:
 external: true

configs:
 app_config:
 file: ./configs/app.yml
```

### Health Checks par Technologie

```yaml
# PostgreSQL
healthcheck:
 test: ["CMD-SHELL", "pg_isready -U postgres"]
 interval: 10s
 timeout: 5s
 retries: 5

# Redis
healthcheck:
 test: ["CMD", "redis-cli", "ping"]
 interval: 10s
 timeout: 3s
 retries: 3

# MongoDB
healthcheck:
 test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
 interval: 10s
 timeout: 5s
 retries: 3

# Kafka
healthcheck:
 test: ["CMD-SHELL", "kafka-broker-api-versions.sh --bootstrap-server localhost:9092"]
 interval: 30s
 timeout: 10s
 retries: 5

# HTTP API
healthcheck:
 test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
 interval: 30s
 timeout: 3s
 retries: 3
 start_period: 10s

# Python script custom
healthcheck:
 test: ["CMD-SHELL", "python /app/healthcheck.py"]
 interval: 30s
 timeout: 5s
 retries: 3
```

### Gestion des Profiles

```yaml
# docker-compose.yml
services:
 prometheus:
 image: prom/prometheus
 profiles: ["monitoring", "prod"]
 # ...
 
 grafana:
 image: grafana/grafana
 profiles: ["monitoring", "prod"]
 # ...
 
 debug-tools:
 image: nicolaka/netshoot
 profiles: ["debug"]
 # ...
```

**Utilisation :**
```bash
# Démarrer avec monitoring
docker compose --profile monitoring up

# Démarrer production complète
docker compose --profile prod --profile monitoring up

# Démarrer avec debug
docker compose --profile dev --profile debug up
```

---

## Partie 3 : Docker Swarm

### Différences Compose vs Stack

| Fonctionnalité | Docker Compose | Docker Stack |
|---------------|----------------|--------------|
| `build` | Supporté | Non supporté (utiliser images) |
| `depends_on` | Supporté | Non supporté (ordre non garanti) |
| `container_name` | Supporté | Non supporté |
| `deploy` | Ignoré | Requis |
| `replicas` | Via `deploy.replicas` | Supporté |
| `networks` | Overlay automatique | Overlay automatique |

### Template Stack Swarm Complet

```yaml
version: '3.9'

services:
 web:
 image: registry.example.com/web:latest
 deploy:
 mode: replicated
 replicas: 5
 
 # Stratégie de mise à jour
 update_config:
 parallelism: 2 # Mise à jour de 2 conteneurs à la fois
 delay: 10s # Délai entre chaque batch
 failure_action: rollback
 monitor: 60s # Période de monitoring après update
 max_failure_ratio: 0.3
 order: start-first # Démarrer les nouveaux avant d'arrêter les anciens
 
 # Configuration de rollback
 rollback_config:
 parallelism: 2
 delay: 5s
 failure_action: pause
 monitor: 30s
 
 # Politique de redémarrage
 restart_policy:
 condition: on-failure
 delay: 5s
 max_attempts: 3
 window: 120s
 
 # Contraintes de placement
 placement:
 constraints:
 - node.role == worker
 - node.labels.environment == production
 - node.labels.storage == ssd
 preferences:
 - spread: node.labels.datacenter
 
 # Ressources
 resources:
 limits:
 cpus: '0.50'
 memory: 512M
 reservations:
 cpus: '0.25'
 memory: 256M
 
 # Labels
 labels:
 - "traefik.enable=true"
 - "traefik.http.routers.web.rule=Host(`example.com`)"
 
 networks:
 - frontend
 - backend
 
 secrets:
 - source: db_password
 target: /run/secrets/db_password
 uid: '1001'
 gid: '1001'
 mode: 0400
 
 configs:
 - source: nginx_config
 target: /etc/nginx/nginx.conf
 mode: 0440
 
 ports:
 - target: 80
 published: 8080
 protocol: tcp
 mode: ingress # ou 'host' pour pas de load balancing
 
 healthcheck:
 test: ["CMD", "curl", "-f", "http://localhost/health"]
 interval: 30s
 timeout: 3s
 retries: 3
 start_period: 40s

networks:
 frontend:
 driver: overlay
 attachable: true
 backend:
 driver: overlay
 internal: true

secrets:
 db_password:
 external: true

configs:
 nginx_config:
 file: ./configs/nginx.conf

volumes:
 data:
 driver: local
 driver_opts:
 type: nfs
 o: addr=10.0.0.1,rw
 device: ":/exports/data"
```

### Commandes Swarm Utiles

```bash
# Initialisation
docker swarm init --advertise-addr <IP>

# Ajouter un worker
docker swarm join --token <TOKEN> <IP>:2377

# Ajouter un manager
docker swarm join-token manager

# Lister les nodes
docker node ls

# Inspecter un node
docker node inspect <NODE_ID>

# Promouvoir un worker en manager
docker node promote <NODE_ID>

# Ajouter un label à un node
docker node update --label-add environment=production <NODE_ID>

# Stack operations
docker stack deploy -c docker-stack.yml mystack
docker stack ls
docker stack services mystack
docker stack ps mystack

# Service operations
docker service ls
docker service inspect --pretty <SERVICE_NAME>
docker service logs -f <SERVICE_NAME>
docker service ps <SERVICE_NAME>

# Scaling
docker service scale mystack_web=10

# Rolling update manuel
docker service update --image web:v2 mystack_web

# Rollback
docker service rollback mystack_web

# Forcer une mise à jour (sans changement d'image)
docker service update --force mystack_web

# Secrets
docker secret create db_password ./password.txt
docker secret ls
docker secret inspect db_password

# Configs
docker config create nginx_config ./nginx.conf
docker config ls
```

### Stratégies de Placement Avancées

```yaml
# Exemples de contraintes de placement
placement:
 constraints:
 # Rôle du node
 - node.role == worker
 - node.role == manager
 
 # Hostname
 - node.hostname == worker-01
 - node.hostname != worker-02
 
 # Labels personnalisés
 - node.labels.environment == production
 - node.labels.storage == ssd
 - node.labels.gpu == true
 
 # Architecture
 - node.platform.arch == x86_64
 - node.platform.os == linux
 
 # Combinaisons
 - node.role == worker
 - node.labels.environment == production
 - node.labels.region == eu-west-1

# Préférences de distribution
placement:
 preferences:
 # Distribuer sur les zones de disponibilité
 - spread: node.labels.zone
 
 # Distribuer sur les datacenters
 - spread: node.labels.datacenter
 
 # Distribuer sur les racks
 - spread: node.labels.rack
```

---

## Partie 4 : Sécurité Docker

### Dockerfile Sécurisé - Template Complet

```dockerfile
# Stage 1: Builder
FROM python:3.11-slim AS builder

# Installer uniquement les dépendances de build nécessaires
RUN apt-get update && apt-get install -y --no-install-recommends \
 gcc \
 g++ \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copier et installer les dépendances
COPY requirements.txt .
RUN pip install --user --no-cache-dir --no-warn-script-location \
 -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim

# Métadonnées
LABEL maintainer="your-email@example.com" \
 version="1.0" \
 description="ML Service"

# Installer uniquement les dépendances runtime nécessaires
RUN apt-get update && apt-get install -y --no-install-recommends \
 curl \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get clean

# Créer un utilisateur non-root
RUN groupadd --gid 1001 appuser && \
 useradd --uid 1001 --gid appuser --shell /bin/bash --create-home appuser

WORKDIR /app

# Copier les dépendances Python du builder
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local

# Copier le code applicatif
COPY --chown=appuser:appuser . .

# Mettre à jour le PATH pour l'utilisateur
ENV PATH=/home/appuser/.local/bin:$PATH

# Changer de user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
 CMD curl -f http://localhost:8000/health || exit 1

# Exposer le port
EXPOSE 8000

# Point d'entrée sécurisé
ENTRYPOINT ["python"]
CMD ["-m", "gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "app:app"]
```

### Configuration Swarm/Compose Sécurisée

```yaml
services:
 app:
 image: app:latest
 
 # Utilisateur non-root (si non défini dans l'image)
 user: "1001:1001"
 
 # Capabilities Linux restreintes
 cap_drop:
 - ALL
 cap_add:
 - NET_BIND_SERVICE # Uniquement si besoin de binder port < 1024
 - CHOWN # Si besoin de changer ownership
 
 # Options de sécurité
 security_opt:
 - no-new-privileges:true
 - apparmor:docker-default
 - seccomp:default
 
 # Filesystem read-only avec tmpfs pour les dossiers temporaires
 read_only: true
 tmpfs:
 - /tmp:size=100M,mode=1777
 - /app/cache:size=200M,mode=1777
 - /run:size=50M,mode=1777
 
 # PID limits (prévenir fork bomb)
 pids_limit: 200
 
 # Ressources limitées
 deploy:
 resources:
 limits:
 cpus: '1.0'
 memory: 1G
 pids: 100
 reservations:
 cpus: '0.5'
 memory: 512M
 
 # Utiliser des secrets, pas des env vars
 secrets:
 - source: db_password
 target: /run/secrets/db_password
 mode: 0400
 
 # Network isolation
 networks:
 - app_network
 
 # Logging limité
 logging:
 driver: "json-file"
 options:
 max-size: "10m"
 max-file: "3"
```

### Scan de Sécurité - Script Automatisé

```bash
#!/bin/bash
# security-scan.sh - Scanner toutes les images

IMAGES=("ml-service:latest" "data-api:latest" "preprocessor:latest")
REPORT_FILE="security-report.md"

echo "# Security Scan Report" > $REPORT_FILE
echo "Date: $(date)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

for IMAGE in "${IMAGES[@]}"; do
 echo "## Scanning $IMAGE" >> $REPORT_FILE
 echo "" >> $REPORT_FILE
 
 # Docker Scout
 echo "### Docker Scout Results" >> $REPORT_FILE
 docker scout cves $IMAGE --only-severity critical,high >> $REPORT_FILE 2>&1
 
 # Trivy
 echo "" >> $REPORT_FILE
 echo "### Trivy Results" >> $REPORT_FILE
 trivy image --severity HIGH,CRITICAL $IMAGE >> $REPORT_FILE 2>&1
 
 echo "" >> $REPORT_FILE
 echo "---" >> $REPORT_FILE
 echo "" >> $REPORT_FILE
done

echo "Report generated: $REPORT_FILE"
```

---

## Partie 5 : CI/CD

### Variables Secrets GitHub Actions

Dans votre repo GitHub : `Settings > Secrets and variables > Actions`

**Secrets requis :**
- `DOCKER_USERNAME`: Votre username Docker Hub ou GHCR
- `DOCKER_PASSWORD`: Votre token d'accès
- `SWARM_HOST`: IP du manager Swarm
- `SWARM_SSH_KEY`: Clé SSH pour se connecter au Swarm

### Pipeline Complet avec Tests

```yaml
name: Complete CI/CD Pipeline

on:
 push:
 branches: [main, develop]
 tags: ['v*']
 pull_request:
 branches: [main]

env:
 REGISTRY: ghcr.io
 IMAGE_NAME: ${{ github.repository }}

jobs:
 # Lint et Tests Unitaires
 lint-and-test:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4
 
 - name: Set up Python
 uses: actions/setup-python@v4
 with:
 python-version: '3.11'
 
 - name: Install dependencies
 run: |
 pip install flake8 pytest pytest-cov black isort
 pip install -r requirements.txt
 
 - name: Run linters
 run: |
 flake8 app/ --max-line-length=120
 black --check app/
 isort --check-only app/
 
 - name: Run unit tests
 run: |
 pytest tests/ -v --cov=app --cov-report=xml
 
 - name: Upload coverage
 uses: codecov/codecov-action@v3
 with:
 file: ./coverage.xml

 # Build et Tests d'Intégration
 build:
 runs-on: ubuntu-latest
 needs: lint-and-test
 strategy:
 matrix:
 service: [ml-service, data-api, preprocessor]
 steps:
 - uses: actions/checkout@v4
 
 - name: Set up Docker Buildx
 uses: docker/setup-buildx-action@v3
 
 - name: Build image
 uses: docker/build-push-action@v5
 with:
 context: ./app/${{ matrix.service }}
 file: ./app/${{ matrix.service }}/Dockerfile
 push: false
 load: true
 tags: ${{ matrix.service }}:test
 cache-from: type=gha,scope=${{ matrix.service }}
 cache-to: type=gha,mode=max,scope=${{ matrix.service }}
 
 - name: Run integration tests
 run: |
 docker run -d --name test-${{ matrix.service }} ${{ matrix.service }}:test
 sleep 10
 docker exec test-${{ matrix.service }} python -m pytest tests/integration/
 docker stop test-${{ matrix.service }}

 # Scan de Sécurité
 security:
 runs-on: ubuntu-latest
 needs: build
 strategy:
 matrix:
 service: [ml-service, data-api, preprocessor]
 steps:
 - uses: actions/checkout@v4
 
 - name: Build image
 run: |
 docker build -t ${{ matrix.service }}:scan \
 -f ./app/${{ matrix.service }}/Dockerfile \
 ./app/${{ matrix.service }}
 
 - name: Run Trivy scanner
 uses: aquasecurity/trivy-action@master
 with:
 image-ref: ${{ matrix.service }}:scan
 format: 'sarif'
 output: 'trivy-${{ matrix.service }}.sarif'
 severity: 'CRITICAL,HIGH'
 exit-code: '1' # Fail si vulnérabilités critiques
 
 - name: Upload Trivy results
 if: always()
 uses: github/codeql-action/upload-sarif@v2
 with:
 sarif_file: 'trivy-${{ matrix.service }}.sarif'
 
 - name: Run Hadolint (Dockerfile linter)
 uses: hadolint/hadolint-action@v3.1.0
 with:
 dockerfile: ./app/${{ matrix.service }}/Dockerfile
 failure-threshold: warning

 # Build et Push (branches principales uniquement)
 push:
 runs-on: ubuntu-latest
 needs: [build, security]
 if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v'))
 strategy:
 matrix:
 service: [ml-service, data-api, preprocessor]
 permissions:
 contents: read
 packages: write
 steps:
 - uses: actions/checkout@v4
 
 - name: Log in to registry
 uses: docker/login-action@v3
 with:
 registry: ${{ env.REGISTRY }}
 username: ${{ github.actor }}
 password: ${{ secrets.GITHUB_TOKEN }}
 
 - name: Extract metadata
 id: meta
 uses: docker/metadata-action@v5
 with:
 images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}/${{ matrix.service }}
 tags: |
 type=ref,event=branch
 type=sha,prefix={{branch}}-
 type=semver,pattern={{version}}
 type=semver,pattern={{major}}.{{minor}}
 type=raw,value=latest,enable={{is_default_branch}}
 
 - name: Set up Docker Buildx
 uses: docker/setup-buildx-action@v3
 
 - name: Build and push
 uses: docker/build-push-action@v5
 with:
 context: ./app/${{ matrix.service }}
 file: ./app/${{ matrix.service }}/Dockerfile
 platforms: linux/amd64,linux/arm64
 push: true
 tags: ${{ steps.meta.outputs.tags }}
 labels: ${{ steps.meta.outputs.labels }}
 cache-from: type=gha,scope=${{ matrix.service }}
 cache-to: type=gha,mode=max,scope=${{ matrix.service }}

 # Déploiement Staging
 deploy-staging:
 runs-on: ubuntu-latest
 needs: push
 if: github.ref == 'refs/heads/develop'
 environment:
 name: staging
 url: https://staging.example.com
 steps:
 - uses: actions/checkout@v4
 
 - name: Setup SSH
 run: |
 mkdir -p ~/.ssh
 echo "${{ secrets.SWARM_SSH_KEY }}" > ~/.ssh/id_rsa
 chmod 600 ~/.ssh/id_rsa
 ssh-keyscan -H ${{ secrets.SWARM_HOST }} >> ~/.ssh/known_hosts
 
 - name: Deploy to Swarm
 run: |
 ssh -i ~/.ssh/id_rsa user@${{ secrets.SWARM_HOST }} << 'EOF'
 cd /opt/ml-pipeline
 docker stack deploy -c docker-stack-staging.yml ml-pipeline-staging
 docker service ls
 EOF
 
 - name: Wait for services
 run: |
 sleep 30
 curl -f https://staging.example.com/health || exit 1
 
 - name: Run smoke tests
 run: |
 curl -f https://staging.example.com/api/health
 curl -X POST https://staging.example.com/api/predict \
 -H "Content-Type: application/json" \
 -d '{"text": "test"}'

 # Déploiement Production (avec approbation manuelle)
 deploy-production:
 runs-on: ubuntu-latest
 needs: push
 if: startsWith(github.ref, 'refs/tags/v')
 environment:
 name: production
 url: https://example.com
 steps:
 - uses: actions/checkout@v4
 
 - name: Setup SSH
 run: |
 mkdir -p ~/.ssh
 echo "${{ secrets.SWARM_SSH_KEY }}" > ~/.ssh/id_rsa
 chmod 600 ~/.ssh/id_rsa
 ssh-keyscan -H ${{ secrets.SWARM_HOST }} >> ~/.ssh/known_hosts
 
 - name: Deploy to Production Swarm
 run: |
 ssh -i ~/.ssh/id_rsa user@${{ secrets.SWARM_HOST }} << 'EOF'
 cd /opt/ml-pipeline
 
 # Backup de la stack actuelle
 docker stack ps ml-pipeline > backup-$(date +%Y%m%d-%H%M%S).txt
 
 # Déploiement avec rolling update
 docker stack deploy -c docker-stack-prod.yml ml-pipeline
 
 # Vérifier le déploiement
 sleep 60
 docker service ls | grep ml-pipeline
 EOF
 
 - name: Health check
 run: |
 sleep 60
 for i in {1..5}; do
 curl -f https://example.com/health && break || sleep 10
 done
 
 - name: Notify deployment
 if: always()
 run: |
 # Envoyer notification Slack/Discord
 echo "Deployment completed"

 # Notification en cas d'échec
 notify-failure:
 runs-on: ubuntu-latest
 needs: [lint-and-test, build, security, push, deploy-staging, deploy-production]
 if: failure()
 steps:
 - name: Send failure notification
 run: |
 # Envoyer notification d'échec
 echo "Pipeline failed"
```

---

## Partie 6 : Monitoring

### Dashboard Grafana - Configuration JSON

Créer `grafana/dashboards/ml-pipeline.json` :

```json
{
 "dashboard": {
 "title": "ML Pipeline Dashboard",
 "panels": [
 {
 "title": "Requests per Second",
 "targets": [
 {
 "expr": "rate(ml_api_requests_total[5m])"
 }
 ]
 },
 {
 "title": "Request Latency (p95)",
 "targets": [
 {
 "expr": "histogram_quantile(0.95, rate(ml_api_request_duration_seconds_bucket[5m]))"
 }
 ]
 },
 {
 "title": "Error Rate",
 "targets": [
 {
 "expr": "rate(ml_api_requests_total{status=~\"5..\"}[5m]) / rate(ml_api_requests_total[5m])"
 }
 ]
 },
 {
 "title": "Active Requests",
 "targets": [
 {
 "expr": "ml_api_active_requests"
 }
 ]
 },
 {
 "title": "Predictions Total",
 "targets": [
 {
 "expr": "ml_predictions_total"
 }
 ]
 },
 {
 "title": "Container CPU Usage",
 "targets": [
 {
 "expr": "rate(container_cpu_usage_seconds_total{name=~\"ml-pipeline.*\"}[5m])"
 }
 ]
 },
 {
 "title": "Container Memory Usage",
 "targets": [
 {
 "expr": "container_memory_usage_bytes{name=~\"ml-pipeline.*\"}"
 }
 ]
 }
 ]
 }
}
```

### Datasource Prometheus Configuration

Créer `grafana/datasources/prometheus.yml` :

```yaml
apiVersion: 1

datasources:
 - name: Prometheus
 type: prometheus
 access: proxy
 url: http://prometheus:9090
 isDefault: true
 editable: false
```

### Alertes Prometheus

Créer `prometheus/alerts.yml` :

```yaml
groups:
 - name: ml_pipeline_alerts
 interval: 30s
 rules:
 # Alerte si taux d'erreur > 5%
 - alert: HighErrorRate
 expr: |
 rate(ml_api_requests_total{status=~"5.."}[5m]) 
 / rate(ml_api_requests_total[5m]) > 0.05
 for: 5m
 labels:
 severity: critical
 annotations:
 summary: "High error rate detected"
 description: "Error rate is {{ $value | humanizePercentage }}"
 
 # Alerte si latence p95 > 1s
 - alert: HighLatency
 expr: |
 histogram_quantile(0.95, 
 rate(ml_api_request_duration_seconds_bucket[5m])
 ) > 1
 for: 5m
 labels:
 severity: warning
 annotations:
 summary: "High latency detected"
 description: "P95 latency is {{ $value }}s"
 
 # Alerte si service down
 - alert: ServiceDown
 expr: up{job="ml-api"} == 0
 for: 2m
 labels:
 severity: critical
 annotations:
 summary: "Service {{ $labels.instance }} is down"
 
 # Alerte si CPU élevé
 - alert: HighCPUUsage
 expr: |
 rate(container_cpu_usage_seconds_total{name=~"ml-pipeline.*"}[5m]) > 0.8
 for: 10m
 labels:
 severity: warning
 annotations:
 summary: "High CPU usage on {{ $labels.name }}"
 description: "CPU usage is {{ $value | humanizePercentage }}"
 
 # Alerte si mémoire élevée
 - alert: HighMemoryUsage
 expr: |
 container_memory_usage_bytes{name=~"ml-pipeline.*"} 
 / container_spec_memory_limit_bytes > 0.9
 for: 5m
 labels:
 severity: warning
 annotations:
 summary: "High memory usage on {{ $labels.name }}"
 description: "Memory usage is {{ $value | humanizePercentage }}"
```

---

## Troubleshooting

### Problèmes Courants

#### 1. Service ne démarre pas
```bash
# Vérifier les logs
docker service logs -f <service_name>

# Vérifier l'état des tasks
docker service ps <service_name> --no-trunc

# Inspecter le service
docker service inspect --pretty <service_name>
```

#### 2. Health check échoue
```bash
# Tester manuellement le health check
docker exec <container_id> curl -f http://localhost:8000/health

# Vérifier les logs du conteneur
docker logs <container_id>
```

#### 3. Network issues
```bash
# Lister les networks
docker network ls

# Inspecter un network
docker network inspect <network_name>

# Tester la connectivité
docker run --rm --network <network_name> nicolaka/netshoot ping <service_name>
```

#### 4. Secrets non accessibles
```bash
# Vérifier que le secret existe
docker secret ls

# Inspecter le secret
docker secret inspect <secret_name>

# Vérifier les permissions dans le conteneur
docker exec <container_id> ls -la /run/secrets/
```

#### 5. Rolling update bloqué
```bash
# Voir l'état du service
docker service ps <service_name>

# Forcer un rollback
docker service rollback <service_name>

# Mettre à jour avec force
docker service update --force <service_name>
```

---

## Ressources Supplémentaires

### Documentation
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [Compose Specification](https://compose-spec.io/)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)

### Outils Recommandés
- **Dive** : Explorer les layers d'images
- **Trivy** : Scanner de vulnérabilités
- **Hadolint** : Linter pour Dockerfiles
- **ctop** : Monitoring interactif des conteneurs
- **lazydocker** : TUI pour gérer Docker

### Commandes d'Installation

```bash
# Dive
brew install dive
# ou
wget https://github.com/wagoodman/dive/releases/download/v0.11.0/dive_0.11.0_linux_amd64.deb
sudo dpkg -i dive_0.11.0_linux_amd64.deb

# Trivy
brew install trivy
# ou
sudo apt-get install trivy

# Hadolint
brew install hadolint
# ou
docker pull hadolint/hadolint

# ctop
brew install ctop
# ou
sudo wget https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 -O /usr/local/bin/ctop
sudo chmod +x /usr/local/bin/ctop

# lazydocker
brew install lazydocker
# ou
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
```

---

Bon courage pour le TP ! 
