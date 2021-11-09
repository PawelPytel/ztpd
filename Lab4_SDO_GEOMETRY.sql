--1a

create table figury(
    id number(1) primary key,
    ksztalt mdsys.sdo_geometry
);

--1b

insert into figury values(
    1,
    mdsys.sdo_geometry(
        2003,
        null,
        null,
        sdo_elem_info_array(1,1003,4),
        sdo_ordinate_array(3,5, 5,3, 7,5)
    )
);

insert into figury values(
    2,
    mdsys.sdo_geometry(
        2003,
        null,
        null,
        sdo_elem_info_array(1,1003,3),
        sdo_ordinate_array(1,1, 5,5)
    )
);

insert into figury values(
    3,
    mdsys.sdo_geometry(
        2002,
        null,
        null,
        sdo_elem_info_array(1,4,2, 1,2,1, 5,2,2),
        sdo_ordinate_array(3,2 ,6,2 ,7,3 ,8,2, 7,1)
    )
);


--1c

insert into figury values(
    4,
    mdsys.sdo_geometry(
        2003,
        null,
        null,
        sdo_elem_info_array(1,1003,4),
        sdo_ordinate_array(5,1, 5,2, 5,3)
    )
);

--1d

select id, sdo_geom.validate_geometry_with_context(ksztalt, 0.1) from figury;

--1e

delete from figury where sdo_geom.validate_geometry_with_context(ksztalt, 0.1) != 'TRUE';

--1f

commit;