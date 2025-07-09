-- Insertion des données selon les spécifications du professeur
-- Année universitaire 2023-2024
-- Semestres impairs uniquement : S1 (L1), S3 (L2), S5 (L3)
-- 5 étudiants par classe, 2 UE par semestre, 2 EC par UE

-- ===============================
-- INSERTION DES SEMESTRES
-- ===============================
INSERT INTO Semestre (Numero, Cycle, Annee) VALUES (1, 'Licence', '2023-2024');
INSERT INTO Semestre (Numero, Cycle, Annee) VALUES (3, 'Licence', '2023-2024');
INSERT INTO Semestre (Numero, Cycle, Annee) VALUES (5, 'Licence', '2023-2024');

-- ===============================
-- INSERTION DES ÉTUDIANTS
-- ===============================

-- Étudiants L1 (matricules de 20230001 à 20230005)
INSERT INTO Etudiant (Nom, Prenom, Age, Sexe, Niveau) VALUES ('FALL', 'Abdou', 22, 'Masculin', 'L1');
INSERT INTO Etudiant (Nom, Prenom, Age, Sexe, Niveau) VALUES ('DIATTA', 'Josephine', 21, 'Feminin', 'L1');
INSERT INTO Etudiant (Nom, Prenom, Age, Sexe, Niveau) VALUES ('NDOYE', 'Cheikh Tidiane', 20, 'Masculin', 'L1');
INSERT INTO Etudiant (Nom, Prenom, Age, Sexe, Niveau) VALUES ('GOMIS', 'Jean Paul', 23, 'Masculin', 'L1');
INSERT INTO Etudiant (Nom, Prenom, Age, Sexe, Niveau) VALUES ('GAYE', 'El Hadji Issa', 21, 'Masculin', 'L1');

-- Étudiants L2 (matricules de 20220001 à 20220005)
INSERT INTO Etudiant (Nom, Prenom, Age, Sexe, Niveau) VALUES ('GUEYE', 'Cheikh Abdou', 23, 'Masculin', 'L2');
INSERT INTO Etudiant (Nom, Prenom, Age, Sexe, Niveau) VALUES ('DIOP', 'Adji Ndeye Astou', 24, 'Feminin', 'L2');
INSERT INTO Etudiant (Nom, Prenom, Age, Sexe, Niveau) VALUES ('DIAGNE', 'Cheikh Abdou', 22, 'Masculin', 'L2');
INSERT INTO Etudiant (Nom, Prenom, Age, Sexe, Niveau) VALUES ('DIEDHIOU', 'Fatoumata', 23, 'Feminin', 'L2');
INSERT INTO Etudiant (Nom, Prenom, Age, Sexe, Niveau) VALUES ('NDIAYE', 'Khadidiatou', 21, 'Feminin', 'L2');

-- Étudiants L3 (matricules de 20210001 à 20210005)
INSERT INTO Etudiant (Nom, Prenom, Age, Sexe, Niveau) VALUES ('SECK', 'Alboury', 23, 'Masculin', 'L3');
INSERT INTO Etudiant (Nom, Prenom, Age, Sexe, Niveau) VALUES ('DIAGNE', 'Ndeye Coumba', 24, 'Feminin', 'L3');
INSERT INTO Etudiant (Nom, Prenom, Age, Sexe, Niveau) VALUES ('DIEDHIOU', 'Albert Louis', 25, 'Masculin', 'L3');
INSERT INTO Etudiant (Nom, Prenom, Age, Sexe, Niveau) VALUES ('MENDY', 'Léontine Nicole', 24, 'Feminin', 'L3');
INSERT INTO Etudiant (Nom, Prenom, Age, Sexe, Niveau) VALUES ('NDIAYE', 'Fatoumatou Zahra', 23, 'Feminin', 'L3');

-- ===============================
-- INSERTION DES UE
-- ===============================

-- UE pour L1 - Semestre 1
INSERT INTO UE (Code, Libelle, Coefficient, Credit, Semestre, Cycle) VALUES ('INF111', 'Programmation 1', 4, 6, 1, 'Licence');
INSERT INTO UE (Code, Libelle, Coefficient, Credit, Semestre, Cycle) VALUES ('INF112', 'Architecture et SE', 3, 5, 1, 'Licence');

