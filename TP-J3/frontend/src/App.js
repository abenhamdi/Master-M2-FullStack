import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5009';

function App() {
  const [installations, setInstallations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [stats, setStats] = useState(null);
  const [alerts, setAlerts] = useState([]);
  const [filterType, setFilterType] = useState('all');
  const [newInstallation, setNewInstallation] = useState({
    name: '',
    type: 'solar',
    location: '',
    latitude: '',
    longitude: '',
    capacity_kw: '',
    installation_date: '',
    status: 'active'
  });
  const [showForm, setShowForm] = useState(false);

  useEffect(() => {
    fetchInstallations();
    fetchStats();
    fetchAlerts();
    // Refresh data every 30 seconds
    const interval = setInterval(() => {
      fetchInstallations();
      fetchStats();
      fetchAlerts();
    }, 30000);
    return () => clearInterval(interval);
  }, [filterType]);

  const fetchInstallations = async () => {
    try {
      setLoading(true);
      const url = filterType === 'all' 
        ? `${API_URL}/api/installations`
        : `${API_URL}/api/installations?type=${filterType}`;
      const response = await axios.get(url);
      setInstallations(response.data.data || response.data);
      setError(null);
    } catch (err) {
      setError('Erreur lors du chargement des installations');
      console.error('Error fetching installations:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchStats = async () => {
    try {
      const response = await axios.get(`${API_URL}/api/stats`);
      setStats(response.data);
    } catch (err) {
      console.error('Error fetching stats:', err);
    }
  };

  const fetchAlerts = async () => {
    try {
      const response = await axios.get(`${API_URL}/api/alerts?resolved=false`);
      setAlerts(response.data.data || []);
    } catch (err) {
      console.error('Error fetching alerts:', err);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setNewInstallation(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await axios.post(`${API_URL}/api/installations`, {
        ...newInstallation,
        capacity_kw: parseFloat(newInstallation.capacity_kw),
        latitude: newInstallation.latitude ? parseFloat(newInstallation.latitude) : null,
        longitude: newInstallation.longitude ? parseFloat(newInstallation.longitude) : null
      });
      setNewInstallation({
        name: '',
        type: 'solar',
        location: '',
        latitude: '',
        longitude: '',
        capacity_kw: '',
        installation_date: '',
        status: 'active'
      });
      setShowForm(false);
      fetchInstallations();
      fetchStats();
    } catch (err) {
      alert('Erreur lors de l\'ajout de l\'installation');
      console.error('Error adding installation:', err);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer cette installation ?')) {
      try {
        await axios.delete(`${API_URL}/api/installations/${id}`);
        fetchInstallations();
        fetchStats();
      } catch (err) {
        alert('Erreur lors de la suppression');
        console.error('Error deleting installation:', err);
      }
    }
  };

  const getTypeIcon = (type) => {
    switch(type) {
      case 'solar': return '☀️';
      case 'wind': return '💨';
      case 'hybrid': return '⚡';
      default: return '🔋';
    }
  };

  const getTypeLabel = (type) => {
    switch(type) {
      case 'solar': return 'Solaire';
      case 'wind': return 'Éolien';
      case 'hybrid': return 'Hybride';
      default: return type;
    }
  };

  const getStatusColor = (status) => {
    switch(status) {
      case 'active': return '#28a745';
      case 'maintenance': return '#ffc107';
      case 'offline': return '#dc3545';
      default: return '#6c757d';
    }
  };

  const getAlertIcon = (type) => {
    switch(type) {
      case 'critical': return '🔴';
      case 'warning': return '⚠️';
      case 'maintenance': return '🔧';
      case 'info': return 'ℹ️';
      default: return '📢';
    }
  };

  if (loading && installations.length === 0) {
    return (
      <div className="App">
        <div className="loading">Chargement des données...</div>
      </div>
    );
  }

  return (
    <div className="App">
      <header className="App-header">
        <h1>🌱 GreenWatt</h1>
        <p>Plateforme de Monitoring des Énergies Renouvelables</p>
      </header>

      {error && <div className="error">{error}</div>}

      {stats && (
        <div className="stats">
          <div className="stat-card">
            <h3>Installations</h3>
            <p className="stat-value">{stats.total_installations}</p>
            <p className="stat-detail">
              {stats.solar_count} ☀️ | {stats.wind_count} 💨 | {stats.hybrid_count} ⚡
            </p>
          </div>
          <div className="stat-card">
            <h3>Capacité Totale</h3>
            <p className="stat-value">{(stats.total_capacity_kw / 1000).toFixed(1)} MW</p>
            <p className="stat-detail">Puissance installée</p>
          </div>
          <div className="stat-card">
            <h3>Production Actuelle</h3>
            <p className="stat-value">{(stats.current_total_power_kw / 1000).toFixed(1)} MW</p>
            <p className="stat-detail">Efficacité: {stats.avg_efficiency?.toFixed(1)}%</p>
          </div>
          <div className="stat-card alert-card">
            <h3>Alertes</h3>
            <p className="stat-value">{stats.unresolved_alerts}</p>
            <p className="stat-detail">Non résolues</p>
          </div>
        </div>
      )}

      {alerts.length > 0 && (
        <div className="alerts-section">
          <h2>🚨 Alertes Actives</h2>
          <div className="alerts-list">
            {alerts.slice(0, 3).map(alert => (
              <div key={alert.id} className={`alert-item alert-${alert.alert_type}`}>
                <span className="alert-icon">{getAlertIcon(alert.alert_type)}</span>
                <div className="alert-content">
                  <strong>{alert.installation_name}</strong>
                  <p>{alert.message}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      <div className="filters">
        <button 
          className={`filter-btn ${filterType === 'all' ? 'active' : ''}`}
          onClick={() => setFilterType('all')}
        >
          Toutes
        </button>
        <button 
          className={`filter-btn ${filterType === 'solar' ? 'active' : ''}`}
          onClick={() => setFilterType('solar')}
        >
          ☀️ Solaire
        </button>
        <button 
          className={`filter-btn ${filterType === 'wind' ? 'active' : ''}`}
          onClick={() => setFilterType('wind')}
        >
          💨 Éolien
        </button>
        <button 
          className={`filter-btn ${filterType === 'hybrid' ? 'active' : ''}`}
          onClick={() => setFilterType('hybrid')}
        >
          ⚡ Hybride
        </button>
      </div>

      <div className="actions">
        <button 
          className="btn btn-primary" 
          onClick={() => setShowForm(!showForm)}
        >
          {showForm ? 'Annuler' : '➕ Ajouter une installation'}
        </button>
        <button 
          className="btn btn-secondary" 
          onClick={() => { fetchInstallations(); fetchStats(); fetchAlerts(); }}
        >
          🔄 Actualiser
        </button>
      </div>

      {showForm && (
        <div className="form-container">
          <h2>Nouvelle Installation</h2>
          <form onSubmit={handleSubmit}>
            <input
              type="text"
              name="name"
              placeholder="Nom de l'installation"
              value={newInstallation.name}
              onChange={handleInputChange}
              required
            />
            <select
              name="type"
              value={newInstallation.type}
              onChange={handleInputChange}
              required
            >
              <option value="solar">Solaire</option>
              <option value="wind">Éolien</option>
              <option value="hybrid">Hybride</option>
            </select>
            <input
              type="text"
              name="location"
              placeholder="Localisation"
              value={newInstallation.location}
              onChange={handleInputChange}
              required
            />
            <div className="form-row">
              <input
                type="number"
                name="latitude"
                placeholder="Latitude"
                value={newInstallation.latitude}
                onChange={handleInputChange}
                step="0.000001"
              />
              <input
                type="number"
                name="longitude"
                placeholder="Longitude"
                value={newInstallation.longitude}
                onChange={handleInputChange}
                step="0.000001"
              />
            </div>
            <input
              type="number"
              name="capacity_kw"
              placeholder="Capacité (kW)"
              value={newInstallation.capacity_kw}
              onChange={handleInputChange}
              step="0.01"
              required
            />
            <input
              type="date"
              name="installation_date"
              value={newInstallation.installation_date}
              onChange={handleInputChange}
            />
            <select
              name="status"
              value={newInstallation.status}
              onChange={handleInputChange}
            >
              <option value="active">Active</option>
              <option value="maintenance">Maintenance</option>
              <option value="offline">Hors ligne</option>
            </select>
            <button type="submit" className="btn btn-success">
              Ajouter
            </button>
          </form>
        </div>
      )}

      <div className="installations-grid">
        {installations.length === 0 ? (
          <p className="no-installations">Aucune installation disponible</p>
        ) : (
          installations.map(installation => (
            <div key={installation.id} className="installation-card">
              <div className="installation-header">
                <span className="type-icon">{getTypeIcon(installation.type)}</span>
                <h3>{installation.name}</h3>
                <span 
                  className="status-badge"
                  style={{ backgroundColor: getStatusColor(installation.status) }}
                >
                  {installation.status}
                </span>
              </div>
              <div className="installation-details">
                <p><strong>Type:</strong> {getTypeLabel(installation.type)}</p>
                <p><strong>📍 Localisation:</strong> {installation.location}</p>
                <p><strong>⚡ Capacité:</strong> {installation.capacity_kw} kW</p>
                {installation.installation_date && (
                  <p><strong>📅 Installation:</strong> {new Date(installation.installation_date).toLocaleDateString('fr-FR')}</p>
                )}
              </div>
              <button 
                className="btn btn-danger btn-small"
                onClick={() => handleDelete(installation.id)}
              >
                🗑️ Supprimer
              </button>
            </div>
          ))
        )}
      </div>

      <footer className="App-footer">
        <p>GreenWatt © 2025 - TP Docker & Kubernetes</p>
        <p className="api-info">API: {API_URL}</p>
      </footer>
    </div>
  );
}

export default App;
