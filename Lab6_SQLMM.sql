--1c
create table myst_major_cities (
    fips_cntry varchar2(2),
    city_name varchar2(40),
    stgeom st_point
);

--1d
insert into
    myst_major_cities
select
    fips_cntry,
    city_name,
    st_point(geom) stgeom
from
    major_cities;

--2a
insert into
    myst_major_cities
values
    (
        'PL',
        'Szczyrk',
        treat(
            st_point.from_wkt('point(19.036107 49.718655)', 8307) as st_point
        )
    );

--2b
select
    name,
    treat(st_point.from_sdo_geom(geom) as st_geometry).get_wkt() as wkt
from
    rivers;

--2c
select
    sdo_util.to_gmlgeometry(st_point.get_sdo_geom(stgeom)) gml
from
    myst_major_cities
where
    city_name = 'Szczyrk';

--3a
create table myst_country_boundaries (
    fips_cntry varchar2(2),
    cntry_name varchar2(40),
    stgeom st_multipolygon
);

--3b
insert into
    myst_country_boundaries
select
    fips_cntry,
    cntry_name,
    st_multipolygon(geom)
from
    country_boundaries;

--3c
select
    b.stgeom.st_geometrytype() as "TYP OBIEKTU",
    count(*) as ile
from
    myst_country_boundaries b
group by
    b.stgeom.st_geometrytype();

--3d
select
    b.stgeom.st_issimple()
from
    myst_country_boundaries b;

--4a
select
    b.cntry_name,
    count(*)
from
    myst_country_boundaries b,
    myst_major_cities c
where
    b.stgeom.st_contains(c.stgeom) = 1
group by
    b.cntry_name;

--4b
select
    a.cntry_name a_name,
    b.cntry_name b_name
from
    myst_country_boundaries a,
    myst_country_boundaries b
where
    b.cntry_name = 'Czech Republic'
    and a.stgeom.st_touches(b.stgeom) = 1;

--4c
select
    distinct b.cntry_name,
    r.name
from
    myst_country_boundaries b,
    rivers r
where
    b.cntry_name = 'Czech Republic'
    and b.stgeom.st_crosses(st_linestring(r.geom)) = 1;

--4d
select
    round(
        treat(a.stgeom.st_union(b.stgeom) as st_polygon).st_area(),
        -2
    ) as powierzchnia
from
    myst_country_boundaries a,
    myst_country_boundaries b
where
    b.cntry_name = 'Czech Republic'
    and a.cntry_name = 'Slovakia';

--4e
select
    b.stgeom obiekt,
    b.stgeom.st_difference(st_geometry(w.geom)).st_geometrytype() wegry_bez
from
    myst_country_boundaries b,
    water_bodies w
where
    b.cntry_name = 'Hungary'
    and w.name = 'Balaton';

--5a
explain plan for
select
    b.cntry_name a_name,
    count(*)
from
    myst_country_boundaries b,
    myst_major_cities c
where
    sdo_within_distance(c.stgeom, b.stgeom, 'distance=100 unit=km') = 'TRUE'
    and b.cntry_name = 'Poland'
group by
    b.cntry_name;

select
    plan_table_output
from
    table(dbms_xplan.display('plan_table', null, 'basic'));

--5b
insert into
    user_sdo_geom_metadata
select
    'myst_major_cities',
    'stgeom',
    t.diminfo,
    t.srid
from
    all_sdo_geom_metadata t
where
    t.table_name = 'MAJOR_CITIES';

insert into
    user_sdo_geom_metadata
select
    'myst_country_boundaries',
    'stgeom',
    t.diminfo,
    t.srid
from
    all_sdo_geom_metadata t
where
    t.table_name = 'COUNTRY_BOUNDARIES';

--5c
create index myst_major_cities_stgeom_idx
on myst_major_cities(stgeom)
indextype is mdsys.spatial_index_v2;

create index myst_country_boundaries_stgeom_idx
on myst_country_boundaries(stgeom)
indextype is mdsys.spatial_index_v2;

--5d
--analogicznie do 5a, indeksy są wykorzystane