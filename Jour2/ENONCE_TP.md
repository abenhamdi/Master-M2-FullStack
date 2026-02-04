TP Docker Avancé - Optimisation Extrême & Images Distroless
**Master 2 Full Stack - Docker Jour 2**  

---

Objectifs pédagogiques

À la fin de ce TP, vous serez capable de :
- Analyser les problèmes de taille et sécurité des images Docker
- Implémenter des solutions d'optimisation par vous-même
- Mesurer l'impact de vos optimisations
- Calculer l'impact environnemental de vos choix techniques
- Comprendre les enjeux de sécurité des conteneurs

---

Contexte & Problématique

Situation actuelle de votre entreprise

Votre entreprise développe 3 microservices critiques :
- **API Node.js/TypeScript** (1.4GB d'image Docker)
- **API Python FastAPI** (980MB d'image Docker)  
- **API Java Spring Boot** (720MB d'image Docker)

Problèmes identifiés

**Coûts élevés**
- Docker Hub : 0.07$/GB/mois pour stockage privé
- AWS ECR : 0.10$/GB/mois
- **Vos 3 images coûtent actuellement 0.22$/mois juste en stockage**

**Performance dégradée**
- Temps de pull : 1.4GB @ 100Mbps = ~2min par déploiement
- CI/CD : 50 builds/jour × 2min = **1h40 perdues quotidiennement**
- Temps de démarrage des conteneurs : 30-45 secondes

**Impact environnemental**
- Serveurs de registry : ~500W de consommation
- Transferts réseau : 3.1GB par déploiement
- **Empreinte carbone estimée : 2.5kg CO2/mois**

**Risques de sécurité**
- Images contiennent : shell, package managers, outils de debug
- **Surface d'attaque : 200+ vulnérabilités par image**
- Conformité : Non conforme aux standards SLSA et NIST SP 800-190

---

Prérequis techniques

Installation requise :
```bash
# Docker avec BuildKit activé
export DOCKER_BUILDKIT=1

# Outils d'analyse
docker pull wagoodman/dive        # Analyse des layers
docker pull aquasec/trivy         # Scan de vulnérabilités

# CLI utiles (optionnel)
brew install grype                # Alternative à Trivy
brew install syft                 # Génération SBOM
```

Compétences requises :
- Docker fondamental (Jour 1)
- Dockerfile multi-stage
- Notions de sécurité applicative

---

Architecture du TP

Vous allez travailler sur **3 applications** représentant des stacks réelles :

Application 1 : API REST Node.js/TypeScript
- Express + TypeScript + PostgreSQL
- **Objectif : 1.4GB → 150MB** (89% réduction)

Application 2 : API Python FastAPI
- FastAPI + SQLAlchemy + Poetry
- **Objectif : 980MB → 80MB** (92% réduction)

Application 3 : Microservice Java Spring Boot
- Spring Boot + Maven + JDK
- **Objectif : 720MB → 170MB** (76% réduction)

---

Mission 1 - API Node.js : Optimisation complète

Étape 1.1 : Analyser la situation actuelle

Vous disposez d'une application Node.js/TypeScript dans le dossier `node-api/`. 

**Votre mission :**
1. Analyser le code existant
2. Construire l'image avec le Dockerfile standard fourni
3. Mesurer la taille, les vulnérabilités et les performances
4. **Identifier les problèmes par vous-même**

```bash
cd node-api
# Analyser le code
cat package.json
cat src/server.ts
cat tsconfig.json

# Construire l'image standard
docker build -t node-api:standard -f Dockerfile.standard .

# Mesurer la taille
docker images node-api:standard
```

**Questions à vous poser :**
- Quelle est la taille de cette image ?
- Combien de vulnérabilités contient-elle ?
- Que contient-elle d'inutile ?
- Comment pourriez-vous l'optimiser ?

Étape 1.2 : Recherche de solutions

**Votre défi :**
- Créer un Dockerfile multi-stage optimisé
- Réduire la taille de l'image de 80% minimum
- Éliminer les vulnérabilités critiques
- Maintenir la fonctionnalité de l'application

**Indices (à utiliser si bloqué) :**
- Recherchez "Docker multi-stage builds"
- Explorez les images de base alternatives
- Pensez aux layers et au cache Docker
- Considérez les utilisateurs non-root

Étape 1.3 : Défi ultime - Sécurité maximale

**Votre mission :**
- Créer une image "distroless" (sans shell, sans package manager)
- Réduire la surface d'attaque au minimum
- Maintenir la fonctionnalité
- Tester que l'application fonctionne toujours

**Indices (à utiliser si bloqué) :**
- Recherchez "distroless images"
- Explorez les images gcr.io/distroless
- Pensez aux implications de sécurité
- Testez l'absence de shell

---

Mission 2 - API Python FastAPI : Optimisation complète

Étape 2.1 : Analyser la situation

Vous disposez d'une application FastAPI dans le dossier `python-api/`.

**Votre mission :**
1. Analyser le code Python existant
2. Comprendre la structure Poetry
3. **Créer votre propre Dockerfile optimisé**
4. Atteindre une taille < 100MB

```bash
cd python-api
# Analyser le code
cat pyproject.toml
cat app/main.py
```

**Questions à vous poser :**
- Comment Poetry gère-t-il les dépendances ?
- Quelles sont les dépendances nécessaires en production ?
- Comment optimiser le build Python ?
- Comment créer une image distroless pour Python ?

Étape 2.2 : Défi d'optimisation

**Votre défi :**
- Créer un Dockerfile multi-stage pour Python
- Utiliser Poetry pour gérer les dépendances
- Créer une image distroless Python
- Maintenir FastAPI + Swagger UI

**Indices (à utiliser si bloqué) :**
- Recherchez "Python distroless images"
- Explorez les images gcr.io/distroless/python3
- Pensez à l'export des dépendances Poetry
- Considérez le PYTHONPATH

---

Mission 3 - API Java Spring Boot : Optimisation complète

Étape 3.1 : Analyser la situation

Vous disposez d'une application Spring Boot dans le dossier `java-api/`.

**Votre mission :**
1. Analyser le code Java existant
2. Comprendre la structure Maven
3. **Créer votre propre Dockerfile optimisé**
4. Atteindre une taille < 200MB

```bash
cd java-api
# Analyser le code
cat pom.xml
cat src/main/java/com/example/demo/DemoApplication.java
```

**Questions à vous poser :**
- Quelle est la différence entre JDK et JRE ?
- Qu'est-ce qui est nécessaire en production ?
- Comment optimiser le build Maven ?
- Comment créer une image distroless pour Java ?

Étape 3.2 : Défi d'optimisation

**Votre défi :**
- Créer un Dockerfile multi-stage pour Java
- Utiliser Maven pour le build
- Créer une image distroless Java
- Maintenir Spring Boot + Actuator

**Indices (à utiliser si bloqué) :**
- Recherchez "Java distroless images"
- Explorez les images gcr.io/distroless/java17
- Pensez à la différence JDK/JRE
- Considérez le JAR final

---

Mission 4 - Analyse et mesure d'impact

Étape 4.1 : Mesurer vos optimisations

**Votre mission :**
1. Comparer les tailles avant/après vos optimisations
2. Mesurer la réduction des vulnérabilités
3. Calculer l'impact Green IT de vos choix
4. Documenter vos décisions techniques

**Outils à utiliser :**
```bash
# Analyser les tailles
docker images

# Scanner les vulnérabilités
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image <votre-image>

# Analyser les layers
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock \
  wagoodman/dive <votre-image>
```

Étape 4.2 : Calculer l'impact business

**Votre défi :**
- Calculer les économies de stockage
- Estimer les gains de performance
- Mesurer l'impact environnemental
- Proposer un ROI à votre direction

**Questions à résoudre :**
- Combien d'argent économisez-vous par mois ?
- Combien de temps gagnez-vous en CI/CD ?
- Quel est l'impact carbone de vos optimisations ?
- Quel est le ROI de votre travail ?

---

Mission 5 - Sécurisation et automatisation

Étape 5.1 : Optimiser le contexte de build

**Votre défi :**
- Créer un `.dockerignore` optimal
- Réduire la taille du contexte de build
- Améliorer les temps de build

Étape 5.2 : Automatiser la sécurité

**Votre mission :**
- Créer un workflow CI/CD pour scanner vos images
- Automatiser la détection des vulnérabilités
- Intégrer la génération de SBOM

---

Mission 6 - Réflexion et présentation

Questions de réflexion :

1. **Performance** : Quelle approche est la plus rapide à build ? Pourquoi ?

2. **Sécurité** : Quels sont les gains de sécurité de vos optimisations ?

3. **Debugging** : Comment debugger une application distroless en production ?

4. **Trade-offs** : Quels sont les inconvénients de vos choix techniques ?

5. **Green IT** : Quel est l'impact environnemental de vos optimisations ?

Livrables attendus :

**Document d'analyse** contenant :
- Vos décisions techniques et leur justification
- Mesures avant/après vos optimisations
- Calculs d'impact Green IT
- Recommandations pour votre organisation

**Repository Git** avec :
- Vos Dockerfiles optimisés
- Scripts d'analyse que vous avez créés
- Fichier `.dockerignore`
- Workflow CI/CD
- README documentant votre travail

**Présentation** (10 slides max) :
- Problématique identifiée
- Solutions implémentées
- Résultats mesurés
- ROI de vos optimisations
- Recommandations futures

---

Critères d'évaluation

| Critère | Points | Description |
|---------|--------|-------------|
| **Résolution de problème** | /30 | Capacité à identifier et résoudre les problèmes |
| **Optimisation technique** | /25 | Qualité des solutions d'optimisation implémentées |
| **Documentation** | /20 | Clarté de l'analyse et justification des choix |
| **Impact Green IT** | /15 | Calculs et compréhension de l'impact environnemental |
| **Bonus innovation** | /10 | Solutions créatives et automations |

---

Ressources complémentaires

Documentation officielle :
- [Docker Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
- [Dockerfile best practices](https://docs.docker.com/develop/dev-best-practices/)
- [Trivy Scanner](https://aquasecurity.github.io/trivy/)

Articles techniques :
- [NIST Container Security Guide SP 800-190](https://csrc.nist.gov/publications/detail/sp/800-190/final)
- [Green Software Foundation](https://greensoftware.foundation/)

Outils d'analyse :
- **dive** : `docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive <image>`
- **trivy** : `docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image <image>`

---

Challenge Bonus

**Défi ultime** : Créer une image optimisée pour une stack complète avec :
- Image totale < 500MB
- Zero vulnérabilités critiques
- Temps de démarrage < 5 secondes
- Pipeline CI/CD complet
- Documentation Green IT

---

Checklist de fin de TP

- [ ] 3 applications analysées et optimisées
- [ ] Dockerfiles multi-stage créés
- [ ] Images distroless implémentées
- [ ] Analyse comparative complète
- [ ] Calculs Green IT effectués
- [ ] Scans de sécurité réalisés
- [ ] Documentation rédigée
- [ ] Repository Git publié
- [ ] Présentation préparée

---

