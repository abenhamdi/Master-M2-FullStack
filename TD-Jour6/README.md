# TP Docker Avancé - Master 2 Data
## Déploiement d'un Pipeline ML en Production avec Docker

**Durée estimée :** 4 heures 
**Niveau :** Master 2 / Professionnel 
**Prérequis :** Docker, Docker Compose, notions de ML/Data Science


## Objectifs Pédagogiques

À l'issue de ce TP, vous serez capable de :

1. **Optimiser des images Docker** pour la production (multi-stage builds, layers caching)
2. **Orchestrer des services complexes** avec Docker Compose avancé
3. **Déployer un cluster** avec Docker Swarm
4. **Sécuriser vos conteneurs** (scanning, secrets, users non-root)
5. **Mettre en place un pipeline CI/CD** pour vos images Docker
6. **Monitorer et logger** vos applications conteneurisées


## Contexte du Projet

Vous êtes Data Engineer dans une startup spécialisée en IA. Votre mission est de déployer en production un pipeline complet de Machine Learning comprenant :

- **Collecte de données** : API REST pour l'ingestion
- **Traitement** : Pipeline de preprocessing avec Apache Kafka
- **Entraînement** : Modèle de prédiction (classification de textes)
- **Serving** : API de prédiction en temps réel
- **Monitoring** : Métriques et logs centralisés

### Architecture Cible

```
 
 API Data > Kafka > Preprocessor
 Ingestion (Broker) Worker 
 
 
 
 
 PostgreSQL ML Model 
 (Storage) Serving 
 
 
 
 
 
 Prometheus + 
 Grafana 
 
```

---

## Partie 1 : Optimisation des Images Docker (45 min)

### Exercice 1.1 : Image Python ML Optimisée

Créez un fichier `Dockerfile.ml-service` pour un service de prédiction ML.

**Contraintes :**
- Base : Python 3.11
- Dépendances : scikit-learn, pandas, numpy, flask
- Taille finale < 500 MB
- Build time < 3 min
- Utiliser multi-stage build
- Layer caching optimisé

**Fichier de dépendances (`requirements.txt`) :**
```
flask==3.0.0
scikit-learn==1.4.0
pandas==2.2.0
numpy==1.26.3
prometheus-client==0.19.0
gunicorn==21.2.0
```

**Critères d'évaluation :**
- Multi-stage build utilisé
- Cache des layers optimisé (COPY requirements avant le code)
- Pas de fichiers inutiles (.pyc, __pycache__, tests)
- Utilisateur non-root
- Health check configuré

** Indice :** Utilisez `python:3.11-slim` comme base, et explorez `.dockerignore`.

---

### Exercice 1.2 : Analyse et Optimisation

Analysez votre image avec :

```bash
docker images
docker history <image-name>
docker scout cves <image-name> # Analyse de sécurité
```

**Questions :**
1. Quelle est la taille de chaque layer ?
2. Combien de vulnérabilités critiques sont détectées ?
3. Comment réduire encore la taille de l'image ?

** Livrable :** `td/partie1/Dockerfile.ml-service` et `td/partie1/analyse.md`


## Partie 2 : Docker Compose Avancé (60 min)

### Exercice 2.1 : Pipeline de Données avec Compose

Créez un `docker-compose.yml` qui orchestre les services suivants :

#### Services à déployer :

1. **PostgreSQL** (base de données)
 - Volume persistant
 - Secrets pour les credentials
 - Health check

2. **Kafka** (message broker)
 - Zookeeper inclus
 - 3 partitions par défaut
 - Retention de 7 jours

3. **API d'Ingestion** (Python Flask)
 - Expose le port 5000
 - Envoie les données vers Kafka
 - Dépend de Kafka

4. **Data Preprocessor** (Consumer Kafka)
 - Consomme depuis Kafka
 - Traite les données
 - Stocke dans PostgreSQL

5. **ML Serving API** (FastAPI)
 - Charge le modèle au démarrage
 - Expose le port 8000
 - Lit depuis PostgreSQL

**Contraintes Docker Compose :**
- Utiliser `networks` pour isoler les services
- Utiliser `secrets` pour les credentials
- Utiliser `configs` pour les fichiers de configuration
- Définir des `healthchecks` pour chaque service
- Limiter les ressources (CPU, mémoire)
- Utiliser `depends_on` avec conditions `service_healthy`

**Exemple de structure attendue :**

