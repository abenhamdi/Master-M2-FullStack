Vérification du TP Docker Avancé

Checklist de vérification

1. Structure des fichiers
- [ ] `ENONCE_TP.md` - Énoncé complet du TP
- [ ] `README.md` - Documentation principale
- [ ] `INSTALLATION.md` - Guide d'installation
- [ ] `ANALYSE_TEMPLATE.md` - Template d'analyse
- [ ] `DEMARRAGE_RAPIDE.md` - Guide de démarrage
- [ ] `.dockerignore` - Fichier d'optimisation
- [ ] `.github/workflows/docker-security.yml` - Workflow CI/CD

2. Applications pré-implémentées
- [ ] `node-api/` - Application Node.js/TypeScript
  - [ ] `package.json` - Dépendances Node.js
  - [ ] `src/server.ts` - Code source TypeScript
  - [ ] `tsconfig.json` - Configuration TypeScript
  - [ ] `Dockerfile.standard` - Version standard (problématique)

- [ ] `python-api/` - Application Python FastAPI
  - [ ] `pyproject.toml` - Configuration Poetry
  - [ ] `app/main.py` - Code source FastAPI

- [ ] `java-api/` - Application Java Spring Boot
  - [ ] `pom.xml` - Configuration Maven
  - [ ] `src/main/java/com/example/demo/DemoApplication.java` - Code source Java

3. Scripts d'analyse
- [ ] `scripts/build-all.sh` - Construction de toutes les images
- [ ] `scripts/analyze.sh` - Analyse comparative
- [ ] `scripts/green-impact.sh` - Calcul d'impact Green IT
- [ ] `scripts/security-scan.sh` - Scan de sécurité

4. Tests de fonctionnement

Test 1 : Construction des images
```bash
# Tester la construction de l'image Node.js standard
cd node-api
docker build -t node-api:standard -f Dockerfile.standard .
docker images node-api:standard
```

Test 2 : Test de l'application
```bash
# Tester le démarrage de l'application
docker run -d -p 3000:3000 --name node-api-test node-api:standard
sleep 5
curl http://localhost:3000/health
docker rm -f node-api-test
```

Test 3 : Vérification des tailles

Tailles attendues
- **Node.js standard** : ~1.2-1.4 GB
- **Python standard** : ~980MB
- **Java standard** : ~720MB

Vérification
```bash
# Afficher les tailles de toutes les images
docker images | grep -E "(node-api|python-api|java-api)"
```

Test 4 : Vérification des vulnérabilités

Vulnérabilités attendues
- **Images standard** : 150-200 vulnérabilités

Vérification
```bash
# Scanner toutes les images
for img in node-api:standard python-api:standard java-api:standard; do
  echo "Scanning $img..."
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy image --quiet $img
done
```

Problèmes courants et solutions

Problème 1 : Build échoue
```bash
# Vérifier que Docker est en cours d'exécution
docker info

# Activer BuildKit
export DOCKER_BUILDKIT=1
```

Problème 2 : Image trop lourde
```bash
# Vérifier le .dockerignore
cat .dockerignore

# Analyser avec dive
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock \
  wagoodman/dive <image-name>
```

Problème 3 : Application ne démarre pas
```bash
# Vérifier les logs
docker logs <container-name>

# Tester manuellement
docker run --rm -it <image-name> /bin/sh
```

Problème 4 : Permissions Docker
```bash
# Ajouter l'utilisateur au groupe docker
sudo usermod -aG docker $USER

# Redémarrer la session
newgrp docker
```

Métriques de succès

Objectifs de réduction de taille
- [ ] Node.js : Réduction > 85%
- [ ] Python : Réduction > 90%
- [ ] Java : Réduction > 75%

Objectifs de sécurité
- [ ] Vulnérabilités critiques : 0
- [ ] Vulnérabilités élevées : < 5
- [ ] Images distroless : Aucun shell

Objectifs de performance
- [ ] Temps de build : < 5 minutes
- [ ] Temps de démarrage : < 30 secondes
- [ ] Taille totale : < 500 MB

Prochaines étapes

Une fois la vérification terminée :

1. **Commencer l'analyse** : Suivre `ENONCE_TP.md`
2. **Remplir le template** : Utiliser `ANALYSE_TEMPLATE.md`
3. **Documenter les résultats** : Screenshots et mesures
4. **Calculer l'impact Green IT** : Utiliser `scripts/green-impact.sh`
5. **Préparer la présentation** : 10 slides maximum

Support

- **Documentation** : `README.md`
- **Installation** : `INSTALLATION.md`
- **Instructions** : `ENONCE_TP.md`
- **Démarrage** : `DEMARRAGE_RAPIDE.md`
- **Analyse** : `ANALYSE_TEMPLATE.md`

