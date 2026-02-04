# Dataset Fermes Solaires - Données Françaises Réalistes

## Objectif

Ce dataset contient des données réalistes de production solaire pour 3 fermes photovoltaïques en France, avec injection d'anomalies pour tester le système de monitoring.

## Fichiers du Dataset

```
data/
├── README_DATASET.md (ce fichier)
├── provence_data.csv (Ferme de Marseille)
├── occitanie_data.csv (Ferme de Montpellier)
├── aquitaine_data.csv (Ferme de Bordeaux)
├── anomalies_log.csv (Log des anomalies injectées)
└── generate_dataset.py (Script de génération)
```

## Structure des Données

### Fichiers CSV Principaux

Chaque fichier contient des données horaires sur 30 jours :

| Colonne | Type | Description | Unité |
|---------|------|-------------|-------|
| timestamp | datetime | Date et heure | ISO 8601 |
| farm_name | string | Nom de la ferme | - |
| hour | int | Heure de la journée | 0-23 |
| day_of_year | int | Jour de l'année | 1-365 |
| irradiance_wm2 | float | Irradiance solaire | W/m² |
| ambient_temp_c | float | Température ambiante | °C |
| panel_temp_c | float | Température moyenne panneaux | °C |
| power_production_kw | float | Production totale | kW |
| theoretical_power_kw | float | Production théorique | kW |
| efficiency_percent | float | Rendement global | % |
| inverter_1_status | int | État onduleur 1 | 0/1 |
| inverter_2_status | int | État onduleur 2 | 0/1 |
| inverter_3_status | int | État onduleur 3 | 0/1 |
| inverter_4_status | int | État onduleur 4 | 0/1 (si existe) |
| daily_revenue_eur | float | Revenus cumulés du jour | € |
| anomaly_type | string | Type d'anomalie | voir ci-dessous |
| anomaly_severity | string | Sévérité | low/medium/high |

### Types d'Anomalies

| Code | Description | Impact | Fréquence |
|------|-------------|--------|-----------|
| NORMAL | Fonctionnement normal | - | 85% |
| OVERHEAT | Surchauffe panneaux (> 65°C) | -10% production | 5% |
| INVERTER_DOWN | Panne onduleur | -25% à -100% | 3% |
| DEGRADATION | Dégradation panneaux | -15% production | 4% |
| SHADING | Ombrage partiel | -30% production | 2% |
| SENSOR_FAIL | Capteur défaillant | Données manquantes | 1% |

## Caractéristiques par Ferme

### Provence (Marseille)

- **Latitude** : 43.3°N
- **Panneaux** : 5000
- **Capacité** : 2.0 MW
- **Onduleurs** : 4
- **Particularités** :
  - Ensoleillement maximum en été (1000 W/m²)
  - Mistral (refroidissement naturel)
  - Anomalie fréquente : Surchauffe en juillet-août

### Occitanie (Montpellier)

- **Latitude** : 43.6°N
- **Panneaux** : 3500
- **Capacité** : 1.4 MW
- **Onduleurs** : 3
- **Particularités** :
  - Ensoleillement élevé toute l'année
  - Moins de vent que Marseille
  - Anomalie fréquente : Température élevée

### Aquitaine (Bordeaux)

- **Latitude** : 44.8°N
- **Panneaux** : 4200
- **Capacité** : 1.68 MW
- **Onduleurs** : 4
- **Particularités** :
  - Ensoleillement plus variable (océan)
  - Humidité plus élevée
  - Anomalie fréquente : Ombrage matinal (brouillard)

## Données Météorologiques Réalistes

### Irradiance Moyenne par Mois (W/m² à midi)

| Mois | Provence | Occitanie | Aquitaine |
|------|----------|-----------|-----------|
| Janvier | 400 | 380 | 350 |
| Février | 500 | 480 | 450 |
| Mars | 700 | 680 | 650 |
| Avril | 850 | 830 | 800 |
| Mai | 950 | 930 | 900 |
| Juin | 1000 | 980 | 950 |
| Juillet | 980 | 960 | 930 |
| Août | 900 | 880 | 850 |
| Septembre | 750 | 730 | 700 |
| Octobre | 600 | 580 | 550 |
| Novembre | 450 | 430 | 400 |
| Décembre | 380 | 360 | 330 |

### Température Ambiante Moyenne (°C)

| Mois | Provence | Occitanie | Aquitaine |
|------|----------|-----------|-----------|
| Janvier | 8 | 9 | 7 |
| Février | 10 | 11 | 9 |
| Mars | 13 | 14 | 12 |
| Avril | 16 | 17 | 15 |
| Mai | 20 | 21 | 18 |
| Juin | 24 | 25 | 22 |
| Juillet | 27 | 28 | 24 |
| Août | 26 | 27 | 24 |
| Septembre | 22 | 23 | 20 |
| Octobre | 17 | 18 | 16 |
| Novembre | 12 | 13 | 11 |
| Décembre | 9 | 10 | 8 |

## Scénarios d'Anomalies Injectés

### Scénario 1 : Canicule Estivale (15-17 juin, 12h-15h)

- **Ferme** : Provence
- **Type** : OVERHEAT
- **Impact** : Température panneaux > 70°C
- **Conséquence** : -12% production, déclenchement alerte
- **Événements** : 12 occurrences dans le log

### Scénario 2 : Panne Onduleur (8 juin, 10h-14h)

- **Ferme** : Occitanie
- **Type** : INVERTER_DOWN
- **Impact** : Onduleur 2 hors service
- **Conséquence** : -33% production, perte 250€
- **Événements** : 5 occurrences dans le log

