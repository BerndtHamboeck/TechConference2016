--optinanl: create a new database IntegrateR
USE [IntegrateR]

execute sp_execute_external_script
  @language = N'R'
, @script = N' mysum <- 40 + 2;
               OutputDataSet <- data.frame(mysum);'
, @input_data_1 = N''
WITH RESULT SETS (([col] int NOT NULL));


execute sp_execute_external_script
  @language = N'R'
, @script = N' mysum <- sum(1:15);
               OutputDataSet <- data.frame(mysum);'
, @input_data_1 = N''
WITH RESULT SETS (([col] int NOT NULL));

execute sp_execute_external_script
  @language = N'R'
, @script = N' x <- array(1:15); y <- 10;
               OutputDataSet <- data.frame(x + y);'
, @input_data_1 = N''
WITH RESULT SETS (([col] int NOT NULL));

execute sp_execute_external_script
  @language = N'R'
, @script = N' x <- 1:15;
			   #InputDataSet is a data.frame
			   str(InputDataSet)
               y <- as.vector(t(InputDataSet));
			   z <- x + y;
               OutputDataSet <- data.frame(z);'
, @input_data_1 = N' SELECT 10 as y'
WITH RESULT SETS (([col] int NOT NULL));



execute sp_execute_external_script
  @language = N'R'
, @script = N'
		rouletteWoche <- c(-120, -50, 200, -150, 210);
		#wochenTage <- c("Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag");
		#names(rouletteWoche) <- wochenTage;

		anzahlTage <- sum(rouletteWoche > 0);
		rouletteTotalPlus <- sum(rouletteWoche[rouletteWoche > 0]);
		rouletteTotal <- sum(rouletteWoche);

        OutputDataSet <- data.frame(anzahlTage, rouletteTotalPlus, rouletteTotal);'
, @input_data_1 = N''
WITH RESULT SETS (([anzahlTage] int, [rouletteTotalPlus] int, [rouletteTotal] int));

use IntegrateR
go

CREATE TABLE [dbo].[Roulette](
	[Won] [int] NOT NULL,
) ON [PRIMARY]
go


insert into Roulette
values (-120), (-50), (200), (-150), (210)
go

execute sp_execute_external_script
  @language = N'R'
, @script = N'
		rouletteWoche <- as.matrix(InputDataSet);

		anzahlTage <- sum(rouletteWoche > 0);
		rouletteTotalPlus <- sum(rouletteWoche[rouletteWoche > 0]);
		rouletteTotal <- sum(rouletteWoche);

        OutputDataSet <- data.frame(anzahlTage, rouletteTotalPlus, rouletteTotal);'
, @input_data_1 = N' Select Won from Roulette'
WITH RESULT SETS (([anzahlTage] int, [rouletteTotalPlus] int, [rouletteTotal] int));

execute sp_execute_external_script
  @language = N'R'
, @script = N'
		rouletteWoche <- as.matrix(InputDataSet);
		wochenTage <- c("Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag");
		names(rouletteWoche) <- wochenTage;

		rouletteTagePlus <- rouletteWoche[rouletteWoche > 0];

        colNames <- cbind(rouletteTagePlus);
        #colNames <- data.frame(rouletteTagePlus, check.names = FALSE);

        OutputDataSet <- data.frame(rownames(colNames), rouletteTagePlus);'
, @input_data_1 = N' Select Won from Roulette'
WITH RESULT SETS (([day] nvarchar(20), [rouletteTagePlus] int));


--cleanup
drop table roulette;


