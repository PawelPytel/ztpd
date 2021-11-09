--zad1
create type samochod as object (
MARKA varchar2(20),
MODEL varchar2(20),
KILOMETRY number,
DATA_PRODUKCJI date,
CENA number(10,2)
);

desc samochod;

create table samochody of samochod;
desc samochod;

insert into samochody values (new samochod('FIAT', 'BRAVA', 60000, date '1999-11-30', 25000));
insert into samochody values (new samochod('MAZDA','323',12000,date '2000-09-22',52000.00));
insert into samochody values (new samochod('FORD', 'MONDEO', 80000, date '1997-10-05', 45000));


select * from samochody;

--zad2

create table wlasciciele (
imie varchar2(100),
nazwisko varchar2(100),
auto samochod
);

insert into wlasciciele values ('JAN', 'KOWALSKI', new samochod('FIAT', 'SEICENTO', 30000, date '0010-12-02', 19500));
insert into wlasciciele values ('ADAM', 'NOWAK', new samochod('OPEL', 'ASTRA', 34000, '0009-06-01', 33700));

select * from wlasciciele;


--zad3
alter type samochod replace as object (
MARKA varchar2(20),
MODEL varchar2(20),
KILOMETRY number,
DATA_PRODUKCJI date,
CENA number(10,2),
member function wartosc return number
);

create or replace type body samochod as member function wartosc return number is
begin
   return cena * power(0.9,extract (year from current_date) - extract(year from data_produkcji));
end wartosc;
end;

SELECT s.marka, s.cena, s.wartosc() FROM SAMOCHODY s;


--zad4
alter type samochod add map member function odwzoruj
return number cascade including table data;

create or replace type body samochod as 
member function wartosc return number is
begin
   return cena * power(0.9,extract (year from current_date) - extract(year from data_produkcji));
end wartosc;
map member function odwzoruj return number is
begin
   return (extract (year from current_date) - extract(year from data_produkcji)) + kilometry/10000;
end odwzoruj;
end;


--zad5
create type wlasciciel as object(
nazwisko varchar2(20),
imie varchar2(20)
);

alter type samochod add ATTRIBUTE wlasciciel_auta wlasciciel cascade;


update samochody
set wlasciciel_auta = new wlasciciel('Kowalski', 'Jan')
where marka='MAZDA';

update samochody
set wlasciciel_auta = new wlasciciel('Nowak', 'Adam')
where marka='FIAT';

update samochody
set wlasciciel_auta = new wlasciciel('test', 'test')
where marka='FORD';

--zad 7
DECLARE
TYPE t_ksiazki IS VARRAY(10) OF VARCHAR2(20);
moje_ksiazki t_ksiazki := t_ksiazki('');
BEGIN
moje_ksiazki(1) := 'test1';
moje_ksiazki.EXTEND(9);
moje_ksiazki(8):='test2';
FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
END LOOP;
moje_ksiazki.TRIM(5);
FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
END LOOP;
END;


--zad9

DECLARE
TYPE t_miesiace IS TABLE OF VARCHAR2(20);
miesiace t_miesiace := t_miesiace();
BEGIN
miesiace.EXTEND(12);
miesiace(1) := 'styczen';
miesiace(2) := 'luty';
miesiace(3) := 'marzec';
miesiace(4) := 'kwiecien';
miesiace(5) := 'maj';
miesiace(6) := 'czerwiec';
miesiace(7) := 'lipiec';
miesiace(8) := 'sierpien';
miesiace(9) := 'wrzesien';
miesiace(10) := 'pazdziernik';
miesiace(11) := 'listopad';
miesiace(12) := 'grudzien';
miesiace.DELETE(5,7);
FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
IF miesiace.EXISTS(i) THEN
DBMS_OUTPUT.PUT_LINE(miesiace(i));
END IF;
END LOOP;
END;

--zad11
create type produkt as object(nazwa varchar2(20), cena number);
create type produkty as table of produkt;

create table zakupy(numer number, koszyk_produktow produkty)
nested table koszyk_produktow store as tab_produkty;

insert into zakupy values(1, new produkty(new produkt('maslo', 1), new produkt('ciastko', 2)));
insert into zakupy values(2, new produkty(new produkt('bulka', 1), new produkt('chleb', 2)));

delete from zakupy
where numer in
(select numer from zakupy z, table(z.koszyk_produktow) k
where k.column_value.nazwa = 'maslo');

--zad22

create type t_ksiazki as table of varchar2(20);

create or replace type pisarz as object(
    id_pisarza number,
    nazwisko varchar2(20),
    data_ur date,
    ksiazki t_ksiazki,
    member function liczba_ksiazek return number
);

create or replace type ksiazka as object(
    id_ksiazki number,
    autor ref pisarz,
    tytul varchar2(20),
    data_wydania date,
    member function wiek return number
);

create or replace type body pisarz as
member function liczba_ksiazek return number is
begin
return ksiazki.count();
end liczba_ksiazek;
end;

create or replace type body ksiazka as
member function wiek return number is
begin
return extract(year from current_date) - extract(year from data_wydania);
end wiek;
end;


create or replace view PisarzeObjView of pisarz
with object oid(id_pisarza) as
select id_pisarza, nazwisko, data_ur, cast(multiset(select tytul from ksiazki k where k.id_pisarza=p.id_pisarza) as t_ksiazki) from pisarze p;

create or replace view KsiazkiObjView OF ksiazka 
with object oid(id_ksiazki) as
select id_ksiazki, make_ref(PisarzeObjView, id_pisarza), tytul, data_wydanie FROM ksiazki;

--zad23
alter type auto not final cascade;
delete from auta;
drop table auta;
create table auta of auto;

create or replace type auto_osobowe under auto (
    liczba_miejsc number,
    czy_klimatyzacja varchar2(3),
    overriding member function wartosc return number
);

create or replace type body auto_osobowe as
    overriding member function wartosc return number is
        wartosc number;
    begin
        wartosc := (self as auto).wartosc();
        if (czy_klimatyzacja = 'TAK') then
            wartosc := wartosc * 1.5;
        end if;
        return wartosc;
    end;
end;

create type auto_ciezarowe under auto (
    maksymalna_ladownosc number,
    overriding member function wartosc return number
);

create or replace type body auto_ciezarowe as
overriding member function wartosc return number is
wartosc number;
begin
wartosc := (self as auto).wartosc();
if (maksymalna_ladownosc > 10000) then
    wartosc := wartosc * 2;
end if;
return wartosc;
end;
end;

insert into auta values (auto_osobowe('Mazda', '6', 10000, date '2000-01-01', 10000, 5, 'TAK'));
insert into auta values (auto_osobowe('Ford', 'Fiesta', 10000, date '2000-01-01', 10000, 5, 'NIE'));
insert into auta values (auto_ciezarowe('Scania', '1', 10000, date '2000-01-01', 10000, 8000));
insert into auta values (auto_ciezarowe('Zuk', '2', 10000, date '2000-01-01', 10000, 12000));

select a.marka, a.wartosc() from auta a;