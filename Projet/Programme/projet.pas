program affectation;
{$mode objfpc}{$H+}
{$codepage UTF8}
{$I-}

USES
cwstring, crt, sysutils;

CONST
alphabet : WideString ='abcdefghijklmnopqrstuvwxyzàâéèêëîïôùûüÿæœç-';
voyelle : WideString = 'aeyuioàâéèêëîïôùûüÿæœ'; //Utile lorsqu'on génère un mot aleatoirement avec des voyelles
//Simplifie l'utilisation des fichiers
adjectif: String = 'adjectif.txt';	
adverbe: String = 'adverbe.txt';
article: String = 'article.txt';
NomCommun: String = 'nomCommun.txt';
NomPropre: String = 'nomPropre.txt';
Verbe: String = 'verbePremierEtDeuxiemeGroupe.txt';


Type Debut_Fin = record //Tableau 1 à 43 qui gère les premières et dernières lettres
			DebutEtFin: integer;
			Debut : integer;
			Fin : integer;
			End;
	TableauTrigramme = record //Tableau utiliser pour le digramme et trigramme
			Debut: integer;
			Fin: integer;
			Compteur: integer;	
			End;	
	Trigramme = array [1..43] of array [1..43] of array [0..43] of TableauTrigramme; //Grille alphabet*alphabet->digramme * alphabet->Trigramme
	Tableau2D = array [1..43] of array [1..43] of integer;
	Tableau3D = array [1..43] of array [1..43] of array [1..43] of integer;
	DebFin = array [1..43] of Debut_Fin;
	LesTableaux = record
			Tri : Trigramme;
			DF : DebFin;
			End;
	
///////////////////////////////////////Tableau de probabilite du digramme et trigramme///////////////////////////////////////
	
{****************************************************************************
                           FONCTION Initialisation a 0 de tout
                           * les tableaux
****************************************************************************}
function initialisationTri():LesTableaux;
Var
Tableau:LesTableaux;
i,j,k:integer;
Begin
	TextColor(Brown);
	for i:=1 to 43 do//Ligne
	Begin
		for j:=1 to 43 do//colonne
		Begin
			for k:=0 to 43 do//tableau 3D
			Begin
				Tableau.Tri[j][i][k].Compteur:=0;
				Tableau.Tri[j][i][k].Debut:=0;
				Tableau.Tri[j][i][k].Fin:=0;
			End;
		End;
	End;
	for i:=1 to 43 do//Tableau du Debut et de la Fin
		Begin
			Tableau.DF[i].DebutEtFin:=0;
			Tableau.DF[i].Debut:=0;
			Tableau.DF[i].Fin:=0;
		End;
	writeln('Initialisation...Fait');
	initialisationTri:=Tableau;
End;
	
	

{****************************************************************************
		FONCTION ProbasDesDebutFin
		* Sommation du tableau des débuts et des fins
		* Les sommations du programme sont très importantes car c'est grâce 
		* à cela que l'on va pouvoir sortir une lettre en fonction des probabilités
****************************************************************************}
function ProbasDesDebutFin(Tableau:LesTableaux):LesTableaux;
Var 
i:integer;
Begin
TextColor(11);
{Sommation des probas integer}
for i:=2 to 43 do
	Begin
	Tableau.DF[i].Debut:=Tableau.DF[i].Debut+Tableau.DF[i-1].Debut;
	Tableau.DF[i].Fin:=Tableau.DF[i].Fin+Tableau.DF[i-1].Fin;
	End;
	writeln('Probabilités Début/Fin...Fait');
ProbasDesDebutFin:=Tableau;
End;

{****************************************************************************
    FONCTION Sommation des compteurs a la couche 0
    * Dans le programme la couche 0 du trigramme correspond au digramme
****************************************************************************}
procedure ProbabiliteDi(Tableau:LesTableaux;Var Tableau1:LesTableaux);
var 
i,j:integer;
Begin
Tableau1:=Tableau;
for i:=1 to 43 do
	Begin
	for j:=2 to 43 do
		Begin
		Tableau1.Tri[j][i][0].Compteur:=Tableau1.Tri[j-1][i][0].Compteur+Tableau1.Tri[j][i][0].Compteur;//On somme
		End;
	End;
	Delay(100);
	writeln('Probabilités Digramme...Fait');
End;

{****************************************************************************
    FONCTION Sommation des Compteurs a toute les couches
    * Ici on somme toutes les couches du trigramme 
****************************************************************************}
procedure SommationProba3D(Tableau:LesTableaux;Var Tableau1:LesTableaux);
var 
i,j,k:integer;
Begin
Tableau1:=Tableau;
for i:=1 to 43 do
	Begin
	for j:=1 to 43 do
		Begin
		for k:=2 to 43 do
			Begin
			Tableau1.Tri[j][i][k].Compteur:=Tableau1.Tri[j][i][k].Compteur+Tableau1.Tri[j][i][k-1].Compteur;
			End;
		End;
	End;
	Delay(100);
	writeln('Probabilités Trigramme...Fait');
End;

{****************************************************************************
    FONCTION Sommation des lettre qui sont seules
****************************************************************************}
procedure SommationProbaLettreSeule(Tableau:LesTableaux;Var Tableau1:LesTableaux);
var 
i:integer;
Begin
Tableau1:=Tableau;
for i:=2 to 43 do 
	Begin
	Tableau1.DF[i].DebutEtFin:=Tableau1.DF[i].DebutEtFin+Tableau1.DF[i-1].DebutEtFin;	
	End;
	Delay(100);
	writeln('Probabilités Lettre Unique...Fait');
End;


{****************************************************************************
    PROCEDURE Affectation des nombre aux Tableaux avec le dictionnaire
    Ici je fais une procedure car on est a 25ligne et avec une fonction on serai a 26
    * Dans cette procedure j'affecte toutes les valeurs au tableau en fonction 
    * de la ligne analyser du dictionnaire
    * A la fin de l'analyse, on a un tableau rempli et il reste juste à le sommer
****************************************************************************}
procedure AffectationTri(Var Tableau:LesTableaux;Document:String);//pas oublier de le renvoyer
Var
x,i:integer;
Fichier : text;
ligne : WideString;
Begin
Tableau:=initialisationTri();//Initialisation obligatoire
Assign(Fichier, Document);{On met le paramètre FILE dans la variable Fichier}
//Ici le Documents est une variable car on utilise la même fonction pour la génération de phrase
Reset(Fichier);//On lit uniquement le fichier
x:=0; //On initialise le nombre de mot
while (not EOF(Fichier)) do //On analyse la ligne suivante du dictionnaire tant qu'il est pas finit
Begin
x:=x+1;//Nombre de mot dans le dictionnaire
readln(Fichier,ligne); //On lit la ligne actuelle 
ClrScr; //Ici c'est uniquement pour la lisibilité 
writeln('Analyse du mot : ',x); //Très utile car permet de suivre l'avancement du programme notemment lorsque le dico est très long (comme 330'000 mots)
if (length(ligne)=1) then Tableau.DF[pos(ligne[1],alphabet)].DebutEtFin:=Tableau.DF[pos(ligne[1],alphabet)].DebutEtFin+1; //Dans le cas où la lettre est seule
if (length(ligne)>1) then //On complete le digramme.Debut et .Fin dans le cas où il y a au moins 2 caracteres
	Begin
	Tableau.Tri[pos(ligne[2],alphabet)][pos(ligne[1],alphabet)][0].Debut:=Tableau.Tri[pos(ligne[2],alphabet)][pos(ligne[1],alphabet)][0].Debut+1;
	Tableau.Tri[pos(ligne[length(ligne)],alphabet)][pos(ligne[length(ligne)-1],alphabet)][0].Fin:=Tableau.Tri[pos(ligne[length(ligne)],alphabet)][pos(ligne[length(ligne)-1],alphabet)][0].Fin+1;
	End;
