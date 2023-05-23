# language: fr

Fonctionnalité: Le personnel de direction édite les PFMPs
  Contexte:
    Sachant que je suis directeur de l'établissement "DINUM"
    Et qu'il y a une élève "Marie Curie" au sein de la classe "3EMEB"
    Et que je me connecte
    Et que je clique sur "Voir les élèves" dans la rangée "3EMEB"
    Et que je clique sur "Voir le profil de l'élève" dans la rangée "Marie Curie"

  Scénario: Le personnel de direction peut voir le nombre de PFMP réalisée
    Quand l'élève n'a réalisé aucune PFMP
    Alors la page contient "Aucune PFMP enregistrée pour le moment."

  Scénario: Le personnel de direction peut rajouter une PFMP
    Quand je clique sur "Ajouter une PFMP"
    Et que je remplis "Date de début" avec "17/03/2023"
    Et que je remplis "Date de fin" avec "20/03/2023"
    Et que je clique sur "Enregistrer"
    Alors la page contient "La PFMP a été enregistrée avec succès"
    Et je peux voir dans le tableau "Périodes de formation en milieu professionnel (PFMP)"
      |      Début |        Fin | État       | Commentaire |
      | 2023-03-17 | 2023-03-20 | En attente |             |
