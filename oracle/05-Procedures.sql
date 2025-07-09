-- 1. Qui calcule la moyenne semestrielle des étudiants d’un niveau donné pour un semestre 
-- donné et remplit la table Resultat ;

CREATE OR REPLACE PROCEDURE CalculerMoyenneSemestrielle (
    niv IN CHAR,
    sem IN CHAR
    -- an IN CHAR
)AS
    CURSOR cur_etudiants IS
        SELECT DISTINCT Etudiant.Matricule
        FROM Etudiant
        WHERE Etudiant.Niveau = niv
    ;

    moy_ue NUMBER(4, 2);
    moy_sem NUMBER(4, 2);
    som_coefs_UE NUMBER := 0;
    som_moy_UE NUMBER := 0;
    v_rang SMALLINT := 1;
    cy  Semestre.Cycle%TYPE;
    v_Resultat VARCHAR2(7);

BEGIN
    -- Récupérer le cycle du semestre
    SELECT Cycle INTO cy FROM Semestre WHERE Numero = sem AND Annee = '2023-2024';

    -- Parcourir les étudiants
    FOR etu IN cur_etudiants LOOP
        moy_sem := 0;
        som_coefs_UE := 0;
        som_moy_UE := 0;

        -- Parcourir les UEs pour chaque étudiant
        FOR ues IN 
            (SELECT UE.Code, UE.Coefficient
             FROM UE
             WHERE UE.Semestre = sem AND UE.Cycle = cy) 
        LOOP
            DECLARE
                somme_coefs_EC NUMBER := 0;
                somme_moy_EC NUMBER := 0;

            BEGIN
                -- Parcourir les ECs pour chaque UE
                FOR ecs IN 
                    (SELECT Note.Moyenne, EC.Coefficient
                     FROM Note, EC 
                     WHERE Note.Etudiant = etu.Matricule 
                       AND Note.EC = EC.Code 
                       AND EC.UE = ues.Code) 
                LOOP
                    somme_coefs_EC := somme_coefs_EC + ecs.Coefficient;
                    somme_moy_EC := somme_moy_EC + (ecs.Coefficient * ecs.Moyenne);
                END LOOP;

                -- Calculer la moyenne de l'UE
                IF somme_coefs_EC > 0 THEN
                    moy_ue := somme_moy_EC / somme_coefs_EC;
                ELSE
                    moy_ue := 0;
                END IF;

                som_coefs_UE := som_coefs_UE + ues.Coefficient;
                som_moy_UE := som_moy_UE + (ues.Coefficient * moy_ue);
            END;
        END LOOP;

        -- Calculer la moyenne semestrielle
        IF som_coefs_UE > 0 THEN
            moy_sem := som_moy_UE / som_coefs_UE;
        ELSE
            moy_sem := 0;
        END IF;

        IF moy_sem >= 10 THEN
            v_Resultat := 'Valide';
        ELSE
            v_Resultat := 'Ajourne';
        END IF;

        -- Calculer la mention 
        DECLARE
            v_mention VARCHAR2(10);
        BEGIN
            IF moy_sem >= 16 THEN
                v_mention := 'Tres Bien';
            ELSIF moy_sem >= 14 THEN
                v_mention := 'Bien';
            ELSIF moy_sem >= 12 THEN
                v_mention := 'Assez Bien';
            ELSIF moy_sem >= 10 THEN
                v_mention := 'Passable';
            ELSE
                v_mention := ' ';
            END IF;

            -- Insérer les résultats dans la table Resultat sans rang
            INSERT INTO Resultat (Etudiant, Semestre, Cycle, Annee, Moyenne, Resultat, Mention, Rang)
            VALUES (etu.Matricule, sem, cy, '2023-2024', moy_sem, v_Resultat, v_mention, NULL); -- Rang est NULL pour l'instant
        END;
    END LOOP;

    -- Mettre à jour les rangs après l'insertion
    DECLARE
        CURSOR cur_resultats IS
            SELECT Etudiant, Moyenne
            FROM Resultat
            WHERE Semestre = sem AND Annee = '2023-2024' AND Cycle = cy
            ORDER BY Moyenne DESC;
    BEGIN
        -- Initialiser le rang
        v_rang := 1;

        -- Boucle pour attribuer les rangs après l'insertion
        FOR etudiant_rang IN cur_resultats LOOP
            -- Mettre à jour le rang dans la table Resultat
            UPDATE Resultat
            SET Rang = v_rang
            WHERE Etudiant = etudiant_rang.Etudiant
              AND Semestre = sem
              AND Annee = '2023-2024'
              AND Cycle = cy;

            -- Incrémenter le rang pour le prochain étudiant
            v_rang := v_rang + 1;
        END LOOP;

        COMMIT; -- Commit des changements dans la base de données
    END;