-- UE pour L2 - Semestre 3
INSERT INTO UE (Code, Libelle, Coefficient, Credit, Semestre, Cycle) VALUES ('INF231', 'Outils Mathématiques', 2, 4, 3, 'Licence');
INSERT INTO UE (Code, Libelle, Coefficient, Credit, Semestre, Cycle) VALUES ('INF232', 'Programmation web', 3, 6, 3, 'Licence');

-- UE pour L3 - Semestre 5
INSERT INTO UE (Code, Libelle, Coefficient, Credit, Semestre, Cycle) VALUES ('INF351', 'Programmation Objet', 3, 5, 5, 'Licence');
INSERT INTO UE (Code, Libelle, Coefficient, Credit, Semestre, Cycle) VALUES ('INF352', 'Réseaux et télécoms 2', 4, 6, 5, 'Licence');

-- ===============================
-- INSERTION DES EC
-- ===============================

-- EC pour L1 - Semestre 1
INSERT INTO EC (Code, Libelle, Coefficient, Credit, UE) VALUES ('INF1111', 'Algorithme 1', 2, 3, 'INF111');
INSERT INTO EC (Code, Libelle, Coefficient, Credit, UE) VALUES ('INF1112', 'Pascal 1', 2, 3, 'INF111');
INSERT INTO EC (Code, Libelle, Coefficient, Credit, UE) VALUES ('INF1121', 'Architecture', 1, 2, 'INF112');
INSERT INTO EC (Code, Libelle, Coefficient, Credit, UE) VALUES ('INF1122', 'Système d''exploitation', 2, 3, 'INF112');

-- EC pour L2 - Semestre 3
INSERT INTO EC (Code, Libelle, Coefficient, Credit, UE) VALUES ('INF2311', 'Proba et Stats', 1, 2, 'INF231');
INSERT INTO EC (Code, Libelle, Coefficient, Credit, UE) VALUES ('INF2312', 'Logique combinatoire', 1, 2, 'INF231');
INSERT INTO EC (Code, Libelle, Coefficient, Credit, UE) VALUES ('INF2321', 'Web statique', 1, 3, 'INF232');
INSERT INTO EC (Code, Libelle, Coefficient, Credit, UE) VALUES ('INF2322', 'Web dynamique', 2, 3, 'INF232');

-- EC pour L3 - Semestre 5
INSERT INTO EC (Code, Libelle, Coefficient, Credit, UE) VALUES ('INF3511', 'Java', 2, 3, 'INF351');
INSERT INTO EC (Code, Libelle, Coefficient, Credit, UE) VALUES ('INF3512', 'Visual Basic', 1, 2, 'INF351');
INSERT INTO EC (Code, Libelle, Coefficient, Credit, UE) VALUES ('INF3521', 'Routage IP', 2, 4, 'INF352');
INSERT INTO EC (Code, Libelle, Coefficient, Credit, UE) VALUES ('INF3522', 'Supports de transmission', 1, 2, 'INF352');

-- ===============================
-- INSERTION DES NOTES
-- ===============================

-- NOTES POUR L1 - SEMESTRE 1
-- Étudiant 20230001
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230001', 'INF1111', '2023-2024', 14.5, 11.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230001', 'INF1112', '2023-2024', 11.5, 11.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230001', 'INF1121', '2023-2024', 13.0, 11.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230001', 'INF1122', '2023-2024', 10.0, 11.75);

-- Étudiant 20230002
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230002', 'INF1111', '2023-2024', 10.5, 11.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230002', 'INF1112', '2023-2024', 11.5, 11.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230002', 'INF1121', '2023-2024', 8.0, 9.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230002', 'INF1122', '2023-2024', 10.0, 11.75);

-- Étudiant 20230003
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230003', 'INF1111', '2023-2024', 14.5, 15.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230003', 'INF1112', '2023-2024', 16.5, 14.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230003', 'INF1121', '2023-2024', 13.0, 14.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230003', 'INF1122', '2023-2024', 15.0, 16.75);

