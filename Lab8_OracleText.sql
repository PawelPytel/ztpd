--1
create table cytaty as
select
    *
from
    zsbd_tools.cytaty;

--2
select
    autor,
    tekst
from
    cytaty
where
    lower(tekst) like '%pesymista%'
    and lower(tekst) like '%optymista%';

--3
create index cytaty_tekst_idx on cytaty(tekst) indextype is ctxsys.context;

--4
select
    autor,
    tekst
from
    cytaty
where
    contains(tekst, 'pesymista and optymista', 1) > 0;

--5
select
    autor,
    tekst
from
    cytaty
where
    contains(tekst, 'pesymista ~ optymista', 1) > 0;

--6
select
    autor,
    tekst
from
    cytaty
where
    contains(tekst, 'near((pesymista, optymista), 3)', 1) > 0;

--7
select
    autor,
    tekst
from
    cytaty
where
    contains(tekst, 'near((pesymista, optymista), 10)', 1) > 0;

--8
select
    autor,
    tekst
from
    cytaty
where
    contains(tekst, 'życi%', 1) > 0;

--9
select
    autor,
    tekst,
    score(1) as dopasowanie
from
    cytaty
where
    contains(tekst, 'życi%', 1) > 0;

--10
select
    autor,
    tekst,
    score(1) as dopasowanie
from
    cytaty
where
    contains(tekst, 'życi%', 1) > 0
    and rownum <= 1
order by
    dopasowanie desc;

--11
select
    autor,
    tekst
from
    cytaty
where
    contains(tekst, 'fuzzy(probelm,,,n)', 1) > 0;

--12
insert into
    cytaty
values
    (
        500,
        'Bertrand Russell',
        'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.'
    );

commit;

--13
select
    autor,
    tekst
from
    cytaty
where
    contains(tekst, 'głupcy', 1) > 0;

--14
select
    token_text
from
    dr$cytaty_tekst_idx$i
where
    token_text = 'głupcy';

--15
drop index cytaty_tekst_idx;

create index cytaty_tekst_idx on cytaty(tekst) indextype is ctxsys.context;

--16
select
    token_text
from
    dr$cytaty_tekst_idx$i
where
    token_text = 'głupcy';

select
    autor,
    tekst
from
    cytaty
where
    contains(tekst, 'głupcy', 1) > 0;

--17
drop index cytaty_tekst_idx;

drop table cytaty;

--część druga
--1
create table quotes as
select
    *
from
    zsbd_tools.quotes;

--2
create index quotes_text_idx on quotes(text) indextype is ctxsys.context;

--3
select
    author,
    text
from
    quotes
where
    contains(text, 'work', 1) > 0;

select
    author,
    text
from
    quotes
where
    contains(text, '$work', 1) > 0;

select
    author,
    text
from
    quotes
where
    contains(text, 'working', 1) > 0;

select
    author,
    text
from
    quotes
where
    contains(text, '$working', 1) > 0;

--4
select
    author,
    text
from
    quotes
where
    contains(text, 'it', 1) > 0;

--it znajduje się na liście stopwords
--5
select
    *
from
    ctx_stoplists;

--default_stoplist
--6
select
    *
from
    ctx_stopwords;

--7
drop index quotes_text_idx;

create index quotes_text_idx on quotes(text) indextype is ctxsys.context parameters ('
    stoplist ctxsys.empty_stoplist
');

--8
select
    author,
    text
from
    quotes
where
    contains(text, 'it', 1) > 0;

--tak
--9
select
    author,
    text
from
    quotes
where
    contains(text, 'fool and humans', 1) > 0;

--10
select
    author,
    text
from
    quotes
where
    contains(text, 'fool and computer', 1) > 0;

--11
select
    author,
    text
from
    quotes
where
    contains(text, '(fool and computer) within sentence', 1) > 0;

--12
drop index quotes_text_idx;

--13
begin ctx_ddl.create_section_group('nullgroup', 'null_section_group');

ctx_ddl.add_special_section('nullgroup', 'sentence');

ctx_ddl.add_special_section('nullgroup', 'paragraph');

end;

--14
create index quotes_text_idx on quotes(text) indextype is ctxsys.context parameters (
    '
    stoplist ctxsys.empty_stoplist
    section group nullgroup
'
);

--15
select
    author,
    text
from
    quotes
where
    contains(text, '(fool and computer) within sentence', 1) > 0;

select
    author,
    text
from
    quotes
where
    contains(text, '(fool and humans) within sentence', 1) > 0;

--16
select
    author,
    text
from
    quotes
where
    contains(text, 'humans', 1) > 0;

--tak, ponieważ myślnik nie jest traktowany jako część słowa
--17
drop index quotes_text_idx;

begin ctx_ddl.create_preference('lex_z_m', 'basic_lexer');

ctx_ddl.set_attribute('lex_z_m', 'printjoins', '_-');

ctx_ddl.set_attribute('lex_z_m', 'index_text', 'yes');

end;

create index quotes_text_idx on quotes(text) indextype is ctxsys.context parameters (
    '
    stoplist ctxsys.empty_stoplist
    section group nullgroup
    lexer lex_z_m
'
);

--18
select
    author,
    text
from
    quotes
where
    contains(text, 'humans', 1) > 0;

--nie
--19
select
    author,
    text
from
    quotes
where
    contains(text, 'non\-humans', 1) > 0;

--20
drop table quotes;

begin ctx_ddl.drop_preference('lex_z_m');

end;