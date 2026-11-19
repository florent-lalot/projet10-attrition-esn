-- ============================================================
-- Projet 10 : creation des 3 tables (donnees RH brutes)
-- Les noms de colonnes sont ceux des fichiers CSV du SIRH,
-- fautes de frappe comprises : le nettoyage vient apres.
-- ============================================================

DROP TABLE IF EXISTS sondage;
DROP TABLE IF EXISTS evaluation;
DROP TABLE IF EXISTS sirh;

-- Fichier SIRH : donnees administratives
CREATE TABLE sirh (
    id_employee                     INTEGER PRIMARY KEY,
    age                             INTEGER,
    genre                           VARCHAR(1),
    revenu_mensuel                  INTEGER,
    statut_marital                  VARCHAR(30),
    departement                     VARCHAR(50),
    poste                           VARCHAR(50),
    nombre_experiences_precedentes  INTEGER,
    nombre_heures_travailless       INTEGER,
    annee_experience_totale         INTEGER,
    annees_dans_l_entreprise        INTEGER,
    annees_dans_le_poste_actuel     INTEGER
);

-- Fichier evaluation : l'identifiant est du texte ("E_1")
CREATE TABLE evaluation (
    satisfaction_employee_environnement         INTEGER,
    note_evaluation_precedente                  INTEGER,
    niveau_hierarchique_poste                   INTEGER,
    satisfaction_employee_nature_travail        INTEGER,
    satisfaction_employee_equipe                INTEGER,
    satisfaction_employee_equilibre_pro_perso   INTEGER,
    eval_number                                 VARCHAR(10) PRIMARY KEY,
    note_evaluation_actuelle                    INTEGER,
    heure_supplementaires                       VARCHAR(3),
    augementation_salaire_precedente            VARCHAR(10),
    -- cle etrangere calculee : "E_12" -> 12
    id_employee INTEGER GENERATED ALWAYS AS (SUBSTRING(eval_number FROM 3)::INTEGER) STORED
        REFERENCES sirh (id_employee)
);

-- Fichier sondage : le code garde ses zeros ("000001", "0000010", "00001470")
CREATE TABLE sondage (
    a_quitte_l_entreprise                   VARCHAR(3),
    nombre_participation_pee                INTEGER,
    nb_formations_suivies                   INTEGER,
    nombre_employee_sous_responsabilite     INTEGER,
    code_sondage                            VARCHAR(10) PRIMARY KEY,
    distance_domicile_travail               INTEGER,
    niveau_education                        INTEGER,
    domaine_etude                           VARCHAR(50),
    ayant_enfants                           VARCHAR(1),
    frequence_deplacement                   VARCHAR(20),
    annees_depuis_la_derniere_promotion     INTEGER,
    annes_sous_responsable_actuel           INTEGER,
    -- cle etrangere calculee : "000012" -> 12
    id_employee INTEGER GENERATED ALWAYS AS (code_sondage::INTEGER) STORED
        REFERENCES sirh (id_employee)
);
