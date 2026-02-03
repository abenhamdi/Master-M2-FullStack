# Master M2 Full Stack - Formation Docker & Kubernetes

Repository contenant les travaux pratiques de la formation Docker & Kubernetes pour Master 2 Full Stack.

## 📚 Contenu

### Jour 2 - Optimisation & Sécurité Docker

**Dossier** : `Jour2/`  
**Thèmes** : Optimisation des images, sécurité des containers, bonnes pratiques

---

### Jour 3 - Orchestration avec Kubernetes

**Projet** : GreenWatt - Plateforme de monitoring des énergies renouvelables  
**Dossier** : `TP-J3/`  
**Thèmes** : Déploiements, Services, ConfigMaps, Secrets

---

### Jour 4 - Monitoring & GitOps

**Projet** : Monitoring de fermes solaires  
**Dossier** : `TP-Jour4/`  
**Thèmes** : Prometheus, Grafana, ArgoCD, GitOps

---

### Jour 5 - Platform Engineering & SRE Avancé

**Projet** : TechMarket - Construction d'une Internal Developer Platform (IDP)  
**Dossier** : `TD-Jour5/`  
**Durée** : 3 heures

#### Thèmes abordés :

🎯 **Bloc 1 - Platform Engineering (45 min)**
- Backstage (IDP)
- Software Catalog
- Software Templates (Golden Paths)
- Plugin Kubernetes

