# Projet 10 : Prédiction de l'attrition en ESN

## Contexte

Une ESN (Entreprise de Services du Numérique) emploie des profils techniques
(développeurs, data analysts, consultants) qu'elle place chez ses clients.
Ces profils étant très demandés, le taux d'attrition (départ des salariés)
y est élevé, et chaque départ coûte cher : recrutement, formation du remplaçant,
perte de compétences.

## Objectif

Ce projet vise à :

- comprendre quelles caractéristiques des salariés sont liées à leur départ
  (analyse exploratoire) ;
- construire un modèle de classification binaire (parti / resté) qui prédit
  le risque de départ, en le comparant à des modèles de référence
  (benchmarks) avec des métriques adaptées aux classes déséquilibrées.

## Données

Trois extractions RH, reliées par l'identifiant de l'employé :

- le SIRH (âge, poste, revenu, ancienneté…) ;
- les évaluations annuelles ;
- un sondage de satisfaction.

Après jointure et nettoyage : 1 470 employés, dont 237 partis (16,1 %).
La cible est `a_quitte_l_entreprise`.

## Gestion de l'environnement : pourquoi uv

Le projet utilise [uv](https://docs.astral.sh/uv/) pour gérer l'environnement
Python et les dépendances.

- **Reproductibilité :** `pyproject.toml` liste les bibliothèques utilisées, et
  `uv.lock` fige la version exacte de chacune, y compris leurs dépendances
  indirectes. Toute personne qui clone le dépôt obtient le même environnement,
  donc les mêmes résultats.
- **Isolation :** les bibliothèques sont installées dans un environnement
  virtuel propre au projet (`.venv`), sans toucher au Python du système ni aux
  autres projets.
- **Simplicité :** une seule commande, `uv sync`, crée l'environnement et
  installe tout. `uv add <bibliothèque>` ajoute une dépendance et met à jour
  les deux fichiers.

Un simple `requirements.txt` avec pip ne fige pas les dépendances indirectes.
Poetry remplit le même rôle que uv ; uv a été retenu pour sa rapidité et parce
qu'il gère aussi l'installation de la version de Python.

## Installation

```bash
git clone https://github.com/florent-lalot/projet10-attrition-esn.git
cd projet10-attrition-esn
uv sync
```

`uv sync` crée l'environnement virtuel `.venv` avec la bonne version de Python
et installe les dépendances listées dans `pyproject.toml`.

## Utilisation

Ouvrir les notebooks dans VS Code ou Jupyter, sélectionner le noyau `.venv`
du projet, puis les exécuter dans l'ordre :

| Notebook                | Contenu                                                                                                                                 |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `01_exploration.ipynb`  | Analyse exploratoire des trois fichiers                                                                                                 |
| `02_preparation.ipynb`  | Jointure, nettoyage, encodage, étude des corrélations                                                                                   |
| `03_modelisation.ipynb` | Premiers modèles : Dummy, régression logistique, Random Forest, XGBoost                                                                 |
| `04_amelioration.ipynb` | Déséquilibre des classes, seuil de décision, overfitting, feature engineering, SMOTE                                                    |
| `05_optimisation.ipynb` | Recherche d'hyperparamètres, choix du modèle final, évaluation sur le test, interprétation (coefficients, Permutation Importance, SHAP) |

Les fonctions de chargement et de préparation sont regroupées dans
`preparation.py` et réutilisées par les notebooks 03 à 05.

## Structure du projet

```text
projet10-attrition-esn/
├── 01_exploration.ipynb
├── 02_preparation.ipynb
├── 03_modelisation.ipynb
├── 04_amelioration.ipynb
├── 05_optimisation.ipynb
├── preparation.py
├── pyproject.toml
├── uv.lock
├── Soutenance_Projet10_Attrition_ESN.pptx
└── README.md
```

## Résultats

Modèle retenu : **régression logistique** (`C = 0,1`, variables standardisées),
avec un seuil de décision de 0,20. À performance égale avec un XGBoost optimisé
(PR-AUC de 0,658 contre 0,652 en validation croisée répétée), le modèle le plus
simple a été retenu.

Sur le jeu de test (294 employés, 47 départs), utilisé une seule fois :

| Recall                             | Precision                 | F1   |
| ---------------------------------- | ------------------------- | ---- |
| 0,66 (31 départs retrouvés sur 47) | 0,44 (40 fausses alertes) | 0,53 |

Facteurs les plus liés au départ : les heures supplémentaires, puis le nombre
d'expériences précédentes, les années depuis la dernière promotion et la
fréquence des déplacements.

## Limites

- Seulement 47 départs dans le jeu de test : les scores sont sensibles à
  quelques employés.
- Les liens observés sont des corrélations, pas des causes.
- Les raisons personnelles de départ (offre extérieure, déménagement…) ne
  figurent pas dans les données.
- Le modèle sert à prioriser des entretiens RH, pas à décider automatiquement
  du sort d'un salarié.
