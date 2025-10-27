package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import java.time.LocalDateTime;
import java.util.*;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.lang.management.RuntimeMXBean;

/**
 * Application Spring Boot optimisée pour Docker distroless
 * Master 2 Full Stack - Docker Optimization
 */
@SpringBootApplication
@RestController
@RequestMapping("/api")
public class DemoApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
    
    /**
     * Endpoint de santé de l'application
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        RuntimeMXBean runtimeBean = ManagementFactory.getRuntimeMXBean();
        MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
        
        Map<String, Object> health = new HashMap<>();
        health.put("status", "healthy");
        health.put("timestamp", LocalDateTime.now().toString());
        health.put("uptime", runtimeBean.getUptime());
        health.put("memory", Map.of(
            "used", memoryBean.getHeapMemoryUsage().getUsed(),
            "max", memoryBean.getHeapMemoryUsage().getMax(),
            "committed", memoryBean.getHeapMemoryUsage().getCommitted()
        ));
        health.put("version", "1.0.0");
        health.put("javaVersion", System.getProperty("java.version"));
        
        return ResponseEntity.ok(health);
    }
    
    /**
     * Récupérer la liste des commandes
     */
    @GetMapping("/orders")
    public ResponseEntity<Map<String, Object>> getOrders() {
        List<Map<String, Object>> orders = Arrays.asList(
            Map.of("id", 1, "total", 99.99, "customer", "Alice", "status", "completed"),
            Map.of("id", 2, "total", 149.99, "customer", "Bob", "status", "pending"),
            Map.of("id", 3, "total", 79.99, "customer", "Charlie", "status", "shipped"),
            Map.of("id", 4, "total", 299.99, "customer", "Diana", "status", "completed")
        );
        
        Map<String, Object> response = new HashMap<>();
        response.put("orders", orders);
        response.put("total", orders.size());
        response.put("timestamp", LocalDateTime.now().toString());
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Récupérer une commande par son ID
     */
    @GetMapping("/orders/{id}")
    public ResponseEntity<Map<String, Object>> getOrder(@PathVariable Long id) {
        Map<String, Object> order = Map.of(
            "id", id,
            "total", 99.99,
            "customer", "Alice",
            "status", "completed",
            "items", Arrays.asList(
                Map.of("name", "Laptop", "price", 99.99, "quantity", 1)
            ),
            "timestamp", LocalDateTime.now().toString()
        );
        
        return ResponseEntity.ok(order);
    }
    
    /**
     * Récupérer la liste des produits
     */
    @GetMapping("/products")
    public ResponseEntity<Map<String, Object>> getProducts() {
        List<Map<String, Object>> products = Arrays.asList(
            Map.of("id", 1, "name", "Laptop", "price", 999.99, "category", "Electronics"),
            Map.of("id", 2, "name", "Mouse", "price", 29.99, "category", "Accessories"),
            Map.of("id", 3, "name", "Keyboard", "price", 79.99, "category", "Accessories"),
            Map.of("id", 4, "name", "Monitor", "price", 299.99, "category", "Electronics")
        );
        
        Map<String, Object> response = new HashMap<>();
        response.put("products", products);
        response.put("total", products.size());
        response.put("timestamp", LocalDateTime.now().toString());
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Récupérer les métriques système
     */
    @GetMapping("/metrics")
    public ResponseEntity<Map<String, Object>> getMetrics() {
        RuntimeMXBean runtimeBean = ManagementFactory.getRuntimeMXBean();
        MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
        
        Map<String, Object> metrics = new HashMap<>();
        metrics.put("timestamp", LocalDateTime.now().toString());
        metrics.put("uptime", runtimeBean.getUptime());
        metrics.put("memory", Map.of(
            "heapUsed", memoryBean.getHeapMemoryUsage().getUsed(),
            "heapMax", memoryBean.getHeapMemoryUsage().getMax(),
            "heapCommitted", memoryBean.getHeapMemoryUsage().getCommitted(),
            "nonHeapUsed", memoryBean.getNonHeapMemoryUsage().getUsed(),
            "nonHeapMax", memoryBean.getNonHeapMemoryUsage().getMax()
        ));
        metrics.put("system", Map.of(
            "javaVersion", System.getProperty("java.version"),
            "osName", System.getProperty("os.name"),
            "osVersion", System.getProperty("os.version"),
            "availableProcessors", Runtime.getRuntime().availableProcessors()
        ));
        
        return ResponseEntity.ok(metrics);
    }
    
    /**
     * Page d'accueil de l'API
     */
    @GetMapping("/")
    public ResponseEntity<Map<String, Object>> root() {
        Map<String, Object> info = new HashMap<>();
        info.put("message", "Spring Boot Distroless Demo - Master 2 Full Stack");
        info.put("version", "1.0.0");
        info.put("endpoints", Map.of(
            "health", "/api/health",
            "orders", "/api/orders",
            "products", "/api/products",
            "metrics", "/api/metrics",
            "actuator", "/actuator"
        ));
        info.put("timestamp", LocalDateTime.now().toString());
        
        return ResponseEntity.ok(info);
    }
}