```yaml
version: '3.9'

services:
 postgres:
 image: postgres:16-alpine
 environment:
 POSTGRES_PASSWORD_FILE: /run/secrets/db_password
 secrets:
 - db_password
 healthcheck:
 test: ["CMD-SHELL", "pg_isready -U postgres"]
 interval: 10s
 timeout: 5s
 retries: 5
 deploy:
 resources:
 limits:
 cpus: '1'
 memory: 1G
 # ... À COMPLÉTER

secrets:
 db_password:
 file: ./secrets/db_password.txt

networks:
 # ... À DÉFINIR
```

** Indice :** Créez 2 networks : `backend` (DB + Kafka) et `frontend` (APIs).

---

### Exercice 2.2 : Variables d'Environnement et Profils

Créez 3 environnements différents :
- **dev** : logs verbose, 1 replica, sans monitoring
- **staging** : logs normaux, 2 replicas, monitoring basique
- **prod** : logs minimaux, 3+ replicas, monitoring complet

Utilisez les **profiles** Docker Compose et des fichiers `.env`.

**Fichiers à créer :**
- `.env.dev`
- `.env.staging`
- `.env.prod`
- `docker-compose.override.yml`

**Commandes attendues :**
```bash
docker compose --profile dev up
docker compose --profile prod up
```

** Livrable :** `td/partie2/docker-compose.yml` et fichiers d'environnement


## Partie 3 : Docker Swarm - Orchestration (50 min)

### Exercice 3.1 : Initialisation du Cluster Swarm

Déployez votre pipeline ML sur un cluster Docker Swarm.

**Étapes :**

1. **Initialiser Swarm**
```bash
docker swarm init
```

2. **Convertir votre docker-compose en stack Swarm**

Créez `docker-stack.yml` compatible Swarm :
- Remplacer `depends_on` par des contraintes de déploiement
- Ajouter des `replicas` et `update_config`
- Configurer le `placement` des services
- Définir des `rollback_config`

**Exemple de configuration de déploiement :**

```yaml
services:
 ml-api:
 image: ml-service:latest
 deploy:
 replicas: 3
 update_config:
 parallelism: 1
 delay: 10s
 failure_action: rollback
 rollback_config:
 parallelism: 1
 delay: 5s
 restart_policy:
 condition: on-failure
 delay: 5s
 max_attempts: 3
 resources:
 limits:
 cpus: '0.5'
 memory: 512M
 reservations:
 cpus: '0.25'
 memory: 256M
 placement:
 constraints:
 - node.role == worker
 # ... À COMPLÉTER
```

3. **Déployer la stack**
```bash
docker stack deploy -c docker-stack.yml ml-pipeline
```


### Exercice 3.2 : Scaling et Rolling Updates

**Missions :**

1. **Scaler le service ML API** à 5 replicas
```bash
docker service scale ml-pipeline_ml-api=5
```

2. **Mettre à jour l'image sans downtime**
 - Modifier le code du service ML
 - Rebuilder l'image avec un nouveau tag
 - Faire un rolling update

3. **Simuler une panne et observer le rollback automatique**

**Questions :**
1. Comment vérifier que les 5 replicas sont bien distribués ?
2. Quel est le temps de downtime lors de la mise à jour ?
3. Comment forcer un rollback manuel ?

** Livrable :** `td/partie3/docker-stack.yml` et `td/partie3/commandes.md`


## Partie 4 : Sécurité Docker (45 min)

### Exercice 4.1 : Hardening des Conteneurs

Sécurisez vos conteneurs en appliquant les bonnes pratiques :

**1. Utilisateur non-root**

Modifiez tous vos Dockerfiles :
```dockerfile
RUN addgroup --system --gid 1001 appuser && \
 adduser --system --uid 1001 --ingroup appuser appuser

USER appuser
```

**2. Secrets Management**

Créez et utilisez des secrets Swarm :
```bash
echo "super_secret_password" | docker secret create db_password -
```

Dans votre stack :
```yaml
services:
 postgres:
 secrets:
 - db_password
 environment:
 POSTGRES_PASSWORD_FILE: /run/secrets/db_password

secrets:
 db_password:
 external: true
```

**3. Scan de vulnérabilités**

Analysez vos images :
```bash
docker scout cves ml-service:latest
docker scout recommendations ml-service:latest
```

**4. Capacités Linux restreintes**

Limitez les capacités :
```yaml
services:
 ml-api:
 cap_drop:
 - ALL
 cap_add:
 - NET_BIND_SERVICE
 security_opt:
 - no-new-privileges:true
```

