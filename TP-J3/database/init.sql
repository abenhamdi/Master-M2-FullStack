-- Script de génération de données réalistes pour GreenWatt

-- Fonction pour générer des données de production solaire réalistes
CREATE OR REPLACE FUNCTION generate_solar_metrics(
    p_installation_id INTEGER,
    p_capacity_kw DECIMAL,
    p_days_back INTEGER
) RETURNS void AS $$
DECLARE
    v_date TIMESTAMP;
    v_hour INTEGER;
    v_power_output DECIMAL;
    v_efficiency DECIMAL;
    v_temperature DECIMAL;
    v_irradiance DECIMAL;
    v_base_efficiency DECIMAL := 0.88; -- Efficacité de base 88%
BEGIN
    -- Générer des données pour les N derniers jours
    FOR day_offset IN 0..p_days_back LOOP
        v_date := NOW() - (day_offset || ' days')::INTERVAL;
        
        -- Générer des données pour chaque heure de la journée
        FOR v_hour IN 0..23 LOOP
            -- Production solaire uniquement pendant la journée (6h-20h)
            IF v_hour >= 6 AND v_hour <= 20 THEN
                -- Calcul de l'irradiance selon l'heure (courbe gaussienne)
                v_irradiance := 1000 * EXP(-POWER((v_hour - 13), 2) / 18.0) * (0.8 + RANDOM() * 0.4);
                
                -- Température varie selon l'heure
                v_temperature := 15 + (v_hour - 6) * 1.5 + RANDOM() * 5;
                
                -- Efficacité diminue avec la température
                v_efficiency := v_base_efficiency - (v_temperature - 25) * 0.004 + RANDOM() * 0.05;
                v_efficiency := GREATEST(0.70, LEAST(0.95, v_efficiency));
                
                -- Puissance de sortie basée sur l'irradiance et l'efficacité
                v_power_output := p_capacity_kw * (v_irradiance / 1000.0) * v_efficiency;
                
                -- Variation saisonnière (moins de production en hiver)
                v_power_output := v_power_output * (0.7 + 0.3 * SIN((EXTRACT(DOY FROM v_date) - 172) * PI() / 182.5));
                
                -- Ajouter des jours nuageux aléatoires (20% de chance)
                IF RANDOM() < 0.2 THEN
                    v_power_output := v_power_output * (0.3 + RANDOM() * 0.4);
                    v_irradiance := v_irradiance * (0.3 + RANDOM() * 0.4);
                END IF;
                
                INSERT INTO production_metrics (
                    installation_id, 
                    timestamp, 
                    power_output_kw, 
                    energy_produced_kwh,
                    efficiency_percent,
                    temperature_celsius,
                    solar_irradiance_wm2
                ) VALUES (
                    p_installation_id,
                    v_date + (v_hour || ' hours')::INTERVAL,
                    ROUND(v_power_output, 2),
                    ROUND(v_power_output, 2), -- Énergie = puissance pour 1h
                    ROUND(v_efficiency * 100, 2),
                    ROUND(v_temperature, 1),
                    ROUND(v_irradiance, 2)
                );
            END IF;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour générer des données de production éolienne réalistes
CREATE OR REPLACE FUNCTION generate_wind_metrics(
    p_installation_id INTEGER,
    p_capacity_kw DECIMAL,
    p_days_back INTEGER
) RETURNS void AS $$
DECLARE
    v_date TIMESTAMP;
    v_hour INTEGER;
    v_power_output DECIMAL;
    v_efficiency DECIMAL;
    v_temperature DECIMAL;
    v_wind_speed DECIMAL;
    v_wind_base DECIMAL;
BEGIN
    FOR day_offset IN 0..p_days_back LOOP
        v_date := NOW() - (day_offset || ' days')::INTERVAL;
        
        -- Vitesse de vent de base pour la journée (varie par jour)
        v_wind_base := 8 + RANDOM() * 8; -- Entre 8 et 16 m/s
        
        FOR v_hour IN 0..23 LOOP
            -- Vitesse du vent varie dans la journée
            v_wind_speed := v_wind_base + SIN(v_hour * PI() / 12) * 3 + RANDOM() * 4;
            v_wind_speed := GREATEST(0, v_wind_speed);
            
            -- Température
            v_temperature := 12 + RANDOM() * 10;
            
            -- Calcul de la puissance selon la vitesse du vent
            -- Formule simplifiée : P = 0.5 * ρ * A * v³ * Cp
            IF v_wind_speed < 3 THEN
                -- Vitesse trop faible
                v_power_output := 0;
                v_efficiency := 0;
            ELSIF v_wind_speed > 25 THEN
                -- Arrêt de sécurité
                v_power_output := 0;
                v_efficiency := 0;
            ELSIF v_wind_speed < 12 THEN
                -- Montée en puissance
                v_power_output := p_capacity_kw * POWER(v_wind_speed / 12, 3);
                v_efficiency := 70 + RANDOM() * 15;
            ELSE
                -- Puissance nominale
                v_power_output := p_capacity_kw * (0.85 + RANDOM() * 0.15);
                v_efficiency := 85 + RANDOM() * 10;
            END IF;
            
            -- Variation saisonnière (plus de vent en hiver)
            v_power_output := v_power_output * (0.8 + 0.4 * COS((EXTRACT(DOY FROM v_date) - 1) * PI() / 182.5));
            
            INSERT INTO production_metrics (
                installation_id,
                timestamp,
                power_output_kw,
                energy_produced_kwh,
                efficiency_percent,
                temperature_celsius,
                wind_speed_ms
            ) VALUES (
                p_installation_id,
                v_date + (v_hour || ' hours')::INTERVAL,
                ROUND(v_power_output, 2),
                ROUND(v_power_output, 2),
                ROUND(v_efficiency, 2),
                ROUND(v_temperature, 1),
                ROUND(v_wind_speed, 2)
            );
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour générer des alertes réalistes
CREATE OR REPLACE FUNCTION generate_realistic_alerts(
    p_days_back INTEGER
) RETURNS void AS $$
DECLARE
    v_installation_id INTEGER;
    v_date TIMESTAMP;
    v_alert_types TEXT[] := ARRAY['warning', 'critical', 'maintenance', 'info'];
    v_alert_type TEXT;
    v_messages TEXT[];