🔒 **Bloc 2 - Policy as Code & Supply Chain Security (45 min)**
- Kyverno (Admission Controller)
- ClusterPolicies (Validation & Mutation)
- Cosign (Signature d'images)
- Supply Chain Security (SLSA, Sigstore)

📊 **Bloc 3 - SRE & Chaos Engineering (45 min)**
- SLIs/SLOs & Error Budget
- Litmus Chaos
- Chaos Experiments (pod-delete)
- Postmortem Blameless

🚀 **Bloc 4 - CI/CD Avancé (45 min)**
- Tekton Pipelines
- Tasks sécurisées (Build, Scan, Sign)
- SBOM (Software Bill of Materials)
- Pipeline complet Cloud Native

#### Architecture TechMarket

```
BACKSTAGE PORTAL (IDP)
        ↓
KUBERNETES CLUSTER
├── Frontend (React)
├── Backend API (Node.js)
└── Payment Service (Node.js)
        ↓
KYVERNO (Policy as Code)
PROMETHEUS (SLOs & Metrics)
LITMUS (Chaos Engineering)
TEKTON (CI/CD Sécurisé)
```

#### Application complète

- **Frontend** : React avec UI moderne
- **Backend** : API Node.js Express avec métriques Prometheus
- **Payment Service** : Service critique avec SLO 99.9%
- **Manifests K8s** : Deployments, Services, HPA, PDB

**➡️ [Commencer le TP Jour 5](./TD-Jour5/README.md)**

---

### Jour 6 - Docker Avancé & Data Engineering ⭐ **NOUVEAU**

**Projet** : Pipeline ML/Data avec Docker - Optimisation, Orchestration & Monitoring  
**Dossier** : `TD-Jour6/`  
**Durée** : 4 heures

#### Thèmes abordés :

🐳 **Partie 1 - Optimisation d'images Docker (45 min)**
- Multi-stage builds
- .dockerignore
- Réduction de taille d'images
- Analyse de vulnérabilités (Docker Scout, Trivy)

📦 **Partie 2 - Docker Compose Avancé (60 min)**
- Orchestration de services complexes
- Secrets et configs management
- Health checks et dependencies
- Resource limits et profiles
- Networks isolés

🐝 **Partie 3 - Docker Swarm (50 min)**
- Déploiement en mode Swarm
- Scaling et replicas
- Rolling updates et rollback
- Placement constraints
- Load balancing

🔒 **Partie 4 - Sécurité Docker (45 min)**
- User non-root
- Capabilities Linux
- Read-only filesystem
- CVE scanning automatisé
- Secrets management

🚀 **Partie 5 - CI/CD avec GitHub Actions (60 min)**
- Pipeline complet (build, test, scan, deploy)
- Multi-architecture builds
- Security scanning intégré
- Déploiement automatisé staging/production
- Notifications et rollback

📊 **Partie 6 - Monitoring & Observabilité (40 min)**
- Prometheus (métriques custom)
- Grafana (dashboards)
- Alerting
- Logs et traces

#### Architecture Pipeline ML/Data

```
DATA INGESTION API (Flask)
        ↓
APACHE KAFKA (Message Broker)
        ↓
DATA PREPROCESSOR (Consumer)
        ↓
POSTGRESQL (Database)
        ↓
ML MODEL SERVING API (Flask)
        ↓
PROMETHEUS & GRAFANA (Monitoring)
```

#### Ressources fournies

- **README.md** : Énoncé complet du TP (6 parties)
- **AIDE.md** : Guide avec templates et exemples
- **Fichiers Word** : Versions .docx pour faciliter la distribution
- **Applications Python** : Code squelette pour ML service, Data API, Preprocessor

**➡️ [Commencer le TP Jour 6](./TD-Jour6/README.md)**

---

## 🚀 Pour commencer

```bash
# Cloner le repository
git clone https://github.com/abenhamdi/Master-M2-FullStack.git
cd Master-M2-FullStack

# Choisir un TP
cd TD-Jour6  # ou TD-Jour5, TP-Jour4, TP-J3, Jour2

# Lire le README
cat README.md
```

---

## 📋 Prérequis généraux

- Docker (v24+)
- Kubernetes (v1.28+) via Kind ou Minikube
- kubectl
- Helm v3
- Git

### Prérequis spécifiques Jour 5

- Cosign (v2.0+)
- Tekton CLI (tkn)
- Compte GitHub (OAuth + GHCR)

---

## 📊 Progression

| Jour | Thème | Status | Difficulté |
|------|-------|--------|-----------|
| Jour 2 | Optimisation Docker | ✅ | ⭐⭐ |
| Jour 3 | Kubernetes Fondamentaux | ✅ | ⭐⭐⭐ |
| Jour 4 | Monitoring & GitOps | ✅ | ⭐⭐⭐⭐ |
| Jour 5 | Platform Engineering & SRE | ✅ | ⭐⭐⭐⭐⭐ |
| **Jour 6** | **Docker Avancé & Data Engineering** | ✅ **NEW** | ⭐⭐⭐⭐ |

---

## 🎓 Compétences développées

### Jour 5 - Platform Engineering

✅ **Techniques** :
- Internal Developer Platforms (IDP)
- Policy as Code
- Supply Chain Security
- Site Reliability Engineering (SRE)
- Chaos Engineering
- CI/CD Cloud Native

✅ **Outils maîtrisés** :
- Backstage, Kyverno, Cosign, Litmus, Tekton, Prometheus

✅ **Certifications préparées** :
- CKA (Certified Kubernetes Administrator)
- CKS (Certified Kubernetes Security Specialist)
- FCSA (CNCF Security Specialist)

### Jour 6 - Docker Avancé & Data Engineering

✅ **Techniques** :
- Optimisation d'images Docker
- Orchestration multi-services (Compose, Swarm)
- Sécurité des conteneurs
- CI/CD avec Docker
- Monitoring et observabilité
- Pipeline ML/Data avec conteneurs

✅ **Outils maîtrisés** :
- Docker, Docker Compose, Docker Swarm
- Prometheus, Grafana
- GitHub Actions
- Trivy, Docker Scout
- Kafka, PostgreSQL

✅ **Certifications préparées** :
- Docker Certified Associate (DCA)
- CKA (Certified Kubernetes Administrator)
- Compétences Data Engineering

---

## 📚 Ressources

### Documentation
- [Kubernetes](https://kubernetes.io/docs)
- [Backstage](https://backstage.io/docs)
- [Kyverno](https://kyverno.io/docs)
- [Tekton](https://tekton.dev/docs)
- [Google SRE Books](https://sre.google/books/)

### Livres recommandés
- **Site Reliability Engineering** (Google)
- **The DevOps Handbook** (Gene Kim)
- **Accelerate** (Nicole Forsgren)
- **Team Topologies** (Matthew Skelton)

---

## 👨‍🏫 Formateur

**Ayoub **  
Formateur Data, IA et DevOps  
15+ ans d'expérience

---

## 📧 Contact

Pour toute question sur les TPs :
- GitHub Issues : [Master-M2-FullStack/issues](https://github.com/abenhamdi/Master-M2-FullStack/issues)

---

**Formation** : Master 2 Full Stack  
**École** : YNOV Montpellier  
**Année** : 2025-2026  
