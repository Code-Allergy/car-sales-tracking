import { cookies } from 'next/headers'
import { NextResponse } from 'next/server'
import {getSupabaseRouteHandlerClient} from "@/lib/supabase";

export async function POST(request: Request) {
    const requestUrl = new URL(request.url)
    const formData = await request.formData()
    const email = String(formData.get('email'))
    const password = String(formData.get('password'))
    const cookieStore = cookies()
    const supabase = getSupabaseRouteHandlerClient(cookieStore);

    await supabase.auth.signUp({
        email,
        password,
        options: {
            emailRedirectTo: `${requestUrl.origin}/auth/callback`,
        },
    });


    return NextResponse.redirect(requestUrl.origin, {
        status: 301,
    })
}
