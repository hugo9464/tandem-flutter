import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-gocardless-token',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
};

interface GoCardlessTokenResponse {
  access: string;
  access_expires: number;
  refresh: string;
  refresh_expires: number;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const secret_id = Deno.env.get('GOCARDLESS_SECRET_ID');
    const secret_key = Deno.env.get('GOCARDLESS_SECRET_KEY');
    const baseUrl = Deno.env.get('GOCARDLESS_BASE_URL');
    
    if (!secret_id || !secret_key || !baseUrl) {
      throw new Error('GoCardless secrets not configured');
    }

    const response = await fetch(`${baseUrl}/token/new/`, {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        secret_id: secret_id,
        secret_key: secret_key,
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`GoCardless auth failed: ${response.status} - ${errorText}`);
    }

    const tokenData: GoCardlessTokenResponse = await response.json();

    return new Response(
      JSON.stringify({
        success: true,
        data: tokenData,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    console.error('GoCardless auth error:', error);
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