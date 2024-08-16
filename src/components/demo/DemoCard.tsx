import {Card, CardFooter, CardHeader} from "@/components/ui/card";
import {Button} from "@/components/ui/button";
import React, {useState} from "react";
import {getSupabaseBrowserClient} from "@/lib/supabase";
import {useRouter} from "next/navigation";
import {toast} from "@/components/ui/use-toast";
import {ToastAction} from "@/components/ui/toast";



const DemoCard = () => {
    const supabase = getSupabaseBrowserClient();
    const router = useRouter();



    const loginAsAdmin = async () => {
        await loginWith(process.env.NEXT_PUBLIC_DEMO_ADMIN_LOGIN, process.env.NEXT_PUBLIC_DEMO_ADMIN_PASSWORD);
    };

    const loginAsEmployee = async () => {
        await loginWith(process.env.NEXT_PUBLIC_DEMO_SALES_LOGIN, process.env.NEXT_PUBLIC_DEMO_SALES_PASSWORD);
    };

    const loginWith = async (email: string | undefined, password: string | undefined) => {
        try {
            const { error } = await supabase.auth.signInWithPassword({
                email: email ?? "", password: password ?? ""
            });

            if (error) throw error;
            router.refresh();
        } catch (error: any) {
            toast({
                variant: "destructive",
                title: "Uh oh! Something went wrong.",
                description: "There was a problem with your request.",
                action: <ToastAction altText="Try again">Try again</ToastAction>,
            })

        }
    }

    return (

        <Card className="max-w-sm mx-auto mt-10">

            <>
                <CardHeader>
                    <h2 className="text-xl font-semibold text-center">Demo Login</h2>
                </CardHeader>
                    <CardFooter className="flex justify-center gap-2">
                        <Button onClick={loginAsAdmin}>Admin View</Button>
                        <Button onClick={loginAsEmployee}>Employee View</Button>
                    </CardFooter>
            </>


        </Card>
    );
};

export default DemoCard;