-- Étudiant 20230004
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230004', 'INF1111', '2023-2024', 12.5, 10.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230004', 'INF1112', '2023-2024', 11.5, 11.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230004', 'INF1121', '2023-2024', 9.0, 9.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230004', 'INF1122', '2023-2024', 12.0, 13.75);

-- Étudiant 20230005
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230005', 'INF1111', '2023-2024', 11.5, 10.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230005', 'INF1112', '2023-2024', 12.5, 9.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230005', 'INF1121', '2023-2024', 11.0, 10.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20230005', 'INF1122', '2023-2024', 10.0, 8.75);

-- NOTES POUR L2 - SEMESTRE 3
-- Étudiant 20220001
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220001', 'INF2311', '2023-2024', 13.5, 12.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220001', 'INF2312', '2023-2024', 14.5, 13.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220001', 'INF2321', '2023-2024', 12.0, 14.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220001', 'INF2322', '2023-2024', 15.0, 16.75);

-- Étudiant 20220002
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220002', 'INF2311', '2023-2024', 11.5, 10.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220002', 'INF2312', '2023-2024', 12.5, 11.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220002', 'INF2321', '2023-2024', 10.0, 12.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220002', 'INF2322', '2023-2024', 13.0, 14.75);

-- Étudiant 20220003
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220003', 'INF2311', '2023-2024', 15.5, 16.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220003', 'INF2312', '2023-2024', 16.5, 17.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220003', 'INF2321', '2023-2024', 14.0, 15.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220003', 'INF2322', '2023-2024', 17.0, 18.75);

-- Étudiant 20220004
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220004', 'INF2311', '2023-2024', 9.5, 8.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220004', 'INF2312', '2023-2024', 10.5, 9.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220004', 'INF2321', '2023-2024', 8.0, 10.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220004', 'INF2322', '2023-2024', 11.0, 12.75);

-- Étudiant 20220005
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220005', 'INF2311', '2023-2024', 12.5, 13.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220005', 'INF2312', '2023-2024', 13.5, 14.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220005', 'INF2321', '2023-2024', 11.0, 13.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20220005', 'INF2322', '2023-2024', 14.0, 15.75);

-- NOTES POUR L3 - SEMESTRE 5
-- Étudiant 20210001
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210001', 'INF3511', '2023-2024', 16.5, 17.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210001', 'INF3512', '2023-2024', 15.5, 16.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210001', 'INF3521', '2023-2024', 17.0, 18.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210001', 'INF3522', '2023-2024', 16.0, 17.75);

-- Étudiant 20210002
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210002', 'INF3511', '2023-2024', 13.5, 14.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210002', 'INF3512', '2023-2024', 14.5, 15.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210002', 'INF3521', '2023-2024', 12.0, 13.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210002', 'INF3522', '2023-2024', 15.0, 16.75);

-- Étudiant 20210003
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210003', 'INF3511', '2023-2024', 11.5, 12.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210003', 'INF3512', '2023-2024', 12.5, 13.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210003', 'INF3521', '2023-2024', 10.0, 11.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210003', 'INF3522', '2023-2024', 13.0, 14.75);

-- Étudiant 20210004
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210004', 'INF3511', '2023-2024', 14.5, 15.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210004', 'INF3512', '2023-2024', 16.5, 17.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210004', 'INF3521', '2023-2024', 15.0, 16.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210004', 'INF3522', '2023-2024', 17.0, 18.75);

-- Étudiant 20210005
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210005', 'INF3511', '2023-2024', 12.5, 13.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210005', 'INF3512', '2023-2024', 13.5, 14.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210005', 'INF3521', '2023-2024', 11.0, 12.75);
INSERT INTO Note (Etudiant, EC, Annee, Controle, Examen) VALUES ('20210005', 'INF3522', '2023-2024', 14.0, 15.75);

-- ===============================
-- RÉSUMÉ DES DONNÉES INSÉRÉES
-- ===============================
-- 15 étudiants : 5 par niveau (L1, L2, L3)
-- 3 semestres : 1, 3, 5
-- 6 UE : 2 par semestre
-- 12 EC : 4 par semestre (2 par UE)
-- 60 notes : 4 notes par étudiant par semestre