BEGIN
    -- Messages d'alerte par type
    v_messages := ARRAY[
        'Efficacité en baisse de 5% - Nettoyage recommandé',
        'Température élevée détectée sur onduleur',
        'Baisse de rendement de 3% - Vérification recommandée',
        'Maintenance préventive programmée',
        'Remplacement de composant nécessaire',
        'Turbine hors ligne - Intervention technique requise',
        'Production optimale atteinte',
        'Mise à jour firmware effectuée avec succès',
        'Connexion réseau instable',
        'Capteur de température défaillant'
    ];
    
    FOR day_offset IN 0..p_days_back LOOP
        v_date := NOW() - (day_offset || ' days')::INTERVAL;
        
        -- Générer 1-3 alertes par jour aléatoirement
        FOR i IN 1..(1 + FLOOR(RANDOM() * 3))::INTEGER LOOP
            -- Choisir une installation aléatoire
            SELECT id INTO v_installation_id 
            FROM installations 
            ORDER BY RANDOM() 
            LIMIT 1;
            
            -- Choisir un type d'alerte (plus de warnings que de critical)
            IF RANDOM() < 0.5 THEN
                v_alert_type := 'warning';
            ELSIF RANDOM() < 0.75 THEN
                v_alert_type := 'info';
            ELSIF RANDOM() < 0.9 THEN
                v_alert_type := 'maintenance';
            ELSE
                v_alert_type := 'critical';
            END IF;
            
            INSERT INTO alerts (
                installation_id,
                alert_type,
                message,
                is_resolved,
                created_at,
                resolved_at
            ) VALUES (
                v_installation_id,
                v_alert_type,
                v_messages[1 + FLOOR(RANDOM() * array_length(v_messages, 1))],
                RANDOM() < 0.7, -- 70% des alertes sont résolues
                v_date + (FLOOR(RANDOM() * 24) || ' hours')::INTERVAL,
                CASE WHEN RANDOM() < 0.7 
                    THEN v_date + (FLOOR(RANDOM() * 48) || ' hours')::INTERVAL 
                    ELSE NULL 
                END
            );
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Script principal de génération
DO $$
DECLARE
    v_installation RECORD;
    v_days_back INTEGER := 90; -- Générer 3 mois de données
BEGIN
    RAISE NOTICE 'Début de la génération de données réalistes...';
    RAISE NOTICE 'Période : % jours', v_days_back;
    
    -- Supprimer les anciennes métriques de test
    DELETE FROM production_metrics;
    DELETE FROM alerts WHERE created_at > NOW() - INTERVAL '90 days';
    
    RAISE NOTICE 'Anciennes données supprimées';
    
    -- Générer des métriques pour chaque installation
    FOR v_installation IN 
        SELECT id, type, capacity_kw, name 
        FROM installations 
        WHERE status = 'active'
    LOOP
        RAISE NOTICE 'Génération pour : % (%, % kW)', 
            v_installation.name, 
            v_installation.type, 
            v_installation.capacity_kw;
        
        IF v_installation.type = 'solar' THEN
            PERFORM generate_solar_metrics(
                v_installation.id, 
                v_installation.capacity_kw, 
                v_days_back
            );
        ELSIF v_installation.type = 'wind' THEN
            PERFORM generate_wind_metrics(
                v_installation.id, 
                v_installation.capacity_kw, 
                v_days_back
            );
        ELSIF v_installation.type = 'hybrid' THEN
            -- Pour hybride, générer les deux types
            PERFORM generate_solar_metrics(
                v_installation.id, 
                v_installation.capacity_kw * 0.6, -- 60% solaire
                v_days_back
            );
            PERFORM generate_wind_metrics(
                v_installation.id, 
                v_installation.capacity_kw * 0.4, -- 40% éolien
                v_days_back
            );
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Génération des alertes...';
    PERFORM generate_realistic_alerts(v_days_back);
    
    RAISE NOTICE '✅ Génération terminée !';
    RAISE NOTICE 'Statistiques :';
    RAISE NOTICE '  - Métriques : % lignes', (SELECT COUNT(*) FROM production_metrics);
    RAISE NOTICE '  - Alertes : % lignes', (SELECT COUNT(*) FROM alerts);
    RAISE NOTICE '  - Période : % à %', 
        (SELECT MIN(timestamp) FROM production_metrics),
        (SELECT MAX(timestamp) FROM production_metrics);
END $$;

-- Nettoyer les fonctions temporaires
DROP FUNCTION IF EXISTS generate_solar_metrics(INTEGER, DECIMAL, INTEGER);
DROP FUNCTION IF EXISTS generate_wind_metrics(INTEGER, DECIMAL, INTEGER);
DROP FUNCTION IF EXISTS generate_realistic_alerts(INTEGER);

-- Afficher un résumé
SELECT 
    'Production totale' as metric,
    ROUND(SUM(energy_produced_kwh), 2) || ' kWh' as value
FROM production_metrics
UNION ALL
SELECT 
    'Nombre de métriques',
    COUNT(*)::TEXT
FROM production_metrics
UNION ALL
SELECT 
    'Alertes non résolues',
    COUNT(*)::TEXT
FROM alerts
WHERE is_resolved = FALSE;