**5. Read-only filesystem**

```yaml
services:
 ml-api:
 read_only: true
 tmpfs:
 - /tmp
 - /app/cache
```


### Exercice 4.2 : Audit et Compliance

**Tâches :**

1. **Scanner toutes vos images** et générer un rapport
2. **Corriger** toutes les vulnérabilités CRITICAL et HIGH
3. **Documenter** les CVE qui ne peuvent pas être corrigées

**Outils suggérés :**
- Docker Scout
- Trivy : `trivy image ml-service:latest`
- Grype : `grype ml-service:latest`

** Livrable :** `td/partie4/security-report.md` avec les CVE et actions correctives


## Partie 5 : CI/CD Pipeline (60 min)

### Exercice 5.1 : GitHub Actions pour Docker

Créez un pipeline CI/CD complet avec GitHub Actions.

**Fichier `.github/workflows/docker-ci.yml` :**

```yaml
name: Docker CI/CD Pipeline

on:
 push:
 branches: [ main, develop ]
 pull_request:
 branches: [ main ]

env:
 REGISTRY: ghcr.io
 IMAGE_NAME: ${{ github.repository }}/ml-service

jobs:
 # JOB 1: Build et Test
 build-and-test:
 runs-on: ubuntu-latest
 steps:
 - name: Checkout code
 uses: actions/checkout@v4

 - name: Set up Docker Buildx
 uses: docker/setup-buildx-action@v3

 - name: Build image
 uses: docker/build-push-action@v5
 with:
 context: .
 file: ./Dockerfile.ml-service
 push: false
 load: true
 tags: ml-service:test
 cache-from: type=gha
 cache-to: type=gha,mode=max

 - name: Test container
 run: |
 docker run -d --name test-container ml-service:test
 sleep 5
 docker exec test-container python -m pytest tests/
 docker stop test-container

 # JOB 2: Security Scan
 security-scan:
 runs-on: ubuntu-latest
 needs: build-and-test
 steps:
 - name: Checkout code
 uses: actions/checkout@v4

 - name: Build image for scanning
 run: docker build -t ml-service:scan -f Dockerfile.ml-service .

 - name: Run Trivy vulnerability scanner
 uses: aquasecurity/trivy-action@master
 with:
 image-ref: ml-service:scan
 format: 'sarif'
 output: 'trivy-results.sarif'
 severity: 'CRITICAL,HIGH'

 - name: Upload Trivy results to GitHub Security
 uses: github/codeql-action/upload-sarif@v2
 with:
 sarif_file: 'trivy-results.sarif'

 # JOB 3: Build et Push (main branch uniquement)
 build-and-push:
 runs-on: ubuntu-latest
 needs: [build-and-test, security-scan]
 if: github.ref == 'refs/heads/main'
 permissions:
 contents: read
 packages: write
 steps:
 - name: Checkout code
 uses: actions/checkout@v4

 - name: Log in to Container Registry
 uses: docker/login-action@v3
 with:
 registry: ${{ env.REGISTRY }}
 username: ${{ github.actor }}
 password: ${{ secrets.GITHUB_TOKEN }}

 - name: Extract metadata
 id: meta
 uses: docker/metadata-action@v5
 with:
 images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
 tags: |
 type=sha,prefix={{branch}}-
 type=semver,pattern={{version}}
 type=semver,pattern={{major}}.{{minor}}

 - name: Build and push
 uses: docker/build-push-action@v5
 with:
 context: .
 file: ./Dockerfile.ml-service
 push: true
 tags: ${{ steps.meta.outputs.tags }}
 labels: ${{ steps.meta.outputs.labels }}
 cache-from: type=gha
 cache-to: type=gha,mode=max

 # JOB 4: Deploy to Staging
 deploy-staging:
 runs-on: ubuntu-latest
 needs: build-and-push
 environment: staging
 steps:
 - name: Deploy to Docker Swarm
 run: |
 # À COMPLÉTER : commandes de déploiement
 echo "Deploying to staging..."
```

**Mission :** Complétez le pipeline avec :
1. Le job de déploiement staging
2. Un job de déploiement production avec approbation manuelle
3. Des notifications Slack/Discord en cas d'échec


### Exercice 5.2 : Multi-Architecture Build

Buildez vos images pour plusieurs architectures (amd64, arm64).

```yaml
- name: Build multi-arch images
 uses: docker/build-push-action@v5
 with:
 platforms: linux/amd64,linux/arm64
 push: true
 tags: ml-service:latest
```

