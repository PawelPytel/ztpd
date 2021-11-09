--zad1

create table dokumenty (
    id number(12) primary key,
    dokument clob
);

--zad2

declare 
    tmp clob;
begin
for i in 1..10000
loop
    tmp := concat(tmp, 'Oto tekst. ');
end loop;

insert into dokumenty values
(1,tmp);
end;

--zad3

select * from dokumenty;

select upper(dokument) from dokumenty;

select length(dokument) from dokumenty;

select dbms_lob.getlength(dokument) from dokumenty;

select substr(dokument,5,1000) from dokumenty;

select dbms_lob.substr(dokument,5,1000) from dokumenty;

--zad4

insert into dokumenty values(2,empty_clob());

--zad5

insert into dokumenty values(3,null);

--zad6

select * from dokumenty;

select upper(dokument) from dokumenty;

select length(dokument) from dokumenty;

select dbms_lob.getlength(dokument) from dokumenty;

select substr(dokument,5,1000) from dokumenty;

select dbms_lob.substr(dokument,5,1000) from dokumenty;

--zad7

select * from all_directories;

--zad8

declare
vClob clob;
vFile bfile := bfilename('ZSBD_DIR','dokument.txt');
dest_offset integer := 1;
src_offset integer := 1;
lang_context integer := 0;
warning integer := null;

begin
select dokument into vClob from dokumenty
where id=2
for update;

dbms_lob.fileopen(vFile, dbms_lob.file_readonly);
dbms_lob.loadclobfromfile(vClob, vFile, dbms_lob.lobmaxsize, dest_offset, src_offset, 873, lang_context, warning);
dbms_lob.fileclose(vFile);
commit;
dbms_output.put_line('Status: ' || warning);
end;

--zad9

update dokumenty
set dokument = to_clob(bfilename('ZSBD_DIR', 'dokument.txt'))
where id = 3;

--zad10
select * from dokumenty;

--zad11

select dbms_lob.getlength(dokument) from dokument;

--zad12

drop table dokumenty;

--zad13

create or replace procedure clob_censor(
    vClob in out clob,
    pattern varchar2
)
is
position integer;
replaceWith varchar2(100);
i integer;
begin
for i in 1..length(pattern) loop
    replaceWith := replaceWith || '.';
end loop;
loop
    position := dbms_lob.instr(vClob, pattern, 1, 1);
    exit when position = 0;
    dbms_lob.write(vClob, length(pattern), position, replaceWith);
end loop;
end clob_censor;

--zad14

create table biographies as select * from zsbd_tools.biographies;

declare
vClob clob;
begin
select bio into vClob from biographies
where id=1 for update;

clob_censor(vClob, 'Cimrman');

commit;
end;

--zad15

drop table biographies;