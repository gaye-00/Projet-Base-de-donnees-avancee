CREATE TABLE Etudiant (
    Matricule CHAR(8),
    Nom VARCHAR2(15),
    Prenom VARCHAR2(60),
    Age SMALLINT,
    Sexe VARCHAR2(8),
    Email VARCHAR2(30),
    Niveau CHAR(2),
    CONSTRAINT pk_etudiant PRIMARY KEY (Matricule)
);

CREATE TABLE Semestre (
    Numero CHAR(1),
    Cycle VARCHAR2(8),
    Annee CHAR(9),
    CONSTRAINT pk_semestre PRIMARY KEY (Numero, Cycle)
);

CREATE TABLE UE (  
    Code CHAR(7),
    Libelle VARCHAR2(50),
    Coefficient SMALLINT,
    Credit SMALLINT,
    Semestre CHAR(1),
    Cycle VARCHAR2(8),
    CONSTRAINT pk_ue PRIMARY KEY (Code),
    CONSTRAINT fk_ue_semestre FOREIGN KEY (Semestre, Cycle) REFERENCES Semestre(Numero, Cycle)
);

CREATE TABLE EC (
    Code CHAR(7),
    Libelle VARCHAR2(50),
    Coefficient SMALLINT,
    Credit SMALLINT,
    UE CHAR(7),
    CONSTRAINT pk_ec PRIMARY KEY (Code),
    CONSTRAINT fk_ec_ue FOREIGN KEY (UE) REFERENCES UE (Code)
);

CREATE TABLE Note (
    Etudiant CHAR(8),
    EC CHAR(7),
    Annee CHAR(9),
    Controle NUMBER(4,2),
    Examen NUMBER(4,2),
    Moyenne NUMBER(4,2),
    CONSTRAINT pk_note PRIMARY KEY (Etudiant, EC),
    CONSTRAINT fk_note_etudiant FOREIGN KEY (Etudiant) REFERENCES Etudiant (Matricule),
    CONSTRAINT fk_note_ec FOREIGN KEY (EC) REFERENCES EC (Code)
);

CREATE TABLE Resultat (
    Etudiant CHAR(8),
    Semestre CHAR(1),
    Cycle VARCHAR2(8),
    Annee CHAR(9),
    Moyenne NUMBER(4, 2),
    Resultat VARCHAR2(7),
    Mention VARCHAR2(10),
    Rang SMALLINT,
    CONSTRAINT pk_resultat PRIMARY KEY (Etudiant, Semestre, Annee),
    CONSTRAINT fk_resultat_etudiant FOREIGN KEY (Etudiant) REFERENCES Etudiant (Matricule),
    CONSTRAINT fk_resultat_semestre FOREIGN KEY (Semestre, Cycle) REFERENCES Semestre (Numero, Cycle)
);
