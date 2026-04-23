\pset format unaligned
\pset tuples_only on

create schema aggr_first_rewriter;
set search_path=aggr_first_rewriter;

create table count_o(a int) distributed randomly;
create table count_i(a int) distributed randomly;
insert into count_o select generate_series(1,100);
insert into count_i select generate_series(1,99);

set optimizer=off;
select 'pg_baseline_a=' || count(*)
from count_o o
where o.a + 1 > (select count(*) from count_i i where i.a = o.a);

select 'pg_baseline_b=' || count(*)
from count_o o
where o.a + 1 > (select count(*) from count_i i where i.a = o.a);

set optimizer=on;
set optimizer_enable_aggr_first_orca_enhancement=on;
show optimizer_enable_aggr_first_orca_enhancement;
select 'orca_enh_on=' || count(*)
from count_o o
where o.a + 1 > (select count(*) from count_i i where i.a = o.a);

set optimizer_enable_aggr_first_orca_enhancement=off;
show optimizer_enable_aggr_first_orca_enhancement;
select 'orca_enh_off=' || count(*)
from count_o o
where o.a + 1 > (select count(*) from count_i i where i.a = o.a);

set optimizer_enable_aggr_first_orca_enhancement=on;
select 'orca_enh_on_recheck=' || count(*)
from count_o o
where o.a + 1 > (select count(*) from count_i i where i.a = o.a);

create table orca_o(a int) distributed randomly;
create table orca_i(a int, b int) distributed randomly;
insert into orca_o values (1),(2),(3),(null);
insert into orca_i values (1,10),(1,null),(null,7);

set optimizer=on;
set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where o.a < (select count(*) from orca_i i where not (i.a is distinct from o.a));
select 'orca_cnt_star_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < (select count(*) from orca_i i where not (i.a is distinct from o.a))
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where o.a < (select count(*) from orca_i i where not (i.a is distinct from o.a));
select 'orca_cnt_star_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < (select count(*) from orca_i i where not (i.a is distinct from o.a))
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
select 'orca_cnt_expr_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < (select count(i.a) from orca_i i where not (i.a is distinct from o.a))
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
select 'orca_cnt_expr_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < (select count(i.a) from orca_i i where not (i.a is distinct from o.a))
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where o.a < (select count(*) from orca_i i where (i.a is distinct from o.a) is false);
select 'orca_cnt_booltest_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < (select count(*) from orca_i i where (i.a is distinct from o.a) is false)
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where o.a < (select count(*) from orca_i i where (i.a is distinct from o.a) is false);
select 'orca_cnt_booltest_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < (select count(*) from orca_i i where (i.a is distinct from o.a) is false)
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where o.a < (select count(*) from orca_i i where (i.a is distinct from o.a) = false);
select 'orca_cnt_eqfalse_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < (select count(*) from orca_i i where (i.a is distinct from o.a) = false)
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where o.a < (select count(*) from orca_i i where (i.a is distinct from o.a) = false);
select 'orca_cnt_eqfalse_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < (select count(*) from orca_i i where (i.a is distinct from o.a) = false)
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where o.a < (select count(*) from orca_i i where (i.a is distinct from o.a) <> true);
select 'orca_cnt_neqtrue_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < (select count(*) from orca_i i where (i.a is distinct from o.a) <> true)
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where o.a < (select count(*) from orca_i i where (i.a is distinct from o.a) <> true);
select 'orca_cnt_neqtrue_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < (select count(*) from orca_i i where (i.a is distinct from o.a) <> true)
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where o.a < (select count(*) from orca_i i where not ((i.a is distinct from o.a) is true));
select 'orca_cnt_notistrue_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < (select count(*) from orca_i i where not ((i.a is distinct from o.a) is true))
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where o.a < (select count(*) from orca_i i where not ((i.a is distinct from o.a) is true));
select 'orca_cnt_notistrue_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < (select count(*) from orca_i i where not ((i.a is distinct from o.a) is true))
  order by a nulls last
) t;

-- non null-propagate agg argument should be rejected by enhanced AGGR_FIRST path
set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where o.a < coalesce((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false), 0);
select 'orca_sum_coalesce_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < coalesce((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false), 0)
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where o.a < coalesce((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false), 0);
select 'orca_sum_coalesce_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < coalesce((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false), 0)
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where o.a < (select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false);
select 'orca_sum_coalesce_nr_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < (select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false)
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where o.a < (select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false);
select 'orca_sum_coalesce_nr_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < (select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false)
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where abs((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false)) > 0;
select 'orca_sum_coalesce_abswrap_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where abs((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false)) > 0
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where abs((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false)) > 0;
select 'orca_sum_coalesce_abswrap_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where abs((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false)) > 0
  order by a nulls last
) t;

-- boolean wrappers should preserve null-reject context for unsafe agg args
set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0) is true;
select 'orca_sum_coalesce_istrue_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0) is true
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0) is true;
select 'orca_sum_coalesce_istrue_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0) is true
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where not ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) <= 0);
select 'orca_sum_coalesce_notle0_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where not ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) <= 0)
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where not ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) <= 0);
select 'orca_sum_coalesce_notle0_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where not ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) <= 0)
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where (((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0) and true);
select 'orca_sum_coalesce_andtrue_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where (((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0) and true)
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where (((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0) and true);
select 'orca_sum_coalesce_andtrue_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where (((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0) and true)
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where (select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) is not null;
select 'orca_sum_coalesce_isnotnull_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where (select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) is not null
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where (select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) is not null;
select 'orca_sum_coalesce_isnotnull_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where (select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) is not null
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0)
   or ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) < 0);
