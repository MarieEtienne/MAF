library(FactoMineR)
library(factoextra)
library(tidyverse)

####################################################
#### Exemple d'AFCM: Preception des OGM

ogm_dta <- read_delim("http://factominer.free.fr/livre/ogm.csv", delim = ";", 
                  escape_double = FALSE, locale = locale(encoding = "WINDOWS-1252"), 
                  trim_ws = TRUE)
dim(ogm_dta)
ogm_dta <- ogm_dta |> mutate(across(where(is.character), as.factor))
summary(ogm_dta)

summary(ogm_dta[,1:15])
# On regroupe des modalités très peu observées


ogm_dta <- ogm_dta %>%
  mutate(`Position Al H`= recode(`Position Al H`, 'Très Favorable'='Favorable')) |> 
  mutate(`Position Culture`= recode(`Position Culture`, 'Très Favorable'='Favorable')) 

# Résumé des variables actives dans l'ACM
summary(ogm_dta[,1:15])
# Résumé des variables supplémentaires
summary(ogm_dta[,16:21])


res <- MCA(ogm_dta, ncp = 5, quali.sup = 17:21, graph = FALSE)

fviz_eig(res, choice = "variance")

fviz_mca_ind(res, invisible = c("var", "quali.sup"), label = "none")

fviz_mca_ind(res, invisible = c("var", "quali.sup"), label = "none", select.ind = list(cos2 = 0.5))


fviz_mca_var(res, invisible = c("ind", "quali.sup"))

fviz_mca_var(res, invisible = c("ind", "quali.sup"), select.var = list(contrib = 10))

fviz_mca_var(res, col.quali.sup="#FF4D00", invisible = c( "ind", "var"))

fviz_mca(res, invisible = c( "quali.sup"), label = "var", select.ind = list(cos2 = 0.5), select.var = list(contrib = 10))


fviz_contrib(res, choice = "var", axes = 1)

fviz_contrib(res, choice = "var", axes = 2)

fviz_cos2(res, choice = "var")