END;
/

BEGIN
    CalculerMoyenneSemestrielle('L1', '1');
END;
/

 
----------------------------------------------------------------------------------------------------

-- 2. Qui affiche les résultats d’une classe donnée (Niveau) par ordre de mérite pour un semestre 
-- donné d’une année donnée 

    -- CREATE OR REPLACE PROCEDURE AfficherResultatsClasse(
    --     p_niveau IN CHAR,     
    --     p_semestre IN CHAR,    
    --     p_annee IN CHAR       
    -- ) AS
    --     v_niveau VARCHAR2(8);  -- Utilisation de VARCHAR2
    -- BEGIN
    --     IF p_niveau = 'L1' OR p_niveau = 'L2' OR p_niveau = 'L3' THEN
    --         v_niveau := 'Licence';
    --     ELSIF p_niveau = 'M1' OR p_niveau = 'M2' THEN
    --         v_niveau := 'Master';
    --     ELSE
    --         v_niveau := 'Inconnu';
    --     END IF;

    --     -- Affichage des résultats triés par ordre de mérite
    --     DBMS_OUTPUT.PUT_LINE('Résultats de la classe ' || p_niveau || ' pour le semestre ' || p_semestre || ' année ' || p_annee);
    --     DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------');
    --     DBMS_OUTPUT.PUT_LINE(' Matricule  | Moyenne | Résultat | Mention     | Rang ');
    --     DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------');

    --     FOR r IN (
    --         SELECT Etudiant, Moyenne, Resultat, Mention, Rang
    --         FROM Resultat
    --         WHERE Cycle = v_niveau AND Semestre = p_semestre AND Annee = p_annee
    --         ORDER BY Moyenne DESC
    --     ) LOOP
    --         DBMS_OUTPUT.PUT_LINE(' ' || r.Etudiant || '  |  ' || r.Moyenne || '  |  ' || r.Resultat || '  |  ' || r.Mention || '  |  ' || r.Rang);
    --     END LOOP;
    -- END;
    -- /


CREATE OR REPLACE PROCEDURE AfficherResultatsClasse(
    p_niveau IN CHAR,     
    p_semestre IN CHAR,    
    p_annee IN CHAR       
) AS
    v_niveau VARCHAR2(8);  
BEGIN
    -- Déduction du niveau général (Licence ou Master)
    IF p_niveau IN ('L1', 'L2', 'L3') THEN
        v_niveau := 'Licence';
    ELSIF p_niveau IN ('M1', 'M2') THEN
        v_niveau := 'Master';
    ELSE
        v_niveau := 'Inconnu';
    END IF;

    -- En-tête
    DBMS_OUTPUT.PUT_LINE('************************************************************************');
    DBMS_OUTPUT.PUT_LINE('Liste des étudiants par ordre de mérite :');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Année : ' || p_annee);
    DBMS_OUTPUT.PUT_LINE('Niveau : ' || 
        CASE 
            WHEN p_niveau = 'L1' THEN 'Licence 1'
            WHEN p_niveau = 'L2' THEN 'Licence 2'
            WHEN p_niveau = 'L3' THEN 'Licence 3'
            WHEN p_niveau = 'M1' THEN 'Master 1'
            WHEN p_niveau = 'M2' THEN 'Master 2'
            ELSE 'Inconnu'
        END);
    DBMS_OUTPUT.PUT_LINE('Semestre : Semestre ' || p_semestre);
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

    -- Boucle sur les résultats triés
    FOR r IN (
        SELECT e.Matricule, e.Nom, e.Prenom, 
               REPLACE(TO_CHAR(r.Moyenne, '90.99'), '.', ',') AS MoyenneStr,
               r.Resultat, r.Mention, r.Rang
        FROM Resultat r
        JOIN Etudiant e ON r.Etudiant = e.Matricule
        WHERE r.Cycle = v_niveau AND r.Semestre = p_semestre AND r.Annee = p_annee
        ORDER BY r.Moyenne DESC
    ) LOOP
        -- Affichage ligne étudiante formatée
        DBMS_OUTPUT.PUT_LINE(
            r.Matricule || ' ' ||
            RPAD(r.Nom || ' ' || r.Prenom, 24) || ' ' ||
            RPAD(r.MoyenneStr, 6) || ' ' ||
            RPAD(r.Resultat, 8) || ' ' ||
            RPAD(r.Mention, 11) || ' ' ||
            r.Rang
        );
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------');
    END LOOP;