if (length(ligne)>2) then //On complete le trigramme .Debut et .Fin dans le cas où il y a au moins 3 caracteres
	Begin
	Tableau.Tri[pos(ligne[2],alphabet)][pos(ligne[1],alphabet)][pos(ligne[3],alphabet)].Debut:=Tableau.Tri[pos(ligne[2],alphabet)][pos(ligne[1],alphabet)][pos(ligne[3],alphabet)].Debut+1;
	Tableau.Tri[pos(ligne[length(ligne)-1],alphabet)][pos(ligne[length(ligne)-2],alphabet)][pos(ligne[length(ligne)],alphabet)].Fin:=Tableau.Tri[pos(ligne[length(ligne)-1],alphabet)][pos(ligne[length(ligne)-2],alphabet)][pos(ligne[length(ligne)],alphabet)].Fin+1;
	End;
Tableau.DF[pos(ligne[1],alphabet)].Debut:= Tableau.DF[pos(ligne[1],alphabet)].Debut+1;//On ajoute 1 au compteur de cette lettre au début
Tableau.DF[pos(ligne[length(ligne)],alphabet)].Fin:= Tableau.DF[pos(ligne[length(ligne)],alphabet)].Fin+1;//On ajoute 1 au compteur de cette lettre a la fin
for i:=2 to length(ligne) do
	Begin //On ajoute 1 au compteur1 de cettre lettre suivie d'elle (digramme)
		Tableau.Tri[pos(ligne[i],alphabet)][pos(ligne[i-1],alphabet)][0].Compteur:=Tableau.Tri[pos(ligne[i],alphabet)][pos(ligne[i-1],alphabet)][0].Compteur+1; //On ajoute 1 à cette lettre suivie d'elle au compteur1
	End;
for i:=3 to length(ligne) do 
	Begin //On ajoute 1 au compteur1 de cettre lettre suivie de cette lettre suivie d'elle (trigramme)
	Tableau.Tri[pos(ligne[i-1],alphabet)][pos(ligne[i-2],alphabet)][pos(ligne[i],alphabet)].Compteur:=Tableau.Tri[pos(ligne[i-1],alphabet)][pos(ligne[i-2],alphabet)][pos(ligne[i],alphabet)].Compteur+1;
	End;
End;
close(Fichier); //On ferme le fichier
writeln('Il y a : ',x,' mots'); //Pour l'utilisateur
Tableau:=ProbasDesDebutFin(Tableau);//creation des probas de lettre au début et fin
End;


///////////////////////////////////////Generation du mot avec le trigramme ou le digramme avec differents cas///////////////////////////////////////
{****************************************************************************
			FONCTION Generation des deux premieres lettres dans le cas ou 
			* le digramme ou le trigramme est executé sans nombre finie de 
			* caractere
			* On notera que le trigramme/digramme sans caractere finit ne générera
			* jamais de lettre seule 
****************************************************************************}
function GenerationDeuxPremieresLettre(Tableau:LesTableaux):WideString;
var 
r,i,alea:integer;
Mot:WideString;
Begin
repeat
	Mot:=''; //initialisation du mot
	r:=0; //Variable nécéssaire pour la prochaine boucle
	alea:=random(Tableau.DF[43].Debut)+1;//On prend un nombre aléatoire entre 1 et le nombre de la derniere case du tableau (La sommation est nécéssaire)
	for i:=1 to 43 do
		Begin 
		//write(Tableau.DF[i].Fin,' ');
		if (alea<=Tableau.DF[i].Debut) and (r=0) then r:=i; //Lorsque la lettre est tirée on met sa correspondance en nombre dans la variable r
		End;
	Mot:=Mot+alphabet[r]; //On aurait pu faire Mot:=alphabet[r] pour ne pas avoir a initialiser la variable mais c'est mieux en cas de bug
	alea:=(random(Tableau.Tri[43][pos(Mot[length(Mot)],alphabet)][0].Compteur)+1);//Ici on tire aussi une lettre grace au digramme car on ne possède qu'une lettre donc 
	//la génération avec le trigramme est impossible
	r:=0; //On re-initialise à 0 la variable r car on va re-tirer une lettre
	for i:=1 to 43 do
		Begin
		if (alea<=Tableau.Tri[i][pos(Mot[1],alphabet)][0].Compteur) and (r=0) then r:=i; //On tire une lettre grace au digramme
		End;
	Mot:=Mot+alphabet[r]; //On ajoute la lettre piochée 
Until Mot[1]<>Mot[2]; //On refait la procedure jusqu'a ce que les deux premieres lettres soient differentes car un mot ne commence jamais un mot avec deux mêmes lettres
GenerationDeuxPremieresLettre:=Mot; //On renvoie les deux premieres lettre
End;



{****************************************************************************
			FONCTION Genere la suite des lettres dans le cas où on génère 
			* un mot sans nombre de caractere finit
			* la méthode Digramme
****************************************************************************}
function SuiteLettreDigramme(Mot2:WideString;Tableau:LesTableaux):WideString;
Var
alea,i,r,inf:integer;
Mot:WideString;
Begin
repeat
	Mot:=Mot2; //On ajoute les deux premieres lettre au Mot
	alea:=random(Tableau.DF[43].Fin)+1; //On prend un nombre aleatoire pour la probabilite de fin du mot
	if (pos(Mot[length(Mot)],alphabet)=1) then inf:=0 else inf:=Tableau.DF[pos(Mot[length(Mot)],alphabet)-1].Fin; //On défini l'intervalle où la lettre est la dernière
	while ((alea<=inf) or (alea>Tableau.DF[pos(Mot[length(Mot)],alphabet)].Fin)) do //Du moment que la derniere lettre n'est pas dans l'intervalle on continue de générer des lettres
		Begin
		alea:=random(Tableau.Tri[43][pos(Mot[length(Mot)],alphabet)][0].Compteur)+1; //Nombre aleatoire parmis le digramme (Tableau[total de la somme de la ligne][dernière lettre][couche du digramme])
		if (Tableau.Tri[43][pos(Mot[length(Mot)],alphabet)][0].Compteur=0) then exit(Mot); //Si le cas n'a jamais été rencontrer alors on retourne le mot actuel
		r:=0; //On remet à 0 la condition
		for i:=1 to 43 do
			Begin
			if ((r=0) and (alea<=Tableau.Tri[i][pos(Mot[length(Mot)],alphabet)][0].Compteur)) then r:=i; //On cherche la lettre d'après
			End;
		if (r=0) then writeln('Pb dans la function suite lettre trigramme'); //Ceci est un cas qu'on est censé jamais rencontrer mais si cela s'affiche, on sait d'où vient le probleme
		Mot:=Mot+alphabet[r]; //On ajoute la lettre suivante au Mot 
		alea:=random(Tableau.DF[43].Fin)+1; //On reprend un nombre aleatoire pour la probabilite de fin de mot
		if (pos(Mot[length(Mot)],alphabet)=1) then inf:=0 else inf:=Tableau.DF[pos(Mot[length(Mot)],alphabet)-1].Fin; //On re-définit l'intervalle où la lettre est la dernière
		End;
