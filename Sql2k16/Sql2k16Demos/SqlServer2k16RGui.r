40 + 2

sum(1:15) 

x <- 1:15 
x


y <- 10 
x + y 


rouletteWoche <- c(-120, -50, 200, -150, 210);
wochenTage <- c("Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag");
names(rouletteWoche) <- wochenTage;
rouletteWoche
#Anzahl der Tage mit Gewinn
anzahlTage <- sum(rouletteWoche > 0);
#Summe der Gewinne
rouletteTotalPlus <- sum(rouletteWoche[rouletteWoche > 0]);
#Gesamtsumme
rouletteTotal <- sum(rouletteWoche);

#Tage mit Gewinn
rouletteTagePlus <- rouletteWoche[rouletteWoche > 0];


anzahlTage
rouletteTotalPlus
rouletteTotal
rouletteTagePlus