END;
/


-- Si rien ne s'affiche, active l'affichage des sorties PL/SQL avec :
SET SERVEROUTPUT ON;

Exec AfficherResultatsClasse('L1', '1', '2023-2024');

BEGIN
    AfficherResultatsClasse('L1', '1', '2023-2024');
END;
/

-----------------------------------------------------------------------------------------------------------

-- 3. Qui fait le classement par ordre de mérite des étudiants d’une classe pour un semestre d’une année donnée ;

CREATE OR REPLACE PROCEDURE ClasserEtudiants(
    p_niveau IN CHAR,      -- Niveau de la classe (ex: 'L1', 'L2', 'L3')
    p_semestre IN CHAR,    -- Semestre concerné (ex: '1', '2', ...)
    p_annee IN CHAR       -- Année académique concernée (ex: '2023-2024')
) AS
    v_rang NUMBER := 1; -- Variable pour attribuer le rang
    v_niveau VARCHAR2(8);  -- Utilisation de VARCHAR2
BEGIN

    IF p_niveau = 'L1' OR p_niveau = 'L2' OR p_niveau = 'L3' THEN
            v_niveau := 'Licence';
        ELSIF p_niveau = 'M1' OR p_niveau = 'M2' THEN
            v_niveau := 'Master';
    ELSE
        v_niveau := 'Inconnu';
    END IF;

    -- Mettre à jour les rangs des étudiants en fonction de leur moyenne
    FOR r IN (
        SELECT Etudiant
        FROM Resultat
        WHERE Cycle = v_niveau 
          AND Semestre = p_semestre 
          AND Annee = p_annee
        ORDER BY Moyenne DESC -- Trier du meilleur au moins bon
    ) LOOP
        -- Mise à jour du rang dans la table Resultat
        UPDATE Resultat
        SET Rang = v_rang
        WHERE Etudiant = r.Etudiant
          AND Semestre = p_semestre
          AND Annee = p_annee;
        
        -- Incrémentation du rang pour le prochain étudiant
        v_rang := v_rang + 1;
    END LOOP;

    COMMIT; -- Valider les modifications
END;
/

BEGIN
    ClasserEtudiants('L1', '1', '2023-2024');
END;
/

SELECT * FROM Resultat 
WHERE Cycle = 'L1' AND Semestre = '1' AND Annee = '2023-2024' 
ORDER BY Rang;

-----------------------------------------------------------------------------------------------------
-- 4. Qui affiche le relevé d’un étudiant donné pour un semestre donné

-- CREATE OR REPLACE PROCEDURE AfficherReleveEtudiant(
--     p_etudiant IN CHAR,    -- Matricule de l'étudiant
--     p_semestre IN CHAR,    -- Semestre concerné (ex: '1', '2', ...)
--     p_annee IN CHAR       -- Année académique concernée (ex: '2023-2024')
-- ) AS
-- BEGIN
--     -- Afficher l'entête du relevé
--     DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
--     DBMS_OUTPUT.PUT_LINE(' RELEVE DE NOTES ');
--     DBMS_OUTPUT.PUT_LINE(' Etudiant: ' || p_etudiant);
--     DBMS_OUTPUT.PUT_LINE(' Semestre: ' || p_semestre);
--     DBMS_OUTPUT.PUT_LINE(' Année: ' || p_annee);
--     DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
--     DBMS_OUTPUT.PUT_LINE('EC       | Libellé                  | CC  | EXAM | Moyenne ');
--     DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');

