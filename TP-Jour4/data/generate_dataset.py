#!/usr/bin/env python3
"""
Générateur de dataset réaliste pour fermes solaires françaises
Usage: python generate_dataset.py --days 30 --start-date 2025-06-01
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import argparse
import math

# Configuration des fermes
FARMS = {
    'provence': {
        'name': 'Provence (Marseille)',
        'latitude': 43.3,
        'panels': 5000,
        'capacity_mw': 2.0,
        'inverters': 4,
        'location': 'Marseille'
    },
    'occitanie': {
        'name': 'Occitanie (Montpellier)',
        'latitude': 43.6,
        'panels': 3500,
        'capacity_mw': 1.4,
        'inverters': 3,
        'location': 'Montpellier'
    },
    'aquitaine': {
        'name': 'Aquitaine (Bordeaux)',
        'latitude': 44.8,
        'panels': 4200,
        'capacity_mw': 1.68,
        'inverters': 4,
        'location': 'Bordeaux'
    }
}

# Irradiance maximale par mois (W/m² à midi) - Données Météo France moyennes
IRRADIANCE_BY_MONTH = {
    'provence': [400, 500, 700, 850, 950, 1000, 980, 900, 750, 600, 450, 380],
    'occitanie': [380, 480, 680, 830, 930, 980, 960, 880, 730, 580, 430, 360],
    'aquitaine': [350, 450, 650, 800, 900, 950, 930, 850, 700, 550, 400, 330]
}

# Température ambiante moyenne par mois (°C)
TEMP_BY_MONTH = {
    'provence': [8, 10, 13, 16, 20, 24, 27, 26, 22, 17, 12, 9],
    'occitanie': [9, 11, 14, 17, 21, 25, 28, 27, 23, 18, 13, 10],
    'aquitaine': [7, 9, 12, 15, 18, 22, 24, 24, 20, 16, 11, 8]
}

# Constantes physiques
PANEL_PEAK_POWER = 400  # Watts
SYSTEM_EFFICIENCY = 0.85  # 85%
TEMP_COEFFICIENT = -0.0035  # -0.35%/°C
STC_TEMPERATURE = 25  # °C
TARIF_RACHAT = 0.18  # €/kWh


def calculate_irradiance(hour, month, farm_key, day_of_year):
    """Calcule l'irradiance selon l'heure, le mois et la localisation"""
    # Pas de soleil la nuit
    if hour < 6 or hour >= 19:
        return 0.0
    
    # Irradiance maximale du mois
    max_irr = IRRADIANCE_BY_MONTH[farm_key][month - 1]
    
    # Courbe sinusoïdale pour la journée (lever 6h, coucher 19h)
    hour_angle = math.pi * (hour - 6) / 13
    base_irradiance = max_irr * math.sin(hour_angle)
    
    # Variabilité journalière (nuages, etc.) - plus stable en été
    if month in [6, 7, 8]:  # Été
        variability = np.random.uniform(0.92, 1.05)
    elif month in [12, 1, 2]:  # Hiver
        variability = np.random.uniform(0.75, 1.10)
    else:  # Printemps/Automne
        variability = np.random.uniform(0.85, 1.08)
    
    return max(0, base_irradiance * variability)


def calculate_ambient_temp(hour, month, farm_key, day_of_year):
    """Calcule la température ambiante selon l'heure et le mois"""
    base_temp = TEMP_BY_MONTH[farm_key][month - 1]
    
    # Variation journalière (min à 6h, max à 14h)
    if 6 <= hour < 14:
        # Montée de température
        temp_variation = (hour - 6) * 1.5
    elif 14 <= hour < 20:
        # Descente de température
        temp_variation = 12 - (hour - 14) * 2
    else:
        # Nuit - plus frais
        temp_variation = -3
    
    # Variabilité aléatoire
    random_var = np.random.uniform(-2, 2)
    
    return base_temp + temp_variation + random_var


def calculate_panel_temp(ambient_temp, irradiance):
    """Calcule la température du panneau"""
    thermal_rise = (irradiance / 1000) * 25
    return ambient_temp + thermal_rise


def calculate_power(panels, irradiance, panel_temp, degradation_factor=1.0):
    """Calcule la production électrique"""
    # Facteur de température
    temp_factor = 1 + (panel_temp - STC_TEMPERATURE) * TEMP_COEFFICIENT
    
    # Production théorique
    power = panels * PANEL_PEAK_POWER * (irradiance / 1000) * SYSTEM_EFFICIENCY * temp_factor
    
    # Application de la dégradation si présente
    power *= degradation_factor
    
    return max(0, power / 1000)  # Conversion en kW


