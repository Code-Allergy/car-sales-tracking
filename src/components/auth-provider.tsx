'use client'
import {SignInWithPasswordCredentials, SignUpWithPasswordCredentials} from "@supabase/supabase-js";
import {Database, Employee, Role} from "@/lib/database.types";
import {createContext, useEffect, useState} from "react";
import {getEmployeeFromAuthUser, getRoleFromEmployee} from "@/lib/dbwrap";
import {AuthContextType} from "@/hooks/use-auth";
import {getSupabaseBrowserClient} from "@/lib/supabase";
import {User} from "@supabase/supabase-js"
import {createBrowserClient} from "@supabase/ssr";



export const AuthContext = createContext<AuthContextType | null>(null);

/**
 *
 * @param children
 * @group React Component
 */
export const AuthProvider = ({children}: any) => {
  const [user, setUser] = useState<User | null>(null);
  const [employee, setEmployee] = useState<Employee | null>(null);
  const [role, setRole] = useState<Role | null>(null);
  const [loading, setLoading] = useState(true);
  const supabase = createBrowserClient<Database>(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )

  // todo add local storage caching?
  useEffect(() => {
    const initializeAuth = async () => {
      try {
        const loadEmployeeAndRole = async (user: User) => {
          // const res = await fetch("/api/user")
          // const json = await res.json();
          const employee = await getEmployeeFromAuthUser(supabase, user)
          const role = await getRoleFromEmployee(supabase, employee);
          setEmployee(employee);
          setRole(role);
          setLoading(false);
        }

        setLoading(true);
        // get session data if there is an active session
        const {data: {session}} = await supabase.auth.getSession();
        setUser(session?.user ?? null);

        if (session?.user) await loadEmployeeAndRole(session.user);

        // subscribe to auth changes.
        const { data: listener } = supabase.auth.onAuthStateChange(
            async (event, session) => {
              setUser(session?.user ?? null);
              if (session) {
                await loadEmployeeAndRole(session.user);
              }
              setLoading(false);
            }
        );

        // cleanup the useEffect hook
        return () => {
          listener?.subscription.unsubscribe();
        };

      }

      catch (error) {
        console.error("Error initializing authentication:", error);
      }
    };

    initializeAuth();
  }, [supabase, supabase.auth]);

  // create signUp, signIn, signOut functions
  const value: AuthContextType = {
    signUp: async (data) => await supabase.auth.signUp(data), /* todo custom signup */
    /* add details about the employee registered as additional data on the user entry to pass to db,
    then use a postgresql function to create the employee entry. */
    signIn: async (data) => await supabase.auth.signInWithPassword(data),
    signOut: async () => await supabase.auth.signOut(),
    user: user ?? null,
    employee: employee ?? null,
    role: role ?? null
  };

  // use a provider to pass down the value
  return (
      <AuthContext.Provider value={value}>
        {!loading && children}
      </AuthContext.Provider>);
};