unit read_ger;
{
Auteur: Patrick Pr‚martin.
Date: 26/06/1992.
      27/07/1992.
      30/12/1992.
Langage: Turbo Pascal 6.0
But: Proc‚dures de gestion du programme READ.EXE
}
interface

procedure init_liste_fichiers;
{
Ordre de s‚lection des fichiers … lire:

     - Nom des fichiers pass‚s en paramˆtre,
     - Contenu du fichier texte READ.DIR (1 ligne par fichier … lire),
     - Fichiers *.DOC du r‚pertoire courant.
}
procedure afficher_fichier (var fin : boolean);

implementation
uses
    read_lst,
    read_var,
    u_sgf,
    u_m_zone,
    u_code_clavier,
    u_curseur,
    u_aff_chaine,
    printer,
    crt,
    dos;

var
   zone : p_m_zone;
   lst_fich : p_liste;
   lst_txt : p_liste;
   fich_cour : p_elem;
   sens_next : boolean;
   lig_1, lig_n : p_elem; { PremiŠre et derniŠre ligne de l'‚cran. }

procedure init_liste_fichiers;
var
   i,
   nb : word;
   s: searchrec;
   fich : string;
   path : dirstr;
   name : namestr;
   ext : extstr;
   f : text;
begin
     nb := 0;
     for i := 1 to paramcount do
         begin
              fsplit (fexpand (paramstr (i)), path, name, ext);
              fich := path+name+ext;
              findfirst (fich, anyfile-directory, s);
              while (doserror = 0) do
                    begin
                         inc (nb);
                         lst_fich^.set_string (path+s.name);
                         findnext (s);
                    end;
              {endwhile}
         end;
     {endfor}
     if (nb = 0)
     then
         begin
           findfirst ('READ.DIR', anyfile-directory, s);
           if (doserror = 0)
           then
             begin
               assign (f, 'READ.DIR');
               reset (f);
               while not eof (f) do
                 begin
                   inc (nb);
                   readln (f,fich);
                   lst_fich^.set_string (fich);
                 end;
               {endwhile}
               close (f);
             end
           else
             begin
               findfirst ('*.doc', anyfile-directory, s);
               while (doserror = 0) do
                 begin
                   inc (nb);
                   lst_fich^.set_string (s.name);
                   findnext (s);
                 end;
               {endwhile}
             end;
           {endif}
         end;
     {endif}
     fich_cour := lst_fich^.first;
     if (nb = 0)
     then
         begin
              writeln ('No file to see...');
              halt (0);
         end;
     {endif}
end; { init_liste_fichiers }

procedure lit_fichier;
var
   nom : string;
   fich : text;
   ch : string;
begin
     nom := fich_cour^.get_string;
     assign (fich, nom);
     {$i-}
     reset (fich);
     {$i+}
     if (ioresult <> 0)
     then
         lst_txt := nil
     else
         begin
              window (20, 10, 58, 14);
              textcolor (lightmagenta);
              textbackground (brown);
              clrscr;
              window (20, 10, 58, 15);
              for nb_col := 1 to 39 do
                  begin
                       gotoxy (nb_col, 1);
                       write (#176);
                       gotoxy (nb_col, 5);
                       write (#176);
                  end;
              {endfor}
              for nb_lig := 1 to 5 do
                  begin
                       gotoxy (1, nb_lig);
                       write (#176);
                       gotoxy (39, nb_lig);
                       write (#176);
                  end;
              {endfor}
              gotoxy (3, 3);
              textcolor (yellow);
              writeln ('Please wait... Reading ', get_nom_fichier (nom));
              window (1, 1, 80, 25);
              nb_lig := 0;
              nb_col := 0;
              lst_txt := new (p_liste, init);
              while not eof (fich) do
                    begin
                         readln (fich, ch);
                         lst_txt^.set_string (ch);
                         if (length (ch) > nb_col)
                         then
                             nb_col := length (ch);
                         {endif}
                         inc (nb_lig);
                    end;
              {endwhile}
              close (fich);
         end;
     {endif}
     asc_tx := taille_curseur (hauteur_x, largeur_ligne, nb_col);
     asc_ty := taille_curseur (hauteur_y, hauteur_ligne, nb_lig);
end; { lit_fichier }

procedure dessin_ascenseur_x;
var
   i : byte;
begin
     asc_x := deplace_curseur (hauteur_x, nb_col, x, asc_tx);
     zone^.add_zone (#17, red, blue, 1, 23, 0, true, touche_gauche);
     zone^.add_zone (#16, red, blue, 79, 23, 0, true, touche_droite);
     for i := 2 to 78 do
         if ((i-1 < asc_x) or (i-1 >= asc_x+asc_tx))
         then
             begin
                  textattr := blue * $0F + cyan;
                  gotoxy (i, 23);
                  write (#176);
             end
         else
             begin
                  textattr := blue * $0F + lightgray;
                  gotoxy (i, 23);
                  write (#178);
             end;
         {endif}
     {endfor}
end; { dessin_ascenseur_x }

procedure dessin_ascenseur_y;
var
   i : byte;
begin
     asc_y := deplace_curseur (hauteur_y, nb_lig, y, asc_ty);
     zone^.add_zone (#30, red, blue, 80, 2, 0, true, touche_haut);
     zone^.add_zone (#31, red, blue, 80, 22, 0, true, touche_bas);
     for i := 3 to 21 do
         if ((i-2 < asc_y) or (i-2 >= asc_y+asc_ty))
         then
             begin
                  textattr := blue * $0F + cyan;
                  gotoxy (80, i);
                  write (#176);
             end
         else
             begin
                  textattr := blue * $0F + lightgray;
                  gotoxy (80, i);
                  write (#178);
             end;
         {endif}
     {endfor}
end; { dessin_ascenseur_y }

procedure dessin_texte;
var
   i : byte;
   e : p_elem;
begin
     window (1, 2, largeur_ligne, 22);
     textcolor (yellow);
     textbackground (magenta);
     clrscr;
     window (1, 1, 80, 25);
     i := 2;
     e := lig_1;
     while ((i < 23) and (e <> nil)) do
           begin
                gotoxy (1, i);
                write (copy (e^.get_string, x, largeur_ligne));
                lig_n := e;
                e := e^.n;
                inc (i);
           end;
     {endwhile}
end; { dessin_texte }

procedure dessin_ecran;
begin
     zone := new (p_m_zone, init);
     window (1, 1, 80, 25);
     textcolor (lightgray);
     textbackground (black);
     clrscr;
     x := 1;
     y := 1;
     lig_1 := lst_txt^.first;
{ Haut d'‚cran. }
     gotoxy (1, 1);
     textcolor (black);
     textbackground (lightgray);
     clreol;
{ Bas d'‚cran. }
     gotoxy (1, 24);
     textcolor (black);
     textbackground (lightgray);
     clreol;
{ Description des zones de cliquage. }
     with zone^ do
          begin
               add_zone ('READ (v'+num_vers+')', red, lightgray, 1, 1, 80, true, touche_f1);
               add_zone ('(c) Olf Software '+dat_vers, red, lightgray, 52, 1, 0, true, touche_f1);
               add_zone (get_nom_fichier (fich_cour^.get_string), red, lightgray, 1, 24, 0, false, carac_nul);
               add_zone ('ESC', red, lightgray, 17, 24, 0, false, touche_escape);
               add_zone (' - Quit', black, lightgray, 20, 24, 0, false, touche_escape);
               add_zone ('N', red, lightgray, 33, 24, 0, false, 'N');
               add_zone ('ext file', black, lightgray, 34, 24, 0, false, 'N');
               add_zone ('P', red, lightgray, 49, 24, 0, false, 'P');
               add_zone ('revious file', black, lightgray, 50, 24, 0, false, 'P');
               add_zone ('F5', red, lightgray, 65, 24, 0, true, touche_f5);
               add_zone (' - Print Text', black, lightgray, 67, 24, 0, true, touche_f5);
          end;
     {endwith}
     dessin_ascenseur_x;
     dessin_ascenseur_y;
     dessin_texte;
end; { dessin_ecran }

procedure efface_ecran;
begin
     if (lst_txt <> nil)
     then
         dispose (lst_txt, done);
     {endif}
     if (zone <> nil)
     then
         dispose (zone, done);
     {endif}
end; { efface_ecran }

procedure calcul_lig_n;
var
   i : byte;
begin
     lig_n := lig_1;
     i := 1;
     while ((i < hauteur_ligne) and (lig_n^.n <> nil)) do
           begin
                inc (i);
                lig_n := lig_n^.n;
           end;
     {endwhile}
end; { calcul_lig_n }


procedure traiter_haut;
begin
     if (y > 1)
     then
         begin
              dec (y);
              lig_1 := lig_1^.p;
              calcul_lig_n;
              window (1, 2, largeur_ligne, 22);
              gotoxy (1, 1);
              textcolor (yellow);
              textbackground (magenta);
              insline;
              window (1, 1, 80, 25);
              gotoxy (1, 2);
              write (copy (lig_1^.get_string, x, largeur_ligne));
              dessin_ascenseur_y;
         end;
     {endif}
end; { traiter_haut }

procedure traiter_bas;
begin
     if (y+20 < nb_lig)
     then
         begin
              inc (y);
              lig_1 := lig_1^.n;
              calcul_lig_n;
              window (1, 2, largeur_ligne, 22);
              gotoxy (1, 1);
              textcolor (yellow);
              textbackground (magenta);
              delline;
              window (1, 1, 80, 25);
              gotoxy (1, 22);
              write (copy (lig_n^.get_string, x, largeur_ligne));
              dessin_ascenseur_y;
         end;
     {endif}
end; { traiter_bas }

procedure traiter_gauche;
begin
     if (x > 1)
     then
         begin
              dec (x);
              dessin_texte;
              dessin_ascenseur_x;
         end;
     {endif}
end; { traiter_gauche }

procedure traiter_droite;
begin
     if (x+78 < nb_col)
     then
         begin
              inc (x);
              dessin_texte;
              dessin_ascenseur_x;
         end;
     {endif}
end; { traiter_droite }

procedure traiter_debut;
begin
     y := 1;
     lig_1 := lst_txt^.first;
     dessin_texte;
     dessin_ascenseur_y;
end; { traiter_debut }

procedure traiter_fin;
begin
     if (nb_lig > hauteur_ligne)
     then
         begin
              lig_n := lst_txt^.last;
              lig_1 := lig_n;
              y := nb_lig;
              while (y > nb_lig-20) do
                    begin
                         lig_1 := lig_1^.p;
                         dec (y);
                    end;
              {endwhile}
              dessin_ascenseur_y;
         end;
     {endif}
     dessin_texte;
end; { traiter_fin }

procedure traiter_page_precedente;
var
   i : byte;
begin
     if (y < 22)
     then
         traiter_debut
     else
         begin
              y := y-hauteur_ligne;
              for i := 1 to hauteur_ligne do
                  lig_1 := lig_1^.p;
              {endfor}
              calcul_lig_n;
              dessin_ascenseur_y;
              dessin_texte;
         end;
     {endif}
end; { traiter_page_precedente }

procedure traiter_page_suivante;
var
   i : byte;
begin
     if (y > nb_lig - hauteur_ligne)
     then
         traiter_fin
     else
         begin
              y := y+hauteur_ligne;
              for i := 1 to hauteur_ligne do
                  lig_1 := lig_1^.n;
              {endfor}
              calcul_lig_n;
              dessin_ascenseur_y;
              dessin_texte;
         end;
     {endif}
end; { traiter_page_suivante }

procedure traiter_impression;
var
   e : p_elem;
   i, j : byte;
begin
     window (20, 10, 59, 14);
     textcolor (lightmagenta);
     textbackground (brown);
     clrscr;
     window (20, 10, 59, 15);
     for i := 1 to 40 do
         begin
              gotoxy (i, 1);
              write (#176);
              gotoxy (i, 5);
              write (#176);
         end;
     {endfor}
     for j := 1 to 5 do
         begin
              gotoxy (1, j);
              write (#176);
              gotoxy (40, j);
              write (#176);
         end;
     {endfor}
     gotoxy (3, 3);
     textcolor (yellow);
     writeln ('Please wait... Printing ', fich_cour^.get_string);
     window (1, 1, 80, 25);
     e := lst_txt^.first;
     while (e <> nil) do
           begin
                writeln (lst, e^.get_string);
                e := e^.n;
           end;
     {endwhile}
     writeln (lst, carac_ff);
     dessin_texte;
end; { traiter_impression }

procedure traiter_aide;
var
   i, j : byte;
   c : char;
begin
     window (10, 5, 69, 19);
     textcolor (lightmagenta);
     textbackground (brown);
     clrscr;
     window (10, 5, 69, 20);
     for i := 1 to 60 do
         begin
              gotoxy (i, 1);
              write (#176);
              gotoxy (i, 15);
              write (#176);
         end;
     {endfor}
     for j := 1 to 15 do
         begin
              gotoxy (1, j);
              write (#176);
              gotoxy (60, j);
              write (#176);
         end;
     {endfor}
     gotoxy (3, 3);
     textcolor (yellow);
     gotoxy (1, 2);
     affic_center_ln ('READ (v'+num_vers+')');
     affic_center_ln ('(c) Olf Software '+dat_vers);
     affic_center_ln ('');
     affic_center_ln ('This program display ASCII files, print them with F5.');
     affic_center_ln ('To use it, type: ''READ File_Name.Ext'' at the prompt.');
     affic_center_ln ('');
     affic_center_ln ('This program is FREEWARE, use and copy it freely...');
     affic_center_ln ('To contact Olf Software, write to:');
     affic_center_ln ('PREMARTIN PATRICK');
     affic_center_ln ('LOT. LE SOULEIADO');
     affic_center_ln ('13790 ROUSSET');
     affic_center_ln ('FRANCE');
     window (1, 1, 80, 25);
     repeat
     until keypressed;
     c := readkey;
     while (keypressed) do
           c := readkey;
     {endwhile}
     dessin_texte;
end; { traiter_aide }

procedure afficher_fichier (var fin : boolean);
var
   fin2 : boolean;
   cn : boolean;
   c : char;
begin
     repeat
           lit_fichier;
           if (lst_txt = nil)
           then
               case sens_next of
                    true : if (fich_cour^.n = nil)
                           then
                               sens_next := false
                           else
                               fich_cour := fich_cour^.n;
                           {endif}
                    false : if (fich_cour^.p = nil)
                            then
                                sens_next := true
                            else
                                fich_cour := fich_cour^.p;
                            {endif}
               end;
           {endif}
     until (lst_txt <> nil);
     dessin_ecran;
     fin2 := false;
     curseur_off;
     repeat
           zone^.test_souris (cn, c);
           if (cn)
           then
               case c of
                    touche_page_up : traiter_page_precedente;
                    touche_page_dn : traiter_page_suivante;
                    touche_home : traiter_debut;
                    touche_end : traiter_fin;
                    touche_haut : traiter_haut;
                    touche_bas : traiter_bas;
                    touche_gauche : traiter_gauche;
                    touche_droite : traiter_droite;
                    touche_f1 : traiter_aide;
                    touche_f5 : traiter_impression;
               end
           else
               case c of
                    touche_escape : fin := true;
                    'N', 'n' : if (fich_cour^.n <> nil)
                               then
                                   begin
                                        fin2 := true;
                                        fich_cour := fich_cour^.n;
                                        sens_next := true;
                                   end;
                               {endif}
                    'P', 'p' : if (fich_cour^.p <> nil)
                               then
                                   begin
                                        fin2 := true;
                                        fich_cour := fich_cour^.p;
                                        sens_next := false;
                                   end;
                               {endif}
               end;
           {endif}
     until (fin2 or fin);
     efface_ecran;
     curseur_on;
end; { afficher_fichier }

var
   old_exitproc : pointer;

procedure read_ger_exit; far;
begin
     if (lst_fich <> nil)
     then
         dispose (lst_fich, done);
     {endif}
     exitproc := old_exitproc;
end; { read_ger_exit }

begin
     lst_fich := new (p_liste, init);
     lst_txt := nil;
     zone := nil;
     fich_cour := nil;
     sens_next := true;
     old_exitproc := exitproc;
     exitproc := @read_ger_exit;
end. { read_ger }
