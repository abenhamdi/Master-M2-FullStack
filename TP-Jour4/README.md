# TP Master 2 - Monitoring de Ferme Solaire avec GitOps

## Objectif

Implémenter une plateforme complète de monitoring temps réel pour 3 fermes solaires photovoltaïques, en utilisant les principes GitOps et une stack d'observabilité moderne.

## Contenu

- **ENONCE.md** : Énoncé détaillé du TP avec toutes les consignes
- **data/** : Dataset complet avec 30 jours de données réelles (3 fermes)
  - provence_data.csv, occitanie_data.csv, aquitaine_data.csv
  - anomalies_log.csv (log des anomalies injectées)
  - README_DATASET.md (documentation du dataset)
- Ce README contient uniquement les informations essentielles pour démarrer

## Durée

**4 heures** (gestion du temps recommandée dans l'énoncé)

## Prérequis Techniques

Avant de commencer, assurez-vous d'avoir installé :

- Docker Desktop (ou équivalent)
- kubectl
- kind ou minikube
- Git
- Node.js 18+ **OU** Java 17+ (selon votre choix)
- Un éditeur de code (VS Code recommandé)

## Démarrage Rapide

### 1. Vérifier votre environnement

```bash
# Vérifier Docker
docker --version

# Vérifier kubectl
kubectl version --client

# Vérifier kind
kind --version

# Vérifier Node.js (si choisi)
node --version
npm --version

# Vérifier Java (si choisi)
java -version
mvn --version
```

### 2. Créer votre repository

```bash
# Créer un nouveau repository sur GitHub
# Nom suggéré : solar-monitoring-gitops-<nom-prenom>

# Cloner et initialiser
git clone https://github.com/<votre-username>/<votre-repo>.git
cd <votre-repo>

# Créer la structure de base
mkdir -p src/solar-simulator k8s/{apps,monitoring,argocd} docs/screenshots scripts

# Copier le dataset fourni (optionnel mais recommandé)
cp -r /path/to/TP/apprenant/data ./data
```

Note : Le dataset fourni contient 30 jours de données réelles pour les 3 fermes.

### 3. Lire l'énoncé complet

Ouvrez ENONCE.md et lisez-le entièrement avant de commencer.

## Checklist de Progression

Cochez au fur et à mesure :

### Phase 1 : Infrastructure (45 min)
- [ ] Cluster Kubernetes créé
- [ ] ArgoCD installé
- [ ] Accès à l'UI ArgoCD vérifié

### Phase 2 : Application (1h15)
- [ ] Simulateur développé (Node.js ou Java)
- [ ] Métriques Prometheus exposées
- [ ] Dockerfile créé et testé
- [ ] Tests unitaires écrits

### Phase 3 : GitOps (1h)
- [ ] Structure Git créée
- [ ] Manifests Kubernetes écrits
- [ ] Configuration Prometheus
- [ ] 5 règles d'alerting

### Phase 4 : Observabilité (45 min)
- [ ] Grafana déployé
- [ ] Dashboard avec 6 panneaux
- [ ] Requêtes PromQL fonctionnelles

### Phase 5 : FinOps (30 min)
- [ ] Analyse des coûts
- [ ] 3 optimisations proposées

### Phase 6 : Documentation (30 min)
- [ ] README technique complet
- [ ] Screenshots
- [ ] Script de démo

## Rendu Final

### Structure Attendue

```
<votre-repo>/
├── README.md
├── docs/
│   ├── ARCHITECTURE.md
│   ├── INSTALLATION.md
│   └── screenshots/
├── src/
│   └── solar-simulator/
├── k8s/
│   ├── apps/
│   ├── monitoring/
│   └── argocd/
└── scripts/
```

### Modalités de Rendu

1. **Push** tout votre code sur GitHub
2. **Vérifiez** que le repository est accessible
3. **Envoyez** le lien par email au professeur

## Besoin d'Aide ?

### Problèmes Courants

**Cluster ne démarre pas :**
```bash
kind delete cluster --name solar-monitoring
kind create cluster --name solar-monitoring
```

**ArgoCD inaccessible :**
```bash
kubectl get pods -n argocd
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

**Métriques non collectées :**
- Vérifier le ServiceMonitor
- Vérifier les labels du Service
- Consulter les logs Prometheus

### Ressources

- **Énoncé complet** : `ENONCE.md`
- **Dataset réel** : `data/` (30 jours × 3 fermes + anomalies)
- **Documentation dataset** : `data/README_DATASET.md`
- Documentation ArgoCD : https://argo-cd.readthedocs.io
- Documentation Prometheus : https://prometheus.io/docs

Astuce : Consultez le dataset pour comprendre les patterns d'anomalies réels.

## Rappels Importants

1. **Gérez votre temps** : 4h passent vite
2. **Testez régulièrement** : Ne pas attendre la fin
3. **Commitez souvent** : Historique Git propre
4. **Documentez au fur et à mesure** : Plus facile que de tout faire à la fin
5. **Prenez des screenshots** : Preuve de fonctionnement

## Compétences Évaluées

- Architecture GitOps (/25)
- Développement Application (/20)
- Observabilité (/25)
- FinOps (/10)
- Documentation (/15)
- Bonus (/5)

**Total : /100 points**

---

**Bon courage !**

N'oubliez pas : ce TP reflète des problématiques réelles d'entreprise. Les compétences acquises sont directement valorisables en entretien et en poste.
