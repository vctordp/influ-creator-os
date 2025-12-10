-- RUN THIS IN SUPABASE SQL EDITOR

-- 1. Create a secure function to update subscription
-- This function uses "SECURITY DEFINER" to run with elevated privileges, 
-- allowing the Webhook (which uses Service Role) to update any user.

create or replace function public.activate_pro_subscription(target_user_id uuid)
returns void
language plpgsql
security definer
as \$\$
begin
  update public.profiles
  set 
    subscription_tier = 'pro',
    potential_revenue = greatest(potential_revenue, 10000), -- Bump revenue projection for PRO users
    updated_at = now()
  where id = target_user_id;
end;
\$\$;

-- 2. Grant permission to Authenticated and Service Role
grant execute on function public.activate_pro_subscription to authenticated;
grant execute on function public.activate_pro_subscription to service_role;