until Mot[length(Mot)]<>Mot[length(Mot)-1]; //On refait cette function jusqu'a ce que les deux dernières lettres ne soient pas identiques
SuiteLettreDigramme:=Mot; //On revoie la fin du mot
End;





{****************************************************************************
			FONCTION Genere la suite des lettres dans le cas où on génère 
			* un mot sans nombre de caractere finit
			* la méthode Trigramme
			* On fait exactement la même chose que pour le digramme sauf que 
			* maintenant on travail sur le tableau :
			* Tableau[dernière lettre][avant dernière lettre][lettre qu'on cherche]
			* le fonctionnement est le meme que la fonction précédente
****************************************************************************}
function SuiteLettreTrigramme(Mot2:WideString;Tableau:LesTableaux):WideString;
Var
alea,i,r,inf:integer;
Mot:WideString;
Begin
repeat
	Mot:=Mot2;
	alea:=random(Tableau.DF[43].Fin)+1;
	if (pos(Mot[length(Mot)],alphabet)=1) then inf:=0 else inf:=Tableau.DF[pos(Mot[length(Mot)],alphabet)-1].Fin;
	while ((alea<=inf) or (alea>Tableau.DF[pos(Mot[length(Mot)],alphabet)].Fin)) do
		Begin
		alea:=(random(Tableau.Tri[pos(Mot[length(Mot)],alphabet)][pos(Mot[length(Mot)-1],alphabet)][43].Compteur)+1);
		if (Tableau.Tri[pos(Mot[length(Mot)],alphabet)][pos(Mot[length(Mot)-1],alphabet)][43].Compteur=0) then exit(Mot);
		r:=0;
		for i:=1 to 43 do
			Begin
			if ((r=0) and (alea<=Tableau.Tri[pos(Mot[length(Mot)],alphabet)][pos(Mot[length(Mot)-1],alphabet)][i].Compteur)) then r:=i;
			End;
		if (r=0) then writeln('Pb dans la function suite lettre trigramme'); //Cas théoriquement impossible
		Mot:=Mot+alphabet[r];
		alea:=random(Tableau.DF[43].Fin)+1;
		if (pos(Mot[length(Mot)],alphabet)=1) then inf:=0 else inf:=Tableau.DF[pos(Mot[length(Mot)],alphabet)-1].Fin;
		End;
until Mot[length(Mot)]<>Mot[length(Mot)-1];
SuiteLettreTrigramme:=Mot;
End;

{****************************************************************************
    FONCTION Creation de la lettre dans le cas où il y a qu'un seul caractere
    * RENVOIE UN CARACTERE
****************************************************************************}

function UnSeulCaractere(Tableau:LesTableaux):WideString;
Var 
i,alea:integer;
Begin
alea:=random(Tableau.DF[43].DebutEtFin)+1;//On prend une lettre seule aleatoire qui a ete rencontree dans le dico 
for i:=1 to 43 do
	Begin
	if (alea<=Tableau.DF[i].DebutEtFin) then exit(alphabet[i]);
	End;
UnSeulCaractere:=voyelle[(random(21))+1];//Si il n'y a pas de lettre seul dans le dictionnaire, on prend une lettre aléatoire
End;

{****************************************************************************
			FONCTION Generation du mot à deux lettre
			* c'est une fonction auxilliaire de DeuxCaractere
****************************************************************************}
function DeuxCaractereGeneration(Tableau: Tableau2D;Zero: integer):WideString;
var 
alea,i,j: integer;
Begin
if (Zero=0) then //Si il y a au moins une fois deux lettre qui commence un mot et les deux meme lettre qui finisse le meme ou un autre mot dans le dictionnaire
	Begin
	alea:=(random(Tableau[43][43]))+1;
	for i:=1 to 43 do
		Begin
		for j:=1 to 43 do
			Begin
			if (alea<=Tableau[j][i]) then exit(alphabet[i]+alphabet[j]);
			End;
		End;
	End
	Else
	Begin //Sinon s'il n'y a pas ce cas dans le dictionnaire alors on invente un mot de deux caractere avec au moins une voyelle dedans
	alea:=(random(2))+1; //Soit la voyelle est avant, soit elle est apres (il peut y avoir deux voyelles)
	if (alea=1) then DeuxCaractereGeneration:=voyelle[random(21)+1]+alphabet[random(43)+1]
	else DeuxCaractereGeneration:=alphabet[random(43)+1]+voyelle[random(21)+1];
	End;
End;


{****************************************************************************
			FONCTION Creation de deux lettre dans le cas de deux caracteres
			* Calcul + Sommation
			* RENVOIE DEUX CARACTERE
			* Si j'aurais eu le temps, j'aurais fait plus simple, c'est faisable
			* grace à une seule variable (j'aurais compter la somme de tout
			* avec une valeur puis j'aurais pris un nombre entre 1 et cette
			* valeur puis parcourue le vrai tableau en enlevant la valeur que 
			* j'aurais mis dans TableauTemp)
****************************************************************************}
function DeuxCaractere(Tableau:LesTableaux):WideString;
Var
i,j: integer;
TableauTemp: Tableau2D;
Begin
for i:=1 to 43 do
	Begin
	for j:=1 to 43 do 
		Begin
		if (Tableau.Tri[j][i][0].Debut<Tableau.Tri[j][i][0].Fin) then TableauTemp[j][i]:=Tableau.Tri[j][i][0].Debut //On affecte la plus petite valeur a notre tableau
		else TableauTemp[j][i]:=Tableau.Tri[j][i][0].Fin;
		if (j<>1) or (i<>1) then 
			Begin
			if (j=1) then TableauTemp[j][i]:=TableauTemp[j][i]+TableauTemp[43][i-1] //Puis on somme le tableau de gauche a droite et de haut en bas 
			else TableauTemp[j][i]:=TableauTemp[j][i]+TableauTemp[j-1][i];
			End;
		End;
	End;
	if (TableauTemp[43][43]<>0) then 
	Begin
	DeuxCaractere:=DeuxCaractereGeneration(TableauTemp,0)//On appelle la fonction auxilliaire pour generer le mot
	End
	else 
	Begin
	DeuxCaractere:=DeuxCaractereGeneration(TableauTemp,1);//On appelle la fonction auxilliaire pour generer le mot
	End;
End;


{****************************************************************************
			FONCTION auxilliaire de TroisCaractere
			* On affecte les valeurs dans le tableau
			* On fait pareil que pour le digramme mais cette fois avec
			* un tableau en trois dimensions (43*43*43)
			* Renvoie un tableau à exploiter
			* Dans ce tableau on voit quand trois lettres commencent au moins 
			* un mot et en finissent au moins un
			* Puis on pioche trois lettres selon ces probabilités 
****************************************************************************}
function RemplissageTroisCaractere(Tableau:LesTableaux):Tableau3D;
var 
i,j,k : integer;
TableauTemp:Tableau3D;
Begin
for k:=1 to 43 do
	Begin
	for i:=1 to 43 do 
		Begin
		for j:=1 to 43 do
			Begin
			if (Tableau.Tri[j][i][k].Debut<Tableau.Tri[j][i][k].Fin) then TableauTemp[j][i][k]:=Tableau.Tri[j][i][k].Debut //On affecte la plus petite valeur
			else TableauTemp[j][i][k]:=Tableau.Tri[j][i][k].Fin; //Plus petite valeur ou la même si .Debut=.Fin
			if ((j<>1) or (i<>1) or (k<>1)) then
				Begin //Ici on économise les boucles et on somme en même temps que l'on rempli le tableau
				//On somme de gauche a droite et de haut en bas
				if ((j=1) and (i=1)) then TableauTemp[j][i][k]:=TableauTemp[j][i][k]+TableauTemp[43][43][k-1]//Lorsqu'on change de couche (T[x][y][couche]) on somme avec 
				//la derniere case de la couche d'avant 
				else if (j=1) then TableauTemp[j][i][k]:=TableauTemp[j][i][k]+TableauTemp[43][i-1][k] //Lorsqu'on passe à une nouvelle ligne on prend la derniere case de la ligne précédente
					else TableauTemp[j][i][k]:=TableauTemp[j][i][k]+TableauTemp[j-1][i][k]; //Dans le cas normal on somme normalement
				End;
			End;
		End;
	End;
RemplissageTroisCaractere:=TableauTemp; //On renvoie le Tableau créé
End;

{****************************************************************************
			FONCTION auxilliaire de TroisCaractere
			* on genere le mots dans le cas où les cas ont deja ete rencontrer
			* dans le dictionnaire
			* RENVOIE TROIS CARACTERE TRIGRAMME
****************************************************************************}
function GenerationTroisCaractereOkay(TableauTemp:Tableau3D):WideString;
var
i,j,k,alea:integer;
Begin
	alea:=(random(TableauTemp[43][43][43])+1);
	for k:=1 to 43 do 
		Begin
		for i:=1 to 43 do
			Begin
			for j:=1 to 43 do
				Begin
				if (alea<=TableauTemp[j][i][k]) then exit(alphabet[i]+alphabet[j]+alphabet[k]);
				End;
			End;
		End;
		//Théoriquement, cette fonction ne se finit jamais mais si le cas arrive, on peut localiser le problème
	TextColor(LightRed);
	Writeln('Le programme a rencontré un problème à la fonction GenerationTroisCaractereOkay.');
	TextColor(14);
	GenerationTroisCaractereOkay:='bug';
End;

{****************************************************************************
			FONCTION auxilliaire de TroisCaractere
			* on genere le mots dans le cas où les cas n'ont pas ete rencontrer
			* dans le dictionnaire
			* Ici on renvoie 3 caractere aléatoire qui contient au moins une 
			* voyelle
			* RENVOIE TROIS CARACTERE 
****************************************************************************}
function GenerationTroisCaractereNotOkay():WideString;
var
alea:integer;
Begin
alea:=random(3)+1;
if (alea=1) then GenerationTroisCaractereNotOkay:=voyelle[random(21)+1]+alphabet[random(43)+1]+alphabet[random(43)+1] //Voyelle+Lettre Aleatoire+Lettre Aleatoire
else if (alea=2) then GenerationTroisCaractereNotOkay:=alphabet[random(43)+1]+voyelle[random(21)+1]+alphabet[random(43)+1] //Lettre Aleatoire+Voyelle+Lettre Aleatoire
	else GenerationTroisCaractereNotOkay:=alphabet[random(43)+1]+alphabet[random(43)+1]+voyelle[random(21)+1];//Lettre Aleatoire+Lettre Aleatoire+Voyelle
End;

{****************************************************************************
			FONCTION creation de trois lettres dans le cas de trois lettre
			* creation + sommation + calcul
			* Lorsque je dis 'le cas a ete rencontrer dans le dictionnaire' 
			* je veux dire que trois lettres commencent et finissent un même mot 
			* RENVOIE TROIS CARACTERE TRIGRAMME
****************************************************************************}
function TroisCaractere(Tableau:LesTableaux):WideString;
Var
TableauTemp:Tableau3D;
Begin
TableauTemp:=RemplissageTroisCaractere(Tableau); //On remplis le Tableau avec une fonction auxilliaire
if (TableauTemp[43][43][43]<>0) then TroisCaractere:=GenerationTroisCaractereOkay(TableauTemp) //Le cas a ete rencontrer dans le dictionnaire
else TroisCaractere:=GenerationTroisCaractereNotOkay;
End;


{****************************************************************************
			FONCTION auxilliaire du digramme a caractere fini
			* Ici on somme tout les compteurs fin et debut
****************************************************************************}
function SommationDesDebutFinDigramme(Tableau:LesTableaux):LesTableaux;
var
i,j:integer;
Begin
for i:=1 to 43 do
	Begin
	for j:=1 to 43 do 
		Begin
		if ((j<>1) or (i<>1)) then 
			Begin
			if (j=1) then Tableau.Tri[j][i][0].Debut:=Tableau.Tri[j][i][0].Debut+Tableau.Tri[43][i-1][0].Debut //Ici on somme tout le tableau .Debut
				else Tableau.Tri[j][i][0].Debut:=Tableau.Tri[j][i][0].Debut+Tableau.Tri[j-1][i][0].Debut; 
			if (j<>1) then Tableau.Tri[j][i][0].Fin:=Tableau.Tri[j-1][i][0].Fin+Tableau.Tri[j][i][0].Fin; //Ici on somme que les lignes .Fin
			End;
		End;
	End;
SommationDesDebutFinDigramme:=Tableau; //On renvoie le tableau sommé
End;

{****************************************************************************
			FONCTION auxilliaire du digramme a caractere fini
			* Ici on choisis a travers le tableau les deux lettre
			* qui seront les premieres
****************************************************************************}
function ChoixDesDeuxPremiereLettre(Tableau:LesTableaux):WideString;
var
i,j,alea:integer;

Begin
alea:=random(Tableau.Tri[43][43][0].Debut)+1; //On prend un nombre aleatoire entre 1 et le nombre
// de lettre qui ont commencer un mot dans le dictionnaire
for i:=1 to 43 do
	Begin
	for j:=1 to 43 do
		Begin
		if (alea<=Tableau.Tri[j][i][0].Debut) then exit(alphabet[i]+alphabet[j]); //Lorsqu'on a trouver les deux lettres du début on les renvoies
		End;
	End;
TextColor(LightRed);
Writeln('Le dictionnaire ne contient aucun mot'); //On ne devrait jamais rencontrer ce cas en théorie 
//mais je le met quand meme puis je trouver cool le ...Echec :D
Writeln('Generation deux premiere lettre...Echec');
TextColor(14);
ChoixDesDeuxPremiereLettre:='Fail---';
End;

{****************************************************************************
			FONCTION auxilliaire du digramme a caractere fini
			* Ici on ajoute une lettre en fonction de la précédente 
			* jusqu'a une lettre avant la fin grâce au digramme 
****************************************************************************}
function CompletionDuMotDigramme(Mot:WideString;Tableau:LesTableaux):WideString;
Var
i,alea:integer;
Begin
alea:=random(Tableau.Tri[43][pos(Mot[length(Mot)],alphabet)][0].Compteur)+1;//Toujours une lettre aleatoire entre 1 et le max
for i:=1 to 43 do
	Begin
		if (alea<=Tableau.Tri[i][pos(Mot[length(Mot)],alphabet)][0].Compteur) then exit(alphabet[i]);
	End;
	//Ici on peut rencontrer ce cas s'il n'y a jamais eu de lettre après la précédente donc pour pas bloquer le 
	//programme j'en génère une aléatoirement
CompletionDuMotDigramme:=alphabet[random(26)+1];//Ici je choisis entre 1 et 26 car ce sont les lettres les plus probables pour moi
End;

{****************************************************************************
			FONCTION auxilliaire du digramme a caractere fini
			*  creation de la derniere lettre du mot lorsque les 
			* caracteres sont au dessus de 2 car on pourra avoir une meilleur
			* précision du Mot
			* Correspond au DIGRAMME
****************************************************************************}
function DerniereLettreDigramme(Mot:WideString;Tableau:LesTableaux):WideString;
var
i,alea:integer;
Begin //Même fonctionnement que la fonction précédente
alea:=random(Tableau.Tri[43][pos(Mot[length(Mot)],alphabet)][0].Fin)+1;
for i:=1 to 43 do
	Begin
	if (alea<=Tableau.Tri[i][pos(Mot[length(Mot)],alphabet)][0].Fin) then exit(alphabet[i]);
	End;
DerniereLettreDigramme:=alphabet[random(26)+1];//Ici je choisis entre 1 et 26 car ce sont les lettres les plus probables pour moi
End;

{****************************************************************************
			FONCTION creation de un mot lorsque les caracteres sont au dessus
			* de 2 car on pourra avoir une meilleur précision du mot créé
			* Ici on regroupe toutes les fonction auxiliaire du digramme
			* Correspond au DIGRAMME
****************************************************************************}
function PlusQueTroisCaractereDigramme(Tableau:LesTableaux;caractere:integer):WideString;
var
Mot:WideString;
i:integer;
Begin
Tableau:=SommationDesDebutFinDigramme(Tableau);
Mot:=ChoixDesDeuxPremiereLettre(Tableau);
if (caractere>3) then
	Begin
	for i:=1 to caractere-3 do //On enleve la premiere lettre et la derniere qui sont générées indépendemment
		Begin
		Mot:=Mot+CompletionDuMotDigramme(Mot,Tableau);
		End;
	End;
Mot:=Mot+DerniereLettreDigramme(Mot,Tableau);
PlusQueTroisCaractereDigramme:=Mot;
End;

{****************************************************************************
			FONCTION auxilliaire de Plusquetroiscaracteretrigramme
			* qui va sommer toutes les probas de premier enchainement
			* de trois lettre pour pouvoir choisir un debut
****************************************************************************}
function SommationDesDebutTrigramme(Tableau:LesTableaux):LesTableaux;
var 
i,j,k:integer;
Begin
for k:=1 to 43 do
	Begin
	for i:=1 to 43 do
		Begin
		for j:=1 to 43 do
			Begin
			if ((k<>1) or (j<>1) or (i<>1)) then
				Begin
				if ((j=1) and (i=1)) then Tableau.Tri[j][i][k].Debut:=Tableau.Tri[j][i][k].Debut+Tableau.Tri[43][43][k-1].Debut
					else if (j=1) then Tableau.Tri[j][i][k].Debut:=Tableau.Tri[j][i][k].Debut+Tableau.Tri[43][i-1][k].Debut
						else Tableau.Tri[j][i][k].Debut:=Tableau.Tri[j][i][k].Debut+Tableau.Tri[j-1][i][k].Debut;
				End;
			End;
		End;
	End;
	SommationDesDebutTrigramme:=Tableau;
End;

{****************************************************************************
			FONCTION auxillaire de plusquetroiscaracteretrigramme
			* genere les trois premières lettres du mot
			* ici on parcours le trigramme .Debut grâce a la fonction 
			* précédente afin de trouver les trois premières lettres
****************************************************************************}
function ChoixDesTroisPremiereLettre(Tableau:LesTableaux):WideString;
var
alea,i,j,k:integer;
Begin
alea:=random(Tableau.Tri[43][43][43].Debut)+1;
for k:=1 to 43 do
	Begin
	for i:=1 to 43 do
		Begin
		for j:=1 to 43 do
			Begin
			if (alea<=Tableau.Tri[j][i][k].Debut) then exit(alphabet[i]+alphabet[j]+alphabet[k]); //On renvoie les trois premieres lettres tirées
			End;
		End;
	End;
	TextColor(LightRed); //Cas qui n'est pas impossible mais très rare car il faut pour cette fonction exit trois lettre
	//que le dictionnaire contienne au moins un mot de 3 lettres ou plus
	Writeln('Le Programme a rencontrer un probleme à la génération des trois premiere lettres.');
	TextColor(14);
End;


{****************************************************************************
			FONCTION auxillaire de plusquetroiscaracteretrigramme
			* va generer la derniere lettre du mot avec beaucoup de précision 
			* grâce au .Fin
****************************************************************************}
function DerniereLettreTrigramme(Mot:WideString;Tableau:LesTableaux):WideString;
var
alea,i,x,y:integer;
Begin
x:=pos(Mot[length(Mot)-1],alphabet); //Avant derniere lettre
y:=pos(Mot[length(Mot)],alphabet); //Derniere lettre
for i:=1 to 43 do
	Begin
	if (i<>1) then Tableau.Tri[y][x][i].Fin:=Tableau.Tri[y][x][i].Fin+Tableau.Tri[y][x][i-1].Fin; //On somme ici car il suffit juste de sommer la ligne qu'on veut
	End;
alea:=random(Tableau.Tri[y][x][43].Fin)+1; 
for i:=1 to 43 do
	Begin
	if (alea<=Tableau.Tri[y][x][i].Fin) then exit(alphabet[i]);
	End;
DerniereLettreTrigramme:=''; //Cas impossible sauf si le dictionnaire ne contient pas de lettre 
End;

{****************************************************************************
			FONCTION auxillaire de plusquetroiscaracteretrigramme
			* complétion du milieu du mot (apres les 3 premiere lettre et 
			* avant la derniere lettre)
****************************************************************************}
function CompletionDuMotTrigramme(Mot:WideString;Tableau:LesTableaux):WideString;
var 
alea,i:integer;
Begin
alea:=random(Tableau.Tri[pos(Mot[length(Mot)],alphabet)][pos(Mot[length(Mot)-1],alphabet)][43].Compteur)+1;
for i:=1 to 43 do
	Begin
		if (alea<=Tableau.Tri[pos(Mot[length(Mot)],alphabet)][pos(Mot[length(Mot)-1],alphabet)][i].Compteur) then exit(alphabet[i]); //Ici on ajoute une lettre en 
		//fonction des deux d'avant
	End;
CompletionDuMotTrigramme:='';
End;
{****************************************************************************
			FONCTION creation d'un mot lorsque les caracteres sont au dessus
			* de 3 car on pourra avoir une meilleure précision du mot 
			* On centralise toutes les fonctions auxillaires
			* Correspond au TRIGRAMME
****************************************************************************}
function PlusQueTroisCaractereTrigramme(Tableau:LesTableaux;caractere:integer):WideString;
var 
Mot,Lettre:WideString;
i:integer;
Begin
Tableau:=SommationDesDebutTrigramme(Tableau);
Mot:=ChoixDesTroisPremiereLettre(Tableau);
if (caractere>4) then 
	Begin
	for i:=1 to caractere-4 do //ici on fait a partir des trois lettres générée et on arrete avant la dernière lettre
		Begin
		Lettre:=CompletionDuMotTrigramme(Mot,Tableau);
		if (Lettre='') then Lettre:=CompletionDuMotDigramme(Mot,Tableau); //Si le trigramme n'as pas réussi a générer le mot 
		//On utilise le digramme et même si le digramme fonctionne pas, il y aura une lettre aléatoire
		Mot:=Mot+Lettre;
		End;
	End;
Lettre:=DerniereLettreTrigramme(Mot,Tableau);
if (Lettre='') then Lettre:=DerniereLettreDigramme(Mot,Tableau); //Ici c'est pareil, si ça fonctionne pas 
//on génère grâce au digramme et au pire on prend une lettre aléatoire
Mot:=Mot+Lettre;
PlusQueTroisCaractereTrigramme:=Mot;
End;


{****************************************************************************
			PROCEDURE qui va creer le sujet et qui va informer sur l'etat du 
			* sujet (pluriel ou singulier)
			* Il faut noter que la génération par le trigramme avec un nombre
			* de caractere fini est plus précise que la génération par 
			* trigramme avec un nombre de caractère indéfini
****************************************************************************}
procedure CreationSujet(var Mot:WideString;var singulier:boolean);
var 
Tableau:LesTableaux;
Aleatoire,i:integer;
Fichier:String;
Begin
singulier:=true; //On initialise la variable
Aleatoire:=random(2)+1; //On choisis un nombre aleatoire entre 1 et 2 
for i:=1 to Aleatoire do
	Begin
	if (Aleatoire=1) then Fichier:=NomPropre //Si le nombre aléatoire est 1 alors la phrase commencera avec un nom propre
		else if (i=1) then Fichier:=article //Sinon elle commence avec article+nom commun
		//Ici on gere le fait que ça génère un nom propre ou article+nom commun grâce à la boucle pour
		else Fichier:=NomCommun; //Une fois qu'on a générer l'article, on doit générer le nom commun
	AffectationTri(Tableau,Fichier); //On lit le dictionnaire et affecte les valeurs
	ProbabiliteDi(Tableau,Tableau);//creation de probas du digramme + sommation
	SommationProba3D(Tableau,Tableau);//sommation du trigramme
	SommationProbaLettreSeule(Tableau,Tableau);
	if (Aleatoire=1) then 
	Begin
	Mot:=PlusQueTroisCaractereTrigramme(Tableau,random(6)+4) //Si c'est un nom propre alors on en créer un avec un nombre de caractere
	//compris entre 4 et 10
	End
	else if (i=1) then //Si on génère un article, on le génère avec un nombre de caractères indéfini
		Begin
		Mot:=GenerationDeuxPremieresLettre(Tableau);
		Mot:=SuiteLettreTrigramme(Mot,Tableau)+' ';
		if ((Mot[length(Mot)-1]='s') or (Mot[length(Mot)-1]='x')) then singulier:=false; //On vérifie s'il est singulier ou pluriel
		End
		else Mot:=Mot+PlusQueTroisCaractereTrigramme(Tableau,random(8)+4); //On génère le nom commun de la même manière que le nom propre mais
		//avec un nombre de caractère entre 4 et 11
	End;
	if (singulier=true) and (Mot[length(Mot)]='s') then Delete(Mot,length(Mot),1) //Si le mot est au singulier mais qu'il a un 's' à la fin, on l'enlève
	else if (singulier=false) then Mot:=Mot+'s'; //Si c'est pluriel alors on ajoute un s
End; 



{****************************************************************************
			PROCEDURE qui va creer le verbe grâce à la méthode du trigramme
			* puis qui va l'accorder avec le sujet
****************************************************************************}
procedure CreationVerbe(Mot:WideString;singulier:boolean; Var MotSortie:WideString);
Var
ungroupe,deuxgroupe:boolean; //Correspond au verbes du premier ou du dexieme groupe
Tableau:LesTableaux;
VerbeConjugue:WideString;
Begin
AffectationTri(Tableau,Verbe); //On lit le dictionnaire des verbes et on affecte les valeurs
ProbabiliteDi(Tableau,Tableau);//creation de probas du digramme + sommation
SommationProba3D(Tableau,Tableau);//sommation du trigramme
SommationProbaLettreSeule(Tableau,Tableau);
ungroupe:=false; //On initialise la variable
deuxgroupe:=false; //On initialise la variable
VerbeConjugue:=PlusQueTroisCaractereTrigramme(Tableau,random(9)+4); //On génère un verbe précisément mais si on y arrive pas on fait avec un nombre de lettre indéfini
Repeat
	if ((VerbeConjugue[length(VerbeConjugue)-1]+VerbeConjugue[length(VerbeConjugue)]<>'er') or (VerbeConjugue[length(VerbeConjugue)-1]+VerbeConjugue[length(VerbeConjugue)]<>'ir')) then
	Begin
	VerbeConjugue:=GenerationDeuxPremieresLettre(Tableau);
	VerbeConjugue:=SuiteLettreTrigramme(VerbeConjugue,Tableau);
	End;
Until((Length(VerbeConjugue)>5) and (Length(VerbeConjugue)<15)); //On recreer des verbes avec un nombre de caractere indéfini jusqu'a ce que la longeur du mot soit entre 6 et 14
	//Maintenant on va identifier le verbe, sa terminaison
	if (VerbeConjugue[length(VerbeConjugue)-1]+VerbeConjugue[length(VerbeConjugue)]='er') then ungroupe:=true
	else if (VerbeConjugue[length(VerbeConjugue)-1]+VerbeConjugue[length(VerbeConjugue)]='ir') then deuxgroupe:=true
		else deuxgroupe:=true; //Dans le cas où les deux dernières lettres ne sont pas er ou ir, il est du deuxieme groupe par défaut
	Delete(VerbeConjugue,length(VerbeConjugue)-1,2); //Ensuite on enlève la terminaison de l'infinitif
	if ((Mot[length(Mot)])=alphabet[29]) then Delete(Mot,length(Mot),1);//Histoire que ca fasse pas un participe passé
	if (VerbeConjugue[length(VerbeConjugue)]='e') then Delete(VerbeConjugue,length(VerbeConjugue),1) //Si le mot finis par un e, on l'enlève
		else if ((VerbeConjugue[length(VerbeConjugue)]='i') and (deuxgroupe=true)) then Delete(VerbeConjugue,length(VerbeConjugue),1); //On enlève le i s'il est du deuxieme groupe
		//Ensuite on ajoute la terminaison qui correspond
	if ((singulier=true) and (ungroupe=true)) then VerbeConjugue:=VerbeConjugue+'e'
		else if ((singulier=true) and (deuxgroupe=true)) then VerbeConjugue:=VerbeConjugue+'it'
			else if ((singulier=false) and (ungroupe=true)) then VerbeConjugue:=VerbeConjugue+'ent'
				else VerbeConjugue:=VerbeConjugue+'issent';
				//Ici il nous reste plus qu'a assembler les mots pour avoir une phrase sujet+verbe
MotSortie:=Mot+' '+VerbeConjugue;
End;


{****************************************************************************
			PROCEDURE qui va creer l'adjectif en en choississant un au hasard 
			* On compte le nombre de mot dans le dictionnaire puis on 
			* en prend un
****************************************************************************}
procedure CreationAdjectif(Mot1:WideString;singulier:boolean;Var Mot:WideString);
var 
	Nbligne:integer;
	Fichier: Text;
	ligne:WideString;
Begin
Mot:=Mot1; //On initialise la variable de la phrase
Assign(Fichier, adjectif); //On va lire le dictionnaire des adjectifs
Reset(Fichier);
Nbligne:=0;
while (not EOF(Fichier)) do //On analyse la ligne suivante du dictionnaire tant qu'il est pas finit
	Begin
	ReadLn(Fichier,ligne);
	Inc(Nbligne);//On compte le nombre de ligne
	End;
close(Fichier); //On ferme le fichier
Nbligne:=random(Nbligne)+1; //Ensuite on prend un nombre aleatoire entre 1 et le nombre de ligne
Reset(Fichier); //On relit le fichier
for Nbligne:=Nbligne downto 1 do
Begin
readln(Fichier,ligne);
if (Nbligne=1) then Mot:=Mot+' '+ligne; //et cette fois on prend l'adjectif qui correspond à la ligne choisis aléatoirement
End;
close(Fichier); //On ferme le fichier
if ((singulier=false) and not((Mot[length(mot)]='s') or (Mot[length(mot)]='x')))then Mot:=Mot+'s'; //On accorde l'adjectif

End;


{****************************************************************************
			PROCEDURE qui va creer l'adverbe exactement de ma même manière que 
			* pour la creation de l'adjectif
****************************************************************************}

procedure CreationAdverbe(Mot1:WideString;Var Mot:Widestring);
var 
	Nbligne:integer;
	Fichier: Text;
	ligne:WideString;
Begin
Mot:=Mot1;
Assign(Fichier, adverbe);
Reset(Fichier);
Nbligne:=0;
while (not EOF(Fichier)) do //On analyse la ligne suivante du dictionnaire tant qu'il est pas finit
	Begin
	ReadLn(Fichier,ligne);
	Inc(Nbligne);
	End;
close(Fichier);
Nbligne:=random(Nbligne)+1;
Reset(Fichier);
for Nbligne:=Nbligne downto 1 do
Begin
readln(Fichier,ligne);
if (Nbligne=1) then Mot:=Mot+' '+ligne;
End;
close(Fichier);
End;

{****************************************************************************
			FONCTION Phrase qui va composer la phrase
****************************************************************************}
function Phrase():WideString;
var
Mot:WideString;
singulier:boolean;
Aleatoire:integer;
Begin
CreationSujet(Mot,singulier); //Le sujet est obligatoire
if (Mot[length(Mot)]=Mot[length(Mot)-1]) then Delete(Mot,length(Mot),1); //un mot ne finis jamais avec deux fois le même caractere
if ((Mot[length(Mot)-1])=alphabet[29]) then Delete(Mot,length(Mot)-1,1);//Histoire que ca fasse pas un participe passer
CreationVerbe(Mot,singulier,Mot); //On crer le verbe
Phrase:=Mot;
Aleatoire:=random(3)+1; //On choisis aleatoirement la forme des phrases
Case Aleatoire of 
			1 : Begin
				writeln('Phrase de forme Sujet+Verbe+Adverbe+Adjectif');
				CreationAdverbe(Mot,Mot);
				CreationAdjectif(Mot,singulier,Mot);
				End;
		   	2 : Begin
				writeln('Phrase de forme Sujet+Verbe+Adjectif');
				CreationAdjectif(Mot,singulier,Mot);
				End;
		   	else 
				writeln('Phrase de forme Sujet+Verbe');
			End;
			Mot[1]:=UpCase(Mot[1]); //On met une majuscule
TextColor(14);
Phrase:=Mot+'.'; //Puis on rajoute un point
End;

{****************************************************************************
                           PROCEDURE AFFICHERMENU
BUT:Afficher le manuel du programme
****************************************************************************}

PROCEDURE AfficherMenu();
Begin
	ClrScr;
	writeln('NAME');
	writeln('      projet - la machine à inventer des mots');
	writeln;
	writeln('SYPNOSIS');
	writeln('      projet [OPTION]...FILE');
	writeln;
	writeln('DESCRIPTION');
	writeln('      Génère des mots ou des phrases à partir du dictionnaire FILE');
	writeln;
	writeln('      -a	utilise la méthode aléatoire pour générer les mots');
	writeln;
	writeln('      -d	utilise la méthode des digrammes pour générer les mots');
	writeln;
	writeln('      -t	utilise la méthode des trigrammes pour générer les mots');
	writeln;
	writeln('      -p	génère une phrase (en utilisant la méthode des trigrammes)');
	writeln;
	writeln('      -n NB   gènere NB mots (par défaut génère 100 mots)');
	writeln;
	writeln('      -s NB affiche uniquement des mots de NB caractères');
	writeln;
	writeln('      -h	affiche cette aide et quitte');
	writeln;
	writeln('AUTHORS');
	writeln('      Ecrit par T. Julien, W. Kaczmarek, V.Mugnier');
	
End;

{****************************************************************************
                        PROCEDURE CHOIX
BUT : choisir un cas parmis les huit possibles dans le manuel du programme
****************************************************************************}


procedure choix(Var choix1:integer);
	VAR
		i,a,d,t,n,s,h,p : integer;
		
	BEGIN 
	  a:=0;
	  d:=0;
	  t:=0;
	  n:=0;
	  s:=0;
	  h:=0;
	  p:=0;
	  choix1:=0;
		for i:=1 to ParamCount do //dertermination des options qui ont été choisies
			begin 
			if (ParamStr(i)='-n') then n:=n+1;
			if (ParamStr(i)='-s') then s:=s+1;
			if (ParamStr(i)='-a') then a:=a+1;
			if (ParamStr(i)='-d') then d:=d+1;
			if (ParamStr(i)='-t') then t:=t+1;
			if (ParamStr(i)='-h') then h:=h+1;
			if (ParamStr(i)='-p') then p:=p+1;
			end; //On renvoie la correspondance a travers la variable choix1 
		if ((n=1) and (a=1) and (d=0) and (t=0) and (s=0) and (h=0) and (p=0)) then choix1:=1;
		if ((n=1) and (a=0) and (d=1) and (t=0) and (s=0) and (h=0) and (p=0)) then choix1:=2;
		if ((n=1) and (a=0) and (d=0) and (t=1) and (s=0) and (h=0) and (p=0)) then choix1:=3;
		if ((n=1) and (a=1) and (d=0) and (t=0) and (s=1) and (h=0) and (p=0)) then choix1:=4;
		if ((n=1) and (a=0) and (d=1) and (t=0) and (s=1) and (h=0) and (p=0)) then choix1:=5;
		if ((n=1) and (a=0) and (d=0) and (t=1) and (s=1) and (h=0) and (p=0)) then choix1:=6;
		if ((n=0) and (a=0) and (d=0) and (t=0) and (s=0) and ((h=0) or (h=1)))then choix1:=7;
		if ((n=0) and (a=0) and (d=0) and (t=0) and (s=0) and (h=0) and (p=1)) then choix1:=8;
	END;


{****************************************************************************
                        FONCTION NBCARACTERE
BUT : renvoyer le nombre de caractères choisi par l'utilisateur pour un mot
****************************************************************************}

function NBcaractere():integer; 
Var 
	i,K,Error: Integer;
	a : string;

Begin
	for i:=1 to ParamCount-1 do
	Begin
		if(ParamStr(i)='-s') then a:=ParamStr(i+1);
	End;
	Val (a,K,Error);
	If (Error<>0) then
	Begin
		NBcaractere:=0; //il n'y a pas de nombre de caractères par défaut
	End
	Else
	Begin
		NBcaractere:=K;
	End;
End;

{****************************************************************************
                        FONCTION NBMOT
BUT : renvoyer le nombre de mots choisi par l'utilisateur ou généré par défaut
****************************************************************************}

function NBmot():integer; 
Var 
	i,K,Error: integer;
	a: String;
	
Begin
	for i:=1 to ParamCount-1 do
	Begin
		if (ParamStr(i)='-n') then a:=ParamStr(i+1);
	End;
	Val(a,K,Error);
	If (Error<>0) then
	Begin
		NBmot:=100; //La fonction génère 100 mots par défaut
	End
	else
	Begin
		NBmot:=K;
	End;
End;

{****************************************************************************
                        FONCTION CREEMOTALEATOIRE
BUT :créer un mot grâce à la méthode aléatoire ((-s) -n -a)
****************************************************************************}

FUNCTION creeMotAleatoire (taille : Integer) : WideString; //Taille qui signifie le nombre de caractère
VAR
	i,k : Integer;
	Mot : WideString;
Begin
	Mot:='';
	for i:=1 to taille do
	Begin
		k := random(42)+1; //on génère une valeur de 1 à 43
		Mot:= Mot + alphabet[k]; //On ajoute la lettre tirée aléatoirement au Mot
	End;
	
	creeMotAleatoire:=Mot;
End;



{****************************************************************************
                        PROCEDURE CAS1
BUT : afficher le mot créer grâce à la méthode aléatoire
****************************************************************************}

procedure cas1();
var 
i:integer;
Begin
writeln('la méthode aléatoire');
TextColor(14);
for i:=1 to NBmot() do
Begin
writeln('Le mot est :', creeMotAleatoire(random(11)+3)); 
End;
End;





{****************************************************************************
                        PROCEDURE CAS2
BUT : afficher le mot créer grâce à la méthode digramme
****************************************************************************}

procedure cas2();
var
Tableau:LesTableaux;
Mot:WideString;
i:integer;
Begin
AffectationTri(Tableau,ParamStr(ParamCount));
ProbabiliteDi(Tableau,Tableau);//creation de probas du digramme + sommation
SommationProba3D(Tableau,Tableau);//sommation du trigramme
SommationProbaLettreSeule(Tableau,Tableau);
writeln('La méthode Digramme');
TextColor(14);
for i:=1 to NBmot() do
Begin
Mot:='';
Mot:=GenerationDeuxPremieresLettre(Tableau);
Mot:=SuiteLettreDigramme(Mot,Tableau);
writeln('Le mot est :', Mot); 
End;
End;


{****************************************************************************
                        PROCEDURE CAS3
BUT : afficher le mot créer grâce à la méthode trigramme
****************************************************************************}

procedure cas3();
var
Tableau:LesTableaux;
Mot:WideString;
i:integer;
Begin
AffectationTri(Tableau,ParamStr(ParamCount));
ProbabiliteDi(Tableau,Tableau);//creation de probas du digramme + sommation
SommationProba3D(Tableau,Tableau);//sommation du trigramme
SommationProbaLettreSeule(Tableau,Tableau);
writeln('la méthode trigramme');
TextColor(14);
for i:=1 to NBmot() do
Begin
Mot:='';
Mot:=GenerationDeuxPremieresLettre(Tableau);
Mot:=SuiteLettreTrigramme(Mot,Tableau);
writeln('Le mot est :', Mot); 
End;
End;


{****************************************************************************
                        PROCEDURE CAS4
BUT : afficher le mot créer grâce à NBcaractere et la méthode aléatoire
****************************************************************************}

procedure cas4();
var 
i,a:integer;
Begin
writeln('la méthode aléatoire en décidant du nombre de caractères');
TextColor(14);
a:=NBcaractere;
if (a=0) then a:=random(10)+1;
for i:=1 to NBmot() do
Begin
writeln('Le mot est :', creeMotAleatoire(a)); 
End;	
End;


{****************************************************************************
                        PROCEDURE CAS5
BUT : afficher le mot créer grâce à NBcaractere et la méthode digramme
****************************************************************************}

procedure cas5();
var
i:integer;
Tableau:LesTableaux;
Mot:WideString;
Begin
AffectationTri(Tableau,ParamStr(ParamCount));
ProbabiliteDi(Tableau,Tableau);//creation de probas du digramme + sommation
SommationProba3D(Tableau,Tableau);//sommation du trigramme
SommationProbaLettreSeule(Tableau,Tableau);
writeln('la méthode digramme en décidant du nombre de caractères');
TextColor(14);
for i:=1 to NBmot() do
Begin
if (NBcaractere=1) then Mot:=UnSeulCaractere(Tableau) //Si il faut que un seul caractere
else if (NBcaractere=2) then Mot:=DeuxCaractere(Tableau) //Si il faut que deux caractere
	else  Mot:=PlusQueTroisCaractereDigramme(Tableau,NBcaractere);
writeln('Le mot est :', Mot); 
End;
End;


{****************************************************************************
                        PROCEDURE CAS6
BUT : afficher le mot créer grâce à NBcaractere et la méthode trigramme
****************************************************************************}

procedure cas6();
var
Tableau:LesTableaux;
Mot:WideString;
i:integer;
Begin
AffectationTri(Tableau,ParamStr(ParamCount));
ProbabiliteDi(Tableau,Tableau);//creation de probas du digramme + sommation
SommationProba3D(Tableau,Tableau);//sommation du trigramme
SommationProbaLettreSeule(Tableau,Tableau);
writeln('la méthode trigramme en décidant du nombre de caractères');
TextColor(14);
for i:=1 to NBmot() do
Begin
if (NBcaractere=1) then Mot:=UnSeulCaractere(Tableau) //Si il faut que un seul caractere
else if (NBcaractere=2) then Mot:=DeuxCaractere(Tableau) //Si il faut que deux caractere
	else  if (NBcaractere=3) then Mot:=TroisCaractere(Tableau)
	else Mot:=PlusQueTroisCaractereTrigramme(Tableau,NBcaractere); //Ici le 20 correspond au nombre de caractere
writeln('Le mot est :', Mot); 
End;
End;



{****************************************************************************
                        PROCEDURE CAS7
BUT : afficher le menu et quitter
****************************************************************************}

procedure cas7();
Begin
AfficherMenu(); 
End;


{****************************************************************************
                        PROCEDURE CAS8
BUT : générer une phrase 
****************************************************************************}
procedure cas8();
Begin

writeln(Phrase);
End;

{****************************************************************************
                        PROCEDURE EFFECTUEACTIONMENU
BUT : afficher lequel des 8 cas l'utilisateur a choisi
****************************************************************************}


PROCEDURE effectueActionMenu (choix1:Integer); 
	BEGIN
		 if not(FileExists(ParamStr(ParamCount))) then writeln('Le fichier indiqué en dernier argument n''existe pas.') //On regarde si le dictionnaire mis existe
			else
			 Begin
				Case choix1 of 
					1 : cas1();
					2 : cas2();
					3 : cas3();
					4 : cas4();
					5 : cas5();
					6 : cas6();
					7 : cas7();
					8 : cas8();
				else
					writeln ('erreur de syntaxe'); //Dans le cas où les paramètres sont incohérents
				End;
			 End;
	END;


Var choix1:integer;
BEGIN
	TextBackground(Black); //On force le terminal à être en noir car nos couleurs choisit sont clair et par conséquent illisible sur fond blanc
	randomize; //Obligatoire afin d'utiliser la fonction random
	choix(choix1); //Attribution du choix
	effectueActionMenu(choix1); //Exploitation du choix de l'utilisateur
	
END.




