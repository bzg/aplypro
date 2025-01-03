# language: fr

Fonctionnalité: Gestion des scolarités de l'élève
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que l'API SYGNE renvoie 10 élèves dans une classe "1MELEC" dont "Jean Dupuis" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et que je consulte le profil de "Jean Dupuis" dans la classe de "1MELEC"

  Scénario: Le personnel veut réintégrer un élève retiré manuellement de la classe
    Quand je clique sur "Retirer l'élève de la classe"
    Et que je clique sur "Confirmer le retrait de l'élève de la classe"
    Alors la page contient "L'élève Jean Dupuis a bien été retiré de la classe 1MELEC"
    Et je peux voir dans le tableau "Élèves retirés manuellement de la classe"
      | Élèves (1)    | Réintégration de l'élève dans la classe |
      | Dupuis Jean   | Réintégrer Jean Dupuis dans la classe 1MELEC |
    Quand je consulte le profil de "Jean Dupuis" dans la classe de "1MELEC"
    Alors la page contient "Retiré(e) manuellement de la classe"
    Quand je consulte la classe "1MELEC"
    Et que je clique sur "Réintégrer Jean Dupuis dans la classe 1MELEC"
    Et que je clique sur "Confirmer la réintégration de l'élève dans la classe"
    Alors la page ne contient pas "Élèves retirés manuellement de la classe"
    Quand je consulte le profil de "Jean Dupuis" dans la classe de "1MELEC"
    Alors la page contient "Retirer l'élève de la classe"
