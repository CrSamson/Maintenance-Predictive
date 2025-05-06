# Projet Maintenance Prédictive des Pompes

Ce projet consiste à utiliser des techniques avancées d'apprentissage statistique pour déterminer efficacement quelles pompes nécessitent un entretien préventif après 6 mois d'utilisation, optimisant ainsi la rentabilité de l'entretien prédictif.

## Objectif

L'objectif principal est d'identifier proactivement les pompes nécessitant une maintenance anticipée pour maximiser le profit net (revenu du liquide extrait moins les coûts d'entretien et d'énergie).

## Données utilisées

* **repairs.csv** : Informations historiques sur les réparations effectuées.
* **sensors-study.csv** : Données de capteurs historiques utilisées pour l'analyse exploratoire.
* **sensors-score.csv** : Données actuelles pour prédire les besoins futurs en maintenance.

## Méthodologie

1. **Prétraitement et nettoyage des données** : Reshape, gestion des NA et création de variables d'efficacité.
2. **Analyse exploratoire (EDA)** : Identification des tendances significatives via ANOVA et visualisation de l'efficacité moyenne mensuelle.
3. **Création d'une cible binaire** : Définition d'une variable indiquant la nécessité d'un entretien préventif.
4. **Sélection des variables importantes** : Utilisation du modèle Random Forest pour déterminer les prédicteurs clés.
5. **Modélisation Random Forest** : Entraînement du modèle prédictif et évaluation de ses performances (confusion matrix, précision).
6. **Prédiction et sélection finale** : Classement des pompes par probabilité de nécessiter une intervention et sélection des 20 000 premières pompes à entretenir.

## Technologies Utilisées

* R (Caret, dplyr, tidyr, ggplot2, randomForest)
* Analyse statistique (ANOVA)
* Modélisation prédictive (Random Forest)

## Exécution du projet

* Installer les packages requis (`caret`, `randomForest`, etc.)
* Charger les données CSV et exécuter le script fourni pour obtenir les prédictions finales.

Ce projet est structuré pour être facilement compréhensible, reproductible, et adapté à des contextes industriels réels.
