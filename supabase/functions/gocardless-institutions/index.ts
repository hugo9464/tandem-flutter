import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-gocardless-token',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
};

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const country = url.searchParams.get('country') || 'FR';
    const accessToken = req.headers.get('x-gocardless-token');
    const baseUrl = Deno.env.get('GOCARDLESS_BASE_URL');

    if (!accessToken) {
      throw new Error('Access token required');
    }

    if (!baseUrl) {
      throw new Error('GoCardless base URL not configured');
    }

    const response = await fetch(
      `${baseUrl}/institutions/?country=${country}`,
      {
        headers: {
          'Accept': 'application/json',
          'Authorization': `Bearer ${accessToken}`,
        },
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Failed to fetch institutions: ${response.status} - ${errorText}`);
    }

    const institutions = await response.json();

    return new Response(
      JSON.stringify({
        success: true,
        data: institutions,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    console.error('GoCardless institutions error:', error);
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