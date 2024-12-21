unit read_lst;
{
Auteur: Patrick Pr‚martin.
Date: 26/06/1992.
Langage: Turbo Pascal 6.0
But: Gestion d'une liste d'‚l‚ments de taille variable. La version par d‚faut
     gŠre une file d'attente (FIFO).
}
interface

type
    p_elem = ^o_elem;
    o_elem = object
                   n : p_elem; { Element suivant }
                   p : p_elem; { Element pr‚c‚dent }
                   t : pointer; { Pointeur vers l'‚l‚ment courant }
                   l : word; { Taille de l'‚l‚ment courant }

                   constructor init (previous, next : p_elem);
                   destructor done;
                   procedure set_string (txt : string);
                   function get_string : string;
    end;

    p_liste = ^o_liste;
    o_liste = object
                    first, last : p_elem;


                    constructor init;
                    destructor done;
                    procedure set_string (ch : string); virtual;
                    function get_string : string; virtual;
    end;

implementation
constructor o_elem.init (previous, next : p_elem);
begin
     n := next;
     p := previous;
     t := nil;
     l := 0;
end; { o_elem.init }

destructor o_elem.done;
begin
     if (t <> nil)
     then
         freemem (t, l);
     {endif}
end; { o_elem.done }

procedure o_elem.set_string (txt : string);
begin
     if (t <> nil)
     then
         freemem (t, l);
     {endif}
     l := succ (length (txt));
     getmem (t, l);
     if (t <> nil)
     then
         move (txt [0], t^, l);
     {endif}
end; { o_elem.set_string }

function o_elem.get_string : string;
var
   c : string;
begin
     if (t <> nil)
     then
         move (t^, c [0], l)
     else
         c := '';
     {endif}
     get_string := c;
end; { o_elem.get_string }

constructor o_liste.init;
begin
     first := nil;
     last := nil;
end; { o_liste.init }

destructor o_liste.done;
begin
     while (first <> nil) do
           begin
                last := first^.n;
                dispose (first, done);
                first := last;
           end;
     {endwhile}
end; { o_liste.done }

procedure o_liste.set_string (ch : string);
var
   e : p_elem;
begin
     e := new (p_elem, init (last, nil));
     if (e <> nil)
     then
         begin
              if (last <> nil)
              then
                  begin
                       last^.n := e;
                       last := e;
                  end
              else
                  begin
                       first := e;
                       last := e;
                  end;
              {endif}
              e^.set_string (ch);
         end;
     {endif}
end; { o_liste.set_string }

function o_liste.get_string : string;
var
   e : p_elem;
   ch : string;
begin
     if (first <> nil)
     then
         begin
              e := first;
              if (first = last)
              then
                  begin
                       first := nil;
                       last := nil;
                  end
              else
                  begin
                       first := first^.n;
                       first^.p := nil;
                  end;
              {endif}
              ch := e^.get_string;
              dispose (e, done);
         end
     else
         ch := '';
     {endif}
end; { o_liste.get_string }

end. { read_lst }
