--zad1

create table movies
(
id number(12) primary key,
title varchar2(400) not null,
category varchar2(50),
year char(4),
cast varchar2(4000),
director varchar2(4000),
story varchar2(4000),
price number(5,2),
cover blob,
mime_type varchar2(50)
);

--zad2

insert into movies (select d.id, d.title, d.category, d.year, d.cast, d.director, d.story, d.price, c.image, c.mime_type from descriptions d left join covers c on d.id = c.movie_id); 

--zad3

select Id, title from movies where cover is null;

--zad4

select Id, title, dbms_lob.getlength(cover) as filesize from movies where cover is not null;

--zad5

select Id, title, dbms_lob.getlength(cover) as filesize from movies where cover is null;

--zad6

select * from all_directories;

--zad7

update movies
set
cover = empty_blob(),
mime_type = 'image/jpeg'
where id = 66;

--zad8

select id, title, length(cover) as filesize from movies where id in (65,66);

--zad9

declare
vBlob blob;
vFile bfile := bfilename('ZSBD_DIR','escape.jpg');
begin
select cover into vBlob from movies
where id=66
for update;
dbms_lob.fileopen(vFile, dbms_lob.file_readonly);
dbms_lob.loadfromfile(vBlob, vFile, dbms_lob.getlength(vFile));
dbms_lob.fileclose(vFile);
commit;
end;

--zad10

create table temp_covers(
    movie_id number(12),
    image bfile,
    mime_type varchar2(50)
);

--zad11

insert into temp_covers values (65,bfilename('ZSBD_DIR','eagles.jpg'),'image/jpeg');

--zad12

select movie_id, dbms_lob.getlength(image) as filesize from temp_covers;

--zad13

declare
vMimeType varchar2(50);
vimage bfile;
vBlob blob;
begin

select mime_type into vMimeType from temp_covers;
select image into vImage from temp_covers;

dbms_lob.createtemporary(vBlob, true);

dbms_lob.fileopen(vImage, dbms_lob.file_readonly);
dbms_lob.loadfromfile(vBlob, vImage,dbms_lob.getlength(vImage));
dbms_lob.fileclose(vImage);

update movies
set cover = vBlob,
mime_type = vMimeType
where id = 65;

dbms_lob.freetemporary(vBlob);

commit;
end;

--zad14

select id, title, length(cover) as filesize from movies where id in (65,66);

--zad15

drop table movies;
drop table temp_covers;