"""
Data Preprocessor Worker - Squelette à compléter
Consomme depuis Kafka, traite les données, stocke dans PostgreSQL
"""

from kafka import KafkaConsumer
import psycopg2
import json
import logging
import os
import time
import re
from datetime import datetime

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Configuration
KAFKA_BOOTSTRAP_SERVERS = os.getenv('KAFKA_BOOTSTRAP_SERVERS', 'kafka:9092')
KAFKA_TOPIC = os.getenv('KAFKA_TOPIC', 'data-ingestion')
KAFKA_GROUP_ID = os.getenv('KAFKA_GROUP_ID', 'preprocessor-group')

DB_HOST = os.getenv('DB_HOST', 'postgres')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'mldata')
DB_USER = os.getenv('DB_USER', 'postgres')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'postgres')


def connect_db():
    """Connexion à PostgreSQL"""
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD
        )
        logger.info("Connexion PostgreSQL établie")
        return conn
    except Exception as e:
        logger.error(f"Erreur connexion DB: {e}")
        return None


def init_database(conn):
    """Initialise le schéma de la base de données"""
    try:
        cursor = conn.cursor()
        
        # TODO: Créer la table pour stocker les données traitées
        # Indice: colonnes - id, raw_text, processed_text, word_count, char_count, timestamp
        create_table_query = """
        CREATE TABLE IF NOT EXISTS processed_data (
            id SERIAL PRIMARY KEY,
            -- TODO: Ajouter les colonnes nécessaires
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        """
        
        cursor.execute(create_table_query)
        conn.commit()
        cursor.close()
        
        logger.info("Schéma de base de données initialisé")
    except Exception as e:
        logger.error(f"Erreur initialisation DB: {e}")


def preprocess_text(text):
    """
    Prétraitement du texte
    TODO: Implémenter le nettoyage et le preprocessing
    """
    # Convertir en minuscules
    processed = text.lower()
    
    # TODO: Ajouter plus de preprocessing
    # - Supprimer les caractères spéciaux
    # - Supprimer les espaces multiples
    # - Tokenisation basique
    
    return {
        "processed_text": processed,
        "word_count": len(processed.split()),
        "char_count": len(processed)
    }


def store_processed_data(conn, data):
    """Stocke les données traitées dans PostgreSQL"""
    try:
        cursor = conn.cursor()
        
        # TODO: Insérer les données dans la table
        insert_query = """
        INSERT INTO processed_data (raw_text, processed_text, word_count, char_count)
        VALUES (%s, %s, %s, %s)
        RETURNING id;
        """
        
        # cursor.execute(insert_query, (...))
        # conn.commit()
        
        # record_id = cursor.fetchone()[0]
        cursor.close()
        
        # logger.info(f"Données stockées avec ID: {record_id}")
        # return record_id
    except Exception as e:
        logger.error(f"Erreur stockage données: {e}")
        conn.rollback()
        return None


def process_message(message, conn):
    """Traite un message Kafka"""
    try:
        data = json.loads(message.value.decode('utf-8'))
        
        logger.info(f"Traitement du message: {data.get('text', '')[:50]}")
        
        # Preprocessing
        raw_text = data.get('text', '')
        processed = preprocess_text(raw_text)
        
        # Préparation pour le stockage
        processed_data = {
            "raw_text": raw_text,
            "processed_text": processed['processed_text'],
            "word_count": processed['word_count'],
            "char_count": processed['char_count'],
            "metadata": data.get('metadata', {})
        }
        
        # TODO: Stocker dans PostgreSQL
        # store_processed_data(conn, processed_data)
        
        logger.info("Message traité avec succès")
        
    except Exception as e:
        logger.error(f"Erreur traitement message: {e}")


def main():
    """Boucle principale du worker"""
    logger.info("Démarrage du preprocessor worker")
    
    # Attendre que les services soient prêts
    time.sleep(10)
    
    # Connexion DB
    conn = connect_db()
    if conn is None:
        logger.error("Impossible de se connecter à la DB, arrêt")
        return
    
    init_database(conn)
    
    # TODO: Créer le consumer Kafka
    # Indice: KafkaConsumer avec value_deserializer
    try:
        consumer = KafkaConsumer(
            KAFKA_TOPIC,
            bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
            group_id=KAFKA_GROUP_ID,
            auto_offset_reset='earliest',
            enable_auto_commit=True
        )
        
        logger.info(f"Consumer Kafka démarré, écoute sur {KAFKA_TOPIC}")
        
        # Boucle de consommation
        for message in consumer:
            process_message(message, conn)
    
    except Exception as e:
        logger.error(f"Erreur consumer Kafka: {e}")
    
    finally:
        if conn:
            conn.close()
        logger.info("Worker arrêté")


if __name__ == '__main__':
    main()
