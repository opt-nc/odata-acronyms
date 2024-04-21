-- Create table with constraints
create or replace table acronyms (
    id_acronym VARCHAR NOT NULL CHECK (id_acronym = UPPER(id_acronym)),
    id_acronym_unique VARCHAR PRIMARY KEY CHECK (id_acronym_unique like id_acronym || '%'),
    description  VARCHAR UNIQUE
);

-- Load acronyms csv data into table
insert into acronyms (id_acronym, id_acronym_unique, description)
from
    (
        FROM read_csv('data/acronyms_optnc.csv',
                            header = true,
                            columns = {
                                'id_acronym': 'VARCHAR',
                                'id_acronym_unique': 'VARCHAR',
                                'description': 'VARCHAR'
    })
);

-- Get a preveiw
from acronyms limit 5;

------------------------------------------------
-- Preserve order of rows

-- Prepare test environment
CREATE SEQUENCE seq_original START 1;
CREATE SEQUENCE seq_sorted START 1;

create or replace temp table orig_table as
    select nextval('seq_original') as index,
            id_acronym,
            description
    from acronyms;

create or replace temp table sorted_table as
    select nextval('seq_sorted') as index,
            id_acronym,
            description
    from (select id_acronym,
                description
            from acronyms
            -- order by acronym and description
            order by id_acronym, id_acronym_unique, description);

-- Check the resulting tables
from orig_table limit 5;
from sorted_table limit 5;

-- Create the table that compares the sorted and original tables columns
create or replace temp table test_sorted(
                                    orig_id_acronym varchar,
                                    orig_description varchar,
                                    orig_index integer,
                                    sorted_index integer
                                    -- the magic part XD
                                    check(orig_index = sorted_index)
                                    );

-- Populate the comparison table
insert into test_sorted
select
    orig_table.id_acronym as orig_id_acronym,
    orig_table.description as orig_description,
    orig_table.index as orig_index,
    sorted_table.index as sorted_index,
from
    orig_table,
    sorted_table
where
    orig_table.id_acronym = sorted_table.id_acronym
    and orig_table.description = sorted_table.description
order by orig_table.index;

-- Check the resulting table
-- from test_sorted
-- where orig_index != sorted_index;

-- reporting des duplicats
from acronyms
    select id_acronym,
        count(*) as nb_occurrences
    group by id_acronym
    having nb_occurrences > 1
    order by nb_occurrences desc;
