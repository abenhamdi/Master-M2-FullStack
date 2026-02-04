#!/bin/bash

# Script de calcul d'impact Green IT
# Master 2 Full Stack - Docker Optimization TP

echo "=== 🌱 CALCUL D'IMPACT GREEN IT ==="
echo "Date: $(date)"
echo ""

# Couleurs pour l'affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Paramètres de calcul
BUILDS_PER_DAY=50
STORAGE_COST_PER_GB=0.10  # $/GB/mois
POWER_CONSUMPTION_W=500   # Watts par serveur
CO2_PER_KWH=0.5          # kg CO2/kWh
NETWORK_COST_PER_GB=0.05  # $/GB de transfert

# Données des optimisations
declare -A OPTIMIZATIONS=(
    ["nodejs_standard"]="1400"
    ["nodejs_distroless"]="150"
    ["python_standard"]="980"
    ["python_distroless"]="80"
    ["java_standard"]="720"
    ["java_distroless"]="170"
)

echo -e "${BLUE}📊 DONNÉES D'OPTIMISATION${NC}"
echo ""

# Calculer les économies pour chaque technologie
for tech in nodejs python java; do
    standard_key="${tech}_standard"
    distroless_key="${tech}_distroless"
    
    if [[ -n "${OPTIMIZATIONS[$standard_key]}" && -n "${OPTIMIZATIONS[$distroless_key]}" ]]; then
        old_size=${OPTIMIZATIONS[$standard_key]}
        new_size=${OPTIMIZATIONS[$distroless_key]}
        savings=$(echo "$old_size - $new_size" | bc)
        percentage=$(echo "scale=1; ($savings / $old_size) * 100" | bc)
        
        echo -e "${GREEN}${tech^^}:${NC}"
        echo "   Standard: ${old_size}MB"
        echo "   Distroless: ${new_size}MB"
        echo "   Économie: ${savings}MB (${percentage}%)"
        echo ""
    fi
done

echo -e "${BLUE}💰 CALCUL DES COÛTS${NC}"
echo ""

# Calculer l'impact financier
total_savings_mb=0
for tech in nodejs python java; do
    standard_key="${tech}_standard"
    distroless_key="${tech}_distroless"
    
    if [[ -n "${OPTIMIZATIONS[$standard_key]}" && -n "${OPTIMIZATIONS[$distroless_key]}" ]]; then
        old_size=${OPTIMIZATIONS[$standard_key]}
        new_size=${OPTIMIZATIONS[$distroless_key]}
        savings=$(echo "$old_size - $new_size" | bc)
        total_savings_mb=$(echo "$total_savings_mb + $savings" | bc)
    fi
done

# Convertir en GB
total_savings_gb=$(echo "scale=3; $total_savings_mb / 1000" | bc)

echo "Économie totale par image: ${total_savings_gb}GB"
echo ""

# Coûts de stockage
monthly_storage_savings=$(echo "scale=2; $total_savings_gb * $STORAGE_COST_PER_GB" | bc)
annual_storage_savings=$(echo "scale=2; $monthly_storage_savings * 12" | bc)

echo -e "${GREEN}💾 COÛTS DE STOCKAGE${NC}"
echo "   Économie mensuelle par image: \$${monthly_storage_savings}"
echo "   Économie annuelle par image: \$${annual_storage_savings}"
echo ""

# Coûts de transfert réseau
network_savings_per_deploy=$(echo "scale=2; $total_savings_gb * $NETWORK_COST_PER_GB" | bc)
daily_network_savings=$(echo "scale=2; $network_savings_per_deploy * $BUILDS_PER_DAY" | bc)
annual_network_savings=$(echo "scale=2; $daily_network_savings * 365" | bc)

echo -e "${GREEN}🌐 COÛTS DE TRANSFERT RÉSEAU${NC}"
echo "   Économie par déploiement: \$${network_savings_per_deploy}"
echo "   Économie quotidienne: \$${daily_network_savings}"
echo "   Économie annuelle: \$${annual_network_savings}"
echo ""

echo -e "${BLUE}⚡ CALCUL DES PERFORMANCES${NC}"
echo ""

# Temps de pull (approximatif)
pull_time_old=$(echo "scale=1; $total_savings_gb * 8" | bc)  # 8 secondes par GB @ 100Mbps
pull_time_new=$(echo "scale=1; ($total_savings_gb - $total_savings_gb * 0.9) * 8" | bc)
time_saved_per_deploy=$(echo "scale=1; $pull_time_old - $pull_time_new" | bc)

echo "Temps de pull économisé par déploiement: ${time_saved_per_deploy}s"
echo ""

# Gain de temps CI/CD
daily_time_saved=$(echo "scale=1; $time_saved_per_deploy * $BUILDS_PER_DAY / 60" | bc)
annual_time_saved=$(echo "scale=1; $daily_time_saved * 365 / 60" | bc)

echo -e "${GREEN}🚀 GAINS DE TEMPS CI/CD${NC}"
echo "   Gain quotidien: ${daily_time_saved} minutes"
echo "   Gain annuel: ${annual_time_saved} heures"
echo ""

echo -e "${BLUE}🌱 IMPACT ENVIRONNEMENTAL${NC}"
echo ""

# Consommation énergétique
power_saved_per_gb=$(echo "scale=3; $POWER_CONSUMPTION_W / 1000" | bc)  # kW par GB
power_saved_kwh=$(echo "scale=3; $total_savings_gb * $power_saved_per_gb * 24 * 365" | bc)
co2_saved=$(echo "scale=2; $power_saved_kwh * $CO2_PER_KWH" | bc)

echo "Énergie économisée par an (1 image): ${power_saved_kwh}kWh"
echo "CO2 évité par an (1 image): ${co2_saved}kg"
echo ""

# Équivalences
car_km=$(echo "scale=0; $co2_saved * 5" | bc)
trees_planted=$(echo "scale=0; $co2_saved / 22" | bc)

echo -e "${GREEN}🌳 ÉQUIVALENCES ENVIRONNEMENTALES${NC}"
echo "   Équivalent: ${car_km}km en voiture"
echo "   Arbres à planter: ${trees_planted}"
echo ""

# Impact pour 100 microservices
microservices=100
total_annual_savings=$(echo "scale=2; $annual_storage_savings * $microservices" | bc)
total_co2_saved=$(echo "scale=2; $co2_saved * $microservices" | bc)
total_trees=$(echo "scale=0; $trees_planted * $microservices" | bc)

echo -e "${BLUE}📈 IMPACT POUR 100 MICROSERVICES${NC}"
echo ""
echo "Économies annuelles totales: \$${total_annual_savings}"
echo "CO2 évité total: ${total_co2_saved}kg"
echo "Arbres équivalents: ${total_trees}"
echo ""

echo -e "${YELLOW}🎯 RECOMMANDATIONS GREEN IT${NC}"
echo ""
echo "1. Utilisez des images distroless pour tous vos microservices"
echo "2. Implémentez des politiques de nettoyage des images"
echo "3. Optimisez vos pipelines CI/CD"
echo "4. Surveillez l'impact environnemental de vos déploiements"
echo "5. Considérez l'utilisation de registries verts"
echo ""

echo "=== ✅ CALCUL TERMINÉ ==="
echo "Date: $(date)"
echo ""
echo -e "${GREEN}💡 Pensez Green IT ! Chaque MB économisé compte pour la planète.${NC}"
