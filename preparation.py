import pandas as pd
from sklearn.model_selection import train_test_split

def charger_donnees():
    # 1. Lecture
    sirh = pd.read_csv("data/extrait_sirh.csv")
    eval_df = pd.read_csv("data/extrait_eval.csv")
    sondage = pd.read_csv("data/extrait_sondage.csv")

    # 2. Clé commune
    eval_df["id_employee"] = eval_df["eval_number"].apply(lambda x: int(x.replace("E_", "")))

    # 3. Jointure
    df = (
    sirh
    .merge(eval_df, on="id_employee", how="left")
    .merge(sondage, left_on="id_employee", right_on="code_sondage", how="left")
    )

    # 4 à 7. Nettoyage

    # Conversion de l'augmentation de salaire
    df["augementation_salaire_precedente"] = df["augementation_salaire_precedente"].apply(
    lambda x: float(x.replace("%", "").strip())
    )
    # Encodage des colonnes Oui/Non
    df["a_quitte_l_entreprise"] = df["a_quitte_l_entreprise"].map({"Non": 0, "Oui": 1})
    df["heure_supplementaires"] = df["heure_supplementaires"].map({"Non": 0, "Oui": 1})

    # Suppression des colonnes inutiles et correction des noms
    df = df.drop(columns=[
    "nombre_heures_travailless",           # constante (80)
    "nombre_employee_sous_responsabilite", # constante (1)
    "ayant_enfants",                       # constante (Y)
    "code_sondage",                        # doublon de id_employee
    "eval_number",                         # doublon de id_employee
    ])

    df = df.rename(columns={
    "augementation_salaire_precedente": "augmentation_salaire_precedente",
    "annes_sous_responsable_actuel": "annees_sous_responsable_actuel",
    })

    return df

def preparer_donnees(df):
    # 1. Séparation cible / features
    y = df["a_quitte_l_entreprise"]
    X = df.drop(columns=["a_quitte_l_entreprise", "id_employee"])

    # 2. Suppression des colonnes redondantes
    X = X.drop(columns=["niveau_hierarchique_poste",
                        "annees_dans_le_poste_actuel",
                        "annees_sous_responsable_actuel"])

    # 3. Encodage ordinal
    ordre = {"Aucun": 0, "Occasionnel": 1, "Frequent": 2}
    X["frequence_deplacement"] = X["frequence_deplacement"].map(ordre)

    # 4. Encodage One Hot
    cols_onehot = ["genre", "statut_marital", "departement", "poste", "domaine_etude"]
    X = pd.get_dummies(X, columns=cols_onehot, drop_first=True, dtype=int)

    return X, y

def ajouter_features(X):
    X = X.copy()

    X["revenu_par_experience"] = X["revenu_mensuel"] / (X["annee_experience_totale"] + 1)
    X["stagnation"] = X["annees_depuis_la_derniere_promotion"] / (X["annees_dans_l_entreprise"] + 1)
    X["satisfaction_moyenne"] = X[[
        "satisfaction_employee_environnement",
        "satisfaction_employee_nature_travail",
        "satisfaction_employee_equipe",
        "satisfaction_employee_equilibre_pro_perso",
    ]].mean(axis=1)

    return X

def separer_train_test(X, y):
    return train_test_split(
        X, y,
        test_size=0.2,
        stratify=y,
        random_state=42
    )