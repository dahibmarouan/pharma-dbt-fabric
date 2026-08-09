# Pharma DBT Fabric

Pipeline de données sur les effets indésirables médicamenteux, construit avec
Python, dbt et DuckDB — projet portfolio pour une reconversion vers le métier
d'Analytics Engineer.

## Question business

Ce projet répond à une question de pharmacovigilance : quels médicaments
génèrent le plus de signalements d'effets indésirables graves, et avec
quelles réactions ces signalements sont-ils le plus souvent associés ?

Source : rapports d'effets indésirables (FAERS) via l'API publique openFDA.

## Architecture

- **Extraction** : script Python paginant sur l'API openFDA, sauvegarde en JSON brut.
- **Chargement** : DuckDB lit les fichiers JSON directement, sans étape de copie séparée.
- **Transformation (dbt)**, en trois couches :
  - `staging` : nettoyage, typage, aplatissement du JSON imbriqué.
  - `intermediate` : dédoublonnage des rapports et propagation aux médicaments/réactions.
  - `marts` : deux tables de faits (`fct_drug_adverse_events`, `fct_reaction_adverse_events`) répondant à la question business.
- **Restitution** : dashboard Power BI (à venir, en attente d'un accès Microsoft Fabric).

### Pourquoi DuckDB plutôt que Microsoft Fabric

Le projet visait initialement Microsoft Fabric. L'essai gratuit s'est heurté à
une restriction d'éligibilité liée aux tenants personnels récemment créés
(problème documenté, indépendant de la configuration du projet). Le
développement a été découplé de l'entrepôt cible : le projet tourne sur
DuckDB en local, et grâce aux adaptateurs dbt, basculer vers Fabric (ou tout
autre entrepôt) ne nécessite qu'un changement de configuration, sans
réécriture du SQL.

## Comment lancer ce projet

1. Cloner le repo et créer un environnement virtuel :
```bash
   git clone https://github.com/dahibmarouan/pharma-dbt-fabric.git
   cd pharma-dbt-fabric
   py -3.12 -m venv venv
   .\venv\Scripts\Activate.ps1
   pip install -r requirements.txt
```

2. Créer un fichier `.env` à la racine avec une clé API openFDA gratuite
   (obtenue sur https://open.fda.gov/apis/authentication/)

3. Lancer l'extraction des données brutes :
```bash
   python scripts/extract_openfda.py
```

4. Construire et tester le projet dbt :
```bash
   cd pharma_project
   dbt build
```

5. (Optionnel) Générer et consulter la documentation :
```bash
   dbt docs generate
   dbt docs serve
```

## Défis rencontrés et décisions prises

**Biais d'échantillonnage détecté** : sur les 500 premiers rapports extraits,
499 étaient marqués comme doublons par openFDA.

**Première hypothèse (invalidée)** : élargir l'échantillon à 20 000 rapports
suffirait à diluer le biais. Vérification après extraction : 19 380/20 000
(96,9%) toujours marqués doublons — l'hypothèse était fausse.

**Vrai diagnostic** : l'API openFDA renvoie ses résultats dans un ordre
interne non documenté. Les identifiants de rapports doublons se suivaient en
séquence quasi continue, signe d'un unique gros lot de soumissions en masse
regroupé par cet ordre par défaut.

**Correction effective** : ajout d'un tri explicite (`sort=receivedate:asc`)
pour parcourir les rapports par date plutôt que dans l'ordre interne de
l'API. Résultat : ~2% de doublons — un taux cohérent avec la littérature sur
les données FAERS. Un dédoublonnage défensif a également été ajouté côté
extraction pour se prémunir des chevauchements de pagination.

**Contrainte technique découverte** : l'API openFDA plafonne `skip` à
25 000, soit un maximum de 26 000 rapports accessibles par pagination
simple (skip/limit). Au-delà, la stratégie `search_after` (curseur) serait
nécessaire — hors scope pour ce projet.