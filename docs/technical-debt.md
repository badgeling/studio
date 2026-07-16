# Suivi de la Dette Technique

Ce document suit les éléments de dette technique dans le projet STUdio.

## Catégories

### Haute Priorité
Éléments à traiter rapidement car ils impactent la maintenabilité, la sécurité ou les performances.

### Priorité Moyenne
Éléments à traiter dans un futur proche mais non bloquants.

### Faible Priorité
Éléments qui peuvent être différés mais ne doivent pas être oubliés.

---

## Dette Technique Actuelle

### Haute Priorité

#### [DEBT-001] Mise à jour de la version Java
- **Module :** Tous les modules
- **Description :** Certains modules (agent, metadata) utilisent encore Java 8 alors que le parent utilise Java 11
- **Impact :** Version Java incohérente entre les modules, problèmes de compatibilité potentiels
- **Effort :** Moyen
- **Solution proposée :** Mettre à jour tous les modules vers Java 11 de manière cohérente

#### [DEBT-002] Mise à jour des dépendances
- **Module :** Tous les modules
- **Description :** Plusieurs dépendances sont obsolètes (gson 2.8.5, commons-io 2.16.1, etc.)
- **Impact :** Vulnérabilités de sécurité potentielles, fonctionnalités manquantes
- **Effort :** Moyen
- **Solution proposée :** Exécuter le workflow de mise à jour des dépendances et passer aux dernières versions stables

#### [DEBT-003] Ajout de tests unitaires
- **Module :** Tous les modules
- **Description :** Faible couverture de tests sur l'ensemble du code
- **Impact :** Risque de régressions, refactoring difficile
- **Effort :** Élevé
- **Solution proposée :** Implémenter des tests unitaires complets pour la fonctionnalité principale

### Priorité Moyenne

#### [DEBT-004] Migration de React 16 vers React 18
- **Module :** web-ui
- **Description :** Le frontend utilise React 16.8.6 qui est obsolète
- **Impact :** Fonctionnalités React 18 manquantes, problèmes de sécurité
- **Effort :** Moyen
- **Solution proposée :** Mettre à jour React vers la dernière version et mettre à jour les composants

#### [DEBT-005] Remplacement des bibliothèques dépréciées
- **Module :** web-ui
- **Description :** Certaines bibliothèques frontend peuvent être dépréciées ou non maintenues
- **Impact :** Problèmes de compatibilité future
- **Effort :** Moyen
- **Solution proposée :** Auditer et remplacer les bibliothèques dépréciées

#### [DEBT-006] Amélioration de la gestion des erreurs
- **Module :** Tous les modules
- **Description :** Gestion des erreurs incohérente dans l'ensemble du code
- **Impact :** Mauvaise expérience utilisateur, débogage difficile
- **Effort :** Moyen
- **Solution proposée :** Implémenter une stratégie cohérente de gestion des erreurs

### Faible Priorité

#### [DEBT-007] Documentation du code
- **Module :** Tous les modules
- **Description :** Commentaires Javadoc manquants ou incomplets
- **Impact :** Intégration difficile pour les nouveaux développeurs
- **Effort :** Faible
- **Solution proposée :** Ajouter une documentation Javadoc complète aux API publiques

#### [DEBT-008] Refactorisation des classes volumineuses
- **Module :** web-ui, core
- **Description :** Certaines classes sont devenues trop volumineuses et complexes
- **Impact :** Maintenance difficile, violation du SRP
- **Effort :** Moyen
- **Solution proposée :** Découper les classes volumineuses en classes plus petites et ciblées

---

## Métriques de Dette

### Couverture de Code
- **Actuel :** Inconnu (à mesurer)
- **Objectif :** 70% minimum
- **Statut :** À mesurer

### Santé des Dépendances
- **Vulnérabilités :** À scanner
- **Dépendances obsolètes :** À identifier
- **Statut :** Workflow configuré

### Qualité du Code
- **Problèmes SpotBugs :** À mesurer
- **Violations PMD :** À mesurer
- **Statut :** Workflow configuré

---

## Stratégie de Réduction de la Dette

1. **Hebdomadaire :** Revoir et prioriser les nouveaux éléments de dette
2. **Planification de sprint :** Allouer 20% de la capacité du sprint à la réduction de la dette
3. **Critères de release :** Aucun élément de dette haute priorité dans la branche de release
4. **Vérifications automatisées :** Workflows CI/CD pour empêcher l'accumulation de nouvelle dette

---

## Références

- [Workflow de Dette Technique](../.github/workflows/technical-debt.yml)
- [Documentation de l'Architecture](architecture.md)