--     -- Afficher les notes de l'étudiant pour le semestre donné
--     FOR r IN (
--         SELECT EC.Code, EC.Libelle, N.Controle, N.Examen, N.Moyenne
--         FROM Note N
--         JOIN EC ON N.EC = EC.Code
--         JOIN UE ON EC.UE = UE.Code
--         WHERE N.Etudiant = p_etudiant
--           AND UE.Semestre = p_semestre
--           AND N.Annee = p_annee
--     ) LOOP
--         DBMS_OUTPUT.PUT_LINE(
--             r.Code || ' | ' || 
--             RPAD(r.Libelle, 25) || ' | ' || 
--             LPAD(r.Controle, 4) || ' | ' || 
--             LPAD(r.Examen, 4) || ' | ' || 
--             LPAD(r.Moyenne, 6)
--         );
--     END LOOP;

--     -- Afficher la moyenne semestrielle et le résultat de l'étudiant
--     FOR res IN (
--         SELECT Moyenne, Resultat, Mention, Rang
--         FROM Resultat
--         WHERE Etudiant = p_etudiant
--           AND Semestre = p_semestre
--           AND Annee = p_annee
--     ) LOOP
--         DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
--         DBMS_OUTPUT.PUT_LINE(' Moyenne Semestre : ' || res.Moyenne);
--         DBMS_OUTPUT.PUT_LINE(' Résultat         : ' || res.Resultat);
--         DBMS_OUTPUT.PUT_LINE(' Mention          : ' || res.Mention);
--         DBMS_OUTPUT.PUT_LINE(' Rang             : ' || res.Rang);
--         DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
--     END LOOP;
-- END;
-- /


CREATE OR REPLACE PROCEDURE AfficherReleveEtudiant(
    p_etudiant IN CHAR,    -- Matricule de l'étudiant
    p_semestre IN CHAR,    -- Semestre concerné (ex: '1', '2', ...)
    p_annee IN CHAR        -- Année académique concernée (ex: '2023-2024')
) AS
    v_nom     VARCHAR2(50);
    v_prenom  VARCHAR2(50);
    v_age     NUMBER(3);
    v_sexe    VARCHAR2(10);
    v_niveau  VARCHAR2(15);
BEGIN
    -- Récupération des informations personnelles
    SELECT Nom, Prenom, Age, Sexe, 
           CASE 
               WHEN Niveau = 'L1' THEN 'Licence 1'
               WHEN Niveau = 'L2' THEN 'Licence 2'
               WHEN Niveau = 'L3' THEN 'Licence 3'
               WHEN Niveau = 'M1' THEN 'Master 1'
               WHEN Niveau = 'M2' THEN 'Master 2'
               ELSE 'Inconnu'
           END
    INTO v_nom, v_prenom, v_age, v_sexe, v_niveau
    FROM Etudiant
    WHERE Matricule = p_etudiant;

    -- En-tête
    DBMS_OUTPUT.PUT_LINE('Relevé de note de l''étudiant :');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Année : ' || p_annee);
    DBMS_OUTPUT.PUT_LINE('Niveau : ' || v_niveau);
    DBMS_OUTPUT.PUT_LINE('Semestre : Semestre ' || p_semestre);
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Numéro de carte : ' || p_etudiant);
    DBMS_OUTPUT.PUT_LINE('Prénom et Nom : ' || INITCAP(v_prenom) || ' ' || UPPER(v_nom));
    DBMS_OUTPUT.PUT_LINE('Age : ' || v_age || ' ans');
    DBMS_OUTPUT.PUT_LINE('Sexe : ' || CASE WHEN UPPER(v_sexe) = 'M' THEN 'Masculin' 
                                           WHEN UPPER(v_sexe) = 'F' THEN 'Féminin'
                                           ELSE INITCAP(v_sexe) END);
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------');

    -- Affichage des EC et notes
    FOR r IN (
        SELECT EC.Code, EC.Libelle, N.Controle, N.Examen, N.Moyenne
        FROM Note N
        JOIN EC ON N.EC = EC.Code
        JOIN UE ON EC.UE = UE.Code
        WHERE N.Etudiant = p_etudiant
          AND UE.Semestre = p_semestre
          AND N.Annee = p_annee
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.Code, 8) || ' ' ||
            RPAD(SUBSTR(r.Libelle, 1, 25), 25) || ' ' ||
            LPAD(REPLACE(TO_CHAR(r.Controle, '90.99'), '.', ','), 5) || ' ' ||
            LPAD(REPLACE(TO_CHAR(r.Examen, '90.99'), '.', ','), 7) || ' ' ||
            LPAD(REPLACE(TO_CHAR(r.Moyenne, '90.99'), '.', ','), 6)
        );
    END LOOP;

    -- Résultat final
    FOR res IN (
        SELECT Moyenne, Resultat, Mention, Rang
        FROM Resultat
        WHERE Etudiant = p_etudiant
          AND Semestre = p_semestre
          AND Annee = p_annee
    ) LOOP
        -- Récupération des crédits validés
        DECLARE
            v_credits NUMBER := 0;
        BEGIN
            SELECT SUM(EC.Credit)
            INTO v_credits
            FROM Note N
            JOIN EC ON N.EC = EC.Code
            JOIN UE ON EC.UE = UE.Code
            WHERE N.Etudiant = p_etudiant
              AND N.Annee = p_annee
              AND UE.Semestre = p_semestre
              AND N.Moyenne >= 10;
              
            DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------');
            DBMS_OUTPUT.PUT_LINE('Moyenne : ' || REPLACE(TO_CHAR(res.Moyenne, '90.99'), '.', ','));
            DBMS_OUTPUT.PUT_LINE('Nombre de crédits : ' || v_credits);
            DBMS_OUTPUT.PUT_LINE('Décision du jury : ' || INITCAP(res.Resultat));
            DBMS_OUTPUT.PUT_LINE('Mention : ' || res.Mention);
            DBMS_OUTPUT.PUT_LINE('Rang : ' || res.Rang);
            DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------');
        END;
    END LOOP;
