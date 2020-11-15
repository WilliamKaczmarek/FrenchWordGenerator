Pour exécuter notre programme, il faut tout d’abord ouvrir un terminal et le compiler :
fpc projet.pas puis l’exécuter avec la commande ./projet.pas.
Devant nous apparaissent donc les instructions pour exécuter notre programme, il ne reste plus qu’à choisir la méthode que l’on souhaite utiliser pour générer des mots. On va ensuite retaper la commande en y ajoutant les
instructions que l’on souhaite, par exemple pour lancer notre programme avec la méthode trigramme et avoir des mots de 6 lettres, on écrit :
./projet -n -s 6 -t dico où ”dico” correspond au dictionnaire avec lequel on va faire notre trigramme.
Il n’y a aucun ordre particulier à respecter, on doit simplement choisir une des 3 méthodes -a ou -d ou -t avec -n plus un nombre de mots que l’on souhaite générer. Par défaut il y en a 100. Si on le souhaite, on peut ajouter l’argument -s plus ESPACE un nombre pour préciser le nombre de lettres/caractères de nos mots(Si il n’y a aucun nombre après -s le programme générera respectivement 3 et 4 lettres pour la méthode digramme et trigramme). Si l’on veut générer une phrase, on met seulement l’argument -p ce qui va nous générer une phrase aléatoire pouvant contenir :
-sujet+verbe
-sujet+verbe+adjectif
-sujet+verbe+adverbe+adjectif
Le sujet est aléatoirement article+nomCommun ou juste nomPropre.
ATTENTION: Veuillez utiliser le programme avec les dictionnaires fournis dans le dossier, si vous souhaitez en utiliser d'autres, faites attention à ce qu'ils ne contiennent que les caractères de la constante 'alphabet' de l'algorithme.
