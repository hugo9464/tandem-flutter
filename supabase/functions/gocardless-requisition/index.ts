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
    const accessToken = req.headers.get('x-gocardless-token');
    const baseUrl = Deno.env.get('GOCARDLESS_BASE_URL');
    
    if (!accessToken) {
      throw new Error('Access token required');
    }

    if (!baseUrl) {
      throw new Error('GoCardless base URL not configured');
    }

    const body = await req.json();
    const { institution_id, redirect_url, reference, user_language = 'FR' } = body;

    if (!institution_id || !redirect_url) {
      throw new Error('institution_id and redirect_url are required');
    }

    const response = await fetch(
      `${baseUrl}/requisitions/`,
      {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          institution_id,
          redirect: redirect_url,
          reference: reference || `tandem_${Date.now()}`,
          user_language,
        }),
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Failed to create requisition: ${response.status} - ${errorText}`);
    }

    const requisition = await response.json();

    return new Response(
      JSON.stringify({
        success: true,
        data: requisition,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    console.error('GoCardless requisition error:', error);
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