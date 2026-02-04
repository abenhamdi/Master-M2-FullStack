const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const redis = require('redis');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5009;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// PostgreSQL connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://admin:GreenEnergy2024!@localhost:5432/greenwatt',
});

// Redis connection
let redisClient;
(async () => {
  try {
    redisClient = redis.createClient({
      url: process.env.REDIS_URL || 'redis://localhost:6379'
    });
    
    redisClient.on('error', (err) => console.log('Redis Client Error', err));
    redisClient.on('connect', () => console.log('✅ Connected to Redis'));
    
    await redisClient.connect();
  } catch (err) {
    console.error('❌ Redis connection failed:', err);
  }
})();

// Test database connection
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('❌ Database connection failed:', err);
  } else {
    console.log('✅ Connected to PostgreSQL at:', res.rows[0].now);
  }
});

// Routes
app.get('/', (req, res) => {
  res.json({ 
    message: 'Welcome to GreenWatt API - Renewable Energy Monitoring Platform',
    version: '1.0.0',
    status: 'running',
    endpoints: [
      '/api/health',
      '/api/ready',
      '/api/installations',
      '/api/installations/:id',
      '/api/production/current',
      '/api/production/history/:id',
      '/api/alerts',
      '/api/stats'
    ]
  });
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Readiness check endpoint
app.get('/api/ready', async (req, res) => {
  try {
    // Check database
    await pool.query('SELECT 1');
    
    // Check Redis
    if (redisClient && redisClient.isOpen) {
      await redisClient.ping();
    }
    
    res.status(200).json({ 
      status: 'ready',
      database: 'connected',
      cache: 'connected'
    });
  } catch (error) {
    res.status(503).json({ 
      status: 'not ready',
      error: error.message 
    });
  }
});

// Get all installations
app.get('/api/installations', async (req, res) => {
  try {
    const { type, status } = req.query;
    
    // Try to get from cache first
    const cacheKey = `installations:${type || 'all'}:${status || 'all'}`;
    if (redisClient && redisClient.isOpen) {
      const cachedData = await redisClient.get(cacheKey);
      if (cachedData) {
        console.log('📦 Returning installations from cache');
        return res.json({
          source: 'cache',
          data: JSON.parse(cachedData)
        });
      }
    }

    // Build query
    let query = 'SELECT * FROM installations WHERE 1=1';
    const params = [];
    
    if (type) {
      params.push(type);
      query += ` AND type = $${params.length}`;
    }
    
    if (status) {
      params.push(status);
      query += ` AND status = $${params.length}`;
    }
    
    query += ' ORDER BY id';
    
    const result = await pool.query(query, params);
    
    // Store in cache for 30 seconds
    if (redisClient && redisClient.isOpen) {
      await redisClient.setEx(cacheKey, 30, JSON.stringify(result.rows));
    }
    
    res.json({
      source: 'database',
      count: result.rows.length,
      data: result.rows
    });
  } catch (error) {
    console.error('Error fetching installations:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get installation by ID
app.get('/api/installations/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM installations WHERE id = $1', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Installation not found' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching installation:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create a new installation
app.post('/api/installations', async (req, res) => {
  try {
    const { name, type, location, latitude, longitude, capacity_kw, installation_date, status } = req.body;
    
    if (!name || !type || !location || !capacity_kw) {
      return res.status(400).json({ error: 'Missing required fields: name, type, location, capacity_kw' });
    }
    
    const result = await pool.query(
      `INSERT INTO installations (name, type, location, latitude, longitude, capacity_kw, installation_date, status) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
      [name, type, location, latitude, longitude, capacity_kw, installation_date, status || 'active']
    );
    
    // Invalidate cache
    if (redisClient && redisClient.isOpen) {
      const keys = await redisClient.keys('installations:*');
      if (keys.length > 0) {
        await redisClient.del(keys);
      }
    }
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating installation:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update an installation
app.put('/api/installations/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, type, location, latitude, longitude, capacity_kw, installation_date, status } = req.body;
    
    const result = await pool.query(
      `UPDATE installations 
       SET name = $1, type = $2, location = $3, latitude = $4, longitude = $5, 
           capacity_kw = $6, installation_date = $7, status = $8, updated_at = NOW() 
       WHERE id = $9 RETURNING *`,
      [name, type, location, latitude, longitude, capacity_kw, installation_date, status, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Installation not found' });
    }
    
    // Invalidate cache
    if (redisClient && redisClient.isOpen) {
      const keys = await redisClient.keys('installations:*');
      if (keys.length > 0) {
        await redisClient.del(keys);
      }
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error updating installation:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete an installation
app.delete('/api/installations/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM installations WHERE id = $1 RETURNING *', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Installation not found' });
    }
    
    // Invalidate cache
    if (redisClient && redisClient.isOpen) {
      const keys = await redisClient.keys('installations:*');
      if (keys.length > 0) {
        await redisClient.del(keys);
      }
    }
    
    res.json({ message: 'Installation deleted successfully', installation: result.rows[0] });
  } catch (error) {
    console.error('Error deleting installation:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get current production for all installations
app.get('/api/production/current', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM current_production ORDER BY id');
    
    res.json({
      count: result.rows.length,
      data: result.rows
    });
  } catch (error) {
    console.error('Error fetching current production:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get production history for a specific installation
app.get('/api/production/history/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { hours = 24 } = req.query;
    
    const result = await pool.query(
      `SELECT * FROM production_metrics 
       WHERE installation_id = $1 AND timestamp > NOW() - INTERVAL '${parseInt(hours)} hours'
       ORDER BY timestamp DESC`,
      [id]
    );
    
    res.json({
      installation_id: parseInt(id),
      period_hours: parseInt(hours),
      count: result.rows.length,
      data: result.rows
    });
  } catch (error) {
    console.error('Error fetching production history:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get all alerts
app.get('/api/alerts', async (req, res) => {
  try {
    const { resolved } = req.query;
    
    let query = `
      SELECT a.*, i.name as installation_name, i.type as installation_type
      FROM alerts a
      JOIN installations i ON a.installation_id = i.id
    `;
    
    if (resolved !== undefined) {
      query += ` WHERE a.is_resolved = ${resolved === 'true'}`;
    }
    
    query += ' ORDER BY a.created_at DESC';
    
    const result = await pool.query(query);
    
    res.json({
      count: result.rows.length,
      data: result.rows
    });
  } catch (error) {
    console.error('Error fetching alerts:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create a new alert
app.post('/api/alerts', async (req, res) => {
  try {
    const { installation_id, alert_type, message } = req.body;
    
    if (!installation_id || !alert_type || !message) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    const result = await pool.query(
      'INSERT INTO alerts (installation_id, alert_type, message) VALUES ($1, $2, $3) RETURNING *',
      [installation_id, alert_type, message]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating alert:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Resolve an alert
app.patch('/api/alerts/:id/resolve', async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await pool.query(
      'UPDATE alerts SET is_resolved = TRUE, resolved_at = NOW() WHERE id = $1 RETURNING *',
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Alert not found' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error resolving alert:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Statistics endpoint
app.get('/api/stats', async (req, res) => {
  try {
    const globalStats = await pool.query('SELECT * FROM global_statistics');
    
    const totalProduction = await pool.query(`
      SELECT 
        SUM(power_output_kw) as current_total_power_kw,
        AVG(efficiency_percent) as avg_efficiency
      FROM current_production
    `);
    
    const unresolvedAlerts = await pool.query(
      'SELECT COUNT(*) as count FROM alerts WHERE is_resolved = FALSE'
    );
    
    res.json({
      ...globalStats.rows[0],
      current_total_power_kw: parseFloat(totalProduction.rows[0].current_total_power_kw || 0),
      avg_efficiency: parseFloat(totalProduction.rows[0].avg_efficiency || 0),
      unresolved_alerts: parseInt(unresolvedAlerts.rows[0].count),
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully...');
  
  if (redisClient) {
    await redisClient.quit();
  }
  
  await pool.end();
  process.exit(0);
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 GreenWatt API running on port ${PORT}`);
  console.log(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🌱 Renewable Energy Monitoring Platform`);
});
