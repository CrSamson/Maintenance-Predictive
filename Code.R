# Clear the environment
rm(list = ls())

# Charger les bibliothèques nécessaires
library(rpart)
library(ggplot2)
library(dplyr)
library(tidyr)

#Lire les données
df_repairs <- read.csv("C:/Users/samso/OneDrive/Bureau/Apprentissage statistique/Devoir 1/repairs.csv")
df_sensors_score <- read.csv("C:/Users/samso/OneDrive/Bureau/Apprentissage statistique/Devoir 1/sensors-score.csv")
df_sensors_study<- read.csv("C:/Users/samso/OneDrive/Bureau/Apprentissage statistique/Devoir 1/sensors-study.csv")

#Vérifier la qualité des raisons de maintenance pour la colonne de 6 et 12 mois
print(table(df_repairs$Bill6))
print(table(df_repairs$Bill12))
#Les raisons semblent être assez uniformes. Il faut vérifier les valeurs manquantes
print(sum(is.na(df_repairs$Bill6))) # 250 valeurs NA dans la colonne Bill6
print(sum(is.na(df_repairs$Cost6))) # 250 valeurs NA dans la colonne Cost6
#Valider que les valeurs manquantes pour Bill6 et Cost6 sont dans les mêmes lignes
print(sum(is.na(df_repairs$Cost6) == is.na(df_repairs$Bill6))) # Les lignes vides de Bill6 et Cost6 sont cohérentes

#Remplacer les NAs dans le Cost6 par 0
df_repairs$Cost6[is.na(df_repairs$Cost6)] <- 0

#Merge sensors_study et repairs en utilisant la colonne ID
df_study <- merge(df_sensors_study, df_repairs, by = "ID")
df_study <- df_study[order(df_study$Month), ]

# Statistiques descriptives pour les principales variables portant sur le dataframe créé précedemment.
summary_stats_study <- df_study %>%
  summarise(
    Mean_Volume = mean(Volume, na.rm = TRUE),
    Mean_Energy = mean(Energy, na.rm = TRUE),
    SD_Volume = sd(Volume, na.rm = TRUE),
    SD_Energy = sd(Energy, na.rm = TRUE),
    Mean_PSD500 = mean(PSD500, na.rm = TRUE),
    Mean_PSD750 = mean(PSD750, na.rm = TRUE)
  )
print(summary_stats_study)

# Calcul des statistiques descriptives par ID
stats_by_pump <- df_study %>%
  group_by(ID) %>%
  summarise(
    Mean_Volume = mean(Volume, na.rm = TRUE),
    Median_Volume = median(Volume, na.rm = TRUE),
    Min_Volume = min(Volume, na.rm = TRUE),
    Max_Volume = max(Volume, na.rm = TRUE),
    SD_Volume = sd(Volume, na.rm = TRUE),
    
    Mean_Energy = mean(Energy, na.rm = TRUE),
    Median_Energy = median(Energy, na.rm = TRUE),
    Min_Energy = min(Energy, na.rm = TRUE),
    Max_Energy = max(Energy, na.rm = TRUE),
    SD_Energy = sd(Energy, na.rm = TRUE),
  )

# Afficher un aperçu des résultats
print(head(stats_by_pump))

#Créer une colonne "efficience" qui est le rapport du Volume / energy
df_study$Efficiency <- df_study$Volume / df_study$Energy

# Calcul des statistiques descriptives de 'Efficiency' par ID
Efficiency_stats_by_pump <- df_study %>%
  group_by(ID) %>%
  summarise(
    Mean_Efficiency = mean(Efficiency, na.rm = TRUE),
    Median_Efficiency = median(Efficiency, na.rm = TRUE),
    Min_Efficiency = min(Efficiency, na.rm = TRUE),
    Max_Efficiency = max(Efficiency, na.rm = TRUE),
    SD_Efficiency = sd(Efficiency, na.rm = TRUE)
  )

# Afficher un aperçu des résultats
print(head(Efficiency_stats_by_pump))

# Visualiser la distribution globale de l'efficience des Pompes ID
ggplot(df_study, aes(x = Efficiency)) +
  geom_histogram(aes(y = ..density..), bins = 30, fill = "blue", color = "white", alpha = 0.7) +
  geom_density(color = "darkorange", size = 1.5) +
  # Ajout de la moyenne sous forme de ligne verticale
  geom_vline(aes(xintercept = mean(Efficiency, na.rm = TRUE)),
             color = "red", linetype = "dashed", size = 1, alpha = 0.8) +
  # Labels et titre
  labs(title = "Distribution Globale de l'Efficience des Pompes",
       x = "Efficience (Volume / Energy)",
       y = "Densité") +
  # Thème
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(size = 12),
    legend.position = "none"
  )

