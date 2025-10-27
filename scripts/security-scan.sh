#!/bin/bash

# Script de scan de sécurité avancé
# TP Docker Avancé - Master 2 Full Stack

set -euo pipefail

# Couleurs pour l'affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonction pour afficher le statut
show_status() {
    local status=$1
    local message=$2
    if [ "$status" = "success" ]; then
        echo -e "${GREEN}✅ $message${NC}"
    elif [ "$status" = "error" ]; then
        echo -e "${RED}❌ $message${NC}"
    elif [ "$status" = "info" ]; then
        echo -e "${BLUE}ℹ️  $message${NC}"
    elif [ "$status" = "warning" ]; then
        echo -e "${YELLOW}⚠️  $message${NC}"
    fi
}

echo "=== 🔒 SCAN DE SÉCURITÉ AVANCÉ ==="
echo "Date: $(date)"
echo ""

# Vérifier que Docker est en cours d'exécution
if ! docker info > /dev/null 2>&1; then
    show_status "error" "Docker n'est pas en cours d'exécution. Veuillez démarrer Docker Desktop."
    exit 1
fi

# Fonction pour scanner avec Trivy
scan_with_trivy() {
    local image_name=$1
    local output_file="security-reports/trivy-${image_name}.json"
    
    show_status "info" "Scan Trivy pour $image_name"
    
    # Créer le répertoire de rapports
    mkdir -p security-reports
    
    # Scanner avec Trivy et sauvegarder le rapport
    if command -v trivy &> /dev/null; then
        trivy image --format json --output "$output_file" "$image_name"
        trivy image --severity CRITICAL,HIGH,MEDIUM --format table "$image_name"
    else
        show_status "warning" "Trivy non disponible, utilisation via Docker"
        docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            -v "$(pwd)/security-reports:/reports" \
            aquasec/trivy image --format json --output "/reports/trivy-${image_name}.json" "$image_name"
        docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy image --severity CRITICAL,HIGH,MEDIUM --format table "$image_name"
    fi
    
    echo ""
}

# Fonction pour scanner avec Syft (SBOM)
generate_sbom() {
    local image_name=$1
    local output_file="security-reports/sbom-${image_name}.json"
    
    show_status "info" "Génération du SBOM pour $image_name"
    
    # Générer le SBOM avec Syft
    if command -v syft &> /dev/null; then
        syft "$image_name" --output json > "$output_file"
        syft "$image_name" --output table
    else
        show_status "warning" "Syft non disponible, utilisation via Docker"
        docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            -v "$(pwd)/security-reports:/reports" \
            anchore/syft "$image_name" --output json > "$output_file"
        docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            anchore/syft "$image_name" --output table
    fi
    
    echo ""
}

# Fonction pour analyser avec Dive
analyze_with_dive() {
    local image_name=$1
    local output_file="security-reports/dive-${image_name}.json"
    
    show_status "info" "Analyse Dive pour $image_name"
    
    # Analyser avec Dive
    if command -v dive &> /dev/null; then
        dive "$image_name" --ci --json > "$output_file" 2>/dev/null || true
        dive "$image_name" --ci
    else
        show_status "warning" "Dive non disponible, utilisation via Docker"
        docker run --rm -it \
            -v /var/run/docker.sock:/var/run/docker.sock \
            wagoodman/dive "$image_name" --ci
    fi
    
    echo ""
}

# Fonction pour vérifier les secrets
scan_secrets() {
    local image_name=$1
    local output_file="security-reports/secrets-${image_name}.json"
    
    show_status "info" "Scan des secrets pour $image_name"
    
    # Scanner les secrets avec Trivy
    if command -v trivy &> /dev/null; then
        trivy image --scanners secret --format json --output "$output_file" "$image_name"
        trivy image --scanners secret --format table "$image_name"
    else
        show_status "warning" "Trivy non disponible, utilisation via Docker"
        docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            -v "$(pwd)/security-reports:/reports" \
            aquasec/trivy image --scanners secret --format json --output "/reports/secrets-${image_name}.json" "$image_name"
        docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy image --scanners secret --format table "$image_name"
    fi
    
    echo ""
}

