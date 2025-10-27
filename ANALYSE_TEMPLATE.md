Template d'analyse - TP Docker Avancé
**Nom :** [Votre nom]  
**Date :** [Date]  
**Groupe :** [Votre groupe]

---
Résumé exécutif

Objectifs atteints
- [ ] Réduction de taille des images > 80%
- [ ] Implémentation d'images distroless
- [ ] Scan de sécurité réalisé
- [ ] Calcul d'impact Green IT

Gains principaux
- **Taille totale économisée :** [X] GB
- **Réduction moyenne :** [X]%
- **Vulnérabilités éliminées :** [X]

---

Partie 1 - API Node.js

1.1 Analyse comparative des tailles

| Version | Taille | Réduction | Temps de build |
|---------|--------|-----------|----------------|
| Standard | [X] MB | - | [X] min |
| Multi-stage | [X] MB | [X]% | [X] min |
| Distroless | [X] MB | [X]% | [X] min |

1.2 Analyse des vulnérabilités

| Version | Critical | High | Medium | Low | Total |
|---------|----------|------|--------|-----|-------|
| Standard | [X] | [X] | [X] | [X] | [X] |
| Multi-stage | [X] | [X] | [X] | [X] | [X] |
| Distroless | [X] | [X] | [X] | [X] | [X] |

1.3 Analyse des layers avec dive

**Screenshot de l'analyse dive pour l'image standard :**
```
[Insérer ici le screenshot de dive pour node-api:standard]
```

**Screenshot de l'analyse dive pour l'image distroless :**
```
[Insérer ici le screenshot de dive pour node-api:distroless]
```

1.4 Observations techniques

**Problèmes rencontrés :**
- [Décrire les problèmes rencontrés]

**Solutions appliquées :**
- [Décrire les solutions]

**Points d'amélioration :**
- [Décrire les améliorations possibles]

---
Partie 2 - API Python FastAPI

2.1 Analyse de l'image distroless

| Métrique | Valeur |
|----------|--------|
| Taille finale | [X] MB |
| Temps de build | [X] min |
| Vulnérabilités | [X] |
| Layers | [X] |

2.2 Test de l'application

**Tests réalisés :**
```bash
# Commandes de test
curl http://localhost:8000/health
curl http://localhost:8000/docs
```

**Résultats :**
- [ ] Application démarre correctement
- [ ] Endpoints fonctionnels
- [ ] Swagger UI accessible
- [ ] Aucun shell disponible (sécurité)

2.3 Analyse avec trivy

**Résultat du scan de sécurité :**
```
[Insérer ici le résultat du scan trivy]
```

---

☕ Partie 3 - API Java Spring Boot

3.1 Analyse de l'image distroless

| Métrique | Valeur |
|----------|--------|
| Taille finale | [X] MB |
| Temps de build | [X] min |
| Vulnérabilités | [X] |
| Layers | [X] |

3.2 Test de l'application

**Tests réalisés :**
```bash
# Commandes de test
curl http://localhost:8080/health
curl http://localhost:8080/api/orders
```

**Résultats :**
- [ ] Application démarre correctement
- [ ] Endpoints fonctionnels
- [ ] Temps de démarrage acceptable
- [ ] Aucun JDK en production

3.3 Comparaison avec image standard

**Gains obtenus :**
- Taille : [X] MB → [X] MB ([X]% réduction)
- Vulnérabilités : [X] → [X] ([X]% réduction)
- Temps de build : [X] min → [X] min

---

Partie 4 - Analyse comparative globale

4.1 Tableau récapitulatif

| Application | Standard | Distroless | Réduction | Vulnérabilités éliminées |
|-------------|----------|------------|-----------|---------------------------|
| Node.js | [X] MB | [X] MB | [X]% | [X] |
| Python | [X] MB | [X] MB | [X]% | [X] |
| Java | [X] MB | [X] MB | [X]% | [X] |
| **TOTAL** | **[X] MB** | **[X] MB** | **[X]%** | **[X]** |

4.2 Analyse des performances

**Temps de build :**
- Node.js : [X] min
- Python : [X] min
- Java : [X] min
- **Total :** [X] min

**Temps de démarrage :**
- Node.js : [X] sec
- Python : [X] sec
- Java : [X] sec

4.3 Analyse de sécurité

**Vulnérabilités critiques éliminées :** [X]
**Vulnérabilités élevées éliminées :** [X]
**Surface d'attaque réduite :** [X]%

---
Partie 5 - Impact Green IT

