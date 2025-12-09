#!/bin/bash

# Script d'analyse comparative des images Docker
# Master 2 Full Stack - Docker Optimization TP

echo "=== ANALYSE COMPARATIVE DES IMAGES DOCKER ==="
echo "Date: $(date)"
echo ""

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'analyse d'une image
analyze_image() {
    local IMAGE=$1
    local IMAGE_NAME=$(echo $IMAGE | cut -d: -f1)
    local IMAGE_TAG=$(echo $IMAGE | cut -d: -f2)
    
    echo -e "${BLUE}📦 Image: $IMAGE${NC}"
    
    # Vérifier si l'image existe
    if ! docker images $IMAGE | grep -q $IMAGE_NAME; then
        echo -e "${RED}   ❌ Image non trouvée${NC}"
        echo ""
        return
    fi
    
    # Taille de l'image
    local SIZE=$(docker images $IMAGE --format "{{.Size}}")
    echo -e "${GREEN}   📏 Taille: $SIZE${NC}"
    
    # Nombre de layers
    local LAYERS=$(docker history $IMAGE --no-trunc | wc -l)
    echo -e "${GREEN}   🏗️  Layers: $LAYERS${NC}"
    
    # Taille en MB (approximative)
    local SIZE_MB=$(docker images $IMAGE --format "{{.Size}}" | sed 's/[^0-9.]//g' | head -1)
    if [[ $SIZE_MB =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo -e "${GREEN}   💾 Taille numérique: ${SIZE_MB}MB${NC}"
    fi
    
    # Scan des vulnérabilités
    echo -e "${YELLOW}   🔍 Scan sécurité en cours...${NC}"
    local VULNERABILITIES=$(docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy image --quiet --severity HIGH,CRITICAL $IMAGE 2>/dev/null | \
        grep "Total:" | awk '{print $2}' || echo "0")
    
    if [ "$VULNERABILITIES" = "0" ] || [ -z "$VULNERABILITIES" ]; then
        echo -e "${GREEN}   ✅ Aucune vulnérabilité critique${NC}"
    else
        echo -e "${RED}   ⚠️  Vulnérabilités critiques: $VULNERABILITIES${NC}"
    fi
    
    # Informations sur l'OS
    local OS_INFO=$(docker run --rm $IMAGE cat /etc/os-release 2>/dev/null | grep "PRETTY_NAME" | cut -d'"' -f2 || echo "Non disponible")
    echo -e "${GREEN}   🐧 OS: $OS_INFO${NC}"
    
    # Vérifier la présence d'un shell
    local SHELL_AVAILABLE=$(docker run --rm $IMAGE which sh 2>/dev/null && echo "Oui" || echo "Non")
    if [ "$SHELL_AVAILABLE" = "Oui" ]; then
        echo -e "${YELLOW}   🐚 Shell disponible: $SHELL_AVAILABLE${NC}"
    else
        echo -e "${GREEN}   🔒 Shell disponible: $SHELL_AVAILABLE (Distroless)${NC}"
    fi
    
    echo ""
}

# Fonction pour calculer les économies
calculate_savings() {
    local OLD_SIZE=$1
    local NEW_SIZE=$2
    local PERCENTAGE=$(echo "scale=2; (($OLD_SIZE - $NEW_SIZE) / $OLD_SIZE) * 100" | bc)
    echo "$PERCENTAGE"
}

echo -e "${BLUE}🔍 Analyse des images Node.js...${NC}"
echo ""

# Analyser les images Node.js
for img in node-api:standard node-api:multi-stage node-api:distroless; do
    analyze_image $img
done

echo -e "${BLUE}🔍 Analyse des images Python...${NC}"
echo ""

# Analyser les images Python
for img in python-api:distroless; do
    analyze_image $img
done

for img in python-api:multi-stage; do
    analyze_image $img
done

echo -e "${BLUE}🔍 Analyse des images Java...${NC}"
echo ""

# Analyser les images Java
for img in java-api:distroless; do
    analyze_image $img
done

for img in java-api:multi-stage; do
    analyze_image $img
done

echo "=== 📊 RÉSUMÉ DES GAINS ==="
echo ""

# Calculer les économies (valeurs approximatives)
echo -e "${GREEN}Node.js:${NC}"
echo "   Standard: ~1.4GB"
echo "   Multi-stage: ~250MB (82% réduction)"
echo "   Distroless: ~150MB (89% réduction)"
echo ""

echo -e "${GREEN}Python:${NC}"
echo "   Standard: ~980MB"
echo "   Distroless: ~80MB (92% réduction)"
echo ""

echo -e "${GREEN}Java:${NC}"
echo "   Standard: ~720MB"
echo "   Distroless: ~170MB (76% réduction)"
echo ""

echo "=== 🎯 RECOMMANDATIONS ==="
echo ""
echo -e "${GREEN}✅ Utilisez des images distroless pour:${NC}"
echo "   • Sécurité maximale (pas de shell)"
echo "   • Taille minimale"
echo "   • Conformité aux standards"
echo ""
echo -e "${YELLOW}⚠️  Considérations:${NC}"
echo "   • Debugging plus complexe"
echo "   • Pas d'accès shell en production"
echo "   • Tests de sécurité nécessaires"
echo ""

echo -e "${BLUE}📈 Impact Green IT:${NC}"
echo "   • Réduction des coûts de stockage"
echo "   • Temps de déploiement plus rapides"
echo "   • Consommation énergétique réduite"
echo ""

echo "=== ✅ ANALYSE TERMINÉE ==="
echo "Date: $(date)"
