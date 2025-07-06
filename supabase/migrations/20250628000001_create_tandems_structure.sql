-- Create tandems table
CREATE TABLE IF NOT EXISTS public.tandems (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create tandem_members table
CREATE TABLE IF NOT EXISTS public.tandem_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tandem_id UUID NOT NULL REFERENCES public.tandems(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'member')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(tandem_id, user_id)
);

-- Function to generate random 6-character code
CREATE OR REPLACE FUNCTION generate_tandem_code()
RETURNS TEXT AS $$
DECLARE
    chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    result TEXT := '';
    i INTEGER;
BEGIN
    FOR i IN 1..6 LOOP
        result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to create tandem with owner
CREATE OR REPLACE FUNCTION create_tandem_with_owner(p_name TEXT, p_user_id UUID)
RETURNS TABLE(id UUID, name TEXT, code TEXT, created_by UUID, created_at TIMESTAMP WITH TIME ZONE, updated_at TIMESTAMP WITH TIME ZONE) AS $$
DECLARE
    v_code TEXT;
    v_tandem_id UUID;
BEGIN
    -- Generate unique code
    LOOP
        v_code := generate_tandem_code();
        EXIT WHEN NOT EXISTS (SELECT 1 FROM public.tandems WHERE code = v_code);
    END LOOP;
    
    -- Create tandem
    INSERT INTO public.tandems (name, code, created_by)
    VALUES (p_name, v_code, p_user_id)
    RETURNING tandems.id INTO v_tandem_id;
    
    -- Add creator as owner
    INSERT INTO public.tandem_members (tandem_id, user_id, role)
    VALUES (v_tandem_id, p_user_id, 'owner');
    
    -- Return the created tandem
    RETURN QUERY
    SELECT t.id, t.name, t.code, t.created_by, t.created_at, t.updated_at
    FROM public.tandems t
    WHERE t.id = v_tandem_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enable RLS
ALTER TABLE public.tandems ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tandem_members ENABLE ROW LEVEL SECURITY;

-- RLS Policies for tandems
CREATE POLICY "Users can view tandems they are members of" ON public.tandems
    FOR SELECT USING (
        id IN (
            SELECT tandem_id 
            FROM public.tandem_members 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create tandems" ON public.tandems
    FOR INSERT WITH CHECK (created_by = auth.uid());

CREATE POLICY "Owners can update their tandems" ON public.tandems
    FOR UPDATE USING (created_by = auth.uid());

CREATE POLICY "Owners can delete their tandems" ON public.tandems
    FOR DELETE USING (created_by = auth.uid());

-- RLS Policies for tandem_members
CREATE POLICY "Users can view members of tandems they belong to" ON public.tandem_members
    FOR SELECT USING (
        tandem_id IN (
            SELECT tandem_id 
            FROM public.tandem_members 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can join tandems" ON public.tandem_members
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can leave tandems" ON public.tandem_members
    FOR DELETE USING (user_id = auth.uid());

CREATE POLICY "Owners can manage members" ON public.tandem_members
    FOR ALL USING (
        tandem_id IN (
            SELECT id 
            FROM public.tandems 
            WHERE created_by = auth.uid()
        )
    );