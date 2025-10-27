Démarrage Rapide - TP Docker Avancé

En 5 minutes, vous êtes prêt !

1. Vérification des prérequis
```bash
# Vérifier Docker
docker --version

# Activer BuildKit
export DOCKER_BUILDKIT=1

# Vérifier que BuildKit est activé
docker buildx version
```

2. Télécharger les outils d'analyse
```bash
# Images Docker pour l'analyse
docker pull wagoodman/dive
docker pull aquasec/trivy
```

3. Construire toutes les images
```bash
# Script automatisé
./scripts/build-all.sh
```

4. Analyser les résultats
```bash
# Analyse comparative
./scripts/analyze.sh

# Impact Green IT
./scripts/green-impact.sh
```

5. Commencer l'analyse
- Ouvrir `ENONCE_TP.md` pour les instructions détaillées
- Remplir `ANALYSE_TEMPLATE.md` avec vos résultats
- Suivre les étapes une par une

Objectifs du TP

- **Réduire la taille des images de 80-90%**
- **Implémenter des images distroless**
- **Analyser l'impact Green IT**
- **Scanner les vulnérabilités**

Structure du projet

```
TP_Apprenants/
├── ENONCE_TP.md              # Énoncé complet
├── README.md                 # Documentation
├── INSTALLATION.md           # Guide d'installation
├── ANALYSE_TEMPLATE.md       # Template d'analyse
├── DEMARRAGE_RAPIDE.md       # Ce fichier
├── node-api/                # Application Node.js
├── python-api/               # Application Python
├── java-api/                 # Application Java
└── scripts/                  # Scripts d'analyse
```

Besoin d'aide ?

1. **Problème d'installation** → `INSTALLATION.md`
2. **Questions techniques** → `ENONCE_TP.md`
3. **Structure d'analyse** → `ANALYSE_TEMPLATE.md`
4. **Support** → Contact formateur

Checklist de démarrage

- [ ] Docker installé et fonctionnel
- [ ] BuildKit activé
- [ ] Images d'analyse téléchargées
- [ ] Scripts exécutés avec succès
- [ ] Énoncé lu et compris
- [ ] Template d'analyse ouvert

---