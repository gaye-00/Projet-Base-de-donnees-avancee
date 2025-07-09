-- Drop TRIGGER MatriculeEtu;

-- 1. Qui attribue de manière automatique un numéro de matricule à chaque étudiant ;

CREATE OR REPLACE TRIGGER MatriculeEtu 
BEFORE INSERT ON Etudiant 
FOR EACH ROW
DECLARE
    m VARCHAR2(20); -- Utiliser VARCHAR2 pour éviter les problèmes de longueur fixe
    n NUMBER; -- Utiliser NUMBER pour les calculs numériques
    a VARCHAR2(4); -- Année en format chaîne
    v VARCHAR2(2); -- Niveau en format chaîne
BEGIN
    v := :New.Niveau;
    -- Compter le nombre d'étudiants dans le même niveau
    SELECT COUNT(*) INTO n FROM Etudiant WHERE Niveau = v;
    
    -- Déterminer l'année en fonction du niveau
    IF v = 'L1' THEN
        a := '2023';
    ELSIF v = 'L2' THEN
        a := '2022';
    ELSIF v = 'L3' THEN
        a := '2021';
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Niveau non valide.');
    END IF;
    
    -- Générer le matricule
    m := a || LPAD(n + 1, 3, '0'); -- Ajouter des zéros devant pour avoir 3 chiffres
    :New.Matricule := m;
END;
/

-- 2. Qui vérifie la validité du sexe qui ne peut prendre que Masculin ou Féminin ;

CREATE OR REPLACE TRIGGER SexeValide 
BEFORE INSERT OR UPDATE ON Etudiant 
FOR EACH ROW
BEGIN
    -- Vérification de la validité du sexe
    IF :NEW.Sexe NOT IN ('Masculin', 'Feminin') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Sexe non valide. Il doit être "Masculin" ou "Féminin".');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        -- Log de l'erreur dans la sortie DBMS
        DBMS_OUTPUT.PUT_LINE('Erreur lors de la vérification du sexe :' || SQLERRM);
        -- Relance l'exception pour qu'elle soit gérée par l'appelant
        RAISE;
END;
/

-- 3. Qui attribue de manière automatique une adresse e-mail à chaque nouvel étudiant ;


CREATE OR REPLACE TRIGGER EmailAutomatique
BEFORE INSERT ON Etudiant
FOR EACH ROW
DECLARE
    prenom_parts VARCHAR2(100);
    prenom_initial VARCHAR2(10);
    nom_initial VARCHAR2(2);
    email_count NUMBER;
BEGIN
    prenom_initial := '';
    
    -- Extraire la première lettre de chaque partie du prénom
    FOR i IN 1..LENGTH(:NEW.Prenom) - LENGTH(REPLACE(:NEW.Prenom, ' ', '')) + 1 LOOP
        prenom_parts := TRIM(REGEXP_SUBSTR(:NEW.Prenom, '[^ ]+', 1, i));
        prenom_initial := prenom_initial || LOWER(SUBSTR(prenom_parts, 1, 1));
    END LOOP;

    -- Prendre la première lettre du nom
    nom_initial := LOWER(SUBSTR(:NEW.Nom, 1, 1));

    -- Compter les emails existants avec le même préfixe (avant @)
    SELECT COUNT(*) INTO email_count
    FROM Etudiant e
    WHERE LOWER(SUBSTR(e.Email, 1, INSTR(e.Email, '@') - 1)) LIKE LOWER(prenom_initial || '.' || nom_initial || '%');

    -- Générer l'email
    IF email_count > 0 THEN
        :NEW.Email := prenom_initial || '.' || nom_initial || TO_CHAR(email_count + 1) || '@zig.univ.sn';
    ELSE
        :NEW.Email := prenom_initial || '.' || nom_initial || '@zig.univ.sn';
    END IF;

END;
/


-- 4. Qui attribue de manière automatique les codes des UE ;

CREATE OR REPLACE TRIGGER GenerateUECode
BEFORE INSERT ON UE
FOR EACH ROW
DECLARE
    num_licence CHAR(1);
    num_ue NUMBER;
    ue_count NUMBER;
BEGIN
    -- Déterminer le numéro de licence en fonction du semestre
    CASE :NEW.Semestre
        WHEN '1' THEN num_licence := '1';
        WHEN '2' THEN num_licence := '1';
        WHEN '3' THEN num_licence := '2';
        WHEN '4' THEN num_licence := '2';
        WHEN '5' THEN num_licence := '3';
        WHEN '6' THEN num_licence := '3';
        ELSE
            RAISE_APPLICATION_ERROR(-20002, 'Semestre invalide');
    END CASE;

    -- Compter le nombre d'UE déjà existantes dans ce semestre et cycle
    SELECT COUNT(*) INTO ue_count
    FROM UE
    WHERE Semestre = :NEW.Semestre AND Cycle = :NEW.Cycle;

    -- Calculer le numéro de l'UE en ajoutant 1 au nombre existant
    num_ue := ue_count + 1;

    -- Générer le code de l'UE (sans LPAD pour éviter les 01, 02...)
    :NEW.Code := 'INF' || num_licence || :NEW.Semestre || num_ue;
END;
/


-- 5. Qui attribue de manière automatique les codes des EC 

CREATE OR REPLACE TRIGGER GenerateECCode
BEFORE INSERT ON EC
FOR EACH ROW
DECLARE
    ue_code VARCHAR2(7); -- Utiliser VARCHAR2 pour éviter les espaces inutiles
    ec_count NUMBER;
BEGIN
    -- Vérifier si l'UE existe et récupérer son code
    SELECT TRIM(Code) INTO ue_code FROM UE WHERE Code = :NEW.UE;

    -- Compter le nombre d'EC déjà existants pour cette UE
    SELECT COUNT(*) INTO ec_count FROM EC WHERE UE = :NEW.UE;

    -- Générer le code EC (ajout d'un chiffre à la fin du code UE)
    :NEW.Code := ue_code || TO_CHAR(ec_count + 1);

    -- Vérifier la longueur du code généré
    IF LENGTH(:NEW.Code) > 7 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Code EC trop long : ' || :NEW.Code);
    END IF;
END;
/

-- 6. Qui Calcule et modifie la moyenne de l’EC pour chaque étudiant dès que les notes de 
-- contrôle et d’examen sont données (Insertion ou modification) ;

CREATE OR REPLACE TRIGGER CalculateECMoyenne
BEFORE INSERT OR UPDATE ON Note
FOR EACH ROW
BEGIN
    -- Vérifier si les notes de contrôle et d'examen sont valides
    IF :NEW.Controle IS NOT NULL AND :NEW.Examen IS NOT NULL THEN
        -- Calcul de la moyenne selon un coefficient (exemple : 30% contrôle, 70% examen)
        :NEW.Moyenne := (:NEW.Controle * 0.3) + (:NEW.Examen * 0.7);
    ELSE
        -- Si l'une des notes est NULL, mettre la moyenne à NULL
        :NEW.Moyenne := NULL;
    END IF;
END;
/

-- 7. Qui vérifie la validité du résultat qui ne peut prendre que Valide ou Ajourne.
CREATE OR REPLACE TRIGGER CheckValidResultat
BEFORE INSERT OR UPDATE ON Resultat
FOR EACH ROW
BEGIN
    -- Vérifier si le résultat est soit 'Valide' soit 'Ajourne'
    IF :NEW.Resultat NOT IN ('Valide', 'Ajourne') THEN
        RAISE_APPLICATION_ERROR(-20004, 'Le résultat doit être "Valide" ou "Ajourne".');
    END IF;
END;
/












