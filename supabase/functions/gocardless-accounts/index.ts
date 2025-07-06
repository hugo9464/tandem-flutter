import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-gocardless-token',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const requisitionId = url.searchParams.get('requisition_id');
    const accessToken = req.headers.get('x-gocardless-token');
    const baseUrl = Deno.env.get('GOCARDLESS_BASE_URL');

    if (!accessToken || !requisitionId) {
      throw new Error('Access token and requisition_id required');
    }

    if (!baseUrl) {
      throw new Error('GoCardless base URL not configured');
    }

    // 1. Récupérer la requisition pour obtenir les IDs des comptes
    const requisitionResponse = await fetch(
      `${baseUrl}/requisitions/${requisitionId}/`,
      {
        headers: {
          'Accept': 'application/json',
          'Authorization': `Bearer ${accessToken}`,
        },
      }
    );

    if (!requisitionResponse.ok) {
      const errorText = await requisitionResponse.text();
      throw new Error(`Failed to fetch requisition: ${requisitionResponse.status} - ${errorText}`);
    }

    const requisition = await requisitionResponse.json();

    // 2. Récupérer les détails de chaque compte
    const accountsDetails = await Promise.all(
      requisition.accounts.map(async (accountId: string) => {
        try {
          const accountResponse = await fetch(
            `${baseUrl}/accounts/${accountId}/details/`,
            {
              headers: {
                'Accept': 'application/json',
                'Authorization': `Bearer ${accessToken}`,
              },
            }
          );

          if (accountResponse.ok) {
            const accountData = await accountResponse.json();
            return {
              id: accountId,
              ...accountData.account,
            };
          }
          return { id: accountId, error: 'Failed to fetch details' };
        } catch (error) {
          return { id: accountId, error: error.message };
        }
      })
    );

    return new Response(
      JSON.stringify({
        success: true,
        data: {
          requisition,
          accounts: accountsDetails,
        },
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    console.error('GoCardless accounts error:', error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    );
  }
});