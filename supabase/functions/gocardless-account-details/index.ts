import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-gocardless-token',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
};

const GOCARDLESS_BASE_URL = Deno.env.get("GOCARDLESS_BASE_URL") || "https://bankaccountdata.gocardless.com/api/v2";

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const accountId = url.searchParams.get('account_id');
    
    if (!accountId) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'account_id parameter is required'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        }
      );
    }

    const authHeader = req.headers.get('x-gocardless-token');
    if (!authHeader) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Authorization token is required'
        }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        }
      );
    }

    console.log(`[GoCardless] Fetching account details for ID: ${accountId}`);

    const response = await fetch(`${GOCARDLESS_BASE_URL}/accounts/${accountId}/`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${authHeader}`,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error(`[GoCardless] Account details API error: ${response.status} - ${errorText}`);
      return new Response(
        JSON.stringify({
          success: false,
          error: `GoCardless API error: ${response.status} - ${errorText}`
        }),
        {
          status: response.status,
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        }
      );
    }

    const data = await response.json();
    console.log(`[GoCardless] Account details retrieved successfully for ID: ${accountId}`);

    return new Response(
      JSON.stringify({
        success: true,
        data: data
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      }
    );

  } catch (error) {
    console.error('[GoCardless] Account details error:', error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      }
    );
  }
});