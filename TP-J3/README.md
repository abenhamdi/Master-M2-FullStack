# TP Jour 3 - Docker Compose & Kubernetes

## 🌱 Projet GreenWatt
**Plateforme de monitoring des énergies renouvelables**



## 📋 Objectifs du TP

Ce TP vous permettra de :
- ✅ Conteneuriser une application fullstack (React + Node.js + PostgreSQL + Redis)
- ✅ Orchestrer les services avec Docker Compose
- ✅ Déployer l'application sur Kubernetes
- ✅ Implémenter le scaling et le monitoring


---

## Architecture de l'Application

```
GreenWatt Platform
├── Frontend (React)          → Port 3000
├── Backend API (Node.js)     → Port 5000
├── Database (PostgreSQL)     → Port 5432
└── Cache (Redis)             → Port 6379
```

### Données
- **10 installations** d'énergies renouvelables en Occitanie
- **Types** : Solaire, Éolien, Hybride
- **Métriques** : Production, efficacité, alertes


## Partie 0 : Tester l'Application en Local 

### Prérequis
- Node.js 18+
- PostgreSQL 15+
- Redis 7+

### 1. Base de Données

```bash
# Créer la base de données
createdb greenwatt

# Initialiser le schéma
psql -d greenwatt -f database/init.sql
```

### 2. Backend

```bash
cd backend

# Installer les dépendances
npm install

# Configurer les variables d'environnement
cp env.example .env
# Éditer .env avec vos paramètres

# Démarrer le serveur
npm start
```

Le backend sera accessible sur `http://localhost:5000`

### 3. Frontend

```bash
cd frontend

# Installer les dépendances
npm install

# Démarrer l'application
npm start
```

Le frontend sera accessible sur `http://localhost:3000`


##  Partie 1 : Dockerisation

### Objectif
Créer des Dockerfiles optimisés pour chaque service.

### Tâches

#### 1.1 Dockerfile Backend
Créez `backend/Dockerfile` :
- Utilisez une image Node.js Alpine
- Implémentez un multi-stage build
- Optimisez pour la production
- Ajoutez un healthcheck

#### 1.2 Dockerfile Frontend
Créez `frontend/Dockerfile` :
- Stage 1 : Build avec Node.js
- Stage 2 : Servir avec NGINX
- Configurez NGINX pour React Router

#### 1.3 Tests
```bash
# Construire les images
docker build -t greenwatt-backend ./backend
docker build -t greenwatt-frontend ./frontend

# Tester
docker run -p 5000:5000 greenwatt-backend
docker run -p 3000:80 greenwatt-frontend
```


##Partie 2 : Docker Compose (1h30)

### Objectif
Orchestrer tous les services avec Docker Compose.

### Tâches

#### 2.1 Créer docker-compose.yml
Définissez les services :
- `database` : PostgreSQL 15
- `cache` : Redis 7
- `backend` : Votre image backend
- `frontend` : Votre image frontend

#### 2.2 Configuration
- Créez un réseau `greenwatt-network`
- Définissez des volumes pour la persistance
- Configurez les variables d'environnement
- Ajoutez des healthchecks
- Définissez les dépendances (`depends_on`)

#### 2.3 Lancement
```bash
# Construire et démarrer
docker-compose up --build -d

# Vérifier les logs
docker-compose logs -f

# Tester l'application
curl http://localhost:5001/api/health
open http://localhost:3000
```


## Partie 3 : Kubernetes 

### Objectif
Déployer l'application sur un cluster Kubernetes.

### Prérequis
- Docker Desktop avec Kubernetes activé
- kubectl installé

### Tâches

#### 3.1 Namespace et Configuration
Créez les fichiers :
- `k8s/namespace.yaml` : Namespace `greenwatt`
- `k8s/configmap.yaml` : Variables d'environnement
- `k8s/secrets.yaml` : Credentials (base64)
- `k8s/pvc.yaml` : Stockage persistant (10Gi)

#### 3.2 Base de Données
- `k8s/postgres-deployment.yaml` : 1 replica, volume monté
- `k8s/postgres-service.yaml` : ClusterIP sur port 5432

#### 3.3 Cache
- `k8s/redis-deployment.yaml` : 1 replica
- `k8s/redis-service.yaml` : ClusterIP sur port 6379

#### 3.4 Backend
- `k8s/backend-deployment.yaml` : 2 replicas, healthchecks
- `k8s/backend-service.yaml` : ClusterIP sur port 5000

#### 3.5 Frontend
- `k8s/frontend-deployment.yaml` : 2 replicas
- `k8s/frontend-service.yaml` : LoadBalancer sur port 80

#### 3.6 Ingress (Bonus)
- `k8s/ingress.yaml` : Routage HTTP

#### 3.7 Auto-scaling (Bonus)
- `k8s/hpa.yaml` : Horizontal Pod Autoscaler

### Déploiement

```bash
# Appliquer les manifests
kubectl apply -f k8s/

# Vérifier les pods
kubectl get pods -n greenwatt

# Vérifier les services
kubectl get svc -n greenwatt

# Accéder à l'application
kubectl port-forward -n greenwatt svc/frontend-service 3000:80
```


## Tests et Vérification

### Vérifier les Pods
```bash
kubectl get pods -n greenwatt -w
```

### Vérifier les Logs
```bash
kubectl logs -n greenwatt -l app=backend
```

### Tester l'API
```bash
kubectl port-forward -n greenwatt svc/backend-service 5000:5000
curl http://localhost:5000/api/health
curl http://localhost:5000/api/installations
```

### Tester le Scaling
```bash
# Scaler manuellement
kubectl scale deployment backend -n greenwatt --replicas=3

# Vérifier
kubectl get pods -n greenwatt
```

## Ressources

### Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### Commandes Utiles

**Docker**
```bash
docker ps                    # Lister les conteneurs
docker logs <container>      # Voir les logs
docker exec -it <container> sh  # Shell dans un conteneur
```

**Docker Compose**
```bash
docker-compose up -d         # Démarrer
docker-compose down          # Arrêter
docker-compose logs -f       # Logs en temps réel
docker-compose ps            # Statut des services
```

**Kubernetes**
```bash
kubectl get all -n greenwatt        # Tout lister
kubectl describe pod <pod> -n greenwatt  # Détails d'un pod
kubectl logs <pod> -n greenwatt     # Logs d'un pod
kubectl exec -it <pod> -n greenwatt -- sh  # Shell dans un pod
```

---

## Troubleshooting

### Problème : Port déjà utilisé
```bash
# Trouver le processus
lsof -i :5000
# Tuer le processus
kill -9 <PID>
```

### Problème : Image non trouvée
```bash
# Reconstruire l'image
docker-compose build --no-cache
```

### Problème : Pod en CrashLoopBackOff
```bash
# Voir les logs
kubectl logs <pod> -n greenwatt
# Décrire le pod
kubectl describe pod <pod> -n greenwatt
```

## Livrables

À la fin du TP, vous devez avoir :
- [ ] `backend/Dockerfile`
- [ ] `frontend/Dockerfile`
- [ ] `docker-compose.yml`
- [ ] Dossier `k8s/` avec tous les manifests
- [ ] Application fonctionnelle sur Kubernetes



## Support

En cas de blocage :
1. Consultez la documentation officielle
2. Vérifiez les logs (`docker logs`, `kubectl logs`)
3. Demandez de l'aide au formateur

---

Bon courage ! 

À vos claviers les copaings ! 🙂
