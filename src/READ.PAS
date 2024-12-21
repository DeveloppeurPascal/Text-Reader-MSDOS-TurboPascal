program read;
{
Auteur: Patrick Pr‚martin.
Date: 26/06/1992. (1.0)
      27/07/1992. (1.1)
      30/12/1992. (1.2)
Langage: Turbo Pascal 6.0
But: Programme permettant de consulter des fichiers texte.
     L'interface de ce logiciel permet l'utilisation de la souris, et du
     clavier. Les textes se trouvent dans une fenˆtre avec ascenceurs
     verticaux et horizontaux.
}
{$m 32768, 0, 655360}
uses
    read_var,
    read_ger,
    u_parametre,
    crt;

var
   fin : boolean;

begin
     if ((param_del ('/?')) or (param_del ('/H')))
     then
         begin

              writeln ('Read v',num_vers);
              writeln ('(c) Olf Software ', dat_vers);
              writeln;
              writeln ('Use and copy this program freely, it is freeware...');
              writeln;
              writeln ('Syntax: READ [file_name{.ext}]');
              writeln ('     It will display all files (* and ? possible).');
              writeln;
              writeln ('If you have a 100% compatible Microsoft mouse, use it');
         end
     else
         begin
              init_liste_fichiers;
              fin := false;
              repeat
                    afficher_fichier (fin);
              until fin;
              window (1, 1, 80, 25);
              textcolor (lightgray);
              textbackground (black);
              clrscr;
         end;
     {endif}
     writeln ('Thank you for using an Olf Software program...');
end.
