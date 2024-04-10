-- Load acronyms data
create
or replace table acronyms (
    id_acronym VARCHAR NOT NULL, CHECK (id_acronym = UPPER(id_acronym)),
    description  VARCHAR UNIQUE
);

insert into acronyms (id_acronym, description)
from
    (
        FROM read_csv('data/acronyms_optnc.csv',
                            header = true,
                            columns = {
                                'id_acronym': 'VARCHAR',
                                'description': 'VARCHAR'
    })
    ) t;

from acronyms;

-- Prepare test environment
CREATE SEQUENCE seq_original START 1;
CREATE SEQUENCE seq_sorted START 1;

create or replace temp table orig_table as
    select nextval('seq_original') as index,
    id_acronym from acronyms;

create or replace temp table sorted_table as
    select nextval('seq_sorted') as index,
    id_acronym
    from (select id_acronym from acronyms order by id_acronym);

-- Check the resulting tables
from orig_table;
from sorted_table;

-- Create the table that compares the sorted and original tables columns
create or replace temp table test_sorted(orig_id_acronym varchar,
                                    orig_index integer,
                                    sorted_index integer
                                    -- the magic part XD
                                    check(orig_index = sorted_index)
                                    );
-- Populate the comparison table
insert into test_sorted
select
    orig_table.id_acronym as orig_id_acronym,
    orig_table.index as orig_index,
    sorted_table.index as sorted_index,
from
    orig_table,
    sorted_table
where
    orig_table.id_acronym = sorted_table.id_acronym
order by orig_table.index;