END;
/

BEGIN
    AfficherReleveEtudiant('2023001', '1', '2023-2024');
END;
/

-----------------------------------------------------------------------------------------------------
-- 5. Qui affiche la liste des EC validés par un étudiant donné pour un semestre donné

-- CREATE OR REPLACE PROCEDURE AfficherECValides(
--     p_etudiant IN CHAR,   -- Matricule de l'étudiant
--     p_semestre IN CHAR,   -- Semestre concerné (ex: '1', '2', ...)
--     p_annee IN CHAR      -- Année académique concernée (ex: '2023-2024')
-- ) AS
-- BEGIN
--     -- Affichage de l'entête
--     DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
--     DBMS_OUTPUT.PUT_LINE(' LISTE DES EC VALIDÉS ');
--     DBMS_OUTPUT.PUT_LINE(' Etudiant: ' || p_etudiant);
--     DBMS_OUTPUT.PUT_LINE(' Semestre: ' || p_semestre);
--     DBMS_OUTPUT.PUT_LINE(' Année: ' || p_annee);
--     DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
--     DBMS_OUTPUT.PUT_LINE('EC       | Libellé                  | Moyenne ');
--     DBMS_OUTPUT.PUT_LINE('------------------------------------------------');

--     -- Sélection et affichage des EC validés
--     FOR r IN (
--         SELECT EC.Code, EC.Libelle, N.Moyenne
--         FROM Note N
--         JOIN EC ON N.EC = EC.Code
--         JOIN UE ON EC.UE = UE.Code
--         WHERE N.Etudiant = p_etudiant
--           AND UE.Semestre = p_semestre
--           AND N.Annee = p_annee
--           AND N.Moyenne >= 10  -- Un EC est validé si la moyenne est >= 10
--     ) LOOP
--         DBMS_OUTPUT.PUT_LINE(
--             r.Code || ' | ' || 
--             RPAD(r.Libelle, 25) || ' | ' || 
--             LPAD(r.Moyenne, 6)
--         );
--     END LOOP;

--     DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
-- END;
-- /


-- CREATE OR REPLACE PROCEDURE AfficherECValides(
--     p_etudiant IN CHAR,   -- Matricule de l'étudiant
--     p_semestre IN CHAR,   -- Semestre concerné (ex: '1', '2', ...)
--     p_annee IN CHAR       -- Année académique concernée (ex: '2023-2024')
-- ) AS
-- BEGIN
--     -- En-tête conforme au modèle
--     DBMS_OUTPUT.PUT_LINE('Liste des EC validés :');
--     DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

