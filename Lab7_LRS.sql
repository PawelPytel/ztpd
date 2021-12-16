--1a
create table a6_lrs (geom sdo_geometry);

--1b
insert into
    a6_lrs
select
    s.geom
from
    streets_and_railroads s
where
    s.id = (
        select
            s_inner.id
        from
            streets_and_railroads s_inner,
            major_cities c
        where
            sdo_relate(
                s_inner.geom,
                sdo_geom.sdo_buffer(c.geom, 10, 1, 'unit=km'),
                'mask=anyinteract'
            ) = 'TRUE'
            and c.city_name = 'Koszalin'
    );

--1c
select
    round(sdo_geom.sdo_length(a.geom, 1, 'unit=km'), 7) as distance,
    st_linestring(a.geom).st_numpoints() as st_numpoints
from
    a6_lrs a;

--1d
update
    a6_lrs a
set
    geom = sdo_lrs.convert_to_lrs_geom(a.geom, 0, sdo_lrs.geom_segment_length(a.geom));

--1e
insert into
    user_sdo_geom_metadata
values
    (
        'a6_lrs',
        'geom',
        mdsys.sdo_dim_array(
            mdsys.sdo_dim_element('x', 12.603676, 26.369824, 1),
            mdsys.sdo_dim_element('y', 45.8464, 58.0213, 1),
            mdsys.sdo_dim_element('m', 0, 300, 1)
        ),
        8307
    );

--1f
create index a6_lrs_geom_idx on a6_lrs(geom) indextype is mdsys.spatial_index;

--2a
select
    sdo_lrs.valid_measure(geom, 500) as valid_500
from
    a6_lrs;

--2b
select
    sdo_lrs.geom_segment_end_pt(geom) as end_pt
from
    a6_lrs;

--2c
select
    sdo_lrs.locate_pt(geom, 150, 0) as km150
from
    a6_lrs;

--2d
select
    sdo_lrs.clip_geom_segment(geom, 120, 160)
from
    a6_lrs;

--2e
select
    sdo_lrs.get_next_shape_pt(a.geom, c.geom) as wjazd_na_a6
from
    a6_lrs a,
    major_cities c
where
    c.city_name = 'Slupsk';

--2f
select
    sdo_geom.sdo_length(
        sdo_lrs.offset_geom_segment(
            a.geom,
            m.diminfo,
            50,
            200,
            50,
            'unit=m'
        ),
        1,
        'unit=m'
    ) as koszt
from
    a6_lrs a,
    user_sdo_geom_metadata m
where
    m.table_name = 'A6_LRS'
    and m.column_name = 'GEOM';