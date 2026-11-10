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

## Installation

Le projet utilise [uv](https://docs.astral.sh/uv/) pour gérer l'environnement.

```bash
git clone https://github.com/florent-lalot/projet10-attrition-esn.git
cd projet10-attrition-esn
uv sync
```

`uv sync` crée l'environnement virtuel `.venv` avec la bonne version de Python
et installe les dépendances listées dans `pyproject.toml`.
Pour ouvrir les notebooks, sélectionner le noyau `.venv` du projet dans VS Code
ou Jupyter.
