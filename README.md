# pharma-dbt-fabric
Pipeline de données sur les effets indésirables médicamenteux (openFDA) avec dbt et Microsoft Fabric

Problématique de pharmacovigilance : quels médicaments génèrent
le plus de signalements d'effets indésirables graves, 
et avec quelles réactions ces signalements sont-ils le plus souvent associés ?

## Défis rencontrés et décisions prises

**Biais d'échantillonnage détecté** : sur les 500 premiers rapports extraits,
499 étaient marqués comme doublons par openFDA — un seul lot de soumissions
en masse par un même fabricant dominait l'échantillon. Détecté via un simple
`GROUP BY` de vérification après l'implémentation du dédoublonnage en couche
intermediate, pas anticipé au départ.

**Décision** : extraction élargie à 20 000 rapports pour diluer cet effet.

**Vrai diagnostic** : l'API openFDA renvoie ses résultats dans un ordre
interne non documenté. Les `report_id` doublons se suivaient en séquence
quasi continue, signe d'un unique gros lot de soumissions en masse regroupé
par cet ordre par défaut. Élargir le volume dans le même ordre ne fait que
rester dans ce même bloc.

**Correction effective** : ajout d'un tri explicite (`sort=receivedate:asc`)
pour parcourir les rapports par date plutôt que dans l'ordre interne de
l'API. Résultat : 397/20 000 (~2%) de doublons — un taux cohérent avec la
littérature sur les données FAERS.

**Contrainte technique découverte** : l'API openFDA plafonne `skip` à 25 000,
soit un maximum de 26 000 rapports accessibles par pagination simple
(skip/limit). Au-delà, la stratégie `search_after` (curseur) serait
nécessaire — hors scope pour ce projet, le plafond de 20 000 restant
largement suffisant pour répondre à la question business posée.