--     -- Sélection des EC validés avec toutes les infos nécessaires
--     FOR r IN (
--         SELECT ec.Code, ec.Libelle, ec.Coefficient AS coef_ec, ue.Coefficient AS coef_ue, 
--                ec.Credit, n.Controle, n.Examen, n.Moyenne
--         FROM Note n
--         JOIN EC ec ON n.EC = ec.Code
--         JOIN UE ue ON ec.UE = ue.Code
--         WHERE n.Etudiant = p_etudiant
--           AND ue.Semestre = p_semestre
--           AND n.Annee = p_annee
--           AND n.Moyenne >= 10
--     ) LOOP
--         DBMS_OUTPUT.PUT_LINE(
--             RPAD(r.Code, 8) || ' ' ||
--             RPAD(SUBSTR(r.Libelle, 25), 25) || ' ' ||
--             RPAD(r.coef_ec, 2) || ' ' ||
--             RPAD(r.coef_ue, 2) || ' ' ||
--             RPAD(r.Credit, 2) || ' ' ||
--             LPAD(REPLACE(TO_CHAR(r.Controle, '90.99'), '.', ','), 5) || ' ' ||
--             LPAD(REPLACE(TO_CHAR(r.Examen, '90.99'), '.', ','), 6) || ' ' ||
--             LPAD(REPLACE(TO_CHAR(r.Moyenne, '90.99'), '.', ','), 6)
--         );
--         DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
--     END LOOP;
-- END;
-- /


CREATE OR REPLACE PROCEDURE AfficherECValides(
    p_etudiant IN CHAR,   -- Matricule de l'étudiant
    p_semestre IN CHAR,   -- Semestre concerné (ex: '1', '2', ...)
    p_annee IN CHAR       -- Année académique concernée (ex: '2023-2024')
) AS
BEGIN
    -- En-tête
    DBMS_OUTPUT.PUT_LINE('Liste des EC validés :');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

    -- Récupération des EC validés avec toutes les infos nécessaires
    FOR r IN (
        SELECT ec.Code, ec.Libelle, ec.Coefficient AS coef_ec, ue.Coefficient AS coef_ue, 
               ec.Credit, n.Controle, n.Examen, n.Moyenne
        FROM Note n
        JOIN EC ec ON n.EC = ec.Code
        JOIN UE ue ON ec.UE = ue.Code
        WHERE n.Etudiant = p_etudiant
          AND ue.Semestre = p_semestre
          AND n.Annee = p_annee
          AND n.Moyenne >= 10
    ) LOOP
        -- Affichage avec libellé bien présent
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.Code, 8) || ' ' ||
            RPAD(SUBSTR(r.Libelle, 1, 30), 30) || ' ' ||
            RPAD(r.coef_ec, 2) || ' ' ||
            RPAD(r.coef_ue, 2) || ' ' ||
            LPAD(REPLACE(TO_CHAR(r.Controle, '90.99'), '.', ','), 5) || ' ' ||
            LPAD(REPLACE(TO_CHAR(r.Examen, '90.99'), '.', ','), 6) || ' ' ||
            LPAD(REPLACE(TO_CHAR(r.Moyenne, '90.99'), '.', ','), 6)
        );
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
    END LOOP;
END;
/

BEGIN
    AfficherECValides('2023001', '1', '2023-2024');
    -- AfficherECValides('2023007', '1', '2023-2024');
END;
/

-----------------------------------------------------------------------------------------------------
-- 6. Qui affiche la liste des étudiants d’une classe donnée et qui ont validé un semestre donné

