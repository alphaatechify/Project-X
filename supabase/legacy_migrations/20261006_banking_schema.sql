-- ==============================================================================
-- SUPABASE BANKING BACKEND DATABASE MIGRATION SCHEMA
-- Project X - Production Grade Banking Architecture
-- ==============================================================================

-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. CREATE ENUM TYPES
CREATE TYPE kyc_status_enum AS ENUM ('pending', 'verified', 'rejected');
CREATE TYPE account_type_enum AS ENUM ('savings', 'checking', 'wallet');
CREATE TYPE transaction_type_enum AS ENUM ('transfer', 'deposit', 'withdrawal', 'bill_payment');
CREATE TYPE transaction_status_enum AS ENUM ('pending', 'completed', 'failed');

-- ==============================================================================
-- 3. PROFILES TABLE (Linked to auth.users)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone_number TEXT UNIQUE,
    avatar_url TEXT,
    kyc_status kyc_status_enum DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS FOR PROFILES
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- ==============================================================================
-- 4. BANK ACCOUNTS TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.bank_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    account_type account_type_enum NOT NULL DEFAULT 'savings',
    balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0.00),
    currency VARCHAR(3) NOT NULL DEFAULT 'INR',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS FOR BANK ACCOUNTS
ALTER TABLE public.bank_accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own bank accounts"
    ON public.bank_accounts FOR SELECT
    USING (auth.uid() = user_id);

-- ==============================================================================
-- 5. BENEFICIARIES TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.beneficiaries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    account_number VARCHAR(20) NOT NULL,
    bank_code VARCHAR(20) DEFAULT 'PX001',
    nickname TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_user_beneficiary UNIQUE (user_id, account_number)
);

-- RLS FOR BENEFICIARIES
ALTER TABLE public.beneficiaries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own beneficiaries"
    ON public.beneficiaries FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own beneficiaries"
    ON public.beneficiaries FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own beneficiaries"
    ON public.beneficiaries FOR DELETE
    USING (auth.uid() = user_id);

-- ==============================================================================
-- 6. TRANSACTIONS TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_ref VARCHAR(36) UNIQUE NOT NULL,
    sender_account_id UUID REFERENCES public.bank_accounts(id),
    receiver_account_id UUID REFERENCES public.bank_accounts(id),
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0.00),
    currency VARCHAR(3) NOT NULL DEFAULT 'INR',
    transaction_type transaction_type_enum NOT NULL,
    status transaction_status_enum NOT NULL DEFAULT 'completed',
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS FOR TRANSACTIONS
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view transactions involving their accounts"
    ON public.transactions FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.bank_accounts ba
            WHERE ba.id = transactions.sender_account_id OR ba.id = transactions.receiver_account_id
            AND ba.user_id = auth.uid()
        )
    );

-- ==============================================================================
-- 7. CARDS TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.cards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID NOT NULL REFERENCES public.bank_accounts(id) ON DELETE CASCADE,
    card_number_masked VARCHAR(19) NOT NULL,
    card_holder_name TEXT NOT NULL,
    expiry_month INT NOT NULL CHECK (expiry_month BETWEEN 1 AND 12),
    expiry_year INT NOT NULL,
    card_type VARCHAR(20) DEFAULT 'Virtual Debit',
    is_frozen BOOLEAN DEFAULT FALSE,
    daily_limit DECIMAL(15, 2) DEFAULT 50000.00,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS FOR CARDS
ALTER TABLE public.cards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view cards for their accounts"
    ON public.cards FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.bank_accounts ba
            WHERE ba.id = cards.account_id AND ba.user_id = auth.uid()
        )
    );

-- ==============================================================================
-- 8. ATOMIC STORED PROCEDURE: TRANSFER FUNDS (ACID COMPLIANT)
-- ==============================================================================
CREATE OR REPLACE FUNCTION transfer_funds(
    p_sender_account_id UUID,
    p_receiver_account_number VARCHAR(20),
    p_amount DECIMAL(15, 2),
    p_description TEXT DEFAULT 'Account Transfer'
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_sender_balance DECIMAL(15, 2);
    v_receiver_account_id UUID;
    v_transaction_ref VARCHAR(36);
    v_sender_user_id UUID;
BEGIN
    -- 1. Verify Sender Belongs to Current Authenticated User
    SELECT user_id, balance INTO v_sender_user_id, v_sender_balance
    FROM public.bank_accounts
    WHERE id = p_sender_account_id
    FOR UPDATE; -- Row lock to prevent race conditions

    IF v_sender_user_id IS NULL OR v_sender_user_id != auth.uid() THEN
        RAISE EXCEPTION 'Unauthorized sender account.';
    END IF;

    -- 2. Verify Sender Has Sufficient Balance
    IF v_sender_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient balance.';
    END IF;

    -- 3. Get Receiver Account
    SELECT id INTO v_receiver_account_id
    FROM public.bank_accounts
    WHERE account_number = p_receiver_account_number AND is_active = TRUE
    FOR UPDATE;

    IF v_receiver_account_id IS NULL THEN
        RAISE EXCEPTION 'Receiver account not found or inactive.';
    END IF;

    IF p_sender_account_id = v_receiver_account_id THEN
        RAISE EXCEPTION 'Cannot transfer money to the same account.';
    END IF;

    -- 4. Deduct from Sender
    UPDATE public.bank_accounts
    SET balance = balance - p_amount, updated_at = NOW()
    WHERE id = p_sender_account_id;

    -- 5. Credit Receiver
    UPDATE public.bank_accounts
    SET balance = balance + p_amount, updated_at = NOW()
    WHERE id = v_receiver_account_id;

    -- 6. Record Transaction
    v_transaction_ref := 'TXN-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 10));

    INSERT INTO public.transactions (
        transaction_ref,
        sender_account_id,
        receiver_account_id,
        amount,
        transaction_type,
        status,
        description
    ) VALUES (
        v_transaction_ref,
        p_sender_account_id,
        v_receiver_account_id,
        p_amount,
        'transfer',
        'completed',
        p_description
    );

    RETURN jsonb_build_object(
        'success', true,
        'transaction_ref', v_transaction_ref,
        'amount', p_amount,
        'message', 'Transfer completed successfully'
    );
END;
$$;

-- ==============================================================================
-- 9. AUTOMATIC USER REGISTRATION TRIGGER (CREATES DEFAULT BANK ACCOUNT)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user_setup()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_account_no VARCHAR(20);
BEGIN
    -- Insert Profile
    INSERT INTO public.profiles (id, full_name, phone_number, avatar_url)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Bank Customer'),
        NEW.phone,
        NEW.raw_user_meta_data->>'avatar_url'
    );

    -- Generate Random Account Number
    v_account_no := '1000' || LPAD((FLOOR(RANDOM() * 1000000000))::TEXT, 9, '0');

    -- Create Default Primary Savings Account with ₹10,000 Sign-Up Bonus
    INSERT INTO public.bank_accounts (user_id, account_number, account_type, balance)
    VALUES (NEW.id, v_account_no, 'savings', 10000.00);

    RETURN NEW;
END;
$$;

-- Trigger execution
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_setup();
