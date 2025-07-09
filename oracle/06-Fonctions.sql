-- 1. Qui calcule et renvoie la moyenne d’un étudiant pour une UE d’un semestre
CREATE OR REPLACE FUNCTION CalculerMoyenneUE(
    p_etudiant IN CHAR,    -- Matricule de l'étudiant
    p_ue IN CHAR,         -- Code de l'UE
    p_semestre IN CHAR,   -- Semestre concerné
    p_annee IN CHAR       -- Année académique
) RETURN NUMBER IS
    v_moyenne_ue NUMBER := 0;  -- Variable pour stocker la moyenne de l'UE
    v_total_coeff NUMBER := 0; -- Total des coefficients des EC
    v_somme_ponderation NUMBER := 0; -- Somme pondérée des moyennes des EC
BEGIN
    -- Calculer la somme pondérée des moyennes des EC de l'UE
    SELECT SUM(N.Moyenne * EC.Coefficient), SUM(EC.Coefficient)
    INTO v_somme_ponderation, v_total_coeff
    FROM Note N
    JOIN EC ON N.EC = EC.Code
    WHERE N.Etudiant = p_etudiant
      AND EC.UE = p_ue
      AND N.Annee = p_annee;

    -- Vérifier si des EC ont été trouvés
    IF v_total_coeff > 0 THEN
        v_moyenne_ue := v_somme_ponderation / v_total_coeff;
    ELSE
        v_moyenne_ue := NULL; -- Aucun EC trouvé pour l'UE
    END IF;

    RETURN v_moyenne_ue;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL; -- Aucun enregistrement trouvé
    WHEN OTHERS THEN
        RETURN NULL; -- Autre erreur non gérée
END;
/


SELECT CalculerMoyenneUE('20230001', 'INF111', '1', '2023-2024') FROM dual;


DECLARE
    v_moyenne NUMBER;
BEGIN
    v_moyenne := CalculerMoyenneUE('2023001', 'INF111', '1', '2023-2024');
    DBMS_OUTPUT.PUT_LINE('Moyenne de l''UE : ' || v_moyenne);
END;
/


----------------------------------------------------------------------------------------------------------
-- 2. Qui calcule et renvoie la moyenne semestrielle d’un étudiant pour une année donnée
CREATE OR REPLACE FUNCTION CalculerMoyenneSemestre(
    p_etudiant IN CHAR,   -- Matricule de l'étudiant
    p_semestre IN CHAR,   -- Semestre concerné
    p_annee IN CHAR      -- Année académique
) RETURN NUMBER IS
    v_moyenne_semestre NUMBER := 0;  -- Variable pour stocker la moyenne semestrielle
    v_total_coeff NUMBER := 0; -- Total des coefficients des UE
    v_somme_ponderation NUMBER := 0; -- Somme pondérée des moyennes des UE
BEGIN
    -- Calculer la somme pondérée des moyennes des UE du semestre
    SELECT SUM(CalculerMoyenneUE(p_etudiant, UE.Code, p_semestre, p_annee) * UE.Coefficient),
           SUM(UE.Coefficient)
    INTO v_somme_ponderation, v_total_coeff
    FROM UE
    WHERE UE.Semestre = p_semestre;

    -- Vérifier si des UE ont été trouvées
    IF v_total_coeff > 0 THEN
        v_moyenne_semestre := v_somme_ponderation / v_total_coeff;
    ELSE
        v_moyenne_semestre := NULL; -- Aucun UE trouvé pour le semestre
    END IF;

    RETURN v_moyenne_semestre;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL; -- Aucun enregistrement trouvé
    WHEN OTHERS THEN
        RETURN NULL; -- Autre erreur non gérée
END;
/

SELECT CalculerMoyenneSemestre('2023001', '1', '2023-2024') FROM dual;


DECLARE
    v_moyenne NUMBER;
BEGIN
    v_moyenne := CalculerMoyenneSemestre('2023001', '1', '2023-2024');
    DBMS_OUTPUT.PUT_LINE('Moyenne semestrielle : ' || v_moyenne);
END;
/

----------------------------------------------------------------------------------------------------------
-- 3. Qui renvoie la moyenne de classe pour un semestre donné
CREATE OR REPLACE FUNCTION CalculerMoyenneClasse(
    p_niveau IN CHAR,    -- Niveau de la classe (ex: 'L1', 'L2')
    p_semestre IN CHAR,  -- Semestre concerné (ex: '1', '2')
    p_annee IN CHAR      -- Année académique (ex: '2023-2024')
) RETURN NUMBER IS
    v_moyenne_classe NUMBER := 0;  -- Variable pour stocker la moyenne de classe
    v_total_etudiants NUMBER := 0; -- Nombre total d'étudiants dans la classe
    v_somme_moyennes NUMBER := 0;  -- Somme des moyennes semestrielles des étudiants