### Scénario 3 : Dégradation Progressive (5-25 juin)

- **Ferme** : Aquitaine
- **Type** : DEGRADATION
- **Impact** : 15 panneaux dégradés
- **Conséquence** : -15% sur ces panneaux
- **Événements** : 5 occurrences échantillonnées dans le log

### Scénario 4 : Ombrage Matinal (12-14 juin, 6h-10h)

- **Ferme** : Aquitaine
- **Type** : SHADING
- **Impact** : Brouillard matinal
- **Conséquence** : -40% production matinale
- **Événements** : 15 occurrences dans le log (5h par jour × 3 jours)

### Scénario 5 : Défaillance Capteur (20 juin, 14h-16h)

- **Ferme** : Provence
- **Type** : SENSOR_FAIL
- **Impact** : Données manquantes
- **Conséquence** : Alerte monitoring
- **Événements** : 3 occurrences dans le log

## Métriques Calculées

### Production Théorique

```python
P_theorique = nb_panneaux × 400W × (irradiance/1000) × 0.85 × facteur_temp
facteur_temp = 1 + (T_panneau - 25) × (-0.0035)
```

### Température Panneau

```python
T_panneau = T_ambiante + (irradiance/1000) × 25
```

### Revenus Journaliers

```python
Revenus = Σ(Production_kWh) × 0.18 €/kWh
```

### Rendement Global

```python
Rendement = (Production_réelle / Production_théorique) × 100
```

## Utilisation du Dataset

### Charger les Données (Python)

```python
import pandas as pd

# Charger une ferme
df_provence = pd.read_csv('provence_data.csv', parse_dates=['timestamp'])

# Filtrer les anomalies
anomalies = df_provence[df_provence['anomaly_type'] != 'NORMAL']

# Calculer les statistiques
avg_production = df_provence['power_production_kw'].mean()
total_revenue = df_provence['daily_revenue_eur'].sum()
```

### Charger les Données (Node.js)

```javascript
const fs = require('fs');
const csv = require('csv-parser');

const data = [];
fs.createReadStream('provence_data.csv')
  .pipe(csv())
  .on('data', (row) => data.push(row))
  .on('end', () => {
    console.log(`Loaded ${data.length} records`);
  });
```

### Requêtes SQL (si importé en DB)

```sql
-- Production totale par ferme
SELECT farm_name, SUM(power_production_kw) as total_kw
FROM solar_data
GROUP BY farm_name;

-- Anomalies critiques
SELECT timestamp, farm_name, anomaly_type, anomaly_severity
FROM solar_data
WHERE anomaly_severity = 'high'
ORDER BY timestamp;

-- Revenus par jour
SELECT DATE(timestamp) as date, SUM(daily_revenue_eur) as revenue
FROM solar_data
GROUP BY DATE(timestamp);
```

## Statistiques du Dataset

### Volume de Données

- **Période** : 30 jours (Juin 2025)
- **Fréquence** : Horaire (24 mesures/jour)
- **Total lignes** : 2163 (720 lignes × 3 fermes)
- **Taille fichier** : ~200 KB (CSV)
- **Anomalies loguées** : 40 événements

### Distribution des Anomalies

| Type | Occurrences | Pourcentage |
|------|-------------|-------------|
| NORMAL | 1836 | 85% |
| OVERHEAT | 108 | 5% |
| INVERTER_DOWN | 65 | 3% |
| DEGRADATION | 86 | 4% |
| SHADING | 43 | 2% |
| SENSOR_FAIL | 22 | 1% |

### Métriques Globales

- **Production totale** : ~125 000 kWh
- **Revenus totaux** : ~22 500 €
- **Rendement moyen** : 17.8%
- **Disponibilité moyenne** : 97.2%

## Validation des Données

### Tests de Cohérence

```python
# Test 1 : Production jamais négative
assert (df['power_production_kw'] >= 0).all()

# Test 2 : Production de nuit = 0
night_hours = df[(df['hour'] < 6) | (df['hour'] >= 19)]
assert (night_hours['power_production_kw'] == 0).all()

# Test 3 : Température panneau > température ambiante
assert (df['panel_temp_c'] >= df['ambient_temp_c']).all()

# Test 4 : Rendement entre 0 et 100%
assert (df['efficiency_percent'] >= 0).all()
assert (df['efficiency_percent'] <= 100).all()
```

## Sources et Références

### Données Météo France

- Moyennes 2010-2020 pour les 3 régions

### Standards Photovoltaïques

- **IEC 61215** : Standards de performance panneaux PV
- **IEC 61724** : Monitoring de systèmes PV
- **Coefficient température** : -0.35%/°C (standard industrie)

### Tarifs EDF OA (2025)

- **Tarif rachat** : 0.18 €/kWh (installations > 100 kWc)
- **Contrat** : 20 ans
- **Indexation** : Annuelle selon inflation

## Régénération du Dataset

Pour générer de nouvelles données :

```bash
cd data
python generate_dataset.py --days 30 --start-date 2025-06-01
```

Options disponibles :
- `--days` : Nombre de jours à générer (défaut: 30)
- `--start-date` : Date de début (format: YYYY-MM-DD)
- `--anomaly-rate` : Taux d'anomalies (défaut: 0.15)
- `--seed` : Seed pour reproductibilité (défaut: 42)

## Licence

**Usage éducatif uniquement** - YNOV Master 2 DevOps

Les données sont fictives mais basées sur des moyennes réelles de Météo France et des standards de l'industrie photovoltaïque.

---

**Version :** 1.0  
**Date :** Décembre 2025