-- CREATE OR REPLACE PROCEDURE AfficherEtudiantsValidantSemestre(
-- CREATE OR REPLACE PROCEDURE AfficherEtudValideSem(
--     p_niveau IN CHAR,    -- Niveau de la classe (ex: 'L1', 'L2', 'L3')
--     p_semestre IN CHAR,  -- Semestre concerné (ex: '1', '2', ...)
--     p_annee IN CHAR     -- Année académique concernée (ex: '2023-2024')
-- ) AS
-- BEGIN
--     -- Affichage de l'en-tête
--     DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
--     DBMS_OUTPUT.PUT_LINE(' LISTE DES ÉTUDIANTS AYANT VALIDÉ LE SEMESTRE ');
--     DBMS_OUTPUT.PUT_LINE(' Niveau: ' || p_niveau);
--     DBMS_OUTPUT.PUT_LINE(' Semestre: ' || p_semestre);
--     DBMS_OUTPUT.PUT_LINE(' Année: ' || p_annee);
--     DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
--     DBMS_OUTPUT.PUT_LINE('Matricule | Nom                 | Prénom              | Moyenne | Mention');
--     DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

--     -- Sélection et affichage des étudiants ayant validé le semestre
--     FOR r IN (
--         SELECT E.Matricule, E.Nom, E.Prenom, R.Moyenne, R.Mention
--         FROM Resultat R
--         JOIN Etudiant E ON R.Etudiant = E.Matricule
--         WHERE E.Niveau = p_niveau
--           AND R.Semestre = p_semestre
--           AND R.Annee = p_annee
--           AND R.Resultat = 'Valide' -- Un semestre est validé si le résultat est "Valide"
--     ) LOOP
--         DBMS_OUTPUT.PUT_LINE(
--             r.Matricule || ' | ' ||
--             RPAD(r.Nom, 20) || ' | ' ||
--             RPAD(r.Prenom, 20) || ' | ' ||
--             LPAD(r.Moyenne, 6) || ' | ' ||
--             r.Mention
--         );
--     END LOOP;

--     DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
-- END;
-- /



CREATE OR REPLACE PROCEDURE AfficherEtudValideSem(
    p_niveau IN CHAR,    -- Niveau (ex: 'L1', 'L2', 'M1', etc.)
    p_semestre IN CHAR,  -- Semestre (ex: '1', '2', ...)
    p_annee IN CHAR      -- Année académique (ex: '2023-2024')
) AS
    v_cycle VARCHAR2(10);
BEGIN
    -- Déduire le cycle
    IF p_niveau IN ('L1', 'L2', 'L3') THEN
        v_cycle := 'Licence';
    ELSIF p_niveau IN ('M1', 'M2') THEN
        v_cycle := 'Master';
    ELSE
        v_cycle := 'Inconnu';
    END IF;

    DBMS_OUTPUT.PUT_LINE('Liste des étudiants qui ont validé :');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Matricule  Prénom               Nom                 Age  Sexe      Moyenne  Mention');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

    FOR r IN (
        SELECT e.Matricule, e.Prenom, e.Nom, e.Age, 
               CASE 
                   WHEN UPPER(e.Sexe) = 'M' THEN 'Masculin'
                   WHEN UPPER(e.Sexe) = 'F' THEN 'Féminin'
                   ELSE INITCAP(e.Sexe)
               END AS Genre,
               REPLACE(TO_CHAR(r.Moyenne, '90.99'), '.', ',') AS MoyenneStr,
               r.Mention
        FROM Resultat r
        JOIN Etudiant e ON r.Etudiant = e.Matricule
        WHERE e.Niveau = p_niveau
          AND r.Cycle = v_cycle
          AND r.Semestre = p_semestre
          AND r.Annee = p_annee
          AND r.Resultat = 'Valide'
        ORDER BY r.Moyenne DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.Matricule, 11) ||
            RPAD(INITCAP(r.Prenom), 20) ||
            RPAD(UPPER(r.Nom), 20) ||
            LPAD(r.Age, 5) || '  ' ||
            RPAD(r.Genre, 10) ||
            LPAD(r.MoyenneStr, 8) || '  ' ||
            r.Mention
        );
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
    END LOOP;
END;
/


BEGIN
    AfficherEtudValideSem('L1', '1', '2023-2024');
END;
/

-----------------------------------------------------------------------------------------------------
-- 7. Qui donne le major d’une classe donnée pour un semestre donné

-- CREATE OR REPLACE PROCEDURE AfficherMajorClasseSemestre(
--     p_niveau IN CHAR,    -- Niveau de la classe (ex: 'Licence', 'Master', etc.)
--     p_semestre IN CHAR,  -- Semestre concerné (ex: '1', '2', ...)
--     p_annee IN CHAR      -- Année académique (ex: '2023-2024')
-- ) AS
--     v_matricule Etudiant.Matricule%TYPE;
--     v_nom Etudiant.Nom%TYPE;
--     v_prenom Etudiant.Prenom%TYPE;
--     v_moyenne Resultat.Moyenne%TYPE;
-- BEGIN
--     -- Récupérer l'étudiant avec la meilleure moyenne
--     SELECT E.Matricule, E.Nom, E.Prenom, R.Moyenne
--     INTO v_matricule, v_nom, v_prenom, v_moyenne
--     FROM Resultat R
--     JOIN Etudiant E ON R.Etudiant = E.Matricule
--     WHERE E.Niveau = p_niveau
--       AND R.Semestre = p_semestre
--       AND R.Annee = p_annee
--       AND R.Moyenne = (
--           SELECT MAX(R2.Moyenne)
--           FROM Resultat R2
--           JOIN Etudiant E2 ON R2.Etudiant = E2.Matricule
--           WHERE E2.Niveau = p_niveau
--             AND R2.Semestre = p_semestre
--             AND R2.Annee = p_annee
--       );

