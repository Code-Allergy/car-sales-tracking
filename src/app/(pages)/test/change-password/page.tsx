'use client'

import React from 'react';
import { useRouter } from 'next/navigation';
import {Database, getSupabaseBrowserClient} from "@/lib/database";
import {SupabaseClient} from "@supabase/supabase-js";
import {Form, FormControl, FormField, FormItem, FormLabel, FormMessage} from "@/components/ui/form";
import {Input} from "@/components/ui/input";
import {Button} from "@/components/ui/button";
import {useForm} from "react-hook-form";
import * as z from "zod";
import {zodResolver} from "@hookform/resolvers/zod";

export default function UpdatePassword() {
  const router = useRouter();
  const supabase: SupabaseClient<Database> = getSupabaseBrowserClient();

  const passwordChangeFormSchema = z.object({
    password: z.string().min(6)
  })



  // todo ts:any
  const handleSubmit = async (e: any) => {
    const { data, error } = await supabase.auth.updateUser(
        { password: e.password });
    if (error) {
      console.error('Error updating password:', error);
    } else {
      console.log('Password updated successfully');
      router.push('dashboard'); // todo add success page
    }
  };

  const form = useForm<z.infer<typeof passwordChangeFormSchema>>({
    resolver: zodResolver(passwordChangeFormSchema),
    defaultValues: {
      password: '',
    },
  });

  return (
      <div className={"flex"}>
        <div className={"flex items-center justify-center mx-4 my-4"}>
          <Form {...form}>
            <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-8">
              <FormField
                  control={form.control}
                  name="password"
                  render={({ field }) => (
                      <FormItem>
                        <FormLabel>Password</FormLabel>
                        <FormControl>
                          <Input
                              type={"password"}
                              {...field}
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                  )}
              />
              <Button type={"submit"}>Submit</Button>
            </form>
          </Form>
        </div>
      </div>
  );
}