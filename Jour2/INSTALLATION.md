Guide d'installation - TP Docker Avancé

🚀 Installation rapide

 Option 1 : Installation automatique (recommandée)

```bash
# Rendre le script exécutable
chmod +x install-requirements.sh

# Installation complète
./install-requirements.sh

# Ou installation sélective
./install-requirements.sh docker    # Docker uniquement
./install-requirements.sh python   # Python et pip uniquement
./install-requirements.sh node     # Node.js uniquement
./install-requirements.sh java     # Java et Maven uniquement
./install-requirements.sh tools    # Outils d'analyse uniquement
./install-requirements.sh check     # Vérification uniquement
```

Option 2 : Installation manuelle

📋 Prérequis système

Docker
```bash
# Linux
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# macOS
brew install --cask docker
# Ou télécharger Docker Desktop depuis https://docker.com

# Windows
# Télécharger Docker Desktop depuis https://docker.com
```

Python 3.11+
```bash
# Linux
sudo apt-get update
sudo apt-get install python3 python3-pip python3-venv

# macOS
brew install python

# Windows
# Télécharger depuis https://www.python.org/downloads/
```

Poetry (gestionnaire de dépendances Python)
```bash
curl -sSL https://install.python-poetry.org | python3 -
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Node.js 18+
```bash
# Linux
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# macOS
brew install node

# Windows
# Télécharger depuis https://nodejs.org/
```

Java 17+ et Maven
```bash
# Linux
sudo apt-get update
sudo apt-get install openjdk-17-jdk maven

# macOS
brew install openjdk@17 maven

# Windows
# Télécharger OpenJDK depuis https://adoptium.net/
# Télécharger Maven depuis https://maven.apache.org/
```

🔧 Outils d'analyse Docker

Dive (analyse des layers)
```bash
# Linux
wget https://github.com/wagoodman/dive/releases/download/v0.10.0/dive_0.10.0_linux_amd64.deb
sudo apt install ./dive_0.10.0_linux_amd64.deb

# macOS
brew install dive

# Windows
# Télécharger depuis https://github.com/wagoodman/dive/releases
```

Trivy (scanner de vulnérabilités)
```bash
# Linux
sudo apt-get update
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

# macOS
brew install trivy

# Windows
# Télécharger depuis https://github.com/aquasecurity/trivy/releases
```

Syft (génération de SBOM)
```bash
# Linux
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# macOS
brew install syft

# Windows
# Télécharger depuis https://github.com/anchore/syft/releases
```

⚙️ Configuration de l'environnement

Activer Docker BuildKit
```bash
# Temporaire
export DOCKER_BUILDKIT=1

# Permanent
echo 'export DOCKER_BUILDKIT=1' >> ~/.bashrc
echo 'export DOCKER_BUILDKIT=1' >> ~/.zshrc
```

Vérifier les installations
```bash
# Docker
docker --version
docker-compose --version

# Python
python3 --version
pip3 --version
poetry --version

# Node.js
node --version
npm --version

# Java
java --version
mvn --version

# Outils d'analyse
dive --version
trivy --version
syft --version
```

🐳 Images Docker nécessaires

Images de base
```bash
# Pull des images de base
docker pull node:18-alpine
docker pull python:3.11-slim
docker pull maven:3.9-eclipse-temurin-17
docker pull openjdk:17-jre-slim
```

Images distroless
```bash
# Pull des images distroless
docker pull gcr.io/distroless/nodejs18-debian11
docker pull gcr.io/distroless/python3-debian11
docker pull gcr.io/distroless/java17-debian11
```

Outils d'analyse
```bash
# Pull des outils d'analyse
docker pull wagoodman/dive
docker pull aquasec/trivy
docker pull anchore/syft
```

🧪 Test de l'installation

Test Docker
```bash
# Vérifier que Docker fonctionne
docker run hello-world

# Vérifier BuildKit
docker buildx version
```

Test Python
```bash
# Créer un environnement virtuel
python3 -m venv venv
source venv/bin/activate  # Linux/macOS
# ou venv\Scripts\activate  # Windows

# Installer Poetry
pip install poetry
poetry --version
```

Test Node.js
```bash
# Créer un projet test
mkdir test-node && cd test-node
npm init -y
npm install express
node -e "console.log('Node.js fonctionne!')"
```

Test Java
```bash
# Créer un projet Maven test
mvn archetype:generate -DgroupId=com.test -DartifactId=test-app -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
cd test-app
mvn compile
```

🆘 Résolution de problèmes

Docker ne démarre pas
```bash
# Linux
sudo systemctl start docker
sudo systemctl enable docker

# macOS
# Ouvrir Docker Desktop depuis Applications

# Windows
# Démarrer Docker Desktop
```

Permissions Docker
```bash
# Ajouter l'utilisateur au groupe docker
sudo usermod -aG docker $USER

# Redémarrer la session
newgrp docker
```

Poetry non trouvé
```bash
# Ajouter au PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Ou réinstaller
curl -sSL https://install.python-poetry.org | python3 -
```

BuildKit non activé
```bash
# Vérifier la variable
echo $DOCKER_BUILDKIT

# L'activer
export DOCKER_BUILDKIT=1

# Vérifier
docker buildx version
```

📚 Ressources utiles

### Documentation officielle
- [Docker](https://docs.docker.com/)
- [Python](https://docs.python.org/)
- [Node.js](https://nodejs.org/docs/)
- [Java](https://docs.oracle.com/en/java/)
- [Poetry](https://python-poetry.org/docs/)

Outils d'analyse
- [Dive](https://github.com/wagoodman/dive)
- [Trivy](https://aquasecurity.github.io/trivy/)
- [Syft](https://github.com/anchore/syft)

Support
- Issues GitHub: https://github.com/docker-master2/tp-distroless
- Documentation TP: README.md
- Instructions: ENONCE_TP.md

✅ Checklist d'installation

- [ ] Docker installé et fonctionnel
- [ ] Python 3.11+ installé
- [ ] pip installé
- [ ] Poetry installé
- [ ] Node.js 18+ installé
- [ ] npm installé
- [ ] Java 17+ installé
- [ ] Maven installé
- [ ] Dive installé
- [ ] Trivy installé
- [ ] Syft installé
- [ ] BuildKit activé
- [ ] Images Docker téléchargées
- [ ] Tests de fonctionnement réussis

🎯 Prochaines étapes

Une fois l'installation terminée :

1. **Naviguer vers le TP** :
   ```bash
   cd TP_Apprenants
   ```

2. **Construire toutes les images** :
   ```bash
   ./scripts/build-all.sh
   ```

3. **Analyser les résultats** :
   ```bash
   ./scripts/analyze.sh
   ```

4. **Calculer l'impact Green IT** :
   ```bash
   ./scripts/green-impact.sh
   ```

5. **Suivre les instructions** :
   - Lire le README.md
   - Suivre ENONCE_TP.md
   - Remplir ANALYSE_TEMPLATE.md

---
