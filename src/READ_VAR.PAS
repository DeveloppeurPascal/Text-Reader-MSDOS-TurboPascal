unit read_var;
{
Auteur: Patrick Pr‚martin.
Date: 26/06/1992
      27/07/1992.
      30/12/1992.
Langage: Turbo Pascal 6.0
But: D‚claration des donn‚es utilis‚es par READ.
}
interface

const
     num_vers : string [3] = '1.2';
     dat_vers : string [10] = '12/30/1992';
     hauteur_x = 77; { Largeur de l'ascenseur horizontal. }
     hauteur_y = 19; { Hauteur de l'ascenseur vertical. }
     largeur_ligne = 79; { Nombre de colonnes par ligne. }
     hauteur_ligne = 21; { Nombre de lignes par ‚cran. }

var
   x, y : word; { Position dans le texte du caractŠre haut/gauche de l'‚cran. }
   asc_x, asc_y : byte; { Position des ascenseurs. }
   asc_tx, asc_ty : byte; { Taille des ascenseurs horizontaux et verticaux. }
   nb_lig, nb_col : word; { Hauteur et largeur du texte. }

function taille_curseur (hauteur_ascenseur, larg_lig, nb_lig : word) : word;
function deplace_curseur (hauteur_ascenseur, nb_lig, num_lig, tail_curseur : word) : byte;

implementation

function taille_curseur (hauteur_ascenseur, larg_lig, nb_lig : word) : word;
var
   res : word;
begin
     if ((nb_lig / hauteur_ascenseur) <= 1)
     then
         res := hauteur_ascenseur
     else
         res := (larg_lig * hauteur_ascenseur) div nb_lig;
     {endif}
     if (res < 1)
     then
         res := 1;
     {endif}
     taille_curseur := res;
end; { Taille_Curseur }

function deplace_curseur (hauteur_ascenseur, nb_lig, num_lig, tail_curseur : word) : byte;
begin
     if (nb_lig = 0)
     then
         deplace_curseur := 1
     else
         deplace_curseur := succ ((num_lig * hauteur_ascenseur) div nb_lig);
     {endif}
end; { Deplace_Curseur }

procedure var_init;
begin
     x := 1;
     y := 1;
     asc_x := 1;
     asc_y := 1;
     asc_tx := hauteur_x;
     asc_ty := hauteur_y;
     nb_lig := 0;
     nb_col := 0;
end;

begin
     var_init;
end. { READ_VAR }
