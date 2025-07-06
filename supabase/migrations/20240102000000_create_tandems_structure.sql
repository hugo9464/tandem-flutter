-- Create tandems table
CREATE TABLE IF NOT EXISTS tandems (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  code text UNIQUE NOT NULL,
  created_by uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Create tandem_members table
CREATE TABLE IF NOT EXISTS tandem_members (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tandem_id uuid REFERENCES tandems(id) ON DELETE CASCADE NOT NULL,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role text CHECK (role IN ('owner', 'member')) NOT NULL DEFAULT 'member',
  joined_at timestamptz DEFAULT now() NOT NULL,
  UNIQUE(tandem_id, user_id)
);

-- Create indexes
CREATE INDEX idx_tandem_members_user_id ON tandem_members(user_id);
CREATE INDEX idx_tandem_members_tandem_id ON tandem_members(tandem_id);
CREATE INDEX idx_tandems_code ON tandems(code);

-- Enable RLS
ALTER TABLE tandems ENABLE ROW LEVEL SECURITY;
ALTER TABLE tandem_members ENABLE ROW LEVEL SECURITY;

-- RLS Policies for tandems
CREATE POLICY "Users can view tandems they are members of" ON tandems
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM tandem_members 
      WHERE tandem_members.tandem_id = tandems.id 
      AND tandem_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create tandems" ON tandems
  FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Tandem owners can update their tandems" ON tandems
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM tandem_members 
      WHERE tandem_members.tandem_id = tandems.id 
      AND tandem_members.user_id = auth.uid()
      AND tandem_members.role = 'owner'
    )
  );

CREATE POLICY "Tandem owners can delete their tandems" ON tandems
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM tandem_members 
      WHERE tandem_members.tandem_id = tandems.id 
      AND tandem_members.user_id = auth.uid()
      AND tandem_members.role = 'owner'
    )
  );

-- RLS Policies for tandem_members
CREATE POLICY "Users can view members of their tandems" ON tandem_members
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM tandem_members tm
      WHERE tm.user_id = auth.uid()
      AND tm.tandem_id = tandem_members.tandem_id
    )
  );

CREATE POLICY "Users can join tandems" ON tandem_members
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can leave tandems" ON tandem_members
  FOR DELETE
  USING (auth.uid() = user_id);

-- Function to generate unique tandem code
CREATE OR REPLACE FUNCTION generate_tandem_code()
RETURNS text AS $$
DECLARE
  chars text := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  result text := '';
  i integer;
BEGIN
  FOR i IN 1..6
  LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to create a tandem and add creator as owner
CREATE OR REPLACE FUNCTION create_tandem_with_owner(
  p_name text,
  p_user_id uuid
)
RETURNS TABLE(
  id uuid,
  name text,
  code text,
  created_by uuid,
  created_at timestamptz
) AS $$
DECLARE
  v_tandem_id uuid;
  v_code text;
  v_attempts integer := 0;
BEGIN
  -- Generate unique code with retry logic
  LOOP
    v_code := generate_tandem_code();
    v_attempts := v_attempts + 1;
    
    -- Try to insert tandem
    BEGIN
      INSERT INTO tandems (name, code, created_by)
      VALUES (p_name, v_code, p_user_id)
      RETURNING tandems.id INTO v_tandem_id;
      
      -- If successful, break the loop
      EXIT;
    EXCEPTION
      WHEN unique_violation THEN
        -- If code already exists and we've tried less than 10 times, try again
        IF v_attempts >= 10 THEN
          RAISE EXCEPTION 'Could not generate unique code after 10 attempts';
        END IF;
    END;
  END LOOP;
  
  -- Add creator as owner
  INSERT INTO tandem_members (tandem_id, user_id, role)
  VALUES (v_tandem_id, p_user_id, 'owner');
  
  -- Return the created tandem
  RETURN QUERY
  SELECT t.id, t.name, t.code, t.created_by, t.created_at
  FROM tandems t
  WHERE t.id = v_tandem_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;