**Test :** Vérifiez avec `docker manifest inspect`.

** Livrable :** `td/partie5/.github/workflows/docker-ci.yml`


## Partie 6 : Monitoring et Logging (40 min)

### Exercice 6.1 : Stack Prometheus + Grafana

Ajoutez le monitoring à votre architecture.

**Services supplémentaires dans `docker-compose.yml` :**

```yaml
services:
 # ... services existants ...

 prometheus:
 image: prom/prometheus:latest
 volumes:
 - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
 - prometheus_data:/prometheus
 command:
 - '--config.file=/etc/prometheus/prometheus.yml'
 - '--storage.tsdb.path=/prometheus'
 - '--storage.tsdb.retention.time=30d'
 ports:
 - "9090:9090"
 networks:
 - monitoring

 grafana:
 image: grafana/grafana:latest
 volumes:
 - grafana_data:/var/lib/grafana
 - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
 - ./grafana/datasources:/etc/grafana/provisioning/datasources
 environment:
 - GF_SECURITY_ADMIN_PASSWORD__FILE=/run/secrets/grafana_password
 - GF_USERS_ALLOW_SIGN_UP=false
 secrets:
 - grafana_password
 ports:
 - "3000:3000"
 networks:
 - monitoring
 depends_on:
 - prometheus

 # Exporters
 node-exporter:
 image: prom/node-exporter:latest
 volumes:
 - /proc:/host/proc:ro
 - /sys:/host/sys:ro
 - /:/rootfs:ro
 command:
 - '--path.procfs=/host/proc'
 - '--path.sysfs=/host/sys'
 - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
 networks:
 - monitoring

 cadvisor:
 image: gcr.io/cadvisor/cadvisor:latest
 volumes:
 - /:/rootfs:ro
 - /var/run:/var/run:ro
 - /sys:/sys:ro
 - /var/lib/docker/:/var/lib/docker:ro
 networks:
 - monitoring

volumes:
 prometheus_data:
 grafana_data:

networks:
 monitoring:
 driver: overlay
```

**Fichier `prometheus/prometheus.yml` :**

```yaml
global:
 scrape_interval: 15s
 evaluation_interval: 15s

scrape_configs:
 - job_name: 'prometheus'
 static_configs:
 - targets: ['localhost:9090']

 - job_name: 'node-exporter'
 static_configs:
 - targets: ['node-exporter:9100']

 - job_name: 'cadvisor'
 static_configs:
 - targets: ['cadvisor:8080']

 - job_name: 'ml-api'
 static_configs:
 - targets: ['ml-api:8000']
 metrics_path: '/metrics'

 - job_name: 'data-api'
 static_configs:
 - targets: ['data-api:5000']
 metrics_path: '/metrics'
```


### Exercice 6.2 : Instrumentation de votre Code

Ajoutez des métriques Prometheus dans votre API ML.

**Exemple (`ml_service/app.py`) :**

```python
from prometheus_client import Counter, Histogram, Gauge, generate_latest
from flask import Flask, request, Response
import time

app = Flask(__name__)

# Métriques
REQUEST_COUNT = Counter(
 'ml_api_requests_total',
 'Total requests to ML API',
 ['method', 'endpoint', 'status']
)

REQUEST_LATENCY = Histogram(
 'ml_api_request_duration_seconds',
 'Request latency in seconds',
 ['endpoint']
)

PREDICTIONS_COUNT = Counter(
 'ml_predictions_total',
 'Total predictions made',
 ['model_version']
)

MODEL_ACCURACY = Gauge(
 'ml_model_accuracy',
 'Current model accuracy',
 ['model_version']
)

ACTIVE_REQUESTS = Gauge(
 'ml_api_active_requests',
 'Number of active requests'
)

@app.before_request
def before_request():
 request.start_time = time.time()
 ACTIVE_REQUESTS.inc()

@app.after_request
def after_request(response):
 request_latency = time.time() - request.start_time
 REQUEST_LATENCY.labels(endpoint=request.path).observe(request_latency)
 REQUEST_COUNT.labels(
 method=request.method,
 endpoint=request.path,
 status=response.status_code
 ).inc()
 ACTIVE_REQUESTS.dec()
 return response

@app.route('/predict', methods=['POST'])
def predict():
 data = request.json
 # Logique de prédiction...
 prediction = model.predict(data)
 
 PREDICTIONS_COUNT.labels(model_version='v1.0').inc()
 
 return {'prediction': prediction}

@app.route('/metrics')
def metrics():
 return Response(generate_latest(), mimetype='text/plain')

if __name__ == '__main__':
 app.run(host='0.0.0.0', port=8000)
```