BEGIN
    -- Calculer la somme des moyennes des étudiants et le nombre total d'étudiants
    SELECT SUM(CalculerMoyenneSemestre(E.Matricule, p_semestre, p_annee)), 
           COUNT(*)
    INTO v_somme_moyennes, v_total_etudiants
    FROM Etudiant E
    WHERE E.Niveau = p_niveau;

    -- Vérifier si des étudiants ont été trouvés
    IF v_total_etudiants > 0 THEN
        v_moyenne_classe := v_somme_moyennes / v_total_etudiants;
    ELSE
        v_moyenne_classe := NULL; -- Aucun étudiant trouvé
    END IF;

    RETURN v_moyenne_classe;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL; -- Aucun enregistrement trouvé
    WHEN OTHERS THEN
        RETURN NULL; -- Autre erreur non gérée
END;
/


SELECT CalculerMoyenneClasse('L1', '1', '2023-2024') FROM dual;


DECLARE
    v_moyenne_classe NUMBER;
BEGIN
    v_moyenne_classe := CalculerMoyenneClasse('L1', '1', '2023-2024');
    DBMS_OUTPUT.PUT_LINE('Moyenne de la classe : ' || v_moyenne_classe);
END;
/

----------------------------------------------------------------------------------------------------------
-- 4. Qui renvoie la moyenne de classe pour un EC donné
CREATE OR REPLACE FUNCTION CalculerMoyenneClasseEC(
    p_ec_code IN CHAR,   -- Code de l'EC (ex: 'INF1111')
    p_annee IN CHAR      -- Année académique (ex: '2023-2024')
) RETURN NUMBER IS
    v_moyenne_classe NUMBER := 0;  -- Variable pour stocker la moyenne de classe
    v_total_etudiants NUMBER := 0; -- Nombre total d'étudiants ayant une note dans cet EC
    v_somme_moyennes NUMBER := 0;  -- Somme des moyennes des étudiants pour cet EC
BEGIN
    -- Calculer la somme des moyennes des étudiants et le nombre total d'étudiants
    SELECT SUM(N.Moyenne), COUNT(*)
    INTO v_somme_moyennes, v_total_etudiants
    FROM Note N
    WHERE N.EC = p_ec_code
    AND N.Annee = p_annee;

    -- Vérifier si des étudiants ont été trouvés
    IF v_total_etudiants > 0 THEN
        v_moyenne_classe := v_somme_moyennes / v_total_etudiants;
    ELSE
        v_moyenne_classe := NULL; -- Aucun étudiant trouvé
    END IF;

    RETURN v_moyenne_classe;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL; -- Aucun enregistrement trouvé
    WHEN OTHERS THEN
        RETURN NULL; -- Autre erreur non gérée
END;
/

SELECT CalculerMoyenneClasseEC('INF1111', '2023-2024') FROM dual;


DECLARE
    v_moyenne_ec NUMBER;
BEGIN
    v_moyenne_ec := CalculerMoyenneClasseEC('INF1111', '2023-2024');
    DBMS_OUTPUT.PUT_LINE('Moyenne de classe pour EC INF1111 : ' || v_moyenne_ec);
END;
/

----------------------------------------------------------------------------------------------------------
-- 5. Qui renvoie la moyenne de classe pour une UE donnée
CREATE OR REPLACE FUNCTION CalculerMoyenneClasseUE(
    p_ue_code IN CHAR,   -- Code de l'UE (ex: 'INF111')
    p_annee IN CHAR      -- Année académique (ex: '2023-2024')
) RETURN NUMBER IS
    v_moyenne_classe NUMBER := 0;  -- Variable pour stocker la moyenne de classe
    v_total_etudiants NUMBER := 0; -- Nombre total d'étudiants ayant une note dans cette UE
    v_somme_moyennes NUMBER := 0;  -- Somme des moyennes des étudiants pour cette UE
BEGIN
    -- Calculer la somme des moyennes des étudiants et le nombre total d'étudiants
    SELECT SUM(N.Moyenne), COUNT(*)
    INTO v_somme_moyennes, v_total_etudiants
    FROM Note N
    JOIN EC E ON N.EC = E.Code
    WHERE E.UE = p_ue_code
    AND N.Annee = p_annee;

    -- Vérifier si des étudiants ont été trouvés
    IF v_total_etudiants > 0 THEN
        v_moyenne_classe := v_somme_moyennes / v_total_etudiants;
    ELSE
        v_moyenne_classe := NULL; -- Aucun étudiant trouvé
    END IF;

    RETURN v_moyenne_classe;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL; -- Aucun enregistrement trouvé
    WHEN OTHERS THEN
        RETURN NULL; -- Autre erreur non gérée
END;
/


SELECT CalculerMoyenneClasseUE('INF111', '2023-2024') FROM dual;


DECLARE
    v_moyenne_ue NUMBER;
BEGIN
    v_moyenne_ue := CalculerMoyenneClasseUE('INF111', '2023-2024');
    DBMS_OUTPUT.PUT_LINE('Moyenne de classe pour UE INF111 : ' || v_moyenne_ue);
END;
/

----------------------------------------------------------------------------------------------------------