def inject_anomaly(row, farm_key, day, hour, anomaly_scenarios):
    """Injecte des anomalies selon des scénarios prédéfinis"""
    anomaly_type = 'NORMAL'
    anomaly_severity = 'none'
    degradation_factor = 1.0
    inverter_status = [1] * FARMS[farm_key]['inverters']
    
    # Scénario 1: Canicule (Provence, jours 15-17, 12h-16h)
    if farm_key == 'provence' and 15 <= day <= 17 and 12 <= hour <= 16:
        if row['panel_temp_c'] > 65:
            anomaly_type = 'OVERHEAT'
            anomaly_severity = 'high'
            degradation_factor = 0.88  # -12% production
            anomaly_scenarios.append({
                'timestamp': row['timestamp'],
                'farm': farm_key,
                'type': 'OVERHEAT',
                'severity': 'high',
                'description': 'Surchauffe panneaux durant canicule',
                'impact': '-12% production'
            })
    
    # Scénario 2: Panne onduleur (Occitanie, jour 8, 10h-14h)
    if farm_key == 'occitanie' and day == 8 and 10 <= hour <= 14:
        anomaly_type = 'INVERTER_DOWN'
        anomaly_severity = 'critical'
        inverter_status[1] = 0  # Onduleur 2 HS
        degradation_factor = 0.67  # -33% production
        anomaly_scenarios.append({
            'timestamp': row['timestamp'],
            'farm': farm_key,
            'type': 'INVERTER_DOWN',
            'severity': 'critical',
            'description': 'Onduleur 2 hors service',
            'impact': '-33% production, perte ~250€'
        })
    
    # Scénario 3: Dégradation progressive (Aquitaine, jours 5-25)
    if farm_key == 'aquitaine' and 5 <= day <= 25:
        if np.random.random() < 0.3:  # 30% du temps
            anomaly_type = 'DEGRADATION'
            anomaly_severity = 'medium'
            degradation_factor = 0.85  # -15% sur certains panneaux
    
    # Scénario 4: Ombrage matinal (Aquitaine, jours 12-14, 6h-10h)
    if farm_key == 'aquitaine' and 12 <= day <= 14 and 6 <= hour <= 10:
        anomaly_type = 'SHADING'
        anomaly_severity = 'medium'
        degradation_factor = 0.60  # -40% production
        if hour == 8:  # Log une seule fois
            anomaly_scenarios.append({
                'timestamp': row['timestamp'],
                'farm': farm_key,
                'type': 'SHADING',
                'severity': 'medium',
                'description': 'Brouillard matinal (océan)',
                'impact': '-40% production matinale'
            })
    
    # Scénario 5: Défaillance capteur (Provence, jour 20, 14h-16h)
    if farm_key == 'provence' and day == 20 and 14 <= hour <= 16:
        anomaly_type = 'SENSOR_FAIL'
        anomaly_severity = 'high'
        # Données manquantes ou erronées
        row['irradiance_wm2'] = np.nan
        row['power_production_kw'] = np.nan
        anomaly_scenarios.append({
            'timestamp': row['timestamp'],
            'farm': farm_key,
            'type': 'SENSOR_FAIL',
            'severity': 'high',
            'description': 'Capteur irradiance défaillant',
            'impact': 'Données manquantes - alerte monitoring'
        })
    
    # Anomalies aléatoires (5% du temps en journée)
    if 8 <= hour <= 17 and np.random.random() < 0.05 and anomaly_type == 'NORMAL':
        random_anomaly = np.random.choice(['OVERHEAT', 'DEGRADATION', 'SHADING'], p=[0.5, 0.3, 0.2])
        if random_anomaly == 'OVERHEAT' and row['panel_temp_c'] > 60:
            anomaly_type = 'OVERHEAT'
            anomaly_severity = 'medium'
            degradation_factor = 0.90
        elif random_anomaly == 'DEGRADATION':
            anomaly_type = 'DEGRADATION'
            anomaly_severity = 'low'
            degradation_factor = 0.92
        elif random_anomaly == 'SHADING':
            anomaly_type = 'SHADING'
            anomaly_severity = 'low'
            degradation_factor = 0.85
    
    return anomaly_type, anomaly_severity, degradation_factor, inverter_status