# Fonction pour générer un rapport de sécurité complet
generate_security_report() {
    local image_name=$1
    
    show_status "info" "Génération du rapport de sécurité complet pour $image_name"
    
    local report_file="security-reports/security-report-${image_name}.md"
    
    cat > "$report_file" << EOF
# Rapport de Sécurité - $image_name

**Date :** $(date)
**Image :** $image_name

## 🔍 Résumé des Scans

### Vulnérabilités (Trivy)
- **Critiques :** $(grep -c '"Severity":"CRITICAL"' "security-reports/trivy-${image_name}.json" 2>/dev/null || echo "0")
- **Élevées :** $(grep -c '"Severity":"HIGH"' "security-reports/trivy-${image_name}.json" 2>/dev/null || echo "0")
- **Moyennes :** $(grep -c '"Severity":"MEDIUM"' "security-reports/trivy-${image_name}.json" 2>/dev/null || echo "0")

### Secrets Détectés
- **Total :** $(grep -c '"Severity"' "security-reports/secrets-${image_name}.json" 2>/dev/null || echo "0")

### Analyse de Taille (Dive)
- **Taille totale :** $(docker images --format "table {{.Size}}" "$image_name" | tail -1)
- **Layers :** $(docker history "$image_name" --format "table {{.CreatedBy}}" | wc -l)

## 📊 Recommandations

1. **Vulnérabilités critiques :** Mettre à jour les packages affectés
2. **Secrets :** Vérifier qu'aucun secret n'est exposé
3. **Taille :** Optimiser les layers pour réduire la surface d'attaque
4. **Base d'image :** Utiliser des images distroless récentes

## 🔗 Fichiers de Rapport

- Vulnérabilités : \`security-reports/trivy-${image_name}.json\`
- SBOM : \`security-reports/sbom-${image_name}.json\`
- Secrets : \`security-reports/secrets-${image_name}.json\`
- Dive : \`security-reports/dive-${image_name}.json\`

---
*Rapport généré automatiquement par le script de sécurité*
EOF

    show_status "success" "Rapport généré : $report_file"
}

# Fonction principale de scan
scan_image() {
    local image_name=$1
    
    echo -e "${BLUE}🔍 Scan complet de l'image $image_name${NC}"
    echo "=================================="
    
    # Vérifier que l'image existe
    if ! docker image inspect "$image_name" > /dev/null 2>&1; then
        show_status "error" "Image $image_name non trouvée"
        return 1
    fi
    
    # Scanner les vulnérabilités
    scan_with_trivy "$image_name"
    
    # Générer le SBOM
    generate_sbom "$image_name"
    
    # Analyser avec Dive
    analyze_with_dive "$image_name"
    
    # Scanner les secrets
    scan_secrets "$image_name"
    
    # Générer le rapport complet
    generate_security_report "$image_name"
    
    show_status "success" "Scan complet terminé pour $image_name"
    echo ""
}

# Images à scanner
IMAGES=(
    "python-api:distroless-secure"
    "java-api:distroless-secure"
    "node-api:distroless-secure"
)

# Scanner toutes les images
for image in "${IMAGES[@]}"; do
    if docker image inspect "$image" > /dev/null 2>&1; then
        scan_image "$image"
    else
        show_status "warning" "Image $image non trouvée, construction nécessaire"
    fi
done

echo -e "${GREEN}🎉 Scan de sécurité terminé !${NC}"
echo ""
echo -e "${BLUE}📁 Rapports disponibles dans le répertoire security-reports/ :${NC}"
ls -la security-reports/ 2>/dev/null || echo "Aucun rapport généré"

echo ""
echo -e "${YELLOW}💡 Prochaines étapes :${NC}"
echo "1. Examinez les rapports de vulnérabilités"
echo "2. Corrigez les vulnérabilités critiques"
echo "3. Vérifiez qu'aucun secret n'est exposé"
echo "4. Optimisez les images selon les recommandations"
