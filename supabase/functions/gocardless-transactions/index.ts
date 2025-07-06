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
    const accountId = url.searchParams.get('account_id');
    const accessToken = req.headers.get('x-gocardless-token');
    const baseUrl = Deno.env.get('GOCARDLESS_BASE_URL');

    if (!accessToken || !accountId) {
      throw new Error('Access token and account_id required');
    }

    if (!baseUrl) {
      throw new Error('GoCardless base URL not configured');
    }

    const response = await fetch(
      `${baseUrl}/accounts/${accountId}/transactions/`,
      {
        headers: {
          'Accept': 'application/json',
          'Authorization': `Bearer ${accessToken}`,
        },
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Failed to fetch transactions: ${response.status} - ${errorText}`);
    }

    const transactions = await response.json();

    return new Response(
      JSON.stringify({
        success: true,
        data: transactions,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    console.error('GoCardless transactions error:', error);
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