#Quelles sont les pompes qui ont un ratio d'efficience inférieur à 2 ?
less_efficient_pumps = subset(df_study, Efficiency < 2 )
print(n_distinct(less_efficient_pumps$ID)) # 42 pompes qui ont une efficience inférieure à 2
print(unique(less_efficient_pumps$ID)) # Pour maximiser le profit il faut porter attention à ces pompes

# Reformater les données : créer une séquence temporelle
reshaped_data <- df_study %>%
  pivot_wider(
    id_cols = ID,  # Identifier chaque pompe par son ID
    names_from = Month,  # Créer des colonnes pour chaque mois
    values_from = c(Volume, Energy, PSD500, PSD750, PSD1000, PSD1250, PSD1500, PSD1750, PSD2000, PSD2250, PSD2500, PSD2750, PSD3000),
    names_sep = "_Month"  # Ajouter un suffixe de mois aux noms des colonnes
  )

# Vérifier le résultat
print(head(reshaped_data))


# Filtrer les données pour l'ID == 1
data_id_2 <- df_study %>%
  filter(ID == 2)

# Créer un graphique en ligne
ggplot(data_id_2, aes(x = Month, y = Efficiency)) +
  geom_line(color = "blue", size = 1) +  # Ligne bleue
  geom_point(color = "red", size = 2) +  # Points rouges pour les mois
  labs(
    title = "Évolution de l'Efficience pour la Pompe ID 1",
    x = "Mois",
    y = "Efficience (Volume / Energy)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold")
  )

# Ajuster un modèle de régression linéaire
lm_model <- lm(Efficiency ~ Month, data = data_id_2)

# Résumé du modèle pour obtenir la pente
summary(lm_model)

# Extraire la pente (coefficient de Month)
slope <- coef(lm_model)["Month"]
print(paste("La pente de la ligne est :", slope))

# Filtrer les données pour l'ID == 441
data_id_1 <- df_study %>%
  filter(ID == 1)

# Créer un graphique en ligne
ggplot(data_id_1, aes(x = Month, y = Efficiency)) +
  geom_line(color = "blue", size = 1) +  # Ligne bleue
  geom_point(color = "red", size = 2) +  # Points rouges pour les mois
  labs(
    title = "Évolution de l'Efficience pour la Pompe ID 1",
    x = "Mois",
    y = "Efficience (Volume / Energy)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold")
  )

# Ajuster un modèle de régression linéaire
lm_model <- lm(Efficiency ~ Month, data = data_id_1)

# Résumé du modèle pour obtenir la pente
summary(lm_model)

# Extraire la pente (coefficient de Month)
slope <- coef(lm_model)["Month"]
print(paste("La pente de la ligne est :", slope))

# Calcul de la variation moyenne de l'efficience
data_id_1 <- data_id_1 %>%
  arrange(Month) %>%  # S'assurer que les mois sont dans l'ordre
  mutate(Diff_Efficiency = Efficiency - lag(Efficiency),
         Diff_Month = Month - lag(Month))

# Calculer la pente moyenne
average_slope <- mean(data_id_1$Diff_Efficiency / data_id_1$Diff_Month, na.rm = TRUE)
print(paste("La pente moyenne entre les mois est :", average_slope))

#====================================================================================================

# Calculer la pente moyenne pour chaque pompe ID
average_slope_by_id <- df_study %>%
  arrange(ID, Month) %>%  # S'assurer que les données sont triées par ID et par mois
  group_by(ID) %>%  # Grouper par pompe ID
  mutate(
    Diff_Efficiency = Efficiency - lag(Efficiency),  # Variation d'efficience
    Diff_Month = Month - lag(Month)  # Variation du mois (devrait être 1 si les données sont cohérentes)
  ) %>%
  summarise(
    Average_Slope = mean(Diff_Efficiency / Diff_Month, na.rm = TRUE)  # Moyenne des pentes
  )

# Afficher les résultats
print(head(average_slope_by_id))

ggplot(average_slope_by_id, aes(x = Average_Slope)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white", alpha = 0.7) +
  labs(
    title = "Distribution des Pentes Moyennes de l'efficience des Pompes",
    x = "Pente Moyenne",
    y = "Fréquence"
  ) +
  theme_minimal()

moyenne_pentes = mean(average_slope_by_id$Average_Slope)
pente_positive = subset(average_slope_by_id, Average_Slope > moyenne_pentes)
print(nrow(pente_positive))

pompes_no_6months = subset(df_repairs, Cost6 == 0)
pompes_with_6months = subset(df_repairs, Cost6 > 0)

pente_positive_no6months = sum(pompes_no_6months$ID %in% pente_positive$ID)
pente_positive_with6months = sum(pompes_with_6months$ID %in% pente_positive$ID)





