--1a
insert into
    user_sdo_geom_metadata
values
    (
        'figury',
        'ksztalt',
        mdsys.sdo_dim_array(
            mdsys.sdo_dim_element('x', 0, 100, 0.01),
            mdsys.sdo_dim_element('y', 0, 100, 0.01)
        ),
        null
    );

--1b
select
    sdo_tune.estimate_rtree_index_size(3000000, 8192, 10, 2, 0)
from
    figury
where
    rownum <= 1;

--1c
create index figury_ksztalt_idx on figury(ksztalt) indextype is mdsys.spatial_index_v2;

--1d
select
    id
from
    figury
where
    sdo_filter(
        ksztalt,
        sdo_geometry(
            2001,
            null,
            sdo_point_type(3, 3, null),
            null,
            null
        )
    ) = 'TRUE';

--nie, ponieważ sdo_filter dokonuje tylko pierwszego etapu filtrowania i zwraca "kandydatów"
--1e
select
    id
from
    figury
where
    sdo_relate(
        ksztalt,
        sdo_geometry(
            2001,
            null,
            sdo_point_type(3, 3, null),
            null,
            null
        ),
        'mask=anyinteract'
    ) = 'TRUE';

--tak
--2a
select
    a.city_name as miasto,
    round(sdo_nn_distance(1), 7) as odl
from
    major_cities a,
    major_cities b
where
    sdo_nn(
        a.geom,
        mdsys.sdo_geometry(
            2001,
            8307,
            b.geom.sdo_point,
            b.geom.sdo_elem_info,
            b.geom.sdo_ordinates
        ),
        'sdo_num_res=9 unit=km',
        1
    ) = 'TRUE'
    and b.city_name = 'Warsaw'
    and a.city_name != 'Warsaw';

--2b
select
    a.city_name miasto
from
    major_cities a,
    major_cities b
where
    sdo_within_distance(
        a.geom,
        mdsys.sdo_geometry(
            2001,
            8307,
            b.geom.sdo_point,
            b.geom.sdo_elem_info,
            b.geom.sdo_ordinates
        ),
        'distance=100 unit=km'
    ) = 'TRUE'
    and b.city_name = 'Warsaw'
    and a.city_name != 'Warsaw';

--2c
select
    b.cntry_name as kraj,
    c.city_name as miasto
from
    country_boundaries b,
    major_cities c
where
    sdo_relate(c.geom, b.geom, 'mask=inside') = 'TRUE'
    and b.cntry_name = 'Slovakia';

--2d
select
    a.cntry_name as panstwo,
    round(
        sdo_geom.sdo_distance(a.geom, b.geom, 1, 'unit=km'),
        7
    ) as odl
from
    country_boundaries a,
    country_boundaries b
where
    sdo_relate(
        a.geom,
        sdo_geometry(
            2001,
            8307,
            b.geom.sdo_point,
            b.geom.sdo_elem_info,
            b.geom.sdo_ordinates
        ),
        'mask=anyinteract'
    ) != 'TRUE'
    and b.cntry_name = 'Poland';

--3a
select
    a.cntry_name,
    round(
        sdo_geom.sdo_length(
            sdo_geom.sdo_intersection(a.geom, b.geom, 1),
            1,
            'unit=km'
        ),
        7
    ) as odleglosc
from
    country_boundaries a,
    country_boundaries b
where
    sdo_filter(a.geom, b.geom) = 'TRUE'
    and b.cntry_name = 'Poland'
    and a.cntry_name != 'Poland';

--3b
select
    cntry_name
from
    country_boundaries
where
    sdo_geom.sdo_area(geom) = (
        select
            max(sdo_geom.sdo_area(geom))
        from
            country_boundaries
    );

--3c
select
    round(
        sdo_geom.sdo_area(
            sdo_geom.sdo_mbr(
                sdo_geom.sdo_union(
                    a.geom,
                    b.geom,
                    0.001
                )
            ),
            1,
            'unit=sq_km'
        ),
        5
    ) as sq_km
from
    major_cities a,
    major_cities b
where
    a.city_name = 'Warsaw'
    and b.city_name = 'Lodz';

--3d
select
    sdo_geom.sdo_union(a.geom, b.geom, 0.01).get_dims() || sdo_geom.sdo_union(a.geom, b.geom, 0.01).get_lrs_dim() || lpad(
        sdo_geom.sdo_union(a.geom, b.geom, 0.01).get_gtype(),
        2,
        '0'
    ) as gtype
from
    country_boundaries a,
    major_cities b
where
    a.cntry_name = 'Poland'
    and b.city_name = 'Prague';

--3e
select
    b.city_name,
    a.cntry_name
from
    country_boundaries a,
    major_cities b
where
    a.cntry_name = b.cntry_name
    and sdo_geom.sdo_distance(
        sdo_geom.sdo_centroid(a.geom, 1),
        b.geom,
        1
    ) = (
        select
            min(
                sdo_geom.sdo_distance(sdo_geom.sdo_centroid(a.geom, 1), b.geom, 1)
            )
        from
            country_boundaries a,
            major_cities b
        where
            a.cntry_name = b.cntry_name
    );

--3f
select
    name,
    round(sum(dlugosc), 7) as dlugosc
from
    (
        select
            b.name,
            sdo_geom.sdo_length(
                sdo_geom.sdo_intersection(a.geom, b.geom, 1),
                1,
                'unit=km'
            ) as dlugosc
        from
            country_boundaries a,
            rivers b
        where
            sdo_relate(
                a.geom,
                sdo_geometry(
                    2001,
                    8307,
                    b.geom.sdo_point,
                    b.geom.sdo_elem_info,
                    b.geom.sdo_ordinates
                ),
                'mask=anyinteract'
            ) = 'TRUE'
            and a.cntry_name = 'Poland'
    )
group by
    name;