select 'orca_sum_coalesce_orboth_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0)
     or ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) < 0)
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0)
   or ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) < 0);
select 'orca_sum_coalesce_orboth_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0)
     or ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) < 0)
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0)
   or ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) is null);
select 'orca_sum_coalesce_ormix_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0)
     or ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) is null)
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0)
   or ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) is null);
select 'orca_sum_coalesce_ormix_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0)
     or ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) is null)
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where o.a < coalesce((select sum(i.b + 1) from orca_i i where not (i.a is distinct from o.a)), 0);
select 'orca_sum_expr_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < coalesce((select sum(i.b + 1) from orca_i i where not (i.a is distinct from o.a)), 0)
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where o.a < coalesce((select sum(i.b + 1) from orca_i i where not (i.a is distinct from o.a)), 0);
select 'orca_sum_expr_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < coalesce((select sum(i.b + 1) from orca_i i where not (i.a is distinct from o.a)), 0)
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
select 'orca_sum_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < coalesce((select sum(i.b) from orca_i i where not (i.a is distinct from o.a)), 0)
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
select 'orca_sum_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < coalesce((select sum(i.b) from orca_i i where not (i.a is distinct from o.a)), 0)
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
select 'orca_min_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < coalesce((select min(i.b) from orca_i i where not (i.a is distinct from o.a)), 0)
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
select 'orca_min_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < coalesce((select min(i.b) from orca_i i where not (i.a is distinct from o.a)), 0)
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
select 'orca_max_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < coalesce((select max(i.b) from orca_i i where not (i.a is distinct from o.a)), 0)
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
select 'orca_max_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where o.a < coalesce((select max(i.b) from orca_i i where not (i.a is distinct from o.a)), 0)
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where not ((select avg(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) <= 0);
select 'orca_avg_coalesce_notle0_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where not ((select avg(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) <= 0)
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where not ((select avg(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) <= 0);
select 'orca_avg_coalesce_notle0_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where not ((select avg(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) <= 0)
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where (select min(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) is not null;
select 'orca_min_coalesce_isnotnull_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where (select min(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) is not null
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where (select min(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) is not null;
select 'orca_min_coalesce_isnotnull_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where (select min(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) is not null
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where ((select max(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0) is true;
select 'orca_max_coalesce_istrue_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where ((select max(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0) is true
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where ((select max(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0) is true;
select 'orca_max_coalesce_istrue_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where ((select max(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0) is true
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where (not ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) <= 0))
   or ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) >= 1);
select 'orca_sum_coalesce_or_notle0_ge1_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where (not ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) <= 0))
     or ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) >= 1)
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where (not ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) <= 0))
   or ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) >= 1);
select 'orca_sum_coalesce_or_notle0_ge1_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where (not ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) <= 0))
     or ((select sum(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) >= 1)
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where (((select avg(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0) is true)
  and (o.a is not null);
select 'orca_avg_coalesce_istrue_and_notnull_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where (((select avg(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0) is true)
    and (o.a is not null)
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where (((select avg(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0) is true)
  and (o.a is not null);
select 'orca_avg_coalesce_istrue_and_notnull_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where (((select avg(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) > 0) is true)
    and (o.a is not null)
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where not (
  (((select avg(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) <= 0) is not false)
  or (o.a is null)
);
select 'orca_avg_coalesce_not_isnotfalse_or_isnull_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where not (
    (((select avg(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) <= 0) is not false)
    or (o.a is null)
  )
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where not (
  (((select avg(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) <= 0) is not false)
  or (o.a is null)
);
select 'orca_avg_coalesce_not_isnotfalse_or_isnull_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where not (
    (((select avg(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) <= 0) is not false)
    or (o.a is null)
  )
  order by a nulls last
) t;

set optimizer_enable_aggr_first_orca_enhancement=on;
explain (costs off)
select * from orca_o o
where not (
  ((select min(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) is null)
   or (o.a is null)
);
select 'orca_min_coalesce_not_or_isnull_on=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where not (
    ((select min(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) is null)
     or (o.a is null)
  )
  order by a nulls last
) t;
set optimizer_enable_aggr_first_orca_enhancement=off;
explain (costs off)
select * from orca_o o
where not (
  ((select min(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) is null)
   or (o.a is null)
);
select 'orca_min_coalesce_not_or_isnull_off=' || coalesce(string_agg(coalesce(a::text,'NULL'), ',' order by a nulls last), '')
from (
  select a from orca_o o
  where not (
    ((select min(coalesce(i.b, 0)) from orca_i i where (i.a is distinct from o.a) is false) is null)
     or (o.a is null)
  )
  order by a nulls last
) t;

create table agg_o(a int) distributed randomly;
create table agg_i(a int, b int) distributed randomly;
insert into agg_o values (1),(2),(3),(4),(5);
insert into agg_i values (1,10),(1,null),(2,20),(4,null);

set optimizer=off;
select 'sum_off=' || count(*)
from agg_o o
where o.a < coalesce((select sum(i.b) from agg_i i where i.a = o.a), 0);
select 'avg_off=' || count(*)
from agg_o o
where o.a < coalesce((select avg(i.b) from agg_i i where i.a = o.a), 0);

set optimizer=on;
select 'sum_on=' || count(*)
from agg_o o
where o.a < coalesce((select sum(i.b) from agg_i i where i.a = o.a), 0);
select 'avg_on=' || count(*)
from agg_o o
where o.a < coalesce((select avg(i.b) from agg_i i where i.a = o.a), 0);

drop schema aggr_first_rewriter cascade;
