-- DROP USER gerant CASCADE;
-- DROP USER employe CASCADE;

---------------------------------------------------------------------------------------------------------

-- 1. Créer deux utilisateurs nommés gerant et employe avec les mots de passe Difficile23 et Facile2023 ;

Create USER gerant Identified By Difficile23
Default Tablespace  		USERS
Temporary Tablespace  		TEMP
Quota 						Unlimited on USERS
Password  					Expire
Account  					Unlock
;

Create USER employe Identified By Facile2023
Default Tablespace  		USERS
Temporary Tablespace  		TEMP
Quota 						Unlimited on USERS
Password  					Expire
Account  					Unlock
;

---------------------------------------------------------------------------------------------------------

-- 2. Donner les privilèges suivants à ces utilisateurs :
-- a. Les privilèges d’un super utilisateur (administrateur) à gerant ;

Grant Create Session To gerant ; 
Grant Resource To gerant ; 
Grant DBA To gerant ; 
Grant SysDBA To gerant ;

---------------------------------------------------------------------------------------------------------

-- b. La possibilité de calculer les moyennes à employe ;

-- Autoriser employe à lire les données
GRANT SELECT ON Etudiant TO employe;
GRANT SELECT ON EC TO employe;
GRANT SELECT ON Note TO employe;

-- Autoriser employe à mettre à jour les moyennes dans la table Note
GRANT UPDATE (Moyenne) ON Note TO employe;

-- Autoriser employe à insérer ou modifier des données si nécessaire
GRANT INSERT, UPDATE ON Note TO employe;

---------------------------------------------------------------------------------------------------------
-- c. La possibilité de faire les rangs à employe ;

-- Autoriser employe à lire les données
GRANT SELECT ON Resultat TO employe;

-- Autoriser employe à mettre à jour la colonne Rang
GRANT UPDATE (Rang) ON Resultat TO employe;

-- Si employe doit aussi insérer des données dans Resultat
GRANT INSERT ON Resultat TO employe;

---------------------------------------------------------------------------------------------------------
-- d. La possibilité d’afficher les résultats à employe.

GRANT SELECT ON Resultat TO employe;