--     -- Afficher les résultats
--     DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
--     DBMS_OUTPUT.PUT_LINE(' MAJOR DE LA CLASSE ');
--     DBMS_OUTPUT.PUT_LINE(' Niveau: ' || p_niveau);
--     DBMS_OUTPUT.PUT_LINE(' Semestre: ' || p_semestre);
--     DBMS_OUTPUT.PUT_LINE(' Année: ' || p_annee);
--     DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
--     DBMS_OUTPUT.PUT_LINE('Matricule : ' || v_matricule);
--     DBMS_OUTPUT.PUT_LINE('Nom       : ' || v_nom);
--     DBMS_OUTPUT.PUT_LINE('Prénom    : ' || v_prenom);
--     DBMS_OUTPUT.PUT_LINE('Moyenne   : ' || v_moyenne);
--     DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');

-- EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--         DBMS_OUTPUT.PUT_LINE('Aucun étudiant trouvé pour ce semestre et cette classe.');
--     WHEN OTHERS THEN
--         DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
-- END;
-- /

CREATE OR REPLACE PROCEDURE AfficherMajorClasseSemestre(
    p_niveau IN CHAR,    -- Niveau (ex: 'L1', 'M1', etc.)
    p_semestre IN CHAR,  -- Semestre (ex: '1', '2', ...)
    p_annee IN CHAR      -- Année académique (ex: '2023-2024')
) AS
    v_matricule Etudiant.Matricule%TYPE;
    v_nom Etudiant.Nom%TYPE;
    v_prenom Etudiant.Prenom%TYPE;
    v_age Etudiant.Age%TYPE;
    v_sexe Etudiant.Sexe%TYPE;
    v_cycle VARCHAR2(10);
BEGIN
    -- Déterminer le cycle
    IF p_niveau IN ('L1', 'L2', 'L3') THEN
        v_cycle := 'Licence';
    ELSIF p_niveau IN ('M1', 'M2') THEN
        v_cycle := 'Master';
    ELSE
        v_cycle := 'Inconnu';
    END IF;

    -- Récupération du major
    SELECT E.Matricule, E.Nom, E.Prenom, E.Age, 
           CASE 
               WHEN UPPER(E.Sexe) = 'M' THEN 'Masculin'
               WHEN UPPER(E.Sexe) = 'F' THEN 'Féminin'
               ELSE INITCAP(E.Sexe)
           END
    INTO v_matricule, v_nom, v_prenom, v_age, v_sexe
    FROM Resultat R
    JOIN Etudiant E ON R.Etudiant = E.Matricule
    WHERE E.Niveau = p_niveau
      AND R.Semestre = p_semestre
      AND R.Annee = p_annee
      AND R.Cycle = v_cycle
      AND R.Moyenne = (
          SELECT MAX(R2.Moyenne)
          FROM Resultat R2
          JOIN Etudiant E2 ON R2.Etudiant = E2.Matricule
          WHERE E2.Niveau = p_niveau
            AND R2.Semestre = p_semestre
            AND R2.Annee = p_annee
            AND R2.Cycle = v_cycle
      );

    -- Affichage au format demandé par le prof
    DBMS_OUTPUT.PUT_LINE('L''étudiant majore de sa classe :');
    DBMS_OUTPUT.PUT_LINE(
        v_matricule || ' ' ||
        UPPER(v_nom) || ' ' || INITCAP(v_prenom) || ' ' ||
        v_age || ' ' || v_sexe
    );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Aucun étudiant trouvé pour ce semestre et cette classe.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
END;
/



BEGIN
    AfficherMajorClasseSemestre('L1', '1', '2023-2024');
END;
/

-----------------------------------------------------------------------------------------------------

