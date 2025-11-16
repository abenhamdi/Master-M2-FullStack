TP Docker Avancé - Optimisation Extrême & Images Distroless
**Master 2 Full Stack - Docker Jour 2**

Votre mission

Votre entreprise a un problème : **3 microservices avec des images Docker trop lourdes et peu sécurisées**. 

Votre mission : **analyser, optimiser et sécuriser ces applications** pour réduire les coûts et améliorer la sécurité.

Démarrage rapide

1. Prérequis
```bash
# Docker avec BuildKit activé
export DOCKER_BUILDKIT=1

# Outils d'analyse (optionnel mais recommandé)
docker pull wagoodman/dive        # Analyse des layers
docker pull aquasec/trivy         # Scan de vulnérabilités
```

2. Structure du projet
```
TP_Apprenants/
├── ENONCE_TP.md              # Énoncé complet avec votre mission
├── README.md                 # Ce fichier
├── ANALYSE_TEMPLATE.md       # Template pour documenter vos résultats
├── node-api/                 # Application Node.js/TypeScript
│   ├── src/server.ts         # Code source
│   ├── package.json          # Dépendances
│   ├── tsconfig.json         # Configuration TypeScript
│   └── Dockerfile.standard   # Version actuelle (problématique)
├── python-api/               # Application Python FastAPI
│   ├── app/main.py           # Code source
│   └── pyproject.toml        # Configuration Poetry
├── java-api/                 # Application Java Spring Boot
│   ├── src/main/java/...     # Code source
│   └── pom.xml               # Configuration Maven
└── scripts/                  # Scripts d'analyse (à utiliser)
    ├── analyze.sh
    └── green-impact.sh
```

3. Votre processus de travail

1. **Lire l'énoncé** : `ENONCE_TP.md` - Comprendre la problématique
2. **Analyser les applications** : Explorer le code source fourni
3. **Identifier les problèmes** : Taille, sécurité, performance
4. **Rechercher des solutions** : Multi-stage builds, images distroless
5. **Implémenter vos optimisations** : Créer vos propres Dockerfiles
6. **Mesurer l'impact** : Utiliser les outils d'analyse
7. **Documenter vos résultats** : Remplir `ANALYSE_TEMPLATE.md`

Objectifs d'apprentissage

- **Analyser** les problèmes de taille et sécurité
- **Implémenter** des solutions d'optimisation
- **Mesurer** l'impact de vos choix techniques
- **Calculer** l'impact environnemental
- **Comprendre** les enjeux de sécurité

Ressources pour vous aider

- [Docker Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
- [Dockerfile best practices](https://docs.docker.com/develop/dev-best-practices/)
- [Trivy Scanner](https://aquasecurity.github.io/trivy/)
- [Dive - Docker Image Analysis](https://github.com/wagoodman/dive)

Besoin d'aide ?

1. **Problème d'installation** → `INSTALLATION.md`
2. **Questions techniques** → `ENONCE_TP.md`
3. **Structure d'analyse** → `ANALYSE_TEMPLATE.md`
4. **Support** → Contact formateur

