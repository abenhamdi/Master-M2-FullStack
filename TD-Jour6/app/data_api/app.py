"""
API d'Ingestion de Données - Squelette à compléter
Reçoit les données et les envoie vers Kafka
"""

from flask import Flask, request, jsonify
from kafka import KafkaProducer
import json
import logging
import os
from datetime import datetime

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Configuration Kafka
KAFKA_BOOTSTRAP_SERVERS = os.getenv('KAFKA_BOOTSTRAP_SERVERS', 'kafka:9092')
KAFKA_TOPIC = os.getenv('KAFKA_TOPIC', 'data-ingestion')

# TODO: Initialiser le producteur Kafka
# Indice: KafkaProducer avec value_serializer=lambda v: json.dumps(v).encode('utf-8')
producer = None

def init_kafka():
    """Initialise la connexion Kafka"""
    global producer
    try:
        # TODO: Créer le KafkaProducer
        # producer = KafkaProducer(...)
        logger.info(f"Connexion Kafka établie: {KAFKA_BOOTSTRAP_SERVERS}")
        return True
    except Exception as e:
        logger.error(f"Erreur connexion Kafka: {e}")
        return False


@app.route('/health', methods=['GET'])
def health():
    """Health check"""
    # TODO: Vérifier que Kafka est accessible
    return jsonify({"status": "healthy"}), 200


@app.route('/ingest', methods=['POST'])
def ingest_data():
    """
    Endpoint d'ingestion de données
    
    Request body:
    {
        "text": "Texte à traiter",
        "metadata": {
            "source": "api",
            "user_id": "123"
        }
    }
    """
    try:
        if not request.json:
            return jsonify({"error": "No JSON data provided"}), 400
        
        # Enrichir les données avec timestamp
        data = request.json
        data['timestamp'] = datetime.utcnow().isoformat()
        data['ingestion_time'] = datetime.utcnow().timestamp()
        
        # TODO: Envoyer vers Kafka
        # Indice: producer.send(KAFKA_TOPIC, value=data)
        
        logger.info(f"Data ingested: {data.get('text', '')[:50]}")
        
        return jsonify({
            "status": "success",
            "message": "Data sent to processing queue"
        }), 202
    
    except Exception as e:
        logger.error(f"Error ingesting data: {e}")
        return jsonify({"error": str(e)}), 500


@app.route('/stats', methods=['GET'])
def stats():
    """Statistiques d'ingestion"""
    # TODO: Retourner des stats (nombre de messages envoyés, etc.)
    return jsonify({
        "total_ingested": 0,
        "kafka_topic": KAFKA_TOPIC
    }), 200


if __name__ == '__main__':
    init_kafka()
    logger.info("Starting Data Ingestion API")
    app.run(host='0.0.0.0', port=5000, debug=True)