**Mission :**
1. Instrumentez tous vos services avec des métriques pertinentes
2. Créez un dashboard Grafana avec :
 - Taux de requêtes par seconde
 - Latence p50, p95, p99
 - Taux d'erreur
 - Nombre de prédictions
 - Utilisation CPU/Mémoire des conteneurs

** Livrable :** `td/partie6/grafana/dashboards/ml-pipeline.json`


## Bonus : Challenge Avancé (optionnel)

### Challenge 1 : Auto-scaling basé sur les métriques

Créez un système d'auto-scaling qui :
1. Monitore la charge CPU/mémoire des services
2. Scale automatiquement les replicas en fonction de la charge
3. Logs les événements de scaling

**Indice :** Utilisez l'API Docker Swarm avec un script Python.


### Challenge 2 : Blue-Green Deployment

Implémentez une stratégie de déploiement blue-green :
1. Deux stacks identiques (blue et green)
2. Un reverse proxy (Traefik/Nginx) qui route le trafic
3. Script de switch entre blue et green
4. Rollback automatique en cas d'erreur


### Challenge 3 : Distributed Tracing

Intégrez Jaeger pour le tracing distribué :
1. Instrumentez vos services avec OpenTelemetry
2. Tracez le parcours d'une requête à travers tous les services
3. Visualisez les goulots d'étranglement


## Livrables Finaux

Structure attendue de votre dépôt :

```
td/
 README.md # Ce fichier
 partie1/
 Dockerfile.ml-service
 .dockerignore
 analyse.md
 partie2/
 docker-compose.yml
 .env.dev
 .env.staging
 .env.prod
 secrets/
 db_password.txt
 partie3/
 docker-stack.yml
 commandes.md
 partie4/
 Dockerfile.ml-service (sécurisé)
 security-report.md
 partie5/
 .github/
 workflows/
 docker-ci.yml
 partie6/
 prometheus/
 prometheus.yml
 grafana/
 dashboards/
 ml-pipeline.json
 datasources/
 prometheus.yml
 ml_service/
 app.py (avec métriques)
 app/
 ml_service/
 data_api/
 preprocessor/
 requirements.txt
```

## Ressources et Aides

### Documentation Officielle
- [Docker Docs](https://docs.docker.com/)
- [Docker Compose Spec](https://docs.docker.com/compose/compose-file/)
- [Docker Swarm](https://docs.docker.com/engine/swarm/)
- [Prometheus](https://prometheus.io/docs/)
- [Grafana](https://grafana.com/docs/)

### Commandes Utiles

```bash
# Docker Build
docker build -t image:tag .
docker buildx build --platform linux/amd64,linux/arm64 -t image:tag .

# Docker Compose
docker compose up -d
docker compose ps
docker compose logs -f service_name
docker compose down -v

# Docker Swarm
docker swarm init
docker stack deploy -c stack.yml stack_name
docker service ls
docker service logs stack_name_service_name
docker service scale stack_name_service_name=5
docker service update --image new_image:tag stack_name_service_name

# Secrets
docker secret create secret_name file.txt
docker secret ls

# Monitoring
docker stats
docker system df

# Security
docker scout cves image:tag
trivy image image:tag
```

## Points d'Attention

1. **Persistance des données** : Utilisez des volumes nommés, pas des bind mounts en production
2. **Secrets** : JAMAIS dans les images ou le code, toujours via Docker secrets ou vault
3. **Logs** : Utilisez un driver de logs centralisé (json-file avec rotation, ou syslog)
4. **Ressources** : Toujours limiter CPU et mémoire pour éviter le noisy neighbor
5. **Health checks** : Indispensables pour Swarm et Compose avec `depends_on`
6. **Networks** : Isolez les services sensibles (DB, Kafka) dans des networks dédiés


## Support

En cas de blocage :
1. Consultez les logs : `docker compose logs -f`
2. Vérifiez les health checks : `docker compose ps`
3. Inspectez les conteneurs : `docker inspect container_name`
4. Consultez la documentation officielle


**Bon courage ! **

*Ce TP reflète des situations réelles de production. Prenez le temps de comprendre chaque concept, ils vous seront utiles dans votre carrière de Data Engineer.*
