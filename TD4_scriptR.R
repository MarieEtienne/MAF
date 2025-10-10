library(FactoMineR)
library(factoextra)
library(tidyverse)
dta_logement_conso <- read.csv(file = "https://raw.githubusercontent.com/MarieEtienne/MAF/refs/heads/master/logement_conso2023.csv", header = TRUE)


## Sur les typographie de département en termes d'habitats

## On peut commencer par regarder département x taille des logements, on trouve un axe intéressant qui range les modalités taille de logement, sans surpise les départements parisiens sont associés aux petits logements

## Plus intéressant prendre departement x annees de construction, et d'ajouter la superficie en supplémentaires. 

dta_superficie_annee <- dta_logement_conso |> 
  group_by(Code.Département) |> 
  summarise(across(starts_with(c("Superficie","Résidences")), sum) ) |> 
  arrange(Code.Département) |> 
  column_to_rownames("Code.Département")

dta_superficie_annee  |> summarise(across(where(is.numeric),  sum))


dta_superficie_ca <- CA(dta_superficie_annee, col.sup = 7:13 )
fviz_eig(dta_superficie_ca)

### contribution des lignes

inertia.row <- tibble(Dept= row.names(dta_superficie_annee),
                      poids = dta_superficie_ca$call$marge.row, 
                      inertie = dta_superficie_ca$row$inertia,
                      percent.inertie = dta_superficie_ca$row$inertia / sum(dta_superficie_ca$row$inertia),
                      contrib_Dim1 = round(dta_superficie_ca$row$contrib[,1],2),
                      contrib_Dim2 = round(dta_superficie_ca$row$contrib[,2],2),
                      contrib_Dim3 = round(dta_superficie_ca$row$contrib[,3],2))
inertia.row |>  arrange(-contrib_Dim1)

inertia.row |>  arrange(-contrib_Dim2)



### contribution des colonnes

inertia.col <- tibble(Disc= colnames(dta_superficie_annee[,7:13]),
                      poids = dta_superficie_ca$call$marge.col, 
                      inertie = dta_superficie_ca$col$inertia,
                      percent.inertie = dta_superficie_ca$col$inertia / sum(dta_superficie_ca$col$inertia),
                      contrib_Dim1 = round(dta_superficie_ca$col$contrib[,1],2),
                      contrib_Dim2 = round(dta_superficie_ca$col$contrib[,2],2),
                      contrib_Dim3 = round(dta_superficie_ca$col$contrib[,3],2))
inertia.col |>  arrange(-contrib_Dim1)
inertia.col |>  arrange(-contrib_Dim2)


fviz_ca_col(dta_superficie_ca, select.col = list(contrib = 6)) ## select.col selectionne toutes les colonnes actives, astuce pour ne pas afficher les supplméntaires invisible ne semble pas fonctionner
fviz_ca_row(dta_superficie_ca) 
fviz_ca(dta_superficie_ca, select.row = list(cos2 = 0.95))

dta_35_coord <- dta_superficie_ca$row$coord |> as_tibble() |> 
  slice(36) |> mutate(Dept = 35) |> ## attention a cause de la corse le 35 est sur la ligne 36   
  rename_with(.cols = starts_with("Dim"), .fn = ~ paste0("coord_", .x))

dta_35_cos2 <- dta_superficie_ca$row$cos2 |> as_tibble() |> slice(36) |> mutate(Dept = 35) |> 
  rename_with(.cols = starts_with("Dim"), .fn = ~ paste0("cos2_", .x))
dta_35 <- dta_35_coord |> inner_join(dta_35_cos2)

fviz_ca(dta_superficie_ca, select.row = list(cos2 = 0.95)) + geom_label(data = dta_35, aes(x= `coord_Dim 1`, y = `coord_Dim 2`, label = "35"))
  
##qualite de la représentation du 35



`## une ACP pour la conso ?
nbr_total_logement <- dta_logement_conso |> 
  select(starts_with("Résidence"), Code.Département, Code.EPCI) |> 
  summarize(across(where(is.numeric), sum)) |> 
  rowwise() %>%
  mutate(sum = sum(c_across(starts_with("Résidence")))) |> 
  select(sum, Code.Département, Code.EPCI)

dta_logement_conso |> 
  select(Code.Département, Conso.totale..MWh., 
         Conso.totale.corrigée.de.l.aléa.climatique.à.usages.thermose, 
         Conso.totale.à.usages.thermosensibles..MWh., 
         Nb.sites, Nombre.d.habitants, Taux.de.chauffage.électrique) |> 
  inner_join(nbr_total_logement) |> 
  mutate(Nbre_logemens_elec = Taux.de.chauffage.électrique * sum) |> 
  group_by(Code.Département) |> 
  summarize(across(where(is.numeric),sum))  
  


## récupérer les coordonnées d'un déartement
dta_superficie_ca$row$coord[,1] 




