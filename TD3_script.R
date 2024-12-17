library(FactoMineR) ## pour AFC et ACM
library(factoextra) ## pour des jolies visaulisation, adaptables
library(tidyverse)  ## pour la manipulation tidy

### Exo université
# Importation des donnees
univ_dta <- read.table(file = "https://husson.github.io/img/universite.csv",
                   sep=";", dec=".", header = T, row.names = 1)


## ATtention aux marges !!!
# les données sont déja sous forme de table de contingence
## calcul des marges
## marge colonnes
colSums(univ_dta)
univ_dta |>  
  summarise(across(where(is.numeric), sum)) 


### version tidy
univ_dta |>   
  select(Licence.F, Licence.H, Master.F, Master.H, Doctorat.F, Doctorat.H) |> 
  mutate(marges_lignes = rowSums(across(where(is.numeric)))) |> 
  select(marges_lignes) |> 
  mutate(freq = marges_lignes/sum(marges_lignes))


# test du chi2 pour savoir si on peut espérer voir une structure
## attention les étudiants n'ont pas eu le cours sur le tets. 
## j'ai expliqué rapidement en TD ce qu'téait le test du chi2, mais ce n'est sans doute pas très clair pour tous.
chisq.test(univ_dta[,1:6])


chisq.test(univ_dta[,9:11])

## AFC sur le croisement Discipline x (Niveau-Genre)
univ_ca <- CA(univ_dta, col.sup=7:12, graph = FALSE)
summary(univ_ca, nb.dec = 2, nbelements=2)

## Visualisation des valeurs propres
### Est ce normal qu'il n'y ait que 5 dimensions ? --> nombre max dimension = min(I-1, J-1)
fviz_eig(univ_ca, addlabels=FALSE,  choice = "variance")
### essentiellement un axe important


## Visualisation des profils lignes
fviz_ca_row(univ_ca)
fviz_ca_row(univ_ca, select.row = list(cos2 = 0.6),axes = c(2,3))



inertia.row <- tibble(Disc= row.names(univ_dta),
                      poids = univ_ca$call$marge.row, 
                      inertie = univ_ca$row$inertia,
                      percent.inertie = univ_ca$row$inertia / sum(univ_ca$row$inertia),
                      contrib_Dim1 = round(univ_ca$row$contrib[,1],2),
                      contrib_Dim2 = round(univ_ca$row$contrib[,2],2),
                      contrib_Dim3 = round(univ_ca$row$contrib[,3],2))
inertia.row |>  arrange(-contrib_Dim2)

## seulemnt les 5 plus contributifs aux axes
fviz_ca_row(univ_ca, select.row = list(cos2 = 5)) 

## Visualisation des profils col
fviz_ca(univ_ca) 

## Visualisation jointe
fviz_ca_col(univ_ca, select.row = list(cos2 = 5)) 


## ---------------------------
## exo credits

# Importation des données
credit <- read.csv("https://husson.github.io/img/credit.csv", sep = ";")

# Statistiques descriptives (vérification de l'importation des données)

summary(credit)

# Conversion de "Age" en variable qualitative
credit <- credit |> 
  mutate(across(where(is.character), as.factor))

# Graphiques univariés pour détecter les modalités rares
credit |> 
  pivot_longer(cols = everything(), names_to = "variable", values_to = "value") |> 
  group_by(variable, value) |>  
  summarise(count = n()) |> 
  ggplot(aes(x = value, y = count, fill = variable)) +
  geom_bar(stat = "identity") +
  facet_wrap(~variable, scales = "free", ncol = 3) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Distribution des variables", x = NULL, y = "Fréquence")

# Regroupement d'une modalité rare dans "Marche"
credit <- credit |> 
  mutate(Marche = fct_recode(Marche, Moto = "Side-car"))

# Analyse des correspondances multiples (MCA)
res.mca <- MCA(credit, quali.sup = 6:11, graph = FALSE)

# Choix du nombre d'axes via un scree plot
fviz_eig(res.mca, addlabels = TRUE,  choice = "eigenvalue") +
  labs(title = "Variance expliquée par dimension")

# Visualisation des individus
fviz_mca_ind(res.mca, repel = TRUE, 
             label = "none", 
             habillage = "Marche", 
             addEllipses = TRUE, 
             ellipse.type = "confidence") +
  labs(title = "Représentation des individus (MCA)")

# Visualisation des variables
fviz_mca_var(res.mca, repel = TRUE) +
  labs(title = "Représentation des variables (MCA)")

# Visualisation des modalités qualitatives supplémentaires
fviz_mca_var(res.mca, col.var = "cos2", gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"), 
             select.var = list(cos2 = 0.2)) +
  labs(title = "Modalités les plus corrélées aux axes")

# Plan factoriel 3/4 pour les individus
fviz_mca_ind(res.mca, axes = c(3, 4), repel = TRUE, 
             habillage = "Marche", addEllipses = TRUE) +
  labs(title = "Plan factoriel 3/4 des individus")

# Plan factoriel 3/4 pour les variables
fviz_mca_var(res.mca, axes = c(3, 4), repel = TRUE) +
  labs(title = "Plan factoriel 3/4 des variables")

# Description des axes (corrélation des variables avec les axes)
desc_axes <- dimdesc(res.mca, axes = 1:4)
