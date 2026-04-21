-- Controle de dívidas + RLS (cada auth.uid() vê só as próprias linhas).
-- No painel: Authentication > Providers > Email > habilitar (senha).
-- Para uma pessoa só, pode desativar "Confirm email" no mesmo e-mail.
-- Depois rode este script em SQL > New query.

create table if not exists public.dividas (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  descricao text not null,
  categoria text not null,
  valor numeric(14, 2) not null check (valor > 0),
  vencimento date,
  pago boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists dividas_user_id_idx on public.dividas (user_id);
create index if not exists dividas_vencimento_idx on public.dividas (vencimento);

alter table public.dividas enable row level security;

drop policy if exists "dividas_select_own" on public.dividas;
drop policy if exists "dividas_insert_own" on public.dividas;
drop policy if exists "dividas_update_own" on public.dividas;
drop policy if exists "dividas_delete_own" on public.dividas;

create policy "dividas_select_own"
  on public.dividas for select
  using (auth.uid() = user_id);

create policy "dividas_insert_own"
  on public.dividas for insert
  with check (auth.uid() = user_id);

create policy "dividas_update_own"
  on public.dividas for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "dividas_delete_own"
  on public.dividas for delete
  using (auth.uid() = user_id);

create or replace function public.dividas_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists dividas_set_updated_at on public.dividas;
create trigger dividas_set_updated_at
  before update on public.dividas
  for each row
  execute function public.dividas_set_updated_at();