def generate_farm_data(farm_key, start_date, num_days, seed=42):
    """Génère les données pour une ferme"""
    np.random.seed(seed)
    farm = FARMS[farm_key]
    data = []
    anomaly_scenarios = []
    
    for day in range(num_days):
        current_date = start_date + timedelta(days=day)
        month = current_date.month
        day_of_year = current_date.timetuple().tm_yday
        daily_revenue = 0
        
        for hour in range(24):
            timestamp = current_date + timedelta(hours=hour)
            
            # Calculs de base
            irradiance = calculate_irradiance(hour, month, farm_key, day_of_year)
            ambient_temp = calculate_ambient_temp(hour, month, farm_key, day_of_year)
            panel_temp = calculate_panel_temp(ambient_temp, irradiance)
            
            # Production théorique
            theoretical_power = calculate_power(farm['panels'], irradiance, panel_temp)
            
            # Création de la ligne de données
            row = {
                'timestamp': timestamp,
                'farm_name': farm_key,
                'hour': hour,
                'day_of_year': day_of_year,
                'irradiance_wm2': round(irradiance, 1),
                'ambient_temp_c': round(ambient_temp, 1),
                'panel_temp_c': round(panel_temp, 1),
                'theoretical_power_kw': round(theoretical_power, 2)
            }
            
            # Injection d'anomalies
            anomaly_type, anomaly_severity, degradation_factor, inverter_status = inject_anomaly(
                row, farm_key, day, hour, anomaly_scenarios
            )
            
            # Production réelle avec anomalies
            actual_power = theoretical_power * degradation_factor
            
            # Si onduleur HS, production nulle
            if 0 in inverter_status:
                actual_power = 0
            
            # Calcul du rendement
            if theoretical_power > 0:
                efficiency = (actual_power / theoretical_power) * 100
            else:
                efficiency = 0
            
            # Revenus
            energy_kwh = actual_power * 1  # 1 heure
            revenue = energy_kwh * TARIF_RACHAT
            daily_revenue += revenue
            
            # Complétion de la ligne
            row.update({
                'power_production_kw': round(actual_power, 2),
                'efficiency_percent': round(efficiency, 1),
                'inverter_1_status': inverter_status[0],
                'inverter_2_status': inverter_status[1] if len(inverter_status) > 1 else 1,
                'inverter_3_status': inverter_status[2] if len(inverter_status) > 2 else 1,
                'inverter_4_status': inverter_status[3] if len(inverter_status) > 3 else 0,
                'daily_revenue_eur': round(daily_revenue, 2),
                'anomaly_type': anomaly_type,
                'anomaly_severity': anomaly_severity
            })
            
            data.append(row)
    
    return pd.DataFrame(data), anomaly_scenarios


def main():
    parser = argparse.ArgumentParser(description='Génère un dataset réaliste de fermes solaires')
    parser.add_argument('--days', type=int, default=30, help='Nombre de jours à générer')
    parser.add_argument('--start-date', type=str, default='2025-06-01', help='Date de début (YYYY-MM-DD)')
    parser.add_argument('--seed', type=int, default=42, help='Seed pour reproductibilité')
    args = parser.parse_args()
    
    start_date = datetime.strptime(args.start_date, '%Y-%m-%d')
    
    print(f"🌞 Génération du dataset de fermes solaires")
    print(f"📅 Période: {args.start_date} ({args.days} jours)")
    print(f"🎲 Seed: {args.seed}")
    print()
    
    all_anomalies = []
    
    # Génération pour chaque ferme
    for farm_key in FARMS.keys():
        print(f"⚡ Génération des données pour {FARMS[farm_key]['name']}...")
        df, anomalies = generate_farm_data(farm_key, start_date, args.days, args.seed)
        
        # Sauvegarde CSV
        filename = f"{farm_key}_data.csv"
        df.to_csv(filename, index=False)
        
        # Statistiques
        total_production = df['power_production_kw'].sum()
        total_revenue = df['daily_revenue_eur'].max()
        avg_efficiency = df['efficiency_percent'].mean()
        num_anomalies = len(df[df['anomaly_type'] != 'NORMAL'])
        
        print(f"  ✅ {len(df)} lignes générées")
        print(f"  📊 Production totale: {total_production:.0f} kWh")
        print(f"  💰 Revenus totaux: {total_revenue:.2f} €")
        print(f"  ⚙️  Rendement moyen: {avg_efficiency:.1f}%")
        print(f"  ⚠️  Anomalies: {num_anomalies} ({num_anomalies/len(df)*100:.1f}%)")
        print(f"  💾 Sauvegardé: {filename}")
        print()
        
        all_anomalies.extend(anomalies)
    
    # Sauvegarde du log des anomalies
    if all_anomalies:
        df_anomalies = pd.DataFrame(all_anomalies)
        df_anomalies.to_csv('anomalies_log.csv', index=False)
        print(f"📋 Log des anomalies sauvegardé: anomalies_log.csv ({len(all_anomalies)} événements)")
    
    print()
    print("✅ Génération terminée avec succès!")
    print()
    print("📁 Fichiers créés:")
    print("  - provence_data.csv")
    print("  - occitanie_data.csv")
    print("  - aquitaine_data.csv")
    print("  - anomalies_log.csv")


if __name__ == '__main__':
    main()

