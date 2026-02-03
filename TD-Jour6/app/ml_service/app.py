"""
API de Prédiction ML - Squelette à compléter
Service de classification de textes avec monitoring Prometheus
"""

from flask import Flask, request, jsonify, Response
import pickle
import numpy as np
from prometheus_client import Counter, Histogram, Gauge, generate_latest
import time
import logging

# Configuration du logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# TODO: Définir les métriques Prometheus
# Indice: Counter pour les requêtes, Histogram pour la latence, Gauge pour les actives
REQUEST_COUNT = None  # À COMPLÉTER
REQUEST_LATENCY = None  # À COMPLÉTER
PREDICTIONS_COUNT = None  # À COMPLÉTER
ACTIVE_REQUESTS = None  # À COMPLÉTER
MODEL_ACCURACY = None  # À COMPLÉTER

# Chargement du modèle (simulé)
class DummyModel:
    """Modèle de classification simple pour les tests"""
    def __init__(self):
        self.version = "v1.0"
        self.accuracy = 0.87
        
    def predict(self, text):
        """Prédiction basique basée sur la longueur du texte"""
        score = (len(text) % 100) / 100.0
        prediction = 1 if score > 0.5 else 0
        return {
            "prediction": prediction,
            "confidence": score,
            "model_version": self.version
        }

try:
    model = DummyModel()
    logger.info(f"Modèle chargé avec succès - Version: {model.version}")
except Exception as e:
    logger.error(f"Erreur lors du chargement du modèle: {e}")
    model = None


@app.before_request
def before_request():
    """Middleware avant chaque requête"""
    # TODO: Implémenter le tracking du temps et incrémenter ACTIVE_REQUESTS
    pass


@app.after_request
def after_request(response):
    """Middleware après chaque requête"""
    # TODO: Calculer la latence, mettre à jour les métriques
    # Indice: request.start_time défini dans before_request
    pass
    return response


@app.route('/health', methods=['GET'])
def health():
    """
    Health check endpoint pour Docker
    Retourne 200 si le service est prêt
    """
    if model is None:
        return jsonify({
            "status": "unhealthy",
            "reason": "Model not loaded"
        }), 503
    
    return jsonify({
        "status": "healthy",
        "model_version": model.version,
        "model_accuracy": model.accuracy
    }), 200


@app.route('/ready', methods=['GET'])
def ready():
    """
    Readiness check endpoint
    Vérifie que le service est prêt à accepter des requêtes
    """
    # TODO: Vérifier que toutes les dépendances sont disponibles
    # (base de données, modèle chargé, etc.)
    return jsonify({"status": "ready"}), 200


@app.route('/predict', methods=['POST'])
def predict():
    """
    Endpoint de prédiction
    
    Request body:
    {
        "text": "Texte à classifier"
    }
    
    Response:
    {
        "prediction": 0 ou 1,
        "confidence": 0.0 à 1.0,
        "model_version": "v1.0"
    }
    """
    try:
        # Validation de la requête
        if not request.json or 'text' not in request.json:
            return jsonify({
                "error": "Missing 'text' field in request"
            }), 400
        
        text = request.json['text']
        
        if not isinstance(text, str) or len(text) == 0:
            return jsonify({
                "error": "Text must be a non-empty string"
            }), 400
        
        # Prédiction
        if model is None:
            return jsonify({
                "error": "Model not available"
            }), 503
        
        result = model.predict(text)
        
        # TODO: Incrémenter le compteur de prédictions
        # PREDICTIONS_COUNT.labels(model_version=model.version).inc()
        
        logger.info(f"Prediction made: {result['prediction']}")
        
        return jsonify(result), 200
    
    except Exception as e:
        logger.error(f"Error during prediction: {e}")
        return jsonify({
            "error": "Internal server error",
            "details": str(e)
        }), 500


@app.route('/metrics', methods=['GET'])
def metrics():
    """
    Endpoint Prometheus metrics
    Expose les métriques au format Prometheus
    """
    # TODO: Mettre à jour la métrique d'accuracy
    # if model:
    #     MODEL_ACCURACY.labels(model_version=model.version).set(model.accuracy)
    
    return Response(generate_latest(), mimetype='text/plain')


@app.route('/info', methods=['GET'])
def info():
    """
    Informations sur le service et le modèle
    """
    if model is None:
        return jsonify({
            "error": "Model not loaded"
        }), 503
    
    return jsonify({
        "service": "ML Prediction API",
        "version": "1.0.0",
        "model": {
            "version": model.version,
            "accuracy": model.accuracy,
            "type": "text_classifier"
        },
        "endpoints": {
            "/health": "Health check",
            "/ready": "Readiness check",
            "/predict": "Make prediction (POST)",
            "/metrics": "Prometheus metrics",
            "/info": "Service information"
        }
    }), 200


@app.errorhandler(404)
def not_found(error):
    """Handler pour les routes non trouvées"""
    return jsonify({
        "error": "Endpoint not found",
        "available_endpoints": ["/health", "/ready", "/predict", "/metrics", "/info"]
    }), 404


@app.errorhandler(500)
def internal_error(error):
    """Handler pour les erreurs internes"""
    logger.error(f"Internal error: {error}")
    return jsonify({
        "error": "Internal server error"
    }), 500


if __name__ == '__main__':
    # Mode développement
    logger.info("Starting ML Prediction API in development mode")
    app.run(host='0.0.0.0', port=8000, debug=True)
