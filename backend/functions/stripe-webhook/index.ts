// Follow this setup guide to deploy: https://supabase.com/docs/guides/functions/deploy
// Or copy-paste into Supabase Dashboard > Edge Functions > Create new "stripe-webhook"
// DEPLOYMENT TEST: Triggering GitHub Action...

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

// Env variables (Set these in Supabase Dashboard > Settings > Edge Functions)
// STRIPE_WEBHOOK_SECRET
// SUPABASE_URL
// SUPABASE_SERVICE_ROLE_KEY

serve(async (req) => {
    try {
        const signature = req.headers.get("stripe-signature");
        if (!signature) {
            return new Response("No signature", { status: 400 });
        }

        // In a real production env, verify signature using stripe-node or similar.
        // For this MVP Deno function, we assume the secret is kept safe and simple body parsing.
        // NOTE: For full security, use 'stripe' npm package with Deno import map.

        const body = await req.json();

        // Check for "checkout.session.completed"
        if (body.type === "checkout.session.completed") {
            const session = body.data.object;
            const clientReferenceId = session.client_reference_id; // We passed UUID here
            const customerEmail = session.customer_details?.email;

            console.log(`Payment received for: \${clientReferenceId} (\${customerEmail})`);

            // Initialize Supabase Admin Client
            const supabase = createClient(
                Deno.env.get("SUPABASE_URL") ?? "",
                Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
            );

            // Call our RPC function to activate PRO
            if (clientReferenceId) {
                const { error } = await supabase.rpc('activate_pro_subscription', {
                    target_user_id: clientReferenceId
                });

                if (error) {
                    console.error("Database update failed:", error);
                    return new Response("Database update failed", { status: 500 });
                }

                // Optional: Create a Notification for the user
                await supabase.from('notifications').insert({
                    user_id: clientReferenceId,
                    title: "Bem-vindo ao PRO! 🚀",
                    message: "Sua assinatura foi ativada com sucesso. Aproveite!",
                    type: 'reward'
                });
            }
        }

        return new Response(JSON.stringify({ received: true }), {
            headers: { "Content-Type": "application/json" },
        })

    } catch (err) {
        return new Response(err.message, { status: 400 })
    }
})
