-- ============================================================
-- Projet 10 : requetes SQL qui reproduisent le nettoyage Python
-- ============================================================

-- 1. Nettoyage de la table sirh
--    Python : suppression de nombre_heures_travailless (constante a 80)
SELECT
    s.id_employee,
    s.age,
    s.genre,
    s.revenu_mensuel,
    s.statut_marital,
    s.departement,
    s.poste,
    s.nombre_experiences_precedentes,
    s.annee_experience_totale,
    s.annees_dans_l_entreprise,
    s.annees_dans_le_poste_actuel
FROM sirh AS s;
-- 2. Nettoyage de la table evaluation
--    Python : id_employee extrait de eval_number (colonne calculee en SQL),
--    pourcentage converti en nombre, Oui/Non en 1/0,
--    suppression de eval_number, renommage de augementation_...
SELECT
    e.id_employee,
    e.satisfaction_employee_environnement,
    e.note_evaluation_precedente,
    e.niveau_hierarchique_poste,
    e.satisfaction_employee_nature_travail,
    e.satisfaction_employee_equipe,
    e.satisfaction_employee_equilibre_pro_perso,
    e.note_evaluation_actuelle,
    CASE e.heure_supplementaires WHEN 'Oui' THEN 1 WHEN 'Non' THEN 0 END AS heure_supplementaires,
    CAST(TRIM(REPLACE(e.augementation_salaire_precedente, '%', '')) AS NUMERIC) AS augmentation_salaire_precedente
FROM evaluation AS e;
-- 3. Nettoyage de la table sondage
--    Python : a_quitte_l_entreprise en 1/0, suppression de
--    nombre_employee_sous_responsabilite, ayant_enfants et code_sondage,
--    renommage de annes_sous_responsable_actuel
SELECT
    d.id_employee,
    CASE d.a_quitte_l_entreprise WHEN 'Oui' THEN 1 WHEN 'Non' THEN 0 END AS a_quitte_l_entreprise,
    d.nombre_participation_pee,
    d.nb_formations_suivies,
    d.distance_domicile_travail,
    d.niveau_education,
    d.domaine_etude,
    d.frequence_deplacement,
    d.annees_depuis_la_derniere_promotion,
    d.annes_sous_responsable_actuel AS annees_sous_responsable_actuel
FROM sondage AS d;
-- 4. Jointure des 3 tables nettoyees (equivalent de charger_donnees en Python)
CREATE OR REPLACE VIEW employes_propres AS
WITH sirh_propre AS (
    SELECT
        s.id_employee, s.age, s.genre, s.revenu_mensuel, s.statut_marital,
        s.departement, s.poste, s.nombre_experiences_precedentes,
        s.annee_experience_totale, s.annees_dans_l_entreprise,
        s.annees_dans_le_poste_actuel
    FROM sirh AS s
),
evaluation_propre AS (
    SELECT
        e.id_employee,
        e.satisfaction_employee_environnement,
        e.note_evaluation_precedente,
        e.niveau_hierarchique_poste,
        e.satisfaction_employee_nature_travail,
        e.satisfaction_employee_equipe,
        e.satisfaction_employee_equilibre_pro_perso,
        e.note_evaluation_actuelle,
        CASE e.heure_supplementaires WHEN 'Oui' THEN 1 WHEN 'Non' THEN 0 END AS heure_supplementaires,
        CAST(TRIM(REPLACE(e.augementation_salaire_precedente, '%', '')) AS NUMERIC) AS augmentation_salaire_precedente
    FROM evaluation AS e
),
sondage_propre AS (
    SELECT
        d.id_employee,
        CASE d.a_quitte_l_entreprise WHEN 'Oui' THEN 1 WHEN 'Non' THEN 0 END AS a_quitte_l_entreprise,
        d.nombre_participation_pee, d.nb_formations_suivies,
        d.distance_domicile_travail, d.niveau_education, d.domaine_etude,
        d.frequence_deplacement, d.annees_depuis_la_derniere_promotion,
        d.annes_sous_responsable_actuel AS annees_sous_responsable_actuel
    FROM sondage AS d
)
SELECT *
FROM sirh_propre AS s
LEFT JOIN evaluation_propre AS e USING (id_employee)
LEFT JOIN sondage_propre AS d USING (id_employee);

SELECT COUNT(*) AS nb_employes FROM employes_propres;
-- 5. Statistiques descriptives par classe (reste = 0, parti = 1)
\x on
SELECT
    a_quitte_l_entreprise,
    COUNT(*) AS effectif,
    ROUND(AVG(age), 1) AS age_moyenne,
    ROUND(STDDEV(age), 1) AS age_ecart_type,
    MIN(age) AS age_min,
    MAX(age) AS age_max,
    ROUND(AVG(revenu_mensuel), 0) AS revenu_moyenne,
    ROUND(STDDEV(revenu_mensuel), 0) AS revenu_ecart_type,
    MIN(revenu_mensuel) AS revenu_min,
    MAX(revenu_mensuel) AS revenu_max,
    ROUND(AVG(annees_dans_l_entreprise), 1) AS anciennete_moyenne,
    ROUND(STDDEV(annees_dans_l_entreprise), 1) AS anciennete_ecart_type,
    MIN(annees_dans_l_entreprise) AS anciennete_min,
    MAX(annees_dans_l_entreprise) AS anciennete_max,
    ROUND(AVG(distance_domicile_travail), 1) AS distance_moyenne,
    ROUND(STDDEV(distance_domicile_travail), 1) AS distance_ecart_type,
    MIN(distance_domicile_travail) AS distance_min,
    MAX(distance_domicile_travail) AS distance_max,
    ROUND(AVG(annees_depuis_la_derniere_promotion), 1) AS promotion_moyenne,
    ROUND(STDDEV(annees_depuis_la_derniere_promotion), 1) AS promotion_ecart_type,
    MIN(annees_depuis_la_derniere_promotion) AS promotion_min,
    MAX(annees_depuis_la_derniere_promotion) AS promotion_max,
    ROUND(AVG(augmentation_salaire_precedente), 1) AS augmentation_moyenne,
    ROUND(STDDEV(augmentation_salaire_precedente), 1) AS augmentation_ecart_type,
    MIN(augmentation_salaire_precedente) AS augmentation_min,
    MAX(augmentation_salaire_precedente) AS augmentation_max
FROM employes_propres
GROUP BY a_quitte_l_entreprise
ORDER BY a_quitte_l_entreprise;
\x off