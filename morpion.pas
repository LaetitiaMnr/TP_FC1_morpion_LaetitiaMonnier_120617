program morpi; // Laetitia Monnier

uses crt;

CONST
	MAXCOUPS = 9;

TYPE
	tab = array[1..3,1..3] of char;

TYPE
	tabSymbole = array[1..2] of char;

TYPE
	tabPseudo = array[1..2] of string;

TYPE
	tabScore = array[1..2] of integer;

//Cette procedure initialise le tableau du plateau.
PROCEDURE initTableau(var plateau : tab);
VAR
	i, j : integer;
begin
	FOR i := 1 TO 3 DO
	begin
		FOR j := 1 TO 3 DO
			plateau[i,j] := ' ';
	end;
end;

//Cette procedure affiche le plateau graphiquement.
PROCEDURE affichagePlateau();
VAR
	i, j : integer;
begin
	write(' '); // Affichage des chiffres en haut.
	FOR i := 1 TO 3 DO
		write('   ', i);
	writeln();

	write(' '); // Affichage du côté haut de la première ligne de cases.
	FOR i := 1 TO 3 DO
		write('   -');
	writeln();

	FOR i := 1 TO 3 DO
	begin
		write(i); // Affichage des chiffres sur le côté.

		FOR j := 1 TO 4 DO // Affichage des côtés gauche et droite des cases.
			write(' |  ');
		writeln();

		write(' ');// Affichage des côtés haut et bas des cases.
		FOR j := 1 TO 3 DO
			write('   -');
		writeln();
	end;
	writeln();
	
end;

//Cette procedure permet de positionner à 10 les instructions de la procedure tour, et ainsi d'effacer l'écran sans utiliser un clrscr.
PROCEDURE effaceEcranTour();
VAR
	compteur : integer;
begin
	GOTOXY(1,10);
	FOR compteur := 1 TO 6 DO
		writeln('                                                                                ');
	GOTOXY(1,10);
end;

//Dans cettte procédure, le joueur entre son pseudo.
PROCEDURE choixJoueur(var pseudos : tabPseudo);
begin
	writeln('Joueur 1 : Entrez votre pseudo.');
	readln(pseudos[1]);
	writeln('Joueur 2 : Entrez votre pseudo.');
	readln(pseudos[2]);
	clrscr;
end;

//Cette fonction sera appelée dans la procédure choixPion et permet d'attribuer un symbole pour chaque joueur.
FUNCTION symbole(n : integer):char;
begin
	CASE n OF
		1 : symbole := 'O';
		2 : symbole := 'X';
	end;
end;

//Dans cette procédure, le joueur 1 choisi son symbole.
PROCEDURE choixPion(var joueurs : tabSymbole);
VAR
	n : integer;
begin
	writeln('Joueur 1 : Si voulez-vous être le ', symbole(1), ' appuyez sur 1, sinon pour être le ', symbole(2), ' appuyez sur 2.');
	readln(n);
	joueurs[1] := symbole(n);
	joueurs[2] := symbole((n MOD 2) + 1); //Ce calcul permet d'attribuer automatiquement le symbole restant au joueur 2, quelque soit le choix du joueur 1.
	clrscr;
end;

//Cette fonction vérifie si une case du plateau est occupée ou non.
FUNCTION verification(plateau : tab; x, y : integer):boolean;
VAR
	resultat : boolean;
begin
	resultat := FALSE;
	IF (plateau[x,y] = 'X') OR (plateau[x,y] = 'O') THEN
		resultat := TRUE;
	verification := resultat;
end;

{Cette fonction vérifie les différentes possibilités de victoire.
Les deux premiers IF vérifie horizontalement et verticalement que 3 symboles se suivent.
On ne fait la vérification des diagonales seulement si les 2 premiers IF sont faux et que la somme de x + y soit pair.}
FUNCTION verifVictoire(joueur : char; plateau : tab; x, y : integer):boolean;
VAR
	compteur : integer;
	resultatX, resultatY : boolean;
begin
	resultatX := TRUE;
	resultatY := TRUE;

	FOR compteur := 1 TO 3 DO
	begin
		IF plateau[x, compteur] <> joueur THEN
			resultatX := FALSE;
		IF plateau[compteur, y] <> joueur THEN
			resultatY := FALSE;
	end;

	IF ((x + y) MOD 2 = 0) AND (resultatX OR resultatY = FALSE) THEN
	begin
		resultatX := TRUE;
		resultatY := TRUE;

		FOR compteur := 1 TO 3 DO
		begin
			IF plateau[compteur, compteur] <> joueur THEN //On vérifie pour la 1ere diagonale 1,1/2,2/3,3.
				resultatX := FALSE;
			IF plateau[compteur, 4 - compteur] <> joueur THEN //On vérifie pour la 2eme diagonale 1,3/2,2/3,1 (d'où le 4 - compteur).
				resultatY := FALSE;
		end;
	end;

	verifVictoire := resultatX OR resultatY;