5.1 Calculs d'impact environnemental

**Paramètres utilisés :**
- Nombre de déploiements par jour : [X]
- Coût de stockage par GB/mois : [X]$
- Consommation énergétique par serveur : [X]W

**Économies réalisées :**

| Métrique | Valeur | Impact |
|----------|--------|--------|
| Stockage économisé | [X] GB | [X]$/mois |
| Temps de pull économisé | [X] sec/déploiement | [X] min/jour |
| Énergie économisée | [X] kWh/an | [X] kg CO2/an |
| Équivalent voiture | [X] km/an | [X] L essence/an |

5.2 ROI (Return On Investment)

**Coûts évités :**
- Stockage : [X]$/an
- Bande passante : [X]$/an
- Temps de développement : [X]h/an
- **Total :** [X]$/an

**ROI :** [X]% sur 1 an

5.3 Impact pour 100 microservices

**Projection à l'échelle :**
- Stockage total économisé : [X] GB
- Économies annuelles : [X]$
- CO2 évité : [X] kg/an
- Équivalent : [X] km en voiture

---

🔐 Partie 6 - Sécurisation avancée

6.1 .dockerignore optimisé

**Fichier créé :**
```dockerignore
#   [Insérer ici le contenu de votre .dockerignore]
```

**Impact :**
- Réduction de la taille du contexte : [X]%
- Temps de build amélioré : [X]%

6.2 Scan de sécurité automatisé

**Workflow GitHub Actions :**
- [ ] Scan Trivy intégré
- [ ] Génération SBOM
- [ ] Upload des artefacts
- [ ] Notification en cas d'échec

6.3 Bonnes pratiques appliquées

- [ ] Utilisateur non-root
- [ ] Healthcheck intégré
- [ ] Variables d'environnement sécurisées
- [ ] Secrets gérés correctement

---
Partie 7 - Questions de réflexion

7.1 Performance

**Question :** Mesurez le temps de build de chaque Dockerfile. Quelle approche est la plus rapide ?

**Réponse :**
[Votre analyse détaillée]

7.2 Sécurité

**Question :** Comparez les vulnérabilités entre image standard et distroless. Quel est le gain ?

**Réponse :**
[Votre analyse détaillée]

7.3 Debugging

**Question :** Sans shell dans distroless, comment debugger en production ?

**Réponse :**
[Vos solutions proposées]

7.4 Trade-offs

**Question :** Quels sont les inconvénients des images distroless ?

**Réponse :**
[Votre analyse des inconvénients]

#7.5 Green IT

**Question :** Calculez l'impact environnemental pour 100 microservices déployés.

**Réponse :**
[Vos calculs détaillés]

---

Partie 8 - Recommandations

8.1 Pour votre organisation

**Recommandations techniques :**
1. [Recommandation 1]
2. [Recommandation 2]
3. [Recommandation 3]

**Recommandations de processus :**
1. [Recommandation 1]
2. [Recommandation 2]
3. [Recommandation 3]

8.2 Roadmap d'implémentation

**Phase 1 (Immédiat) :**
- [ ] Action 1
- [ ] Action 2

**Phase 2 (3 mois) :**
- [ ] Action 1
- [ ] Action 2

**Phase 3 (6 mois) :**
- [ ] Action 1
- [ ] Action 2

8.3 Métriques de suivi

**KPIs à suivre :**
- Taille moyenne des images : [X] MB
- Nombre de vulnérabilités : [X]
- Temps de build moyen : [X] min
- Temps de déploiement : [X] min

---

🏆 Partie 9 - Conclusion

9.1 Objectifs atteints

- [ ] Réduction de taille > 80%
- [ ] Images distroless implémentées
- [ ] Sécurité renforcée
- [ ] Impact Green IT calculé

9.2 Apprentissages clés

1. [Apprentissage 1]
2. [Apprentissage 2]
3. [Apprentissage 3]

9.3 Perspectives d'évolution

**Prochaines étapes :**
- [ ] Action 1
- [ ] Action 2
- [ ] Action 3

---

📚 Annexes

A. Commandes utilisées

```bash
# [Insérer ici toutes les commandes importantes utilisées]
```

B. Screenshots

- [ ] Screenshot dive - Node.js standard
- [ ] Screenshot dive - Node.js distroless
- [ ] Screenshot trivy - Scan de sécurité
- [ ] Screenshot application - Tests fonctionnels

C. Logs d'erreur

```
[Insérer ici les logs d'erreur rencontrés et leurs solutions]
```

---
