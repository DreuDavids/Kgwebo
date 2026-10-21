-- Covering index for transactions.created_by foreign key.

create index if not exists transactions_created_by_idx
  on public.transactions (created_by);