end;

{Dans cette fonction, les joueurs, à tour de rôle, placent leurs pions en indiquant leurs coordonnées X et Y.
On appelle la procédure verifiaction pour s'assurer que deux symboles n'occupent pas la même place.
Si tour va renvoyer la fonction verifVictoire qui va renvoyer vrai ou faux. Si c'est vrai, alors il y'a une victoire et on sort de la fonction.}
FUNCTION tour(pseudo : string; joueur : char; var plateau : tab):boolean;
VAR
	x, y : integer;
begin
	GOTOXY(1,10);
	writeln('A vous de jouer ', pseudo);
	writeln('Rentrez la coordonnée X de la case');
	REPEAT
		GOTOXY(1,12);
		readln(x);
	UNTIL (x <= 3);
	writeln('Rentrez la coordonnée Y de la case');
	REPEAT
		GOTOXY(1,14);
		readln(y);
	UNTIL (y <= 3);
	IF verification(plateau, x, y) THEN
	begin
		REPEAT
			effaceEcranTour();
			writeln('La place est déjà occupée ! Recommencez.');
			writeln('Rentrez la coordonnée X de la case');
			readln(x);
			writeln('Rentrez la coordonnée Y de la case');
			readln(y);
		UNTIL verification(plateau, x, y) = false;
		GOTOXY(x * 5, y * 3);
		writeln(joueur);
	end
	ELSE
	begin
		plateau[x,y] := joueur;
		GOTOXY(x * 4 + 1,y * 2 + 1);
		write(joueur)
	end;
	effaceEcranTour();

	tour := verifVictoire(joueur, plateau, x, y);
end;

// -- Programme Principal --
{Le 1er repeat permet aux joueurs de recommencer une partie, s'ils le veulent ou non.
Le 2eme repeat demande en combien de manche la partie doit se dérouler.
Le 3eme repeat va donc appeler la fonction tour jusqu'a ce que le nombre de manche soit atteint ou que le score soit largement supérieur
à l'autre (calcul dans le IF).
}
VAR
	pseudos : tabPseudo;
	joueurs : tabSymbole;
	scores : tabScore;
	plateau : tab;
	n, compteur, nbTour : integer;
	fin : boolean;
	f : textfile;
BEGIN
	ASSIGN(f, 'scoreMorpion.txt');
	rewrite(f);
	REPEAT
		clrscr;
		scores[1] := 0;
		scores[2] := 0;
		fin := FALSE;

		choixJoueur(pseudos);
		choixPion(joueurs);
		writeln('En combien de manches voulez-vous jouer ?');
		readln(n);
		REPEAT
			append(f);
			initTableau(plateau);
			clrscr;
			affichagePlateau();
			nbTour := 0;

			REPEAT
				FOR compteur := 1 TO 2 DO
				begin
					nbTour := nbTour + 1;

					IF tour(pseudos[compteur], joueurs[compteur], plateau) THEN
					begin
						scores[compteur] := scores[compteur] + 1;
						writeln(pseudos[compteur], ' a gagné ! Voici les scores :');
						writeln(pseudos[1], ' : ', scores[1]);
						writeln(pseudos[2], ' : ', scores[2]);
						readln;
						IF (scores[compteur] = n DIV 2 + 1) THEN fin := TRUE; //Au meilleur des n manches.
						nbTour := 9;
					end;

					IF nbTour = 9 THEN break;
				end;
			UNTIL nbTour = 9;
		UNTIL fin;

		writeln(f, 'Score de ', pseudos[1], ' : ', scores[1]);
		writeln(f, 'Score de ', pseudos[2], ' : ', scores[2]);
		
		IF scores[1] > scores[2] THEN
		begin
			writeln(f, pseudos[1], ' a gagné cette partie.');
			writeln(f, ' ');
		end
		ELSE
		begin
			writeln(f, pseudos[2], ' a gagné cette partie.');
			writeln(f, ' ');
		end;

		writeln('Voulez-vous rejouer ? (1 = Oui / 0 = Non)');
		readln(n);
	UNTIL n = 0;
	close(f);